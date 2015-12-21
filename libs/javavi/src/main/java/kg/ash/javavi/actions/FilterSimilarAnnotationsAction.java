package kg.ash.javavi.actions;

import kg.ash.javavi.output.OutputSimilarAnnotations;
import kg.ash.javavi.searchers.PackagesLoader;
import kg.ash.javavi.cache.Cache;

public class FilterSimilarAnnotationsAction extends ActionWithTarget {

    @Override
    public String perform(String[] args) {
        if (Cache.cachedClassPackages.isEmpty()) {
            new PackagesLoader(sources)
                .collectPackages(Cache.cachedClassPackages);
        }
        return new OutputSimilarAnnotations(Cache.cachedClassPackages)
            .get(parseTarget(args));
    }
    
}
