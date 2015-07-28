package kg.ash.javavi.actions;

import kg.ash.javavi.output.OutputSimilarClasses;
import kg.ash.javavi.searchers.PackagesLoader;
import kg.ash.javavi.Javavi;

public class FilterSimilarClassesAction extends ActionWithTarget {

    @Override
    public String perform(String[] args) {
        if (Javavi.cachedClassPackages.isEmpty()) {
            new PackagesLoader(sources)
                .collectPackages(Javavi.cachedClassPackages);
        }

        return new OutputSimilarClasses(Javavi.cachedClassPackages)
            .get(parseTarget(args));
    }
    
}
