package kg.ash.javavi;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.Reader;
import java.lang.StringBuilder;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Matcher;
import com.github.javaparser.*;
import com.github.javaparser.ast.*;
import com.github.javaparser.ast.body.*;
import com.github.javaparser.ast.type.*;
import com.github.javaparser.ast.stmt.*;
import com.github.javaparser.ast.visitor.*;

public class Parser implements ClassReader {

    private String sources;
    private String sourceFile;

    public Parser(String sources, String sourceFile) {
        this.sources = sources;
        this.sourceFile = sourceFile;
    }

    @Override
    public void setTypeArguments(List<String> typeArguments) {

    }

    @Override
    public SourceClass read(String targetClass) {
        if (sourceFile == null || sourceFile.isEmpty()) return null;

        if (Javavi.cachedClasses.containsKey(targetClass)) 
            return Javavi.cachedClasses.get(targetClass);

        CompilationUnit cu;
        SourceClass clazz = new SourceClass();

        Javavi.cachedClasses.put(targetClass, clazz);

        List<String> sourceLines = new ArrayList<>();
        try (BufferedReader reader = new BufferedReader(new FileReader(sourceFile))) {
            reader.mark(65536);
            cu = JavaParser.parse(reader, true);
            reader.reset();
            String line;
            while ((line = reader.readLine()) != null) {
                sourceLines.add(line);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            Javavi.debug(ex);
            return null;
        }

        clazz.setPackage(cu.getPackage().getName().toString());

        if (cu.getImports() != null) {
            for (ImportDeclaration id : cu.getImports()) {
                clazz.addImport(new ClassImport(id.getName().toString(), id.isStatic(), id.isAsterisk()));
            }
        }

        ClassVisitor visitor = new ClassVisitor(clazz);
        visitor.visit(cu, null);
        clazz = visitor.getClazz();

        ClassOrInterfaceVisitor coiVisitor = new ClassOrInterfaceVisitor(clazz);
        coiVisitor.visit(cu, null);
        clazz = coiVisitor.getClazz();

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

        //List<String> linked = new ArrayList<>();
        //for (ClassMethod cm : clazz.getMethods()) {
        //    if (cm.getTypeName().equals("int")) continue;
        //    if (cm.getTypeName().equals("long")) continue;
        //    if (cm.getTypeName().equals("boolean")) continue;
        //    if (cm.getTypeName().equals("void")) continue;
        //    if (cm.getTypeName().equals("Object")) continue;
        //    if (cm.getTypeName().equals("String")) continue;
        //    linked.addAll(getFqns(clazz.getImports(), cm.getTypeName()));
        //}

        //for (ClassField cf : clazz.getFields()) {
        //    if (cf.getTypeName().equals("int")) continue;
        //    if (cf.getTypeName().equals("long")) continue;
        //    if (cf.getTypeName().equals("boolean")) continue;
        //    if (cf.getTypeName().equals("void")) continue;
        //    if (cf.getTypeName().equals("Object")) continue;
        //    if (cf.getTypeName().equals("String")) continue;
        //    linked.addAll(getFqns(clazz.getImports(), cf.getTypeName()));
        //}

        //for (String link : linked) {
        //    if (link.equals(clazz.getName())) continue;
        //    if (!clazz.containsInLinked(link)) {
        //        ClassSearcher seacher = new ClassSearcher();
        //        if (seacher.find(link, sources)) {
        //            SourceClass linkedClass = seacher.getReader().read(link);
        //            if (linkedClass != null) {
        //                clazz.addLinkedClass(linkedClass);
        //            }
        //        }
        //    }
        //}

        return clazz;
    }

    private List<String> getFqns(List<ClassImport> imports, String name) {
        if (name.indexOf('<') >= 0) {
            name = name.substring(0, name.indexOf('<'));
        }
        List<String> result = new ArrayList<>();
        for (ClassImport ci : imports) {
            if (!ci.isAsterisk()){
                String importName;
                if (ci.getName().contains(".")) {
                    String[] splitted = ci.getName().split("\\.");
                    importName = splitted[splitted.length - 1];
                } else {
                    importName = ci.getName();
                }

                if (name.equals(importName)) {
                    List<String> exactResult = new ArrayList<>();
                    exactResult.add(ci.getName());
                    return exactResult;
                }
            } else {
                String[] splitted = ci.getName().split("\\.");
                String importName = "";
                for (String s : splitted) {
                    if (!s.equals("*")) {
                        importName += s + ".";
                    }
                }

                importName += name;
                result.add(importName);
            }
        }

        return result;
    }

    private class ClassOrInterfaceVisitor extends VoidVisitorAdapter {

        private SourceClass clazz;

        public ClassOrInterfaceVisitor(SourceClass clazz) {
            this.clazz = clazz;
        }

        public SourceClass getClazz() {
            return clazz;
        }

        @Override
        public void visit(ClassOrInterfaceDeclaration n, Object arg) {
            clazz.setName(n.getName());
            clazz.setModifiers(n.getModifiers());
            clazz.setIsInterface(n.isInterface());
            if (n.getExtends() != null && n.getExtends().size() > 0) {
                String className = n.getExtends().get(0).getName();
                List<String> fqns = getFqns(clazz.getImports(), className);
                fqns.add(clazz.getPackage() + "." + className);
                ClassSearcher seacher = new ClassSearcher();
                for (String fqn : fqns) {
                    if (seacher.find(fqn, sources)) {
                        className = fqn;
                        break;
                    }
                }
                clazz.setSuperclass(className);
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
                ClassSearcher seacher = new ClassSearcher();
                for (ClassOrInterfaceType iface : n.getImplements()) {
                    String className = iface.getName();
                    List<String> fqns = getFqns(clazz.getImports(), className);
                    fqns.add(clazz.getPackage() + "." + className);
                    for (String fqn : fqns) {
                        if (seacher.find(fqn, sources)) {
                            className = fqn;
                            break;
                        }
                    }
                    clazz.addInterface(className);
                }
            }
        }

    }

    private class ClassVisitor extends VoidVisitorAdapter {

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
            constructor.setDeclaration(Parser.getDeclarationName(n.toStringWithoutComments()));
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
            method.setDeclaration(Parser.getDeclarationName(n.toStringWithoutComments()));

            String className = n.getType().toString();
            List<String> fqns = getFqns(clazz.getImports(), className);
            fqns.add(clazz.getPackage() + "." + className);
            ClassSearcher seacher = new ClassSearcher();
            for (String fqn : fqns) {
                if (seacher.find(fqn, sources)) {
                    className = fqn;
                    break;
                }
            }
            method.setTypeName(className);

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
                List<String> fqns = getFqns(clazz.getImports(), className);
                fqns.add(clazz.getPackage() + "." + className);
                ClassSearcher seacher = new ClassSearcher();
                for (String fqn : fqns) {
                    if (seacher.find(fqn, sources)) {
                        className = fqn;
                        break;
                    }
                }
                field.setTypeName(className);

                clazz.addField(field);
            }
        }
    }

    private static String getDeclarationName(String code) {
        code = code.replaceAll("@\\S+(\\s|$)", "");
        code = code.replaceAll("\n", "");
        int index = code.indexOf('{');
        if (index >= 0) {
            return code.substring(0, index).trim();
        }

        return code;
    }

}
