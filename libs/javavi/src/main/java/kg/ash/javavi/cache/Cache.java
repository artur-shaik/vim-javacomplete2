package kg.ash.javavi.cache;

import java.util.HashMap;
import kg.ash.javavi.Javavi;
import kg.ash.javavi.clazz.SourceClass;
import kg.ash.javavi.searchers.ClassMap;
import kg.ash.javavi.searchers.PackagesLoader;

public class Cache {

    public static String PACKAGES_EMPTY_ERROR = "message: packages still empty, try later. indexing...";

    private static Cache instance;

    public static Cache getInstance() {
        if (instance == null) {
            instance = new Cache();
        }
        return instance;
    }
    
    private HashMap<String, SourceClass> classes = new HashMap<>();
    private HashMap<String, ClassMap> classPackages = new HashMap<>();

    private boolean collectIsRunning = false;

    public synchronized void collectPackages() {
        if (collectIsRunning) return;

        collectIsRunning = true;
        new Thread(() -> {
            String sources = Javavi.system.get("sources").replace('\\', '/');
            new PackagesLoader(sources).collectPackages(classPackages);
            collectIsRunning = false;
        }).start();
    }

    public HashMap<String, ClassMap> getClassPackages() {
        if (classPackages.isEmpty()) {
            collectPackages();
        }
        return classPackages;
    }

    public HashMap<String, SourceClass> getClasses() {
        return classes;
    }

}
