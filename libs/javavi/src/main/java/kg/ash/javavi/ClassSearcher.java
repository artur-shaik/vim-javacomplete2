package kg.ash.javavi;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

public class ClassSearcher {

    private boolean isReflected = false;
    private boolean isInSource = false;
    private String sources;
    private String sourceFile = null;

    public boolean find(String targetClass, String sources) {
        Javavi.debug("Search class: " + targetClass);

        this.sources = sources;
        if (Reflection.exist(targetClass) || Reflection.exist("java.lang." + targetClass)) {
            isReflected = true;
            return true;
        } else {
            String[] sourcesArray = sources.split(File.pathSeparator);
            for (String sourceDir : sourcesArray) {
                SourceFileFinder finder = new SourceFileFinder(targetClass);
                try {
                    Files.walkFileTree(Paths.get(sourceDir), finder);

                    if (finder.getTargetFile() != null) {
                        sourceFile = finder.getTargetFile();
                        isInSource = true;
                        return true;
                    }
                } catch (IOException ex) {
                    Javavi.debug(ex);
                }
            }
        }

        return false;
    }

    public ClassReader getReader() {
        if (isReflected()) {
            return new Reflection(sources);
        } else {
            return new Parser(sources, getSourceFile());
        }
    }

    public boolean isReflected() {
        return isReflected;
    }

    public boolean isInSource() {
        return isInSource;
    }

    public String getSourceFile() {
        return sourceFile;
    }
    
}
