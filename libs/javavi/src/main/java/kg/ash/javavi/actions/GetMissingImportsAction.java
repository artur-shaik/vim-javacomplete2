package kg.ash.javavi.actions;

import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.ImportDeclaration;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import kg.ash.javavi.clazz.ClassImport;
import kg.ash.javavi.readers.source.ClassNamesFetcher;
import kg.ash.javavi.readers.source.CompilationUnitCreator;

public class GetMissingImportsAction implements Action {

    @Override
    public String perform(String[] args) {
        String content = getContent(args).replaceAll("\\\\n", "\n");
        CompilationUnit compilationUnit = CompilationUnitCreator.createFromContent(content);
        if (compilationUnit == null) return "Couldn't parse file";

        ClassNamesFetcher classnamesFetcher = new ClassNamesFetcher(compilationUnit);
        Set<String> classnames = classnamesFetcher.getNames();

        List<String> importTails = new ArrayList<>();
        List<String> asteriskImports = new ArrayList<>();
        if (compilationUnit.getImports() != null) {
            for (ImportDeclaration importDeclaration : compilationUnit.getImports()) {
                ClassImport classImport =
                    new ClassImport(importDeclaration.getName().toStringWithoutComments(), importDeclaration.isStatic(), importDeclaration.isAsterisk());
                if (classImport.isAsterisk()) {
                    asteriskImports.add(classImport.getName());
                } else {
                    importTails.add(classImport.getTail());
                }
            }
        }

        StringBuilder result = new StringBuilder("[");
        for (String classname : classnames) {
            if (!importTails.contains(classname)) {
                GetClassPackagesAction getPackagesAction = new GetClassPackagesAction();
                String packages = getPackagesAction.perform(new String[] {classname});

                if (packages.length() == 2) {
                    continue;
                }

                String[] splitted = packages.substring(1, packages.length() - 1).split(",");
                boolean found = false;
                for (String foundPackage : splitted) {
                    foundPackage = foundPackage.trim().substring(1, foundPackage.length() - 1);
                    foundPackage = foundPackage.substring(0, foundPackage.lastIndexOf("."));
                    for (String asteriskImport : asteriskImports) {
                        if (foundPackage.equals(asteriskImport)) {
                            found = true;
                            break;
                        }
                    }
                }
                if (!found) {
                    result.append(packages).append(",");
                }
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

        return "";
    }
    
}
