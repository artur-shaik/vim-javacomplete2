package kg.ash.javavi.output;

import java.util.HashMap;
import kg.ash.javavi.cache.Cache;
import kg.ash.javavi.searchers.ClassMap;

public class OutputPackageInfo {

    private HashMap<String, ClassMap> classPackages;

    public OutputPackageInfo(HashMap<String, ClassMap> classPackages) {
        this.classPackages = classPackages;
    }

    public String get(String targetPackage) {
        StringBuilder sb = new StringBuilder();
        if (classPackages.containsKey(targetPackage)) {
            ClassMap classMap = classPackages.get(targetPackage);

            sb.append("'").append(targetPackage).append("':")
                .append("{'tag':'PACKAGE'")
                .append(",'subpackages':[").append(classMap.getCachedSubpackages()).append("]")
                .append(",'classes':[").append(classMap.getCachedClasses().toString()).append("]")
                .append("},");
        } 

        return String.format("{%s}", sb);
    }

}
