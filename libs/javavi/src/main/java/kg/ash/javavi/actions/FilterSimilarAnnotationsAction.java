package kg.ash.javavi.actions;

import kg.ash.javavi.output.OutputSimilarAnnotations;
import kg.ash.javavi.searchers.PackagesLoader;
import kg.ash.javavi.Javavi;

public class FilterSimilarAnnotationsAction implements Action {

    @Override
    public String perform(String[] args) {
        String sources = Javavi.system.get("sources");
        String target = args[args.length - 1];
        if (Javavi.cachedClassPackages.isEmpty()) {
            new PackagesLoader(sources).collectPackages(Javavi.cachedClassPackages);
        }
        return new OutputSimilarAnnotations(Javavi.cachedClassPackages).get(target);
    }
    
}
