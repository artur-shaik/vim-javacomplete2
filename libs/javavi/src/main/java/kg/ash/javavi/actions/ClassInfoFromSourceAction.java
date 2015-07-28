package kg.ash.javavi.actions;

import kg.ash.javavi.Javavi;
import kg.ash.javavi.clazz.SourceClass;
import kg.ash.javavi.output.OutputClassInfo;
import kg.ash.javavi.readers.Parser;

public class ClassInfoFromSourceAction implements Action {

    @Override
    public String perform(String[] args) {
        String sources = Javavi.system.get("sources");
        String target = args[args.length - 1];
        Parser parser = new Parser(sources, target);
        SourceClass clazz = parser.read(null);
        if (clazz != null) {
            return new OutputClassInfo().get(clazz);
        }

        return "";
    }
    
}
