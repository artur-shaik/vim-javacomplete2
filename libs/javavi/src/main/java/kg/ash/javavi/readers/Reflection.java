package kg.ash.javavi.readers;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Set;
import java.util.TreeMap;
import java.util.Map.Entry;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.StringTokenizer;
import kg.ash.javavi.TargetParser;
import kg.ash.javavi.clazz.*;
import kg.ash.javavi.searchers.*;

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

    public SourceClass getSourceClass(Class cls) {
        TreeMap<String,String> typeArgumentsAccordance = new TreeMap<>();

        SourceClass clazz = new SourceClass();
        clazz.setName(cls.getSimpleName());
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

        Class superclass = cls.getSuperclass();
        List<String> linkedClasses = new ArrayList<>();
        if (superclass != null) {
            clazz.setSuperclass(superclass.getName());
            linkedClasses.add(superclass.getName());
        }

        Type[] interfaces = cls.getGenericInterfaces();
        for (Type iface : interfaces) {
            String genericName = iface.getTypeName().replace('$', '.');
            for (Entry<String,String> kv : typeArgumentsAccordance.entrySet()) {
                genericName = genericName.replaceAll(String.format("\\b%s\\b", kv.getKey()), kv.getValue());
            }
            clazz.addInterface(genericName);
            linkedClasses.add(genericName);
        }

        ClassSearcher seacher = new ClassSearcher();
        for (String linkedClass : linkedClasses) {
            TargetParser parser = new TargetParser(sources);
            linkedClass = parser.parse(linkedClass);
            if (seacher.find(linkedClass, sources)) {
                clazz.addLinkedClass(seacher.getReader().setTypeArguments(parser.getTypeArguments()).read(linkedClass));
            }
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
                String name = t.getTypeName();
                for (Entry<String,String> kv : typeArgumentsAccordance.entrySet()) {
                    name = name.replaceAll(String.format("\\b%s\\b", kv.getKey()), kv.getValue());
                }
                constructor.addTypeParameter(new ClassTypeParameter(name));
            }

            clazz.addConstructor(constructor);
        }

        Field[] fields = cls.getFields();
        for (Field f : fields) {
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

        Method[] methods = cls.getMethods();
        for (Method m : methods) {

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
                String name = t.getTypeName();
                for (Entry<String,String> kv : tAA.entrySet()) {
                    name = name.replaceAll(String.format("\\b%s\\b", kv.getKey()), kv.getValue());
                }
                method.addTypeParameter(new ClassTypeParameter(name));
            }

            clazz.addMethod(method);

        }

        return clazz;
    }

}
