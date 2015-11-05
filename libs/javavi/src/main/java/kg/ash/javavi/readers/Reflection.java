package kg.ash.javavi.readers;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map.Entry;
import java.util.Set;
import java.util.TreeMap;
import kg.ash.javavi.TargetParser;
import kg.ash.javavi.clazz.ClassConstructor;
import kg.ash.javavi.clazz.ClassField;
import kg.ash.javavi.clazz.ClassMethod;
import kg.ash.javavi.clazz.ClassTypeParameter;
import kg.ash.javavi.clazz.SourceClass;
import kg.ash.javavi.searchers.ClassSearcher;

public class Reflection implements ClassReader {

    private String sources;
    private List<String> typeArguments = null;

    @Override
    public ClassReader setTypeArguments(List<String> typeArguments) {
        this.typeArguments = typeArguments;
        return this;
    }

    public Reflection(String sources) {
        this.sources = sources;
    }

    public static boolean exist(String name) {
        boolean result = false;
        try {
            Class.forName(name);
            result = true;
        } catch (Exception ex) {}
        return result;
    }

    @Override
    public SourceClass read(String name) {
        try {
            Class clazz = Class.forName(name);
            return getSourceClass(clazz);
        } catch (Exception ex) {}

        try {
            Class clazz = Class.forName("java.lang." + name);
            return getSourceClass(clazz);
        } catch (Exception ex) {}

        String binaryName = name;
        while (true) {
            try {
                int lastDotPos = binaryName.lastIndexOf('.');
                if (lastDotPos == -1) break;

                binaryName = String.format("%s$%s",
                        binaryName.substring(0, lastDotPos),
                        binaryName.substring(lastDotPos+1, binaryName.length()));

                Class clazz = Class.forName(binaryName);
                return getSourceClass(clazz);
            } catch (Exception e) {}
        }

        return null;
    }

    private List<String> classes = new ArrayList<>();

