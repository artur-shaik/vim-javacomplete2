package kg.ash.javavi.actions;

import kg.ash.javavi.output.OutputSimilarAnnotations;
import kg.ash.javavi.searchers.PackagesLoader;
import kg.ash.javavi.Javavi;

public class FilterSimilarAnnotationsAction extends ActionWithTarget {

    @Override
    public String perform(String[] args) {
        if (Javavi.cachedClassPackages.isEmpty()) {
            new PackagesLoader(sources)
                .collectPackages(Javavi.cachedClassPackages);
        }
        return new OutputSimilarAnnotations(Javavi.cachedClassPackages)
            .get(parseTarget(args));
    }
    
}
