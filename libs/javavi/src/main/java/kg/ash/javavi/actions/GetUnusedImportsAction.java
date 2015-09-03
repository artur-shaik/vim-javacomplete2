package kg.ash.javavi.actions;

public class GetUnusedImportsAction implements Action {

    @Override
    public String perform(String[] args) {
        return "";
    }

    private String getContent(String[] args) {
        for (int i = 0; i < args.length; i++) {
            if (args[i] == "-content") {
                return args[i + 1];
            }
        }

        return "";
    }
    
}
