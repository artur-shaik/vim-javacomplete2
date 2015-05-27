package kg.ash.javavi;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.lang.StringBuilder;
import java.lang.System;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.StringTokenizer;
import java.util.zip.ZipFile;
import com.github.javaparser.*;
import com.github.javaparser.ast.*;

public class PackagesSearcher {

    private HashMap htClasspath = new HashMap();

    private String jarsDirectories;
    private String sourcesDirectories;

    public PackagesSearcher(String jarsDirectories, String sourcesDirectories) {
        this.jarsDirectories = jarsDirectories;
        this.sourcesDirectories = sourcesDirectories;
    }

    public void collectPackages(HashMap<String,StringBuilder[]> packagesMap, HashMap<String,List<String>> classesMap) {
        for (String path : collectClassPath()) {
            if (path.toLowerCase().endsWith(".jar") || path.toLowerCase().endsWith(".zip")) {
                appendListFromJar(path, packagesMap, classesMap);
            }
        }

        for (String entry : getSourcePackages(sourcesDirectories)) {
            appendEntry(entry, packagesMap, classesMap);
        }
    }

    private void appendListFromJar(String path, HashMap<String,StringBuilder[]> packagesMap, HashMap<String,List<String>> classesMap) {
        try {
            for (Enumeration entries = new ZipFile(path).entries(); entries.hasMoreElements(); ) {
                String entry = entries.nextElement().toString();
                appendEntry(entry, packagesMap, classesMap);
            }
        } catch (Exception e) {
            Javavi.debug(e);
        }
    }

    private void appendEntry(String entry, HashMap packagesMap, HashMap<String,List<String>> classesMap) {
        if (entry.endsWith(".class") && entry.indexOf('$') == -1) {
            int slashpos = entry.lastIndexOf('/');
            if (slashpos >= 0) {
                String parent = entry.substring(0, slashpos);
                String child  = entry.substring(slashpos + 1, entry.length() - 6);
                String parentDots = parent.replaceAll("/", ".");
                putItem(packagesMap, parentDots, child, Javavi.INDEX_CLASS);
                putClassPath(classesMap, parentDots, child);

                slashpos = parent.lastIndexOf('/');
                if (slashpos != -1) {
                    addToParent(packagesMap, parent.substring(0, slashpos), parent.substring(slashpos + 1));
                }
            }
        }
    }

    private void putClassPath(HashMap<String,List<String>> classesMap, String parent, String child) {
        if (!classesMap.containsKey(child)) {
            classesMap.put(child, new ArrayList<String>());
        }

        if (!classesMap.get(child).contains(parent)) {
            classesMap.get(child).add(parent);
        }
    }

    private void putItem(HashMap map, String parent, String child, int index) {
        StringBuilder[] sbs = (StringBuilder[])map.get(parent);
        if (sbs == null) {
            sbs = new StringBuilder[] {  
                new StringBuilder(), 	// packages
                new StringBuilder()		// classes
            };
        }

        if (sbs[index].toString().indexOf("'" + child + "',") == -1) {
            sbs[index].append("'").append(child).append("',");
        }

        map.put(parent, sbs);
    }

    private void addToParent(HashMap map, String parent, String child) {
        putItem(map, parent, child, Javavi.INDEX_PACKAGE);

        int slashpos = parent.lastIndexOf('/');
        if (slashpos != -1) {
            addToParent(map, parent.substring(0, slashpos), parent.substring(slashpos + 1));
        }
    }

    private List<String> collectClassPath() {
        List result = new ArrayList<>();

        String extdirs = System.getProperty("java.ext.dirs");
        for (StringTokenizer st = new StringTokenizer(extdirs, File.pathSeparator); st.hasMoreTokens(); ) {
            result.addAll(addClasspathesFromDir(st.nextToken() + File.separator));
        }

        result.addAll(addClasspathesFromDir(System.getProperty("java.home")));

        String classPath = System.getProperty("java.class.path") + File.pathSeparator + jarsDirectories;
        StringTokenizer st = new StringTokenizer(classPath, File.pathSeparator);
        while (st.hasMoreTokens()) {
            String path = st.nextToken();
            File f = new File(path);
            if (!f.exists())
                continue;

            if (path.toLowerCase().endsWith(".jar") || path.toLowerCase().endsWith(".zip")) {
                result.add(f.toString());
            } else if (f.isDirectory()) {
                result.addAll(addClasspathesFromDir(path));
            }
        }

        return result;
    }

    private List<String> addClasspathesFromDir(String dirpath) {
        List<String> result = new ArrayList<>();
        File dir = new File(dirpath);
        if (dir.isDirectory()) {
            ArchFileFinder finder = new ArchFileFinder(Arrays.asList("*.jar", "*.zip", "*.ZIP"));
            try {
                Files.walkFileTree(Paths.get(dir.getPath()), finder);

                for (String path : finder.getResultList()) {
                    result.add(path);
                }
            } catch (IOException ex) {
                Javavi.debug(ex);
            }
        }

        return result;
    }

    private List<String> getSourcePackages(String dirpaths) {
        List<String> result = new ArrayList<>();
        String[] splitted = dirpaths.split(File.pathSeparator);
        for (String dirpath : splitted) {
            File dir = new File(dirpath);
            if (dir.isDirectory()) {
                ArchFileFinder finder = new ArchFileFinder(Arrays.asList("*.java"));
                try {
                    Files.walkFileTree(Paths.get(dir.getPath()), finder);

                    for (String path : finder.getResultList()) {
                        String packagePath = fetchPackagePath(path);
                        if (packagePath != null) {
                            packagePath = packagePath.substring(0, packagePath.length() - 4) + "class";
                            result.add(packagePath);
                        }
                    }
                } catch (IOException ex) {
                    Javavi.debug(ex);
                }
            }
        }
        return result;
    }

    private String fetchPackagePath(String sourcePath) {
        CompilationUnit cu = null;
        try (FileInputStream in = new FileInputStream(sourcePath)) {
            cu = JavaParser.parse(in);
        } catch (Exception ex) {
            return null;
        }

        if (cu.getPackage() != null) {
            int lastslash = sourcePath.lastIndexOf(File.separator);
            if (lastslash >= 0) {
                return 
                    cu.getPackage().getName().toString().replace(".", File.separator) 
                    + File.separator + sourcePath.substring(lastslash + 1);
            }
        }
        return null;
    }
}
