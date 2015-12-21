package kg.ash.javavi.actions;

import kg.ash.javavi.output.OutputClassPackages;
import kg.ash.javavi.searchers.PackagesLoader;
import kg.ash.javavi.cache.Cache;

public class GetClassPackagesAction extends ActionWithTarget {

    @Override
    public String perform(String[] args) {
        if (Cache.cachedClassPackages.isEmpty()) {
            new PackagesLoader(sources)
                .collectPackages(Cache.cachedClassPackages);
        }
        return new OutputClassPackages(Cache.cachedClassPackages)
            .get(parseTarget(args));
    }
    
}
