package kg.ash.javavi.readers.source;

import com.github.javaparser.JavaParser;
import com.github.javaparser.ParseException;
import com.github.javaparser.TokenMgrException;
import com.github.javaparser.ast.CompilationUnit;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.StringReader;

import kg.ash.javavi.apache.logging.log4j.LogManager;
import kg.ash.javavi.apache.logging.log4j.Logger;

public class CompilationUnitCreator {

    public static final Logger logger = LogManager.getLogger();

    public static CompilationUnit createFromFile(String fileName) {
        try {
            return JavaParser.parse(new FileReader(fileName), true);
        } catch (TokenMgrException | ParseException | FileNotFoundException e) {
            logger.error(e, e);
            return null;
        }
    }

    public static CompilationUnit createFromContent(String content) {
        try {
            return JavaParser.parse(new StringReader(content), true);
        } catch (TokenMgrException | ParseException e) {
            logger.error(e, e);
            return null;
        }
    }

}
