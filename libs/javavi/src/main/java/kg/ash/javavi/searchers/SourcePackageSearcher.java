package kg.ash.javavi.searchers;

import com.github.javaparser.JavaParser;
import com.github.javaparser.ast.CompilationUnit;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import kg.ash.javavi.apache.logging.log4j.LogManager;
import kg.ash.javavi.apache.logging.log4j.Logger;

public class SourcePackageSearcher implements PackageSeacherIFace {

    public static final Logger logger = LogManager.getLogger();

    private String sourceDirectories = "";
    private ByExtensionVisitor finder = 
        new ByExtensionVisitor(Arrays.asList("*.java"));

    public SourcePackageSearcher(String sourceDirectories) {
        if (sourceDirectories != null) {
            this.sourceDirectories = sourceDirectories;
        }
    }
    
    public List<PackageEntry> loadEntries() {
        List<PackageEntry> result = new ArrayList<>();
        for (String directory : getExistDirectories()) {
            try {
                logger.debug("search source files");

                Files.walkFileTree(Paths.get(directory), finder);
                for (String path : finder.getResultList()) {
                    String packagePath = fetchPackagePath(path);
                    if (packagePath != null) {
                        logger.trace(path);

                        packagePath = packagePath.substring(0, packagePath.length() - 4) + "class";
                        result.add(new PackageEntry(packagePath, JavaClassMap.SOURCETYPE_SOURCES, path, PackageEntry.FILETYPE_JAVA));
                    }
                }
            } catch (IOException e) {
                logger.error(e, e);
            }
        }
        return result;
    }

    private List<String> getExistDirectories() {
        String[] splitted = sourceDirectories.split(File.pathSeparator);
        return Arrays.asList(splitted).stream()
            .filter(d -> new File(d).isDirectory())
            .map(d -> d).collect(Collectors.toList());
    }

    private String fetchPackagePath(String sourcePath) {
        CompilationUnit cu = null;
        try (FileInputStream in = new FileInputStream(sourcePath)) {
            cu = JavaParser.parse(in);
        } catch (Exception ex) {
            return null;
        }

        if (cu.getPackage() != null) {
            int lastslash = sourcePath.replace('\\', '/').lastIndexOf('/');
            if (lastslash >= 0) {
                String className  = sourcePath.substring(lastslash + 1);
                String path = cu.getPackage().getName().toString().replace(".", File.separator);
                return path + File.separator + className;
            }
        }
        return null;
    }
}

