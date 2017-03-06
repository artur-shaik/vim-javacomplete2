package kg.ash.javavi.readers;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map.Entry;
import java.util.Optional;
import java.util.Set;
import java.util.TreeMap;
import java.util.function.Function;
import java.util.stream.Stream;

import kg.ash.javavi.apache.logging.log4j.LogManager;
import kg.ash.javavi.apache.logging.log4j.Logger;

import kg.ash.javavi.TargetParser;
import kg.ash.javavi.cache.Cache;
import kg.ash.javavi.clazz.ClassConstructor;
import kg.ash.javavi.clazz.ClassField;
import kg.ash.javavi.clazz.ClassMethod;
import kg.ash.javavi.clazz.ClassTypeParameter;
import kg.ash.javavi.clazz.SourceClass;
import kg.ash.javavi.readers.FileClassLoader;
import kg.ash.javavi.searchers.ClassNameMap;
import kg.ash.javavi.searchers.ClassSearcher;

public class Reflection implements ClassReader {

    public static final Logger logger = LogManager.getLogger();

    private String sources;
    private List<String> typeArguments = null;

    private List<String> knownClasses = new ArrayList<>();

    @Override
    public ClassReader setTypeArguments(List<String> typeArguments) {
        this.typeArguments = typeArguments;
        return this;
    }

    public Reflection(String sources) {
        this.sources = sources;
    }

    public static boolean exist(String name) {
        try {
            Class.forName(name);
            return true;
        } catch (Exception | NoClassDefFoundError ex) {
            return false;
        }
    }

    private String getNameWithArguments(String name) {
        if (typeArguments != null && !typeArguments.isEmpty()) {
            name += "<" + String.join(",", typeArguments) + ">";
        }

        return name;
    }

    @Override
    public SourceClass read(String name) {
        String nameWithArguments = getNameWithArguments(name);

        logger.debug("read class with reflections: {}", nameWithArguments);

        HashMap<String, SourceClass> cachedClasses = 
            Cache.getInstance().getClasses();
        if (cachedClasses.containsKey(nameWithArguments)) {
            return cachedClasses.get(nameWithArguments);
        }

        SourceClass result = loadFromCompiledSource(name);
        if (result == null) {
            result = lookup(name);
        }
        if (result == null && !name.startsWith("java.lang.")) {
            result = lookup("java.lang." + name);
        }

        String binaryName = name;
        while (result == null) {
            int lastDotPos = binaryName.lastIndexOf('.');
            if (lastDotPos == -1) break;

            binaryName = String.format("%s$%s",
                    binaryName.substring(0, lastDotPos),
                    binaryName.substring(lastDotPos+1, binaryName.length()));

            result = lookup(binaryName);
        }

        return result;
    }

    private SourceClass loadFromCompiledSource(String name) {
        String last = name.substring(name.lastIndexOf(".") + 1);
        ClassNameMap classMap = (ClassNameMap) Cache.getInstance()
            .getClassPackages().get(getNameWithArguments(last));
        if (classMap != null) {
            if (classMap.getClassFile() != null && classMap.getJavaFile() != null) {
                logger.debug("loading class from compiled source: {}", classMap);

                ClassLoader parentClassLoader = FileClassLoader.class.getClassLoader();
                FileClassLoader fileClassLoader = new FileClassLoader(parentClassLoader, classMap.getClassFile());
                Class clazz = fileClassLoader.loadClass(name);
                if (clazz != null) {
                    try {
                        return getSourceClass(clazz);
                    } catch (Throwable t) {
                        logger.error(t, t);
                    }
                }
            }
        }
        return null;
    }

    private SourceClass lookup(String className) {
        try {
            logger.debug("lookup class name: {}", className);

            Class clazz = Class.forName(className);
            return getSourceClass(clazz);
        } catch (Exception ex) {
            logger.debug(String.format("error lookup %s", className), ex);
            return null;
        }
    }

    private String popTypeArgument(List<String> arguments) {
        if (!arguments.isEmpty()) {
            String argument = arguments.get(0);
            arguments.remove(0);
            return argument;
        }

        return "java.lang.Object";
    }

    private String getGenericName(
            TreeMap<String,String> taa, 
            String genericName) {

        if (typeArguments == null || typeArguments.isEmpty()) {
            return genericName;
        }
        for (Entry<String, String> kv : taa.entrySet()) {
            genericName = genericName
                .replaceAll(
                        String.format("\\b%s\\b", kv.getKey()), 
                        kv.getValue());
        }
        return genericName;
    }

