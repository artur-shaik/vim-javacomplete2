package kg.ash.javavi.actions;

import kg.ash.javavi.Javavi;
import kg.ash.javavi.TargetParser;

public abstract class ActionWithTarget implements Action {

    protected TargetParser targetParser;
    protected String sources;

    public ActionWithTarget() {
        sources = Javavi.system.get("sources").replace('\\', '/');
        targetParser = new TargetParser(sources);
    }

    protected String parseTarget(String[] args) {
        return targetParser.parse(args[args.length - 1]);
    }
    
}
