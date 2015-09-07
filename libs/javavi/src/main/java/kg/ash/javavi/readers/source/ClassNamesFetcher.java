package kg.ash.javavi.readers.source;

import com.github.javaparser.JavaParser;
import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.TypeParameter;
import com.github.javaparser.ast.body.FieldDeclaration;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.ast.expr.Expression;
import com.github.javaparser.ast.expr.FieldAccessExpr;
import com.github.javaparser.ast.expr.MethodCallExpr;
import com.github.javaparser.ast.expr.MethodReferenceExpr;
import com.github.javaparser.ast.expr.ObjectCreationExpr;
import com.github.javaparser.ast.expr.QualifiedNameExpr;
import com.github.javaparser.ast.expr.TypeExpr;
import com.github.javaparser.ast.stmt.ReturnStmt;
import com.github.javaparser.ast.stmt.TypeDeclarationStmt;
import com.github.javaparser.ast.type.ClassOrInterfaceType;
import com.github.javaparser.ast.type.ReferenceType;
import com.github.javaparser.ast.type.Type;
import com.github.javaparser.ast.visitor.DumpVisitor;
import com.github.javaparser.ast.visitor.GenericVisitorAdapter;
import com.github.javaparser.ast.visitor.VoidVisitorAdapter;
import java.io.Reader;
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

    public Set<String> getNames() {
        TypesVisitor visitor = new TypesVisitor();
        visitor.visit(compilationUnit, null);

        return resultList;
    }

    private class TypesVisitor extends VoidVisitorAdapter<Object>{

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
