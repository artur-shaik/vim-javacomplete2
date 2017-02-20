package kg.ash.javavi.actions;

import java.util.Arrays;

import kg.ash.javavi.apache.logging.log4j.LogManager;
import kg.ash.javavi.apache.logging.log4j.Logger;

import kg.ash.javavi.cache.Cache;
import kg.ash.javavi.searchers.ClassNameMap;
import kg.ash.javavi.searchers.JavaClassMap;

public class AddClassToCacheAction implements Action {

    public static final Logger logger = LogManager.getLogger();

    @Override
    public String perform(String[] args) {
        String sourceFile = getArg(args, "-source");
        String className = getArg(args, "-class");
        String packageName = getArg(args, "-package");

        ClassNameMap cnm = (ClassNameMap) 
            Cache.getInstance().getClassPackages()
            .get(className);
        if (cnm == null) {
            cnm = new ClassNameMap(className);
        }
        cnm.setJavaFile(sourceFile);
        cnm.add(
                packageName, 
                JavaClassMap.SOURCETYPE_SOURCES, 
                JavaClassMap.TYPE_SUBPACKAGE,
                null);
        Cache.getInstance().getClassPackages()
            .put(className, cnm);

        return "";
    }

    private String getArg(String[] args, String name) {
        for (int i = 0; i < args.length; i++) {
            if (args[i].equals(name)) {
                return args[i + 1];
            }
        }

        return "";
    }

}
