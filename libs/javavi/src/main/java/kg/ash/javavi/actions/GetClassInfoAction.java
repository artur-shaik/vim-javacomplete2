package kg.ash.javavi.actions;

import kg.ash.javavi.clazz.SourceClass;
import kg.ash.javavi.output.OutputClassInfo;
import kg.ash.javavi.readers.ClassReader;
import kg.ash.javavi.searchers.ClassSearcher;

public class GetClassInfoAction extends ActionWithTarget {

    @Override
    public String perform(String[] args) {
        String target = parseTarget(args);

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
