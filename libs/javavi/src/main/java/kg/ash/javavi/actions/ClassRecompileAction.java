package kg.ash.javavi.actions;

import java.io.File;
import kg.ash.javavi.Javavi;
import kg.ash.javavi.cache.Cache;
import kg.ash.javavi.searchers.ClassNameMap;

public class ClassRecompileAction implements Action {

    @Override 
    public String perform(String[] target) {
        if (target.length == 0) return "";

        String[] splitted = target[0].split("\\.");
        ClassNameMap classMap = findClass(splitted[splitted.length - 1]);
        if (classMap != null && classMap.getClassFile() != null && classMap.getJavaFile() != null) {
            String classFile = classMap.getClassFile();
            String sourceFile = classMap.getJavaFile();
            String classDir = classFile.substring(0, classFile.lastIndexOf(File.separator));

            int offset = findOffset(sourceFile, classDir);
            classDir = classFile.substring(0, offset);

            String compiler = Javavi.system.get("compiler");
            String classPath = System.getProperty("java.class.path");

            execute(String.format("%s -cp %s -d %s %s", compiler, classPath, classDir, sourceFile));
        }

        return "";
    }

    private void execute(String command) {
        Javavi.debug(command);
        try {
            Process p = Runtime.getRuntime().exec(command);
            p.waitFor();
        } catch (Exception e) {
            Javavi.debug(e);
        }
    }

    private int findOffset(String sourceFile, String classDir) {
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

        return offset;
    }

    private ClassNameMap findClass(String name) {
        return (ClassNameMap) Cache.getInstance().getClassPackages().get(name);
    }

}
