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
        return classPackages.keySet().stream()
            .filter(k -> target.length() > 0 && k.startsWith(target))
            .collect(Collectors.toList());
    }
    
}
