package kg.ash.javavi.output;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import kg.ash.javavi.Javavi;
import kg.ash.javavi.cache.Cache;
import kg.ash.javavi.searchers.JavaClassMap;

public abstract class OutputSimilar {

    protected String wordPrefix = "";

    protected HashMap<String, JavaClassMap> classPackages;

    public OutputSimilar(HashMap<String, JavaClassMap> classPackages) {
        this.classPackages = classPackages;
    }

    public String get(String target) {
        if (target == null) target = "";

        if (classPackages == null || classPackages.isEmpty()) {
            return Cache.PACKAGES_EMPTY_ERROR;
        }

        List<String> keys = sort(getKeys(target));

        StringBuilder builder = new StringBuilder();
        for (String key : keys) {
            classPackages.get(key).getPaths().forEach(scope -> {
                builder
                    .append("{").append("'word':'")
                    .append(wordPrefix).append(key)
                    .append("', 'menu':'").append(scope)
                    .append("', 'type': 'c'},")
                    .append(Javavi.NEWLINE);
            });
        }
        return String.format("[%s]", builder);
    }

    private List<String> sort(List<String> keys) {
        Collections.sort(keys, (String s1, String s2) -> {
            int i1 = s1.length(); int i2 = s2.length();
            if (i1 < i2) return -1;
            if (i1 == i2) {
                return s1.compareTo(s2);
            }
            return 1;
        });

        return keys;
    }
    
    protected abstract List<String> getKeys(String target);

}
