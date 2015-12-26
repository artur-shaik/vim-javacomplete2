package kg.ash.javavi.actions;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import kg.ash.javavi.Javavi;
import kg.ash.javavi.cache.Cache;
import kg.ash.javavi.readers.FileClassLoader;
import kg.ash.javavi.searchers.ClassNameMap;

public class RemoveClassInfoFromCache extends ActionWithTarget {
    
    @Override
    public String perform(String[] args) {
        String target = parseTarget(args);
        if (Cache.getInstance().getClasses().containsKey(target)) {
            Cache.getInstance().getClasses().remove(target);
        }

        recompileSource(target);
        return "";
    }

    private void recompileSource(String className) {
        new Thread(() -> {
            String[] splitted = className.split("\\.");
            ClassNameMap classMap = (ClassNameMap) Cache.getInstance().getClassPackages().get(splitted[splitted.length - 1]);
            if (classMap != null && classMap.getClassFile() != null && classMap.getJavaFile() != null) {

                String classFile = classMap.getClassFile();
                String sourceFile = classMap.getJavaFile();

                String classDir = classFile.substring(0, classFile.lastIndexOf(File.separator));
                int offset = 0;
                while (!sourceFile.contains(classDir)) {
                    int index = classDir.indexOf(File.separator, 2);
                    if (index > 0) {
                        classDir = classDir.substring(index);
                        offset += index;
                    } else {
                        break;
                    }
                }

                classDir = classFile.substring(0, offset);
                String compiler = Javavi.system.get("compiler");
                String classPath = System.getProperty("java.class.path");
                String command = String.format("%s -cp %s -d %s %s", compiler, classPath, classDir, sourceFile);
                Javavi.debug(command);
                try {
                    Process p = Runtime.getRuntime().exec(command);
                    p.waitFor();
                } catch (Exception e) {
                    Javavi.debug(e);
                }
            }
        }).start();
    }

}
