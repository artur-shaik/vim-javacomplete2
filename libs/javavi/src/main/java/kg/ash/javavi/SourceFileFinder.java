package kg.ash.javavi;

import java.io.File;
import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitResult;
import java.nio.file.Path;
import java.nio.file.PathMatcher;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;

public class SourceFileFinder extends SimpleFileVisitor<Path> {

    private final PathMatcher matcher;
    private String targetFile = null;
    private String pattern = null;

    public SourceFileFinder(String pat) {
        pattern = pat;
        String path = "";
        if (pattern.contains(".")) {
            String[] splitted = pattern.split("\\.");
            path = splitted[splitted.length - 1];
        } else {
            path = pattern;
        }

        matcher = FileSystems.getDefault()
                .getPathMatcher("glob:" + path + ".java");
    }

    public String getTargetFile() {
        return targetFile;
    }

    private boolean find(Path file) {
        Path name = file.getFileName();
        if (name != null && matcher.matches(name)) {
            if (pattern.contains(".")) {
                String[] splitted = pattern.split("\\.");
                Path parent = file;
                for (int i = splitted.length - 2; i >= 0; i--) {
                    parent = parent.getParent();
                    if (parent != null) {
                        if (!parent.getFileName().toString().equals(splitted[i])) {
                            return false;
                        }
                    } else {
                        return false;
                    }
                }
            }
            targetFile = file.toFile().getPath();
            return true;
        }

        return false;
    }

    @Override
    public FileVisitResult visitFile(Path file,
            BasicFileAttributes attrs) {
        if (!find(file)) {
            return FileVisitResult.CONTINUE;
        }

        return FileVisitResult.TERMINATE;
    }

    @Override
    public FileVisitResult preVisitDirectory(Path dir,
            BasicFileAttributes attrs) {
        if (!find(dir)) {
            return FileVisitResult.CONTINUE;
        }

        return FileVisitResult.TERMINATE;
    }

    @Override
    public FileVisitResult visitFileFailed(Path file,
            IOException exc) {
        System.err.println(exc);
        return FileVisitResult.CONTINUE;
    }
}
