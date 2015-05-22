package kg.ash.javavi;

import java.io.File;
import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitResult;
import java.nio.file.Path;
import java.nio.file.PathMatcher;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.List;
import java.util.ArrayList;

public class ArchFileFinder extends SimpleFileVisitor<Path> {

    private final List<PathMatcher> matchers = new ArrayList<>();
    private List<String> resultList = new ArrayList<>();

    public ArchFileFinder(List<String> patterns) {
        for (String pattern : patterns) {
            matchers.add(FileSystems.getDefault().getPathMatcher("glob:" + pattern));
        }
    }

    public List<String> getResultList() {
        return resultList;
    }

    private void find(Path file) {
        Path name = file.getFileName();
        if (name != null) {
            for (PathMatcher matcher : matchers) {
                if (matcher.matches(name)) {
                    resultList.add(file.toFile().getPath());
                    return;
                }
            }
        }
    }

    @Override
    public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) {
        find(file);
        return FileVisitResult.CONTINUE;
    }

    @Override
    public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) {
        return FileVisitResult.CONTINUE;
    }

    @Override
    public FileVisitResult visitFileFailed(Path file, IOException exc) {
        System.err.println(exc);
        return FileVisitResult.CONTINUE;
    }
}
