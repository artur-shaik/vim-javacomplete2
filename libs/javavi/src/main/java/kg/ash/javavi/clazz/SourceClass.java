package kg.ash.javavi.clazz;

import java.util.ArrayList;
import java.util.List;

public class SourceClass {
    
    private String pakage = null;
    private String name = null;
    private int modifiers;
    private boolean isInterface = false;
    private List<ClassConstructor> constructors = new ArrayList<>();
    private List<ClassMethod> methods = new ArrayList<>();
    private List<ClassField> fields = new ArrayList<>();
    private List<ClassImport> imports = new ArrayList<>();

    private String superclass = null;
    private List<String> interfaces = new ArrayList<>();

    private List<SourceClass> linkedClasses = new ArrayList<>();
    private List<String> typeArguments = new ArrayList<>();

    private List<String> nestedClasses = new ArrayList<>();

    private CodeRegion region = new CodeRegion();

    public String getName() {
        String args = "";
        for (String type : typeArguments) {
            args += type + ",";
        }
        return String.format("%s%s%s", pakage == null ? "" : pakage + ".", name, args.length() > 0 ? "<" + args.substring(0, args.length() - 1) + ">" : "");
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSimpleName() {
        return name;
    }

    public List<ClassConstructor> getConstructors() {
        return constructors;
    }

    public void addConstructor(ClassConstructor constructor) {
        if (constructor != null && !constructors.contains(constructor)) {
            constructors.add(constructor);
        }
    }

    public List<ClassMethod> getMethods() {
        return methods;
    }

    public void addMethod(ClassMethod method) {
        if (method != null && !methods.contains(method)) {
            methods.add(method);
        }
    }

    public List<ClassField> getFields() {
        return fields;
    }

    public void addField(ClassField field) {
        if (field != null && !fields.contains(field)) {
            fields.add(field);
        }
    }

    public int getModifiers() {
        return modifiers;
    }

    public void setModifiers(int modifiers) {
        this.modifiers = modifiers;
    }

    public String getPackage() {
        return pakage;
    }

    public void setPackage(String pakage) {
        this.pakage = pakage;
    }

    public void setSuperclass(String superclass) {
        this.superclass = superclass;
    }

    public String getSuperclass() {
        return superclass;
    }

    public void addImport(ClassImport classImport) {
        imports.add(classImport);
    }

    public List<ClassImport> getImports() {
        return imports;
    }

    public void addInterface(String interfaceName) {
        interfaces.add(interfaceName);
    }

    public List<String> getInterfaces() {
        return interfaces;
    }

    public void setIsInterface(boolean isInterface) {
        this.isInterface = isInterface;
    }

    public boolean isInterface() {
        return isInterface;
    }

    public void addLinkedClass(SourceClass clazz) {
        linkedClasses.add(clazz);
    }

    public List<SourceClass> getLinkedClasses() {
        return linkedClasses;
    }

    public boolean containsInLinked(String fqn) {
        for (SourceClass sc : getLinkedClasses()) {
            if (sc.getName().equals(fqn)) return true;
        }

        return false;
    }

    public void addTypeArgument(String type) {
        typeArguments.add(type);
    }

    public void addNestedClass(String cls) {
        nestedClasses.add(cls);
    }

    public List<String> getNestedClasses() {
        return nestedClasses;
    }

    public void setRegion(int beginLine, int beginColumn, int endLine, int endColumn) {
        setRegion(new CodeRegion(beginLine, beginColumn, endLine, endColumn));
    }

    public void setRegion(CodeRegion region) {
        this.region = region;
    }

    public CodeRegion getRegion() {
        return region;
    }
}
