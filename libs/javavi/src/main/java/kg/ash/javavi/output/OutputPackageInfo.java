package kg.ash.javavi.output;

import kg.ash.javavi.searchers.ClassMap;
import java.util.HashMap;

public class OutputPackageInfo {

    private HashMap<String,ClassMap> classPackages;

    public OutputPackageInfo(HashMap<String,ClassMap> classPackages) {
        this.classPackages = classPackages;
    }
    
    public String get(String targetPackage) {

        StringBuilder sb = new StringBuilder();
        if (classPackages != null && classPackages.containsKey(targetPackage)) {
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
