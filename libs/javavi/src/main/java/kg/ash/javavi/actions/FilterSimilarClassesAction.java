package kg.ash.javavi.actions;

import kg.ash.javavi.output.OutputSimilarClasses;
import kg.ash.javavi.searchers.PackagesLoader;
import kg.ash.javavi.cache.Cache;

public class FilterSimilarClassesAction extends ActionWithTarget {

    @Override
    public String perform(String[] args) {
        if (Cache.cachedClassPackages.isEmpty()) {
            new PackagesLoader(sources)
                .collectPackages(Cache.cachedClassPackages);
        }

        return new OutputSimilarClasses(Cache.cachedClassPackages)
            .get(parseTarget(args));
    }
    
}
