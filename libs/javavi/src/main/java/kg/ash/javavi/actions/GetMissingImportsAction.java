package kg.ash.javavi.actions;

import java.util.ArrayList;
import java.util.List;

import com.github.javaparser.ast.ImportDeclaration;
import com.github.javaparser.ast.PackageDeclaration;

import kg.ash.javavi.clazz.ClassImport;

public class GetMissingImportsAction extends ImportsAction {

    @Override
    public String action() {
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

        if (compilationUnit.getPackage() != null) {
            asteriskImports.add(compilationUnit.getPackage().getName().toStringWithoutComments());
        }

        StringBuilder result = new StringBuilder("[");
        for (String classname : classnames) {
            if (!importTails.contains(classname)) {
                GetClassPackagesAction getPackagesAction = new GetClassPackagesAction();
                String packages = getPackagesAction.perform(new String[] {classname});

                if (packages.startsWith("message:")) {
                    return packages;
                } else if (packages.length() == 2) {
                    continue;
                }

                String[] splitted = packages.substring(1, packages.length() - 1).split(",");
                boolean found = false;
                for (String foundPackage : splitted) {
                    if (foundPackage.trim().isEmpty()) continue;
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

}
