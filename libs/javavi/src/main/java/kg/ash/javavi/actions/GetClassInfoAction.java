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
        boolean found = true;
        while (!seacher.find(target, sources)) {
            if (!target.contains(".")) {
                found = false;
                break;
            }

            target = target.substring(0, target.lastIndexOf("."));
        }

        if (found) {
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
