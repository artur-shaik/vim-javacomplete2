package kg.ash.javavi.actions;

import com.github.javaparser.ast.ImportDeclaration;

import kg.ash.javavi.clazz.ClassImport;

public class GetUnusedImportsAction extends ImportsAction {

    @Override
    public String action() {
        StringBuilder result = new StringBuilder("[");
        for (ImportDeclaration importDeclaration : compilationUnit.getImports()) {
            if (importDeclaration.isAsterisk()) continue;

            ClassImport classImport =
                new ClassImport(importDeclaration.getName().toStringWithoutComments(), importDeclaration.isStatic(), importDeclaration.isAsterisk());

            String classname = classImport.getTail();
            if (!classnames.contains(classname)) {
                result.append("'").append(classImport.getHead()).append(classImport.isStatic() ? "$" : ".").append(classname).append("',");
            }
        }
        return result.append("]").toString();
    }

}
