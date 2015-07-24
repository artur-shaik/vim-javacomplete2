package kg.ash.javavi.searchers;

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
import kg.ash.javavi.Javavi;

public class PackagesLoader {

    private HashMap<String,ClassMap> classesMap = new HashMap<>();
    private List<PackageSeacherIFace> searchers = new ArrayList<>();

    public PackagesLoader(String sourceDirectories) {
        searchers.add(new ClasspathPackageSearcher());
        searchers.add(new SourcePackageSearcher(sourceDirectories));
    }

    public void collectPackages(HashMap<String,ClassMap> classesMap) {
        this.classesMap = classesMap;

        List<PackageEntry> entries = new ArrayList<>();
        searchers.parallelStream().forEach(s -> entries.addAll(s.loadEntries()));

        entries.forEach(entry -> appendEntry(entry.getEntry(), entry.getSource()));
    }

    public void setSearchers(List<PackageSeacherIFace> searchers) {
        this.searchers = searchers;
    }

    private void appendEntry(String name, int source) {
        if (isClassFile(name)) {
            int seppos = name.lastIndexOf(File.separatorChar);
            if (seppos != -1) {
                processClass(name, seppos, source);
            }
        }
    }

    private void processClass(String name, int seppos, int source) {
        String parent = name.substring(0, seppos);
        String child  = name.substring(seppos + 1, name.length() - 6);

        String parentDots = makeDots(parent);
        putClassPath(parentDots, child, source, ClassMap.SUBPACKAGE);
        putClassPath(child, parentDots, source, ClassMap.CLASS);

        addToParent(parent, source);
    }

    private boolean isClassFile(String name) {
        return name.endsWith(".class") && name.indexOf('$') == -1;
    }

    private void addToParent(String name, int source) {
        int seppos = name.lastIndexOf(File.separatorChar);
        if (seppos == -1) {
            return;
        }

        String parent = name.substring(0, seppos);
        String child = name.substring(seppos + 1);

        putClassPath(child, makeDots(parent), source, ClassMap.SUBPACKAGE);

        addToParent(parent, source);
    }

    private void putClassPath(String parent, String child, int source, int type) {
        if (parent.isEmpty() || child.isEmpty()) {
            return;
        }

        if (!classesMap.containsKey(child)) {
            classesMap.put(child, new ClassMap(child));
        }

        classesMap.get(child).add(parent, source, type);
    }

    private String makeDots(String name) {
        return name.replaceAll(File.separator, ".").replaceAll("[.]{2,}", "");
    }
}
