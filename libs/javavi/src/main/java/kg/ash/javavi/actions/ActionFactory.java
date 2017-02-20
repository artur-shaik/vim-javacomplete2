package kg.ash.javavi.actions;

public class ActionFactory {

    public static Action get(String action) {
        switch (action) {
            case "-E":
                return new GetClassInfoAction();
            case "-p":
                return new GetPackageInfoAction();
            case "-s":
                return new GetClassInfoFromSourceAction();
            case "-class-packages":
                return new GetClassPackagesAction();
            case "-similar-classes":
                return new FilterSimilarClassesAction();
            case "-similar-annotations":
                return new FilterSimilarAnnotationsAction();
            case "-D":
                return new ExecuteDaemonAction();
            case "-unused-imports":
                return new GetUnusedImportsAction();
            case "-missing-imports":
                return new GetMissingImportsAction();
            case "-clear-from-cache":
                return new RemoveClassInfoFromCache();
            case "-recompile-class":
                return new ClassRecompileAction();
            case "-collect-packages":
                return new CollectPackagesAction();
            case "-fetch-class-archives":
                return new GetClassesArchiveNamesAction();
            case "-class-info-by-content":
                return new ParseByContentAction();
            case "-get-debug-log-path":
                return new GetDebugLogPath();
            case "-version":
                return new GetAppVersion();
            case "-add-source-to-cache":
                return new AddClassToCacheAction();
        }

        return null;
    }
    
}
