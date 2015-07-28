package kg.ash.javavi.actions;

import kg.ash.javavi.Javavi;
import kg.ash.javavi.TargetParser;
import kg.ash.javavi.clazz.SourceClass;
import kg.ash.javavi.readers.ClassReader;
import kg.ash.javavi.searchers.ClassSearcher;
import kg.ash.javavi.output.OutputClassInfo;

public class GetClassInfoAction implements Action {

    private String sources;

    public GetClassInfoAction() {
        sources = Javavi.system.get("sources");
    }

    @Override
    public String perform(String[] args) {
        TargetParser targetParser = new TargetParser(sources);
        String target = targetParser.parse(args[args.length - 1]);

        ClassSearcher seacher = new ClassSearcher();
        if (seacher.find(target, sources)) {
            ClassReader reader = seacher.getReader();
            reader.setTypeArguments(targetParser.getTypeArguments());
            SourceClass clazz = reader.read(target);
            if (clazz != null) {
                return new OutputClassInfo().get(clazz);
            }
        }

        return "";
    }
    
}
