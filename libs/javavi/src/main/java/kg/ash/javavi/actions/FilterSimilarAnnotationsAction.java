package kg.ash.javavi.actions;

import kg.ash.javavi.output.OutputSimilarAnnotations;
import kg.ash.javavi.searchers.PackagesLoader;
import kg.ash.javavi.cache.Cache;

public class FilterSimilarAnnotationsAction extends ActionWithTarget {

    @Override
    public String perform(String[] args) {
        return new OutputSimilarAnnotations(Cache.getInstance().getClassPackages())
            .get(parseTarget(args));
    }
    
}
