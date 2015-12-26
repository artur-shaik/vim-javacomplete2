package kg.ash.javavi.output;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.stream.Collectors;
import kg.ash.javavi.searchers.JavaClassMap;
import java.util.List;

public class OutputSimilarClasses extends OutputSimilar {

    public OutputSimilarClasses(HashMap<String, JavaClassMap> classPackages) {
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
