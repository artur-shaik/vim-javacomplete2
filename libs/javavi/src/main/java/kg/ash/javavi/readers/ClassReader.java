package kg.ash.javavi.readers;

import kg.ash.javavi.clazz.SourceClass;
import java.util.List;

public interface ClassReader {
    
    public SourceClass read(String fqn);

    public void setTypeArguments(List<String> typeArguments);

}
