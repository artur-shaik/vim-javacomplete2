package kg.ash.javavi.searchers;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.HashMap;
import java.util.Set;

public class ClassMap {

    public static final int CLASSPATH = 0;
    public static final int SOURCES = 1;

    public static final int CLASS = 0;
    public static final int SUBPACKAGE = 1;

    private String name = null;
    private int type;

    private HashMap<String,Integer> map = new HashMap<>();

    private List<String> classes = new ArrayList<>();
    private List<String> subpackages = new ArrayList<>();

    public ClassMap(String name, int type) {
        setName(name);
        setType(type);
    }

    public boolean contains(String path) {
        return map.containsKey(path);
    }

    public void add(String path, int source, int type) {
        if (!contains(path)) {
            map.put(path, source);

            if (type == CLASS) {
                classes.add(path);
            } else {
                subpackages.add(path);
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
        Collections.sort(subpackages);
        StringBuilder cachedSubpackages = new StringBuilder();
        subpackages.forEach(path -> cachedSubpackages.append("'").append(path).append("',"));
        return cachedSubpackages;
    }

    public StringBuilder getCachedClasses() {
        Collections.sort(classes);
        StringBuilder cachedClasses = new StringBuilder();
        classes.forEach(path -> cachedClasses.append("'").append(path).append("',"));
        return cachedClasses;
    }

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

    public void setType(int type) {
        this.type = type;
    }

    public int getType() {
        return type;
    }

    public List<String> getClasses() {
        return classes;
    }

    public List<String> getSubpackages() {
        return subpackages;
    }

    @Override
    public String toString() {
        return String.format("name: %s, type: %d", name, type);
    }
}
