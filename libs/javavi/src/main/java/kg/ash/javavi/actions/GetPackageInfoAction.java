package kg.ash.javavi.actions;

import kg.ash.javavi.Javavi;
import kg.ash.javavi.searchers.PackagesLoader;
import kg.ash.javavi.output.OutputPackageInfo;

public class GetPackageInfoAction extends ActionWithTarget {

    @Override
    public String perform(String[] args) {
        if (Javavi.cachedClassPackages.isEmpty()) {
            new PackagesLoader(sources)
                .collectPackages(Javavi.cachedClassPackages);
        }

        return new OutputPackageInfo(Javavi.cachedClassPackages)
            .get(parseTarget(args));
    }
    
}
