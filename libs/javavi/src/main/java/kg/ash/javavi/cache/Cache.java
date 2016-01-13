package kg.ash.javavi.cache;

import java.io.File;
import java.util.HashMap;
import kg.ash.javavi.Javavi;
import kg.ash.javavi.clazz.SourceClass;
import kg.ash.javavi.searchers.JavaClassMap;
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

    private HashMap<String, JavaClassMap> classPackages = new HashMap<>();

    private CacheSerializator serializator = new CacheSerializator();

    private boolean collectIsRunning = false;

    public synchronized void collectPackages() {
        if (collectIsRunning) return;

        collectIsRunning = true;
        new Thread(() -> {
            loadCache();

            if (classPackages.isEmpty()) {
                HashMap<String, JavaClassMap> classPackagesTemp = new HashMap<>();
                new PackagesLoader(Javavi.system.get("sources")).collectPackages(classPackagesTemp);
                classPackages.putAll(classPackagesTemp);

                saveCache();
            }

            collectIsRunning = false;
        }).start();
    }

    @SuppressWarnings("unchecked")
    public void loadCache() {
        Object o = serializator.loadCache("class_packages");
        if (o != null) {
            try {
                classPackages = (HashMap<String, JavaClassMap>) o;
            } catch (ClassCastException e) {}
        } 
    }
    
    public void saveCache() {
        serializator.saveCache("class_packages", classPackages);
    }

    public HashMap<String, JavaClassMap> getClassPackages() {
        if (classPackages.isEmpty()) {
            collectPackages();
        }
        return classPackages;
    }

    public HashMap<String, SourceClass> getClasses() {
        return classes;
    }

}
