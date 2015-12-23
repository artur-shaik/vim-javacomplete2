package kg.ash.javavi.cache;

import java.util.HashMap;
import kg.ash.javavi.Javavi;
import kg.ash.javavi.clazz.SourceClass;
import kg.ash.javavi.searchers.ClassMap;
import kg.ash.javavi.searchers.PackagesLoader;

public class Cache {

    private static Cache instance;

    public static Cache getInstance() {
        if (instance == null) {
            instance = new Cache();
        }
        return instance;
    }
    
    private HashMap<String, SourceClass> classes = new HashMap<>();
    private HashMap<String, ClassMap> classPackages = new HashMap<>();

    public HashMap<String, ClassMap> getClassPackages() {
        if (classPackages.isEmpty()) {
            String sources = Javavi.system.get("sources").replace('\\', '/');
            new PackagesLoader(sources).collectPackages(classPackages);
        }
        return classPackages;
    }

    public HashMap<String, SourceClass> getClasses() {
        return classes;
    }

}
