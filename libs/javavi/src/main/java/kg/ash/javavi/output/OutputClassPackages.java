package kg.ash.javavi.output;

import kg.ash.javavi.Javavi;
import kg.ash.javavi.searchers.ClassMap;
import java.util.HashMap;

public class OutputClassPackages {

    private HashMap<String,ClassMap> classPackages;

    public OutputClassPackages(HashMap<String,ClassMap> classPackages) {
        this.classPackages = classPackages;
    }

    public String get(String targetClass) {

        StringBuilder builder = new StringBuilder("");
        if (classPackages != null && classPackages.containsKey(targetClass)) {
            classPackages.get(targetClass).getPaths().forEach(scope -> {
                builder
                    .append("'")
                    .append(scope).append(".").append(targetClass)
                    .append("',")
                    .append(Javavi.NEWLINE);
            });
        }

        return String.format("[%s]", builder);
    }
    
}
