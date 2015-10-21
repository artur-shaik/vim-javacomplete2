package kg.ash.javavi.actions;

import kg.ash.javavi.Javavi;

public class RemoveClassInfoFromCache extends ActionWithTarget {
    
    @Override
    public String perform(String[] args) {
        String target = parseTarget(args);
        if (Javavi.cachedClasses.containsKey(target)) {
            Javavi.cachedClasses.remove(target);
        }

        return null;
    }

}
