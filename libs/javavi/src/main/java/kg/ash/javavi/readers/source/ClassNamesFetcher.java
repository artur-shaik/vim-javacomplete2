package kg.ash.javavi.readers.source;

import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.Node;
import com.github.javaparser.ast.TreeVisitor;
import com.github.javaparser.ast.body.ClassOrInterfaceDeclaration;
import com.github.javaparser.ast.body.FieldDeclaration;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.ast.body.MultiTypeParameter;
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
    private final Set<String> resultList = new HashSet<String>();

    public ClassNamesFetcher(CompilationUnit compilationUnit) {
        this.compilationUnit = compilationUnit;
    }

    @SuppressWarnings("unchecked")
    public Set<String> getNames() {
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
                }
            }
        }

    }

    private class AnnotationsVisitor extends VoidVisitorAdapter<Object> {

        private void addAnnotations(List<AnnotationExpr> annotations) {
            if (annotations != null) {
                for (AnnotationExpr expr : annotations) {
                    resultList.add(expr.getName().getName());
                }
            }
        }

        @Override
        public void visit(FieldDeclaration type, Object arg) {
            addAnnotations(type.getAnnotations());
        }

        @Override
        public void visit(MethodDeclaration type, Object arg) {
            addAnnotations(type.getAnnotations());

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
            TypesVisitor t = this;
            TreeVisitor tv = new TreeVisitor() {
                public void process(Node node) {
                    if (node instanceof ClassOrInterfaceType) {
                        if (!node.toStringWithoutComments().contains(".")) {
                            t.visit((ClassOrInterfaceType)node, arg);
                        }
                    } else if (node instanceof NameExpr) {
                        resultList.add(((NameExpr) node).getName());
                    } else if (node instanceof MultiTypeParameter) {
                        ((MultiTypeParameter)node).getTypes().forEach(t -> resultList.add(t.toStringWithoutComments()));
                    }
                }
            };
            tv.visitDepthFirst(type);
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
            resultList.add(type.getName());
            if (type.getTypeArgs() != null) {
                for (Type t : type.getTypeArgs()) {
                    resultList.add(t.toStringWithoutComments());
                }
            }
        }

    }

}
