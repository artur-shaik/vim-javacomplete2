package kg.ash.javavi.actions;

import com.github.javaparser.ast.ImportDeclaration;
import java.util.Set;
import kg.ash.javavi.clazz.ClassImport;

public class GetUnusedImportsAction extends ImportsAction {

    @Override
    public String action() {
        StringBuilder result = new StringBuilder("[");
        for (ImportDeclaration importDeclaration : compilationUnit.getImports()) {
            if (importDeclaration.isAsterisk() || importDeclaration.isStatic()) continue;

            ClassImport classImport = 
                new ClassImport(importDeclaration.getName().toStringWithoutComments(), importDeclaration.isStatic(), importDeclaration.isAsterisk());

            String classname = classImport.getTail();
            if (!classnames.contains(classname)) {
                result.append("'").append(importDeclaration.getName().toStringWithoutComments().replace("\n", "")).append("',");
            }
        }
        return result.append("]").toString();
    }

}
