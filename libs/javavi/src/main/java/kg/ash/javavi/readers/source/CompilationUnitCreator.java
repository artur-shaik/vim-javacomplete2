package kg.ash.javavi.readers.source;

import com.github.javaparser.JavaParser;
import java.io.FileReader;
import java.io.Reader;
import java.io.StringReader;
import com.github.javaparser.ast.CompilationUnit;

public class CompilationUnitCreator {

    public static CompilationUnit createFromFile(String fileName) {
        try {
            return JavaParser.parse(new FileReader(fileName), true);
        } catch (Exception e) {
            return null;
        }
    }

    public static CompilationUnit createFromContent(String content) {
        try {
            return JavaParser.parse(new StringReader(content), true);
        } catch (Exception e) {
            return null;
        }
    }
    
}
