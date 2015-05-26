package kg.ash.javavi;

import java.io.DataInputStream;
import java.io.File;
import java.io.IOException;
import java.io.PrintStream;
import java.lang.StringBuffer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Locale;
import java.util.StringTokenizer;
import java.util.zip.ZipFile;

public class Javavi {

    static final String VERSION	= "2.0.0";

    static final int STRATEGY_ALPHABETIC	= 128;
    static final int STRATEGY_HIERARCHY		= 256;
    static final int STRATEGY_DEFAULT		= 512;

    static final String KEY_NAME		= "'n':";	// "'name':";
    static final String KEY_TYPE		= "'t':";	// "'type':";
    static final String KEY_MODIFIER		= "'m':";	// "'modifier':";
    static final String KEY_PARAMETERTYPES	= "'p':";	// "'parameterTypes':";
    static final String KEY_RETURNTYPE		= "'r':";	// "'returnType':";
    static final String KEY_DESCRIPTION		= "'d':";	// "'description':";
    static final String KEY_DECLARING_CLASS	= "'c':";	// "'declaringclass':";

    static final int INDEX_PACKAGE = 0;
    static final int INDEX_CLASS = 1;

    static String NEWLINE = "";

    static HashMap<String,SourceClass> cachedClasses = new HashMap<>();
    static HashMap<String,StringBuilder[]> cachedPackages = new HashMap<>();
    static HashMap<String,List<String>> cachedClassPackages = new HashMap<>();

    static boolean debugMode = false;

    static void debug(Object s) {
        if (debugMode)
            System.out.println(s);
    }

    static void output(String s) {
        if (!debugMode)
            System.out.print(s);
    }

    private static void usage() {
        System.out.println("Reflection and parsing for javacomplete (" + VERSION + ")");
        System.out.println("  java [-classpath] kg.ash.javavi.Javavi [-sources sourceDirs] [-jars jarDirs] [-h] [-v] [-p] [-E] [name]");
        System.out.println("Options:");
        System.out.println("  -p	        check package existed and read package children");
        System.out.println("  -E	        check class existed and read class information");
        System.out.println("  -h	        help");
        System.out.println("  -v	        version");
        System.out.println("  -sources      sources directory");
        System.out.println("  -jars         jars directories");
    }

    private static final int COMMAND__CLASS_INFO = 1;
    private static final int COMMAND__PACKAGESLIST = 2;
    private static final int COMMAND__SOURCE_PATH_CLASS_INFO = 3;
    private static final int COMMAND__SIMILAR_CLASSES = 4;
    private static final int COMMAND__CLASSNAME_PACKAGES = 5;
    private static final int COMMAND__EXECUTE_DAEMON = 6;


    static String sources = "";
    static String jars = "";
    private static Daemon daemon = null;

    public static void main( String[] args ) throws Exception {
        String response = makeResponse(args);

        debug(response);
        output(response);
    }

    public static String makeResponse(String[] args) {

        String target = "";
        int command = 0;
        int daemonPort = 0;

        for (int i = 0; i < args.length; i++) {
            String arg = args[i];
            debug(arg);
            switch (arg) {
                case "-h":
                    usage();
                    return "";
                case "-v":
                    return "Reflection and parsing for javavi vim plugin (" + VERSION + ")";
                case "-E":
                    command = COMMAND__CLASS_INFO;
                    break;
                case "-p":
                    command = COMMAND__PACKAGESLIST;
                    break;
                case "-s":
                    command = COMMAND__SOURCE_PATH_CLASS_INFO;
                    break;
                case "-class-packages":
                    command = COMMAND__CLASSNAME_PACKAGES;
                    break;
                case "-similar-classes":
                    command = COMMAND__SIMILAR_CLASSES;
                    break;
                case "-sources": 
                    sources = args[++i];
                    debug(sources);
                    break;
                case "-jars": 
                    jars = args[++i];
                    debug(jars);
                    break;
                case "-d":
                    Javavi.debugMode = true;
                    break;
                case "-D":
                    command = COMMAND__EXECUTE_DAEMON;
                    daemonPort = Integer.parseInt(args[++i]);
                    break;
                default:
                    target += arg;
                    break;
            }
        }

        if (debugMode) NEWLINE = "\n";

        String result = "";
        if (command == COMMAND__CLASS_INFO){
            ClassSearcher seacher = new ClassSearcher();
            if (seacher.find(target, sources)) {
                SourceClass clazz = seacher.getReader().read(target);
                if (clazz != null) {
                    result = new OutputBuilder().outputClassInfo(clazz);
                }
            }

        } else if (command == COMMAND__SOURCE_PATH_CLASS_INFO) {
            Parser parser = new Parser(sources, target);
            SourceClass clazz = parser.read(null);
            if (clazz != null) {
                result = new OutputBuilder().outputClassInfo(clazz);
            }

        } else if (command == COMMAND__CLASSNAME_PACKAGES) {
            if (cachedPackages.isEmpty()) {
                new PackagesSearcher(jars, sources).collectPackages(cachedPackages, cachedClassPackages);
            }
            return new OutputBuilder().outputClassPackages(target);
            
        } else if (command == COMMAND__SIMILAR_CLASSES) {
            if (cachedPackages.isEmpty()) {
                new PackagesSearcher(jars, sources).collectPackages(cachedPackages, cachedClassPackages);
            }
            return new OutputBuilder().outputSimilarClasses(target);

        } else if (command == COMMAND__PACKAGESLIST) {
            if (cachedPackages.isEmpty()) {
                new PackagesSearcher(jars, sources).collectPackages(cachedPackages, cachedClassPackages);
            }
            result = new OutputBuilder().outputPackageInfo(target);

        } else if (command == COMMAND__EXECUTE_DAEMON) {
            if (daemon == null) {
                debug("Starting daemon mode");
                daemon = new Daemon(daemonPort);
                daemon.start();
            }

        }

        return result;
    }

}
