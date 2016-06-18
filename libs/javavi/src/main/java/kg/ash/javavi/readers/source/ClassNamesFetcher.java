package kg.ash.javavi.readers.source;

import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.ImportDeclaration;
import com.github.javaparser.ast.Node;
import com.github.javaparser.ast.TreeVisitor;
import com.github.javaparser.ast.body.ClassOrInterfaceDeclaration;
import com.github.javaparser.ast.body.FieldDeclaration;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.ast.body.MultiTypeParameter;
import com.github.javaparser.ast.body.Parameter;
import com.github.javaparser.ast.expr.AnnotationExpr;
import com.github.javaparser.ast.expr.Expression;
import com.github.javaparser.ast.expr.FieldAccessExpr;
import com.github.javaparser.ast.expr.MethodCallExpr;
import com.github.javaparser.ast.expr.NameExpr;
import com.github.javaparser.ast.stmt.BlockStmt;
import com.github.javaparser.ast.type.ClassOrInterfaceType;
import com.github.javaparser.ast.type.Type;
import com.github.javaparser.ast.visitor.VoidVisitorAdapter;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class ClassNamesFetcher {

    private final CompilationUnit compilationUnit;
    private final Set<String> resultList = new HashSet<>();
    private List<String> staticImportsList = new ArrayList<>();

    public ClassNamesFetcher(CompilationUnit compilationUnit) {
        this.compilationUnit = compilationUnit;
    }

    @SuppressWarnings("unchecked")
    public Set<String> getNames() {
        for (ImportDeclaration id : compilationUnit.getImports()) {
            if (id.isStatic()) {
                String name = id.getName().toString();
                staticImportsList.add(name.substring(name.lastIndexOf(".") + 1, name.length()));
            }
        }
        List<VoidVisitorAdapter> adapters = new ArrayList<>();
        adapters.add(new ClassTypeVisitor());
        adapters.add(new TypesVisitor());
        adapters.add(new AnnotationsVisitor());
        adapters.forEach(a -> a.visit(compilationUnit, null));

        return resultList;
    }

    private class ClassTypeVisitor extends VoidVisitorAdapter<Object> {

        @Override
        public void visit(ClassOrInterfaceDeclaration type, Object arg) {
            if (type.getAnnotations() != null) {
                for (AnnotationExpr expr : type.getAnnotations()) {
                    resultList.add(expr.getName().getName());
                    List<Node> children = expr.getChildrenNodes();
                    for (Node node : children.subList(1, children.size())) {
                        new DeepVisitor(this, arg).visitDepthFirst(node);
                    }
                }
            }
        }

    }

    private class AnnotationsVisitor extends VoidVisitorAdapter<Object> {

        private void addAnnotations(List<AnnotationExpr> annotations, Object arg) {
            if (annotations != null) {
                for (AnnotationExpr expr : annotations) {
                    resultList.add(expr.getName().getName());
                    List<Node> children = expr.getChildrenNodes();
                    for (Node node : children.subList(1, children.size())) {
                        new DeepVisitor(this, arg).visitDepthFirst(node);
                    }
                }
            }
        }

        @Override
        public void visit(FieldDeclaration type, Object arg) {
            addAnnotations(type.getAnnotations(), arg);
        }

        @Override
        public void visit(MethodDeclaration type, Object arg) {
            addAnnotations(type.getAnnotations(), arg);
            if (type.getParameters() != null) {
                for (Parameter param : type.getParameters()) {
                    addAnnotations(param.getAnnotations(), arg);
                }
            }

            if (type.getThrows() != null) {
                for (NameExpr expr : type.getThrows()) {
                    resultList.add(expr.getName());
                }
            }
        }

    }

    private class TypesVisitor extends VoidVisitorAdapter<Object>{

        @Override
        public void visit(BlockStmt type, Object arg) {
            new DeepVisitor(this, arg).visitDepthFirst(type);
        }

        @Override
        public void visit(FieldAccessExpr type, Object arg) {
            addStatic(type);
        }

        @Override
        public void visit(MethodCallExpr type, Object arg) {
            addStatic(type);
        }

        private void addStatic(Expression type) {
            if (type.getChildrenNodes() != null && type.getChildrenNodes().size() > 0) {
                String name = type.getChildrenNodes().get(0).toStringWithoutComments();
                if (!name.contains(".")) {
                    resultList.add(name);
                }
            }
        }

        @Override
        public void visit(ClassOrInterfaceType type, Object arg) {
            String name = type.getName();
            String fullName = type.toStringWithoutComments();
            if (!fullName.startsWith(name)) {
                if (!type.getChildrenNodes().isEmpty()) {
                    name = type.getChildrenNodes().get(0).toStringWithoutComments();
                }
            }
            if (name.contains(".")) {
                name = name.split("\\.")[0];
            }
            resultList.add(name);
            if (type.getTypeArgs() != null) {
                for (Type t : type.getTypeArgs()) {
                    String typeName = t.toStringWithoutComments();
                    if (typeName.contains(".")) {
                        typeName = typeName.split("\\.")[0];
                    }
                    resultList.add(typeName);
                }
            }
        }

    }

    private class DeepVisitor extends TreeVisitor {

        private VoidVisitorAdapter adapter;
        private Object arg;

        public DeepVisitor(VoidVisitorAdapter adapter, Object arg) {
            this.adapter = adapter;
            this.arg = arg;
        }

        public void process(Node node) {
            if (node instanceof ClassOrInterfaceType) {
                adapter.visit((ClassOrInterfaceType)node, arg);
            } else if (node instanceof NameExpr) {

                // javaparser has no difference on 'method call' expression,
                // so class name with static method call look the same as
                // object method call. that's why we check here for usual
                // class name type with upper case letter at the beginning.
                // it can miss some unusual class names with lower case at
                // the beginning.
                String name = ((NameExpr) node).getName();
                if (name.matches("^[A-Z][A-Za-z0-9_]+")) {
                    resultList.add(name);
                }
            } else if (node instanceof MultiTypeParameter) {
                ((MultiTypeParameter)node).getTypes()
                    .forEach(t -> resultList.add(t.toStringWithoutComments()));
            } else if (node instanceof MethodCallExpr) {
                MethodCallExpr methodCall = ((MethodCallExpr) node);
                String name = methodCall.getName();
                List<Node> children = node.getChildrenNodes();
                if (children.equals(methodCall.getArgs()) && staticImportsList.contains(name)) {
                    resultList.add(name);
                }
            }
        }
    }
}
