package kg.ash.javavi.actions;

public interface Action {

    public static final int COMMAND__CLASS_INFO = 1;
    public static final int COMMAND__PACKAGESLIST = 2;
    public static final int COMMAND__SOURCE_PATH_CLASS_INFO = 3;
    public static final int COMMAND__SIMILAR_CLASSES = 4;
    public static final int COMMAND__SIMILAR_ANNOTATIONS = 7;
    public static final int COMMAND__CLASSNAME_PACKAGES = 5;
    public static final int COMMAND__EXECUTE_DAEMON = 6;

    public String perform(String[] args);
    
}
