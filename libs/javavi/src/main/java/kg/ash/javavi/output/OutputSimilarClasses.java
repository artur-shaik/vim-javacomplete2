package kg.ash.javavi.output;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.stream.Collectors;
import kg.ash.javavi.searchers.ClassMap;
import java.util.List;

public class OutputSimilarClasses extends OutputSimilar {

    public OutputSimilarClasses(HashMap<String,ClassMap> classPackages) {
        super(classPackages);
    }

    @Override
    protected List<String> getKeys(String target) {
        if (target.isEmpty()) return new ArrayList<>();
        return classPackages.keySet().stream()
            .filter(k -> k.startsWith(target))
            .collect(Collectors.toList());
    }
    
}
