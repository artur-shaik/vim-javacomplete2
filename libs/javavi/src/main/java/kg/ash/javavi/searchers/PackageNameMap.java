package kg.ash.javavi.searchers;

import java.util.Collections;
import java.util.List;

public class PackageNameMap extends JavaClassMap {

    public PackageNameMap(String name) {
        super(name);
    }

    @Override public int getType() {
        return JavaClassMap.TYPE_SUBPACKAGE;
    }

}
