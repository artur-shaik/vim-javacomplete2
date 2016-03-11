package kg.ash.javavi.actions;

import kg.ash.javavi.Javavi;
import kg.ash.javavi.TargetParser;

public abstract class ActionWithTarget implements Action {

    protected TargetParser targetParser;
    protected String sources;

    public ActionWithTarget() {
        if (Javavi.system.containsKey("sources")) {
            sources = Javavi.system.get("sources").replace('\\', '/');
        } else {
            sources = "";
        }
        targetParser = new TargetParser(sources);
    }

    protected String parseTarget(String[] args) {
        if (args.length > 0) {
            return targetParser.parse(args[args.length - 1]);
        } else {
            return "";
        }
    }
    
}
