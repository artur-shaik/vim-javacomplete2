package kg.ash.javavi.searchers;

public class PackageEntry {

    private String entry;
    private int source;

    public PackageEntry(String entry, int source) {
        this.entry = entry;
        this.source = source;
    }

    public String getEntry() {
        return entry;
    }

    public int getSource() {
        return source;
    }

    @Override
    public String toString() {
        return String.format("{%s, %d}", entry, source);
    }
    
}
