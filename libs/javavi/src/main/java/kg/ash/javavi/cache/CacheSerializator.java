package kg.ash.javavi.cache;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.HashMap;

import kg.ash.javavi.apache.logging.log4j.LogManager;
import kg.ash.javavi.apache.logging.log4j.Logger;

import kg.ash.javavi.Javavi;

public class CacheSerializator {

    public static final Logger logger = LogManager.getLogger();

    private String base = null;
    private String project = null;

    public CacheSerializator() {
        if (Javavi.system.containsKey("base")) {
            base = Javavi.system.get("base");
            project = "default";
            if (Javavi.system.containsKey("project")) {
                project = Javavi.system.get("project");
            }

            File cacheFile = new File(base + File.separator + "cache");
            if (!cacheFile.exists()) {
                cacheFile.mkdir();
            }
        }

    }
    
    public void saveCache(String name, Object data) {
        if (base != null) {
            try (
                FileOutputStream fout = new FileOutputStream(
                    base + File.separator + 
                    "cache" + File.separator + 
                    name + "_" + project + ".dat");
                ObjectOutputStream oos = new ObjectOutputStream(fout)
            ) {
                oos.writeObject(data);
            } catch (Throwable e) {
                logger.error(e);
            }
        }
    }

    public Object loadCache(String name) {
        if (base != null) {
            try (
                FileInputStream fin = new FileInputStream(
                    base + File.separator + 
                    "cache" + File.separator + 
                    name + "_" + project + ".dat");
                ObjectInputStream ois = new ObjectInputStream(fin)
            ) {
                return ois.readObject();
            } catch (Throwable e) {}
        }

        return null;
    }

}
