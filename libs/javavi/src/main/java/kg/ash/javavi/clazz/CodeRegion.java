package kg.ash.javavi.clazz;

public class CodeRegion {
    
    private int beginLine = -1;
    private int beginColumn = -1;
    private int endLine = -1;
    private int endColumn = -1;

    public CodeRegion() {

    }

    public CodeRegion(int beginLine, int beginColumn, int endLine, int endColumn) {
        this.beginLine = beginLine;
        this.beginColumn = beginColumn;
        this.endLine = endLine;
        this.endColumn = endColumn;
    }

    public void setBeginLine(int beginLine) {
        this.beginLine = beginLine;
    }

    public int getBeginLine() {
        return beginLine;
    }

    public void setBeginColumn(int beginColumn) {
        this.beginColumn = beginColumn;
    }

    public int getBeginColumn() {
        return beginColumn;
    }

    public void setEndLine(int endLine) {
        this.endLine = endLine;
    }

    public int getEndLine() {
        return endLine;
    }

    public void setEndColumn(int endColumn) {
        this.endColumn = endColumn;
    }

    public int getEndColumn() {
        return endColumn;
    }

}