    @SuppressWarnings("unchecked")
    public SourceClass getSourceClass(Class cls) {
        logger.debug("class loaded: {}", cls.getName());

        String name = cls.getName();
        knownClasses.add(name);
        if (name.contains(".")) {
            name = name.substring(name.lastIndexOf(".") + 1);
        }

        SourceClass clazz = new SourceClass();
        clazz.setName(name);
        clazz.setModifiers(cls.getModifiers());
        clazz.setIsInterface(cls.isInterface());
        if (cls.getPackage() != null) {
            clazz.setPackage(cls.getPackage().getName());
        }

        TreeMap<String,String> typeArgumentsAccordance = new TreeMap<>();
        if (typeArguments != null && !typeArguments.isEmpty()) {
            List<String> arguments = new ArrayList<>(typeArguments);
            Stream.of(cls.getTypeParameters()).forEachOrdered(type -> {
                typeArgumentsAccordance.put(type.getTypeName(), popTypeArgument(arguments));
                clazz.addTypeArgument(typeArgumentsAccordance.get(type.getTypeName()));
            });
        }

        List<Class> linked = new ArrayList<>();
        Stream.of(cls.getDeclaredClasses())
            .forEach(c -> {
                linked.add(c);
                clazz.addNestedClass(c.getName());
            });

        Optional.ofNullable(cls.getSuperclass())
            .ifPresent(c -> {
                linked.add(c);
                clazz.setSuperclass(c.getName());
            });

        Stream.of(cls.getGenericInterfaces())
            .map(i -> getGenericName(typeArgumentsAccordance, i.getTypeName()))
            .forEach(clazz::addInterface);

        ClassSearcher seacher = new ClassSearcher();
        clazz.getInterfaces().stream()
            .forEach(i -> {
                TargetParser parser = new TargetParser(sources);
                String ifaceClassName = parser.parse(i);
                if (seacher.find(ifaceClassName, sources)) {
                    clazz.addLinkedClass(
                        seacher.getReader()
                            .setTypeArguments(parser.getTypeArguments())
                            .read(i));
                }
            });

        linked.stream()
            .filter(c -> !knownClasses.contains(c.getName()))
            .map(this::getSourceClass)
            .forEach(clazz::addLinkedClass);

        Stream.of(cls.getConstructors()).forEachOrdered(ctor -> {
            ClassConstructor constructor = new ClassConstructor();

            String genericDeclaration = 
                getGenericName(
                        typeArgumentsAccordance, 
                        ctor.toGenericString());
            constructor.setDeclaration(genericDeclaration);
            constructor.setModifiers(ctor.getModifiers());

            Stream.of(ctor.getGenericParameterTypes())
                .map(t -> 
                        getGenericName(
                            typeArgumentsAccordance, t.getTypeName()))
                .forEach(t -> 
                        constructor.addTypeParameter(
                            new ClassTypeParameter(t)));

            clazz.addConstructor(constructor);
        });

        Set<Field> fieldsSet = new HashSet<>();
        fieldsSet.addAll(Arrays.asList(cls.getDeclaredFields()));
        fieldsSet.addAll(Arrays.asList(cls.getFields()));
        fieldsSet.forEach(f -> {
            ClassField field = new ClassField();
            field.setName(f.getName());
            field.setModifiers(f.getModifiers());

            String genericType = getGenericName(
                    typeArgumentsAccordance, 
                    f.getGenericType().getTypeName());
            field.setTypeName(genericType);

            clazz.addField(field);
        });

        Set<Method> methodsSet = new HashSet<>();
        methodsSet.addAll(Arrays.asList(cls.getDeclaredMethods()));
        methodsSet.addAll(Arrays.asList(cls.getMethods()));
        methodsSet.forEach(m -> {

            // workaround for Iterable<T> that give us
            // another generic name in List::forEach method
            TreeMap<String,String> tAA = 
                (TreeMap<String,String>)typeArgumentsAccordance.clone();
            List<String> keySet = new ArrayList<>(tAA.keySet());
            Stream.of(m.getDeclaringClass().getTypeParameters())
                .forEach(type -> {
                    Optional<String> key = Optional.ofNullable(
                            keySet.isEmpty() ? null : keySet.get(0));
                    key
                        .filter(k -> !k.equals(type.getTypeName()))
                        .ifPresent(k -> {
                            tAA.put(type.getTypeName(), tAA.get(k));
                            keySet.remove(0);
                        });
                });

            ClassMethod method = new ClassMethod();
            method.setName(m.getName());
            method.setModifiers(m.getModifiers());

            String genericDeclaration =
                getGenericName(tAA, m.toGenericString());
            method.setDeclaration(genericDeclaration);

            String genericReturnType =
                getGenericName(tAA, m.getGenericReturnType().getTypeName());
            method.setTypeName(genericReturnType);

            Type[] parameterTypes = m.getGenericParameterTypes();
            Stream.of(parameterTypes)
                .map(t -> 
                        getGenericName(tAA, t.getTypeName()))
                .forEachOrdered(t -> 
                        method.addTypeParameter(
                            new ClassTypeParameter(t)));

            clazz.addMethod(method);

        });

        Cache.getInstance().getClasses()
            .put(getNameWithArguments(cls.getName()), clazz);
        return clazz;
    }

}
