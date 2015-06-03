package kg.ash.javavi;

import java.lang.StringBuilder;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Set;

public class OutputBuilder {

    public String outputClassInfo(SourceClass clazz) {
        HashMap<String,String> classMap = new HashMap<>();
        putClassInfo(classMap, clazz);

        String result = "";
        if (classMap.size() > 0) {
            StringBuilder sb = new StringBuilder();
            sb.append("{");
            for (String s : classMap.keySet()) {
                sb.append("'").append(s.replace('$', '.'))
                    .append("':").append(classMap.get(s))
                    .append(",");
            }
            sb.append("}");
            result = sb.toString();
        }

        return result;
    }
    
    private void putClassInfo(HashMap<String, String> map, SourceClass clazz) {
        if (map.containsKey(clazz.getName()))
            return ;

        try {
            StringBuilder sb = new StringBuilder();
            sb.append("{")
                .append("'tag':'CLASSDEF',").append(Javavi.NEWLINE)
                .append("'flags':'")
                .append(Integer.toString(clazz.getModifiers(), 2))
                .append("',").append(Javavi.NEWLINE)
                .append("'name':'")
                .append(clazz.getName().replace('$', '.'))
                .append("',").append(Javavi.NEWLINE)
                .append("'classpath':'1',").append(Javavi.NEWLINE)
                .append("'fqn':'")
                .append(clazz.getName().replace('$', '.'))
                .append("',").append(Javavi.NEWLINE);

            if (clazz.isInterface()) {
                sb.append("'extends':[");
            } else {
                String superclass = clazz.getSuperclass();
                if (superclass != null && !"java.lang.Object".equals(superclass)) {
                    sb.append("'extends':['").append(superclass.replace('$', '.'))
                        .append("'],").append(Javavi.NEWLINE);
                }
                sb.append("'implements':[");
            }
            for (String iface : clazz.getInterfaces()) {
                sb.append("'").append(iface.replace('$', '.')).append("',");
            }
            sb.append("],").append(Javavi.NEWLINE);;

            List<ClassConstructor> ctors = clazz.getConstructors();
            sb.append("'ctors':[");
            for (ClassConstructor ctor : ctors) {
                sb.append("{");
                appendModifier(sb, ctor.getModifiers());
                appendParameterTypes(sb, ctor.getTypeParameters());
                sb.append(Javavi.KEY_DESCRIPTION).append("'")
                    .append(ctor.getDeclaration())
                    .append("'");
                sb.append("},").append(Javavi.NEWLINE);
            }
            sb.append("], ").append(Javavi.NEWLINE);

            List<ClassField> fields = clazz.getFields();
            sb.append("'fields':[");
            for (ClassField field : fields){
                sb.append("{");
                sb.append(Javavi.KEY_NAME).append("'")
                    .append(field.getName()).append("',");

                if (!field.getTypeName().equals(clazz.getName())) {
                    sb.append(Javavi.KEY_DECLARING_CLASS)
                        .append("'").append(field.getTypeName())
                        .append("',");
                }
                appendModifier(sb, field.getModifiers());
                sb.append(Javavi.KEY_TYPE).append("'")
                    .append(field.getTypeName()).append("'")
                    .append("},").append(Javavi.NEWLINE);
            }
            sb.append("], ").append(Javavi.NEWLINE);

            List<ClassMethod> methods = clazz.getMethods();
            sb.append("'methods':[");
            for (ClassMethod method : methods) {
                int modifier = method.getModifiers();
                sb.append("{");
                sb.append(Javavi.KEY_NAME).append("'")
                    .append(method.getName()).append("',");
                if (!method.getTypeName().equals(clazz.getName())) {
                    sb.append(Javavi.KEY_DECLARING_CLASS).append("'")
                        .append(method.getTypeName()).append("',");

                }
                appendModifier(sb, modifier);
                sb.append(Javavi.KEY_RETURNTYPE).append("'")
                    .append(method.getTypeName()).append("',");
                appendParameterTypes(sb, method.getTypeParameters());
                sb.append(Javavi.KEY_DESCRIPTION).append("'")
                    .append(method.getDeclaration())
                    .append("'").append("},").append(Javavi.NEWLINE);
            }
            sb.append("], ").append(Javavi.NEWLINE);

            sb.append("}");
            map.put(clazz.getName(), sb.toString());

            for (SourceClass sourceClass : clazz.getLinkedClasses()) {
                putClassInfo(map, sourceClass);
            }
        } catch (Exception ex) {}
    }

