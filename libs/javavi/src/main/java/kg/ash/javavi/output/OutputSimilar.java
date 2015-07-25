package kg.ash.javavi.output;

import java.util.Collections;
import java.util.List;
import kg.ash.javavi.Javavi;
import kg.ash.javavi.searchers.ClassMap;
import java.util.HashMap;

public abstract class OutputSimilar {

    protected String wordPrefix = "";

    protected HashMap<String,ClassMap> classPackages;

    public OutputSimilar(HashMap<String,ClassMap> classPackages) {
        this.classPackages = classPackages == null ? new HashMap<>() : classPackages;
    }

    public String get(String target) {
        if (target == null) target = "";

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
