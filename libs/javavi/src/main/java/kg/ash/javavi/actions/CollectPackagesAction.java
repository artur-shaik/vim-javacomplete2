package kg.ash.javavi.actions;

import kg.ash.javavi.cache.Cache;

public class CollectPackagesAction implements Action {

    @Override
    public String perform(String[] string) {
        Cache.getInstance().getClassPackages().clear();
        Cache.getInstance().collectPackages();

        return "";
    }
    
}
