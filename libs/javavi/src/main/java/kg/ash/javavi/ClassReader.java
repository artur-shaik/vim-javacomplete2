package kg.ash.javavi;

import java.util.List;

public interface ClassReader {
    
    public SourceClass read(String fqn);

    public void setTypeArguments(List<String> typeArguments);

}
