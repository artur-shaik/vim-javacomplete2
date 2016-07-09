package kg.ash.javavi.actions;

import com.github.javaparser.ast.CompilationUnit;

import java.io.UnsupportedEncodingException;
import java.util.Base64;

import kg.ash.javavi.Javavi;
import kg.ash.javavi.actions.Action;
import kg.ash.javavi.output.OutputClassInfo;
import kg.ash.javavi.readers.Parser;
import kg.ash.javavi.readers.source.CompilationUnitCreator;

public class ParseByContentAction implements Action {

    @Override
    public String perform(String[] args) {
        try {
            String targetClass = getArg(args, "-target");
            String base64Content = getArg(args, "-content");
            String content = new String(Base64.getDecoder().decode(base64Content), "UTF-8");
            
            String sources;
            if (Javavi.system.containsKey("sources")) {
                sources = Javavi.system.get("sources").replace('\\', '/');
            } else {
                sources = "";
            }

            Parser parser = new Parser(sources);
            parser.setSourceContent(content);
            return new OutputClassInfo().get(parser.read(targetClass));
        } catch (UnsupportedEncodingException ex) {
            return ex.getMessage();
        }
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