    private void appendModifier(StringBuilder sb, int modifier) {
        sb.append(Javavi.KEY_MODIFIER).append("'")
            .append(Integer.toString(modifier, 2))
            .append("', ");
    }

    private void appendParameterTypes(StringBuilder sb, List<ClassTypeParameter> paramTypes) {
        if (paramTypes == null || paramTypes.isEmpty()) return;

        sb.append(Javavi.KEY_PARAMETERTYPES).append("[");
        for (ClassTypeParameter parameter : paramTypes) {
            sb.append("'").append(parameter.getName()).append("',");
        }
        sb.append("],");
    }

    public String outputPackageInfo(String pathTarget) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        //if (pathTarget.contains(".")) {
        //    pathTarget = pathTarget.replaceAll("\\.", "/");
        //}
        if (Javavi.cachedPackages.containsKey(pathTarget)) {
            StringBuilder[] sbs = (StringBuilder[])Javavi.cachedPackages.get(pathTarget);
            sb.append("'").append( pathTarget ).append("':")
                .append("{'tag':'PACKAGE'");
            if (sbs[Javavi.INDEX_PACKAGE].length() > 0)
                sb.append(",'subpackages':[").append(sbs[Javavi.INDEX_PACKAGE]).append("]");
            if (sbs[Javavi.INDEX_CLASS].length() > 0)
                sb.append(",'classes':[").append(sbs[Javavi.INDEX_CLASS]).append("]");
            sb.append("},");
        } else {
            /* Maybe target is class */
            if (pathTarget.lastIndexOf(".") >= 0) {
                ClassSearcher seacher = new ClassSearcher();
                if (seacher.find(pathTarget, Javavi.sources)) {
                    SourceClass clazz = seacher.getReader().read(pathTarget);
                    if (clazz != null) {
                        return outputClassInfo(clazz);
                    }
                }
            }
        }
        sb.append("}");
        return sb.toString();
    }

    public String outputSimilarClasses(String target) {
        Set<String> keys = Javavi.cachedClassPackages.keySet();
        List<String> keysResult = new ArrayList<>();
        for (String key : keys) {
            if (key.startsWith(target)) {
                keysResult.add(key);
            }
        }

        Collections.sort(keysResult, new Comparator<String>() {

            @Override
            public int compare(String s1, String s2) {
                int i1 = s1.length(); int i2 = s2.length();
                if (i1 < i2) return -1;
                if (i1 == i2) {
                    return s1.compareTo(s2);
                }
                return 1;
            }
        });

        StringBuilder builder = new StringBuilder("[");
        for (String key : keysResult) {
            for (String scope : Javavi.cachedClassPackages.get(key)) {
                builder.append("{").append("\"word\":\"").append(key)
                    .append("\", \"menu\":\"").append(scope.replaceAll("/", "."))
                    .append("\", \"type\": \"c\"},").append(Javavi.NEWLINE);
            }
        }
        builder.append("]");
        return builder.toString();
    }

    public String outputClassPackages(String target) {
        StringBuilder builder = new StringBuilder("[");
        for (String scope : Javavi.cachedClassPackages.get(target)) {
            builder.append("\"").append(scope.replaceAll("/", "."))
                .append(".").append(target).append("\",").append(Javavi.NEWLINE);
        }
        builder.append("]");
        return builder.toString();
    }

}
