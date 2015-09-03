package kg.ash.javavi.actions;

import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.ImportDeclaration;
import java.util.Set;
import kg.ash.javavi.clazz.ClassImport;
import kg.ash.javavi.readers.source.CompilationUnitCreator;
import kg.ash.javavi.readers.source.ClassNamesFetcher;

public class GetUnusedImportsAction implements Action {

    @Override
    public String perform(String[] args) {
        String content = getContent(args).replaceAll("\\\\n", "\n");
        CompilationUnit compilationUnit = CompilationUnitCreator.createFromContent(content);
        if (compilationUnit == null) return "Couldn't parse file";

        ClassNamesFetcher classnamesFetcher = new ClassNamesFetcher(compilationUnit);
        Set<String> classnames = classnamesFetcher.getNames();

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

    private String getContent(String[] args) {
        for (int i = 0; i < args.length; i++) {
            if (args[i].equals("-content")) {
                return args[i + 1];
            }
        }

        return "nope";
    }
    
}
