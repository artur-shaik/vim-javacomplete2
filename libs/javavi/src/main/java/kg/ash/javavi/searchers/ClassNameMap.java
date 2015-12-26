package kg.ash.javavi.searchers;

import java.util.Collections;
import java.util.List;

public class ClassNameMap extends JavaClassMap {

    public ClassNameMap(String name) {
        super(name);
    }

    @Override public int getType() {
        return JavaClassMap.TYPE_CLASS;
    }

}
