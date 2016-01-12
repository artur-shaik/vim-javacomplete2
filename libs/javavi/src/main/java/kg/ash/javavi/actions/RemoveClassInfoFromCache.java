package kg.ash.javavi.actions;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import kg.ash.javavi.Javavi;
import kg.ash.javavi.cache.Cache;
import kg.ash.javavi.readers.FileClassLoader;
import kg.ash.javavi.searchers.ClassNameMap;

public class RemoveClassInfoFromCache extends ActionWithTarget {
    
    @Override
    public String perform(String[] args) {
        String target = parseTarget(args);
        if (Cache.getInstance().getClasses().containsKey(target)) {
            Cache.getInstance().getClasses().remove(target);
        }

        return "";
    }

}
