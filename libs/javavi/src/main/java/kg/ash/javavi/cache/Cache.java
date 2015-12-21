package kg.ash.javavi.cache;

import java.util.HashMap;
import kg.ash.javavi.clazz.SourceClass;
import kg.ash.javavi.searchers.ClassMap;

public class Cache {
    
    public static HashMap<String,SourceClass> cachedClasses = new HashMap<>();
    public static HashMap<String,ClassMap> cachedClassPackages = new HashMap<>();

}
