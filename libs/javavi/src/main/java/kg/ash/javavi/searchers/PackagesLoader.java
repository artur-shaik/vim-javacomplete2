package kg.ash.javavi.searchers;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

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
            int seppos = name.lastIndexOf('$');
            if (seppos < 0) {
                seppos = name.replace('\\', '/').lastIndexOf('/');
            }
            if (seppos != -1) {
                processClass(name, seppos, source);
            }
        }
    }

    private void processClass(String name, int seppos, int source) {
        String parent = name.substring(0, seppos);
        String child  = name.substring(seppos + 1, name.length() - 6);

        boolean nested = false;
        String parentDots = makeDots(parent);
        if (name.contains("$")) {
            nested = true;
            parentDots += "$";
        }

        putClassPath(parentDots, child, source, ClassMap.CLASS, ClassMap.SUBPACKAGE);
        if (!nested) {
            putClassPath(child, parentDots, source, ClassMap.SUBPACKAGE, ClassMap.CLASS);
        }

        addToParent(parent, source);
    }

    private boolean isClassFile(String name) {
        return name.endsWith(".class");
    }

    private void addToParent(String name, int source) {
        int seppos = name.replace('\\', '/').lastIndexOf('/');
        if (seppos == -1) {
            return;
        }

        String parent = name.substring(0, seppos);
        String child = name.substring(seppos + 1);

        putClassPath(child, makeDots(parent), source, ClassMap.SUBPACKAGE, ClassMap.SUBPACKAGE);

        addToParent(parent, source);
    }

    private void putClassPath(String parent, String child, int source, int classMapType, int type) {
        if (parent.isEmpty() || child.isEmpty()) {
            return;
        }

        if (!classesMap.containsKey(child)) {
            classesMap.put(child, new ClassMap(child, classMapType));
        }

        classesMap.get(child).add(parent, source, type);
    }

    private String makeDots(String name) {
        return name.replaceAll("/", ".").replaceAll("[.]{2,}", "");
    }
}
