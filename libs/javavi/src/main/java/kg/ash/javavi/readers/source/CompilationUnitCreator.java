package kg.ash.javavi.readers.source;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.StringReader;

import com.github.javaparser.JavaParser;
import com.github.javaparser.ParseException;
import com.github.javaparser.TokenMgrError;
import com.github.javaparser.ast.CompilationUnit;

import kg.ash.javavi.Javavi;

public class CompilationUnitCreator {

    public static CompilationUnit createFromFile(String fileName) {
        try {
            return JavaParser.parse(new FileReader(fileName), true);
        } catch (TokenMgrError | ParseException | FileNotFoundException e) {
            Javavi.debug(e);
            return null;
        }
    }

    public static CompilationUnit createFromContent(String content) {
        try {
            return JavaParser.parse(new StringReader(content), true);
        } catch (TokenMgrError | ParseException e) {
            Javavi.debug(e);
            return null;
        }
    }

}
