package kg.ash.javavi.searchers;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.List;
import java.util.Optional;
import java.util.zip.ZipFile;
import kg.ash.javavi.Javavi;
import kg.ash.javavi.searchers.ClassMap;

public class ClasspathPackageSearcher implements PackageSeacherIFace {

    private ByExtensionVisitor finder 
        = new ByExtensionVisitor(Arrays.asList("*.jar", "*.JAR", "*.zip", "*.ZIP", "*.class"));
    
    public List<PackageEntry> loadEntries() {
        List<PackageEntry> result = new ArrayList<>();

        List<String> knownPaths = new ArrayList<>();
        collectClassPath().stream()
            .forEach(path -> {
                if (path.toLowerCase().endsWith(".class")) {
                    path = path.substring(0, path.length() - 6).replaceAll(File.separator, ".");
                    String newPath = path.substring(0, path.lastIndexOf("."));
                    String fileName = path.substring(path.lastIndexOf(".") + 1, path.length());
                    Optional<String> knownPath = knownPaths.parallelStream().filter(s -> newPath.endsWith(s)).findFirst();
                    if (knownPath.isPresent()) {
                        result.add(new PackageEntry(knownPath.get() + "." + fileName, ClassMap.CLASSPATH));
                        return;
                    }
                    String[] split = path.split("\\.");
                    int j = split.length - 2;
                    while (j > 0) {
                        path = "";
                        for (int i = j; i <= split.length - 2; i++) {
                            path += split[i] + ".";
                        }
                        String pkg = getPackageByFile(path + fileName);
                        if (pkg != null) {
                            result.add(new PackageEntry(pkg + "." + fileName, ClassMap.CLASSPATH));
                            knownPaths.add(pkg);
                            break;
                        } else {
                            j--;
                        }
                    }
                } else {
                    try {
                        for (Enumeration entries = new ZipFile(path).entries(); entries.hasMoreElements(); ) {
                            String entry = entries.nextElement().toString();
                            result.add(new PackageEntry(entry, ClassMap.CLASSPATH));
                        }
                    } catch (IOException e) {
                        Javavi.debug(e);
                    }
                }
            });

        return result;
    }

    private String getPackageByFile(String path) {
        try {
            Class clazz = Class.forName(path);
            return clazz.getPackage().getName();
        } catch (ClassNotFoundException | NoClassDefFoundError ex) {
            return null;
        }
    }

    private List<String> collectClassPath() {
        List<String> result = new ArrayList<>();

        String extdirs = System.getProperty("java.ext.dirs").replace('\\',  '/');
        for (String path : extdirs.split(File.pathSeparator)) {
            result.addAll(addPathFromDir(path + '/'));
        }

        result.addAll(addPathFromDir(System.getProperty("java.home").replace('\\',  '/')));

        String classPath = System.getProperty("java.class.path").replace('\\', '/') + File.pathSeparator;
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
