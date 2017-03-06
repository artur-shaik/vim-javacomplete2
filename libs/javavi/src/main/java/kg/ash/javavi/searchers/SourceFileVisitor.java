package kg.ash.javavi.searchers;

import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitResult;
import java.nio.file.Path;
import java.nio.file.PathMatcher;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;

import kg.ash.javavi.apache.logging.log4j.LogManager;
import kg.ash.javavi.apache.logging.log4j.Logger;

public class SourceFileVisitor extends SimpleFileVisitor<Path> {

    public static final Logger logger = 
        LogManager.getLogger();

    private final PathMatcher matcher;
    private String targetFile = null;
    private String pattern = null;

    public SourceFileVisitor(String pattern) {
        if (pattern == null) pattern = "";

        String path;
        if (pattern.contains(".")) {
            String[] splitted = pattern.split("\\.");
            path = splitted[splitted.length - 1];
        } else {
            path = pattern;
        }

        logger.info("visit source: {}", path);
        matcher = FileSystems.getDefault()
                .getPathMatcher(String.format("glob:%s.java", path));

        this.pattern = pattern;
    }

    public String getTargetFile() {
        return targetFile;
    }

    private boolean find(Path file) {
        Path name = file.getFileName();
        if (name != null && matcher.matches(name)) {
            if (pattern.contains(".")) {
                return checkPattern(file);
            }
            return true;
        }

        return false;
    }

    private boolean checkPattern(Path file) {
        String[] splitted = pattern.split("\\.");
        for (int i = splitted.length - 2; i >= 0; i--) {
            file = file.getParent();
            if (file != null) {
                String filename = file.getFileName().toString();
                if (!filename.equals(splitted[i])) {
                    return false;
                }
            } else {
                return false;
            }
        }
        return true;
    }

    @Override
    public FileVisitResult visitFile(Path file,
            BasicFileAttributes attrs) {
        if (!find(file)) {
            return FileVisitResult.CONTINUE;
        }

        targetFile = file.toFile().getPath().replace('\\', '/');

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
        return FileVisitResult.CONTINUE;
    }
}
