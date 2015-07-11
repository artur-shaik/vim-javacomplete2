package kg.ash.javavi.searchers;

import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.ArrayList;

public class ClassMap {

    public static final int CLASSPATH = 0;
    public static final int SOURCES = 1;

    private String name;
    private HashMap<String,Integer> map = new HashMap<>();

    public ClassMap(String name) {
        this.name = name;
    }
    
    public boolean contains(String path) {
        return map.containsKey(path);
    }

    public void add(String path, int source) {
        map.put(path, source);
    }

    public Set<String> getPaths() {
        return map.keySet();
    }

    public int getSource(String path) {
        return map.get(path);
    }
}
