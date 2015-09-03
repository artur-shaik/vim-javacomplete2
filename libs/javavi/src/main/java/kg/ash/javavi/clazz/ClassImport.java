package kg.ash.javavi.clazz;

public class ClassImport {
    private String name;
    private boolean isStatic = false;
    private boolean isAsterisk = false;

    public ClassImport(String name, boolean isStatic, boolean isAsterisk) {
        this.name = name;
        this.isStatic = isStatic;
        this.isAsterisk = isAsterisk;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setIsStatic(boolean isStatic) {
        this.isStatic = isStatic;
    }

    public boolean isStatic() {
        return isStatic;
    }

    public void setIsAsterisk(boolean isAsterisk) {
        this.isAsterisk = isAsterisk;
    }

    public boolean isAsterisk() {
        return isAsterisk;
    }

    public String getHead() {
        return name.substring(0, name.lastIndexOf("."));
    }

    public String getTail() {
        if (name.contains(".")) {
            String[] splitted = name.split("\\.");
            return splitted[splitted.length - 1];
        }

        return name;
    }

    public String toString() {
        return String.format("%s, isStatic: %b", name, isStatic);
    }
}
