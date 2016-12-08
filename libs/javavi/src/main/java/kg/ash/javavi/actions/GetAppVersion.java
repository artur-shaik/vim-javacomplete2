package kg.ash.javavi.actions;

import kg.ash.javavi.Javavi;

public class GetAppVersion implements Action {

    @Override
    public String perform(String[] string) {
        return Javavi.VERSION;
    }
}
