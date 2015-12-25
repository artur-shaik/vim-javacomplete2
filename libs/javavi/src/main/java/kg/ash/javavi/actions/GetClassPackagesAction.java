package kg.ash.javavi.actions;

import kg.ash.javavi.output.OutputClassPackages;
import kg.ash.javavi.searchers.PackagesLoader;
import kg.ash.javavi.cache.Cache;

public class GetClassPackagesAction extends ActionWithTarget {

    @Override
    public String perform(String[] args) {
        return new OutputClassPackages(Cache.getInstance().getClassPackages())
            .get(parseTarget(args));
    }
    
}
