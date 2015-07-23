package kg.ash.javavi.searchers;

import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.ArrayList;

public class ClassMap {

    public static final int CLASSPATH = 0;
    public static final int SOURCES = 1;

    public static final int CLASS = 0;
    public static final int SUBPACKAGE = 1;

    private String name;
    private HashMap<String,Integer> map = new HashMap<>();

    private StringBuilder cachedSubpackages = new StringBuilder();
    private StringBuilder cachedClasses = new StringBuilder();

    public ClassMap(String name) {
        this.name = name;
    }
    
    public boolean contains(String path) {
        return map.containsKey(path);
    }

    public void add(String path, int source, int type) {
        if (!contains(path)) {
            map.put(path, source);

            if (type == CLASS) {
                cachedClasses.append("'").append(path).append("',");
            } else {
                cachedSubpackages.append("'").append(path).append("',");
            }
        }
    }

    public Set<String> getPaths() {
        return map.keySet();
    }

    public int getSource(String path) {
        return map.get(path);
    }

    public StringBuilder getCachedSubpackages() {
        return cachedSubpackages;
    }

    public StringBuilder getCachedClasses() {
        return cachedClasses;
    }

}
