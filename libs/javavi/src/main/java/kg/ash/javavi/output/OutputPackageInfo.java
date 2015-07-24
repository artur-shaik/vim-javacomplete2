package kg.ash.javavi.output;

import kg.ash.javavi.searchers.ClassMap;
import java.util.HashMap;

public class OutputPackageInfo {

    private String targetPackage;

    public OutputPackageInfo(String targetPackage) {
        this.targetPackage = targetPackage;
    }
    
    public String get(HashMap<String,ClassMap> classPackages) {
        return String.format("{%s}", filterAndCompose(classPackages).toString());
    }

    private StringBuilder filterAndCompose(HashMap<String,ClassMap> classPackages) {
        StringBuilder sb = new StringBuilder();
        if (classPackages != null && classPackages.containsKey(targetPackage)) {
            ClassMap classMap = classPackages.get(targetPackage);

            sb.append("'").append(targetPackage).append("':")
                .append("{'tag':'PACKAGE'")
                .append(",'subpackages':[").append(classMap.getCachedSubpackages()).append("]")
                .append(",'classes':[").append(classMap.getCachedClasses().toString()).append("]")
                .append("},");
        } 

        return sb;
    }

}
