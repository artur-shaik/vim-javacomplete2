package kg.ash.javavi;

import java.util.HashMap;

import kg.ash.javavi.actions.Action;
import kg.ash.javavi.actions.ActionFactory;
import kg.ash.javavi.clazz.SourceClass;

public class Javavi {

    static final String VERSION	= "2.3.5";

    public static String NEWLINE = "";

    static boolean debugMode = false;

    public static void debug(Object s) {
        if (debugMode)
            System.out.println(s);
    }

    static void output(String s) {
        if (!debugMode)
            System.out.print(s);
    }

    private static void usage() {
        version();
        System.out.println("  java [-classpath] kg.ash.javavi.Javavi [-sources sourceDirs] [-h] [-v] [-d] [-D port] [action]");
        System.out.println("Options:");
        System.out.println("  -h	        help");
        System.out.println("  -v	        version");
        System.out.println("  -sources      sources directory");
        System.out.println("  -d            enable debug mode");
        System.out.println("  -D port       start daemon on specified port");
    }

    private static void version() {
        System.out.println("Reflection and parsing for javavi " +
                "vim plugin (" + VERSION + ")");
    }

    public static HashMap<String,String> system = new HashMap<>();
    public static Daemon daemon = null;

    public static void main( String[] args ) throws Exception {
        String response = makeResponse(args);

        debug(response);
        output(response);
    }

    public static String makeResponse(String[] args) {

        Action action = null;
        boolean asyncRun = false;
        for (int i = 0; i < args.length; i++) {
            String arg = args[i];
            debug(arg);
            switch (arg) {
                case "-h":
                    usage();
                    return "";
                case "-v":
                    version();
                    return "";
                case "-sources":
                    system.put("sources", args[++i]);
                    break;
                case "-n":
                    NEWLINE = "\n";
                    break;
                case "-d":
                    Javavi.debugMode = true;
                    break;
                case "-base":
                    system.put("base", args[++i]);
                    break;
                case "-project":
                    system.put("project", args[++i]);
                    break;
                case "-compiler":
                    system.put("compiler", args[++i]);
                    break;
                case "-async":
                    asyncRun = true;
                    break;
                default:
                    if (action == null) {
                        action = ActionFactory.get(arg);
                    }
            }

            if (action != null) {
                break;
            }
        }

        String result = "";
        if (action != null) {
            if (asyncRun) {
                final Action a = action;
                new Thread(() -> { a.perform(args); }).start();
            } else {
                result = action.perform(args);
            }
        }

        return result;
    }

}
