package kg.ash.javavi.searchers;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.List;
import java.util.ArrayList;
import java.util.function.Predicate;
import java.util.zip.ZipFile;
import kg.ash.javavi.Javavi;
import kg.ash.javavi.searchers.ClassMap;

public class ClasspathPackageSearcher implements PackageSeacherIFace {

    private ByExtensionVisitor finder 
        = new ByExtensionVisitor(Arrays.asList("*.jar", "*.JAR", "*.zip", "*.ZIP"));
    
    public List<PackageEntry> loadEntries() {
        List<PackageEntry> result = new ArrayList<>();

        Predicate<String> isArchive = path -> {
            return path.toLowerCase().endsWith(".jar") 
                || path.toLowerCase().endsWith(".zip");
        };

        collectClassPath().stream()
            .filter(isArchive)
            .forEach(path -> {
                try {
                    for (Enumeration entries = new ZipFile(path).entries(); entries.hasMoreElements(); ) {
                        String entry = entries.nextElement().toString();
                        result.add(new PackageEntry(entry, ClassMap.CLASSPATH));
                    }
                } catch (IOException e) {
                    Javavi.debug(e);
                }
            });

        return result;
    }

    private List<String> collectClassPath() {
        List<String> result = new ArrayList<>();

        String extdirs = System.getProperty("java.ext.dirs");
        for (String path : extdirs.split(File.pathSeparator)) {
            result.addAll(addPathFromDir(path + File.separator));
        }

        result.addAll(addPathFromDir(System.getProperty("java.home")));

        String classPath = System.getProperty("java.class.path") + File.pathSeparator;
        for (String path : classPath.split(File.pathSeparator)) {
            if (path.toLowerCase().endsWith(".jar") || path.toLowerCase().endsWith(".zip")) {
                result.add(path);
            } else {
                result.addAll(addPathFromDir(path));
            }
        }

        return result;
    }

    private List<String> addPathFromDir(String dirpath) {
        List<String> result = new ArrayList<>();
        File dir = new File(dirpath);
        if (dir.isDirectory()) {
            try {
                Files.walkFileTree(Paths.get(dir.getPath()), finder);
                result.addAll(finder.getResultList());
            } catch (IOException ex) {
                Javavi.debug(ex);
            }
        }

        return result;
    }
}
