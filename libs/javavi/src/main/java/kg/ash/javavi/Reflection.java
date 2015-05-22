package kg.ash.javavi;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.StringTokenizer;

public class Reflection implements ClassReader {
    
    private String sources;

    public Reflection(String sources) {
        this.sources = sources;
    }

    public static boolean existed(String name) {
        boolean result = false;
        try {
            Class.forName(name);
            result = true;
        }
        catch (Exception ex) {}
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
        SourceClass clazz = new SourceClass();
        clazz.setName(cls.getSimpleName());
        clazz.setModifiers(cls.getModifiers());
        clazz.setIsInterface(cls.isInterface());
        clazz.setPackage(cls.getPackage().getName());

        Class superclass = cls.getSuperclass();
        List<String> linkedClasses = new ArrayList<>();
        if (superclass != null) {
            clazz.setSuperclass(superclass.getName());
            linkedClasses.add(superclass.getName());
        }

        Class[] interfaces = cls.getInterfaces();
        for (Class iface : interfaces) {
            clazz.addInterface(iface.getName().replace('$', '.'));
            linkedClasses.add(iface.getName().replace('$', '.'));
        }

        ClassSearcher seacher = new ClassSearcher();
        for (String linkedClass : linkedClasses) {
            if (seacher.find(linkedClass, sources)) {
                clazz.addLinkedClass(seacher.getReader().read(linkedClass));
            }
        }

        Constructor[] constructors = cls.getConstructors();
        for (Constructor ctor : constructors) {
            ClassConstructor constructor = new ClassConstructor();
            constructor.setDeclaration(ctor.toString());
            constructor.setModifiers(ctor.getModifiers());

            Class[] parameterTypes = ctor.getParameterTypes();
            for (Class c : parameterTypes) {
                constructor.addTypeParameter(new ClassTypeParameter(c.getName()));
            }

            clazz.addConstructor(constructor);
        }

        Field[] fields = cls.getFields();
        for (Field f : fields) {
            ClassField field = new ClassField();
            field.setName(f.getName());
            field.setModifiers(f.getModifiers());
            field.setTypeName(f.getType().getName());
            clazz.addField(field);
        }

        Method[] methods = cls.getMethods();
        for (Method m : methods) {
            ClassMethod method = new ClassMethod();
            method.setName(m.getName());
            method.setModifiers(m.getModifiers());
            method.setDeclaration(m.toString());
            method.setTypeName(m.getReturnType().getName());

            Class[] parameterTypes = m.getParameterTypes();
            for (Class c : parameterTypes) {
                method.addTypeParameter(new ClassTypeParameter(c.getName()));
            }

            clazz.addMethod(method);

        }

        return clazz;
    }

}
