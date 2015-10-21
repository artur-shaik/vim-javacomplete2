package kg.ash.javavi.readers;

import java.util.ArrayList;
import java.util.List;

import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.ImportDeclaration;
import com.github.javaparser.ast.Node;
import com.github.javaparser.ast.TypeParameter;
import com.github.javaparser.ast.body.ClassOrInterfaceDeclaration;
import com.github.javaparser.ast.body.ConstructorDeclaration;
import com.github.javaparser.ast.body.FieldDeclaration;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.ast.body.VariableDeclarator;
import com.github.javaparser.ast.type.ClassOrInterfaceType;
import com.github.javaparser.ast.visitor.VoidVisitorAdapter;

import kg.ash.javavi.Javavi;
import kg.ash.javavi.clazz.ClassConstructor;
import kg.ash.javavi.clazz.ClassField;
import kg.ash.javavi.clazz.ClassImport;
import kg.ash.javavi.clazz.ClassMethod;
import kg.ash.javavi.clazz.ClassTypeParameter;
import kg.ash.javavi.clazz.SourceClass;
import kg.ash.javavi.readers.source.CompilationUnitCreator;
import kg.ash.javavi.searchers.ClassSearcher;
import kg.ash.javavi.searchers.FqnSearcher;

public class Parser implements ClassReader {

    private String sources;
    private String sourceFile;
    private ClassOrInterfaceDeclaration parentClass = null;

    public Parser(String sources, String sourceFile) {
        this.sources = sources.replace('\\', '/');
        this.sourceFile = sourceFile.replace('\\', '/');
    }

    @Override
    public ClassReader setTypeArguments(List<String> typeArguments) {
        // Not supported yet.
        return this;
    }

    @Override
    public SourceClass read(String targetClass) {
        if (sourceFile == null || sourceFile.isEmpty()) return null;

        if (targetClass.contains("$")) {
            targetClass = targetClass.split("\\$")[0];
        }
        if (Javavi.cachedClasses.containsKey(targetClass)) {
            return Javavi.cachedClasses.get(targetClass);
        }

        CompilationUnit cu = CompilationUnitCreator.createFromFile(sourceFile);
        if (cu == null) {
            return null;
        }

        SourceClass clazz = new SourceClass();
        Javavi.cachedClasses.put(targetClass, clazz);

        clazz.setPackage(cu.getPackage().getName().toString());

        if (cu.getImports() != null) {
            for (ImportDeclaration id : cu.getImports()) {
                clazz.addImport(new ClassImport(id.getName().toString(), id.isStatic(), id.isAsterisk()));
            }
        }

        ClassOrInterfaceVisitor coiVisitor = new ClassOrInterfaceVisitor(clazz);
        coiVisitor.visit(cu, null);
        clazz = coiVisitor.getClazz();

        ClassVisitor visitor = new ClassVisitor(clazz);
        visitChildren(parentClass.getChildrenNodes(), visitor);
        clazz = visitor.getClazz();

        List<String> impls = new ArrayList<>();
        if (clazz.getSuperclass() != null) {
            impls.add(clazz.getSuperclass());
        }

        impls.addAll(clazz.getInterfaces());
        for (String impl : impls) {
            ClassSearcher seacher = new ClassSearcher();
            if (seacher.find(impl, sources)) {
                SourceClass implClass = seacher.getReader().read(impl);
                if (implClass != null) {
                    clazz.addLinkedClass(implClass);
                    for (ClassConstructor c : implClass.getConstructors()) {

                        if (implClass.getName().equals("java.lang.Object")) continue;
                        c.setDeclaration(c.getDeclaration().replace(implClass.getName(), clazz.getName()));
                        c.setDeclaration(c.getDeclaration().replace(implClass.getSimpleName(), clazz.getSimpleName()));
                        clazz.addConstructor(c);
                    }
                    for (ClassMethod method : implClass.getMethods()) {
                        clazz.addMethod(method);
                    }
                    for (ClassField field : implClass.getFields()) {
                        clazz.addField(field);
                    }
                }
            }
        }

        return clazz;
    }

    private void visitChildren(List<Node> nodes, ClassVisitor visitor) {
        for (Node n : nodes) {
            if (n instanceof FieldDeclaration) {
                visitor.visit((FieldDeclaration)n, null);
            } else if (n instanceof MethodDeclaration) {
                visitor.visit((MethodDeclaration)n, null);
            } else if (n instanceof ConstructorDeclaration) {
                visitor.visit((ConstructorDeclaration)n, null);
            } else if (n instanceof ClassOrInterfaceDeclaration) {
                visitor.visit((ClassOrInterfaceDeclaration)n, null);
            }
        }
    }

    private class ClassOrInterfaceVisitor extends VoidVisitorAdapter<Object> {

        private SourceClass clazz;

