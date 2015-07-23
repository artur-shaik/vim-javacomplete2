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

public class PackagesSearcher {

    private String sourceDirectories;
    private HashMap<String,StringBuilder[]> packagesMap = new HashMap<>(); 
    private HashMap<String,ClassMap> classesMap = new HashMap<>();

    public PackagesSearcher(String sourceDirectories) {
        this.sourceDirectories = sourceDirectories;
    }

    public void collectPackages(HashMap<String,StringBuilder[]> packagesMap, HashMap<String,ClassMap> classesMap) {
        this.packagesMap = packagesMap;
        this.classesMap = classesMap;

        List<PackageEntry> entries = new ArrayList<>();
        entries.addAll(new ReflectionPackageSearcher().loadEntries());
        entries.addAll(new SourcePackageSearcher(sourceDirectories).loadEntries());

        entries.forEach(entry -> appendEntry(entry.getEntry(), entry.getSource()));
    }

    private void appendEntry(String entry, int source) {
        if (entry.endsWith(".class") && entry.indexOf('$') == -1) {
            int slashpos = entry.lastIndexOf('/');
            if (slashpos >= 0) {
                String parent = entry.substring(0, slashpos);
                String child  = entry.substring(slashpos + 1, entry.length() - 6);
                String parentDots = parent.replaceAll("/", ".");
                putItem(parentDots, child, Javavi.INDEX_CLASS);
                putClassPath(parentDots, child, source);

                slashpos = parent.lastIndexOf('/');
                if (slashpos != -1) {
                    addToParent(parent.substring(0, slashpos), parent.substring(slashpos + 1));
                }
            }
        }
    }

    private void putClassPath(String parent, String child, int source) {
        if (!classesMap.containsKey(child)) {
            classesMap.put(child, new ClassMap(child));
        }

        if (!classesMap.get(child).contains(parent)) {
            classesMap.get(child).add(parent, source);
        }
    }

    private void putItem(String parent, String child, int index) {
        StringBuilder[] sbs = (StringBuilder[])packagesMap.get(parent);
        if (sbs == null) {
            sbs = new StringBuilder[] {  
                new StringBuilder(), 	// packages
                new StringBuilder()		// classes
            };
        }

        if (sbs[index].toString().indexOf("'" + child + "',") == -1) {
            sbs[index].append("'").append(child).append("',");
        }

        packagesMap.put(parent, sbs);
    }

    private void addToParent(String parent, String child) {
        putItem(parent, child, Javavi.INDEX_PACKAGE);

        int slashpos = parent.lastIndexOf('/');
        if (slashpos != -1) {
            addToParent(parent.substring(0, slashpos), parent.substring(slashpos + 1));
        }
    }

}
