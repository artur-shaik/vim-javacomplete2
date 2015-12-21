package kg.ash.javavi.actions;

import kg.ash.javavi.cache.Cache;

public class RemoveClassInfoFromCache extends ActionWithTarget {
    
    @Override
    public String perform(String[] args) {
        String target = parseTarget(args);
        if (Cache.cachedClasses.containsKey(target)) {
            Cache.cachedClasses.remove(target);
        }

        return null;
    }

}
