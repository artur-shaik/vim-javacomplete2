package kg.ash.javavi;

import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.List;
import kg.ash.javavi.searchers.ClassSearcher;

public class TargetParser {

    private Pattern pattern = Pattern.compile("^(.*?)<(.*)>$");
    private List<String> typeArguments = new ArrayList<>();
    private String sources;

    public TargetParser(String sources) {
        this.sources = sources;
    }

    public String parse(String target) {
        typeArguments.clear();

        Matcher matcher = pattern.matcher(target);
        if (matcher.find()) {
            target = matcher.group(1);
            ClassSearcher seacher = new ClassSearcher();
            String ta = matcher.group(2);
            List<String> args = new ArrayList<>();
            int i = 0;
            int lbr = 0;
            int stidx = 0;
            while (i < ta.length()) {
                char c = ta.charAt(i);
                if (c == '<') {
                    lbr++;
                } else if (c == '>') {
                    lbr--;
                } else if (c == ',' && lbr == 0) {
                    ta = ta.substring(stidx, i - stidx) + "<_split_>" + ta.substring(i - stidx + 1, ta.length());
                    stidx = i;
                }

                i++;
            }

            for (String arguments : ta.split("<_split_>")) {
                arguments = arguments.replaceAll("(\\(|\\))", "");
                String[] argumentVariants = arguments.split("\\|");
                boolean added = false;
                for (String arg : argumentVariants) { 
                    Matcher argMatcher = pattern.matcher(arg);
                    boolean matchResult = argMatcher.find();
                    if (matchResult) {
                        arg = argMatcher.group(1);
                    }
                    if (seacher.find(arg.replaceAll("(\\[|\\])", ""), sources)) {
                        if (matchResult) {
                            typeArguments.add(String.format("%s<%s>", arg, argMatcher.group(2)));
                        } else {
                            typeArguments.add(arg);
                        }
                        added = true;
                        break;
                    }
                }

                if (!added) {
                    typeArguments.add("java.lang.Object");
                }
            }
        }

        return target;
    }

    public List<String> getTypeArguments() {
        return typeArguments;
    }

    public String getTypeArgumentsString() {
        if (typeArguments.isEmpty()) return "";

        StringBuilder builder = new StringBuilder("<");
        for (String arg : typeArguments) {
            builder.append(arg).append(",");
        }
        builder.setCharAt(builder.length() - 1, '>');
        return builder.toString();
    }

}
