package kg.ash.javavi.actions;

import kg.ash.javavi.output.OutputClassPackages;
import kg.ash.javavi.searchers.PackagesLoader;
import kg.ash.javavi.Javavi;

public class GetClassPackagesAction extends ActionWithTarget {

    @Override
    public String perform(String[] args) {
        if (Javavi.cachedClassPackages.isEmpty()) {
            new PackagesLoader(sources)
                .collectPackages(Javavi.cachedClassPackages);
        }
        return new OutputClassPackages(Javavi.cachedClassPackages)
            .get(parseTarget(args));
    }
    
}