    @SuppressWarnings("unchecked")
    public SourceClass getSourceClass(Class cls) {
        TreeMap<String,String> typeArgumentsAccordance = new TreeMap<>();

        SourceClass clazz = new SourceClass();
        String name = cls.getName();
        if (name.contains(".")) {
            name = name.substring(name.lastIndexOf(".") + 1);
        }
        clazz.setName(name);
        clazz.setModifiers(cls.getModifiers());
        clazz.setIsInterface(cls.isInterface());
        clazz.setPackage(cls.getPackage().getName());

        for (int i = 0; i < cls.getTypeParameters().length; i++) {
            Type type = cls.getTypeParameters()[i];
            if (i < typeArguments.size()) {
                typeArgumentsAccordance.put(type.getTypeName(), typeArguments.get(i));
                clazz.addTypeArgument(typeArguments.get(i));
            } else {
                typeArgumentsAccordance.put(type.getTypeName(), "java.lang.Object");
            }
        }

        List<Class> linkedClasses = new ArrayList<>();
        for (Class c : cls.getDeclaredClasses()) {
            clazz.addNestedClass(c.getName());
            linkedClasses.add(c);
        }

        Class superclass = cls.getSuperclass();
        if (superclass != null) {
            clazz.setSuperclass(superclass.getName());
            linkedClasses.add(superclass);
        }

        Type[] interfaces = cls.getGenericInterfaces();
        ClassSearcher seacher = new ClassSearcher();
        for (Type iface : interfaces) {
            String genericName = iface.getTypeName();
            for (Entry<String,String> kv : typeArgumentsAccordance.entrySet()) {
                genericName = genericName.replaceAll(String.format("\\b%s\\b", kv.getKey()), kv.getValue());
            }
            clazz.addInterface(genericName);

            TargetParser parser = new TargetParser(sources);
            String ifaceClassName = parser.parse(genericName);
            if (seacher.find(ifaceClassName, sources)) {
                clazz.addLinkedClass(seacher.getReader().setTypeArguments(parser.getTypeArguments()).read(genericName));
            }
        }

        for (Class linkedClass : linkedClasses) {
            if (classes.contains(linkedClass.getName())) continue;
            classes.add(linkedClass.getName());
            clazz.addLinkedClass(getSourceClass(linkedClass));
        }

        Constructor[] constructors = cls.getConstructors();
        for (Constructor ctor : constructors) {
            ClassConstructor constructor = new ClassConstructor();

            String genericDeclaration = ctor.toGenericString();
            for (Entry<String,String> kv : typeArgumentsAccordance.entrySet()) {
                genericDeclaration = genericDeclaration.replaceAll(String.format("\\b%s\\b", kv.getKey()), kv.getValue());
            }
            constructor.setDeclaration(genericDeclaration);

            constructor.setModifiers(ctor.getModifiers());

            Type[] parameterTypes = ctor.getGenericParameterTypes();
            for (Type t : parameterTypes) {
                String typeName = t.getTypeName();
                for (Entry<String,String> kv : typeArgumentsAccordance.entrySet()) {
                    typeName = typeName.replaceAll(String.format("\\b%s\\b", kv.getKey()), kv.getValue());
                }
                constructor.addTypeParameter(new ClassTypeParameter(typeName));
            }

            clazz.addConstructor(constructor);
        }

        Set<Field> fieldsSet = new HashSet<>();
        fieldsSet.addAll(Arrays.asList(cls.getDeclaredFields()));
        fieldsSet.addAll(Arrays.asList(cls.getFields()));
        for (Field f : fieldsSet) {
            ClassField field = new ClassField();
            field.setName(f.getName());
            field.setModifiers(f.getModifiers());

            String genericType = f.getGenericType().getTypeName();
            for (Entry<String,String> kv : typeArgumentsAccordance.entrySet()) {
                genericType = genericType.replaceAll(String.format("\\b%s\\b", kv.getKey()), kv.getValue());
            }
            field.setTypeName(genericType);

            clazz.addField(field);
        }

        Set<Method> methodsSet = new HashSet<>();
        methodsSet.addAll(Arrays.asList(cls.getDeclaredMethods()));
        methodsSet.addAll(Arrays.asList(cls.getMethods()));
        for (Method m : methodsSet) {

            // workaround for Iterable<T> that give us
            // another generic name in List::forEach method
            TreeMap<String,String> tAA = (TreeMap<String,String>)typeArgumentsAccordance.clone();
            Set<String> keySet = tAA.keySet();
            for (int i = 0; i < m.getDeclaringClass().getTypeParameters().length; i++) {
                Type type = m.getDeclaringClass().getTypeParameters()[i];
                if (i < keySet.size() && !((String)keySet.toArray()[i]).trim().equals(type.getTypeName().trim())) {
                    tAA.put(type.getTypeName(), ((String)keySet.toArray()[i]).trim());
                }
            }

            ClassMethod method = new ClassMethod();
            method.setName(m.getName());
            method.setModifiers(m.getModifiers());

            String genericDeclaration = m.toGenericString();
            for (Entry<String,String> kv : tAA.entrySet()) {
                genericDeclaration = genericDeclaration.replaceAll(String.format("\\b%s\\b", kv.getKey()), kv.getValue());
            }

            method.setDeclaration(genericDeclaration);

            String genericReturnType = m.getGenericReturnType().getTypeName();
            for (Entry<String,String> kv : tAA.entrySet()) {
                genericReturnType = genericReturnType.replaceAll(String.format("\\b%s\\b", kv.getKey()), kv.getValue());
            }
            method.setTypeName(genericReturnType);

            Type[] parameterTypes = m.getGenericParameterTypes();
            for (Type t : parameterTypes) {
                String typeName = t.getTypeName();
                for (Entry<String,String> kv : tAA.entrySet()) {
                    typeName = typeName.replaceAll(String.format("\\b%s\\b", kv.getKey()), kv.getValue());
                }
                method.addTypeParameter(new ClassTypeParameter(typeName));
            }

            clazz.addMethod(method);

        }

        return clazz;
    }

}