        public ClassOrInterfaceVisitor(SourceClass clazz) {
            this.clazz = clazz;
        }

        public SourceClass getClazz() {
            return clazz;
        }

        @Override
        public void visit(ClassOrInterfaceDeclaration n, Object arg) {
            parentClass = n;
            clazz.setName(n.getName());
            clazz.setModifiers(n.getModifiers());
            clazz.setIsInterface(n.isInterface());
            if (n.getExtends() != null && n.getExtends().size() > 0) {
                String className = n.getExtends().get(0).getName();
                clazz.setSuperclass(new FqnSearcher(sources).getFqn(clazz, className));
            } else {
                clazz.setSuperclass("java.lang.Object");
                if (clazz.getConstructors().isEmpty()) {
                    ClassConstructor ctor = new ClassConstructor();
                    ctor.setDeclaration(String.format("public %s()", clazz.getName()));

                    ctor.setModifiers(1);
                    clazz.addConstructor(ctor);
                }
            }

            if (n.getImplements() != null) {
                for (ClassOrInterfaceType iface : n.getImplements()) {
                    String className = iface.getName();
                    clazz.addInterface(new FqnSearcher(sources).getFqn(clazz, className));
                }
            }
        }

    }

    private class ClassVisitor extends VoidVisitorAdapter<Object> {

        private SourceClass clazz;

        public ClassVisitor(SourceClass clazz) {
            this.clazz = clazz;
        }

        public SourceClass getClazz() {
            return clazz;
        }

        @Override
        public void visit(ConstructorDeclaration n, Object arg) {
            ClassConstructor constructor = new ClassConstructor();
            constructor.setDeclaration(n.getDeclarationAsString());
            constructor.setModifiers(n.getModifiers());
            if (n.getTypeParameters() != null) {
                for (TypeParameter parameter : n.getTypeParameters()) {
                    constructor.addTypeParameter(new ClassTypeParameter(parameter.getName()));
                }
            }
            clazz.addConstructor(constructor);
        }

        @Override
        public void visit(MethodDeclaration n, Object arg) {
            ClassMethod method = new ClassMethod();
            method.setName(n.getName());
            method.setModifiers(n.getModifiers());
            method.setDeclaration(n.getDeclarationAsString());

            String className = n.getType().toString();
            method.setTypeName(new FqnSearcher(sources).getFqn(clazz, className));

            if (n.getTypeParameters() != null) {
                for (TypeParameter parameter : n.getTypeParameters()) {
                    method.addTypeParameter(new ClassTypeParameter(parameter.getName()));
                }
            }
            clazz.addMethod(method);
        }

        @Override
        public void visit(FieldDeclaration n, Object arg) {
            for (VariableDeclarator v : n.getVariables()) {
                ClassField field = new ClassField();
                field.setName(v.getId().getName());
                field.setModifiers(n.getModifiers());

                String className = n.getType().toString();
                field.setTypeName(new FqnSearcher(sources).getFqn(clazz, className));

                clazz.addField(field);
            }
        }

        @Override
        public void visit(ClassOrInterfaceDeclaration n, Object arg) {
            SourceClass clazz = new SourceClass();
            clazz.setName(this.clazz.getSimpleName() + "$" + n.getName());
            clazz.setModifiers(n.getModifiers());
            clazz.setIsInterface(n.isInterface());
            if (n.getExtends() != null && n.getExtends().size() > 0) {
                String className = n.getExtends().get(0).getName();
                clazz.setSuperclass(new FqnSearcher(sources).getFqn(clazz, className));
            } else {
                clazz.setSuperclass("java.lang.Object");
                if (clazz.getConstructors().isEmpty()) {
                    ClassConstructor ctor = new ClassConstructor();
                    ctor.setDeclaration(String.format("public %s()", clazz.getName()));

                    ctor.setModifiers(1);
                    clazz.addConstructor(ctor);
                }
            }

            if (n.getImplements() != null) {
                for (ClassOrInterfaceType iface : n.getImplements()) {
                    String className = iface.getName();
                    clazz.addInterface(new FqnSearcher(sources).getFqn(clazz, className));
                }
            }

            clazz.setPackage(this.clazz.getPackage());

            ClassVisitor visitor = new ClassVisitor(clazz);
            visitChildren(n.getChildrenNodes(), visitor);
            this.clazz.addNestedClass(clazz.getName());
            this.clazz.addLinkedClass(clazz);

            Javavi.cachedClasses.put(clazz.getName(), clazz);
        }

    }

    private static String getDeclarationName(String code) {
        code = code.replaceAll("//.*$", "");
        code = code.replaceAll("@\\S+(\\s|$)", "");
        code = code.replaceAll("\n", "");
        code = code.replaceAll("/\\*.*\\*/", "");
        int index = code.indexOf('{');
        if (index >= 0) {
            return code.substring(0, index).trim();
        }

        return code;
    }

}
