package kg.ash.javavi.actions;

import com.github.javaparser.ast.CompilationUnit;
import java.util.Set;
import kg.ash.javavi.readers.source.ClassNamesFetcher;
import kg.ash.javavi.readers.source.CompilationUnitCreator;

public abstract class ImportsAction implements Action {

    protected Set<String> classnames;
    protected CompilationUnit compilationUnit;

    @Override
    public String perform(String[] args) {
        String content = getContent(args).replaceAll("<_Javacomplete-linebreak>".toLowerCase(), "\n");

        compilationUnit = CompilationUnitCreator.createFromContent(content);
        if (compilationUnit == null) return "Couldn't parse file";

        ClassNamesFetcher classnamesFetcher = new ClassNamesFetcher(compilationUnit);
        classnames = classnamesFetcher.getNames();

        return action();
    }
    
    private String getContent(String[] args) {
        for (int i = 0; i < args.length; i++) {
            if (args[i].equals("-content")) {
                return args[i + 1];
            }
        }

        return "";
    }

    public abstract String action();

}
