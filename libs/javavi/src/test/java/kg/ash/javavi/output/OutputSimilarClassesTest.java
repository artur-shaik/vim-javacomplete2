package kg.ash.javavi.output;

import java.util.HashMap;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import kg.ash.javavi.searchers.ClassMap;

public class OutputSimilarClassesTest {

    private String target = "Bar";
    private HashMap<String,ClassMap> classPackages;

    @Before
    public void Init() {
        classPackages = new HashMap<>();

        ClassMap classMap = new ClassMap("Barabaz", ClassMap.CLASS);
        classMap.add("bar", ClassMap.CLASSPATH, ClassMap.SUBPACKAGE);
        classPackages.put("Barabaz", classMap);

        classMap = new ClassMap("Bara", ClassMap.CLASS);
        classMap.add("bar.bara", ClassMap.CLASSPATH, ClassMap.SUBPACKAGE);
        classPackages.put("Bara", classMap);

        classMap = new ClassMap("Bazaraz", ClassMap.CLASS);
        classMap.add("bar.baz", ClassMap.CLASSPATH, ClassMap.SUBPACKAGE);
        classPackages.put("Bazaraz", classMap);

        classMap = new ClassMap("Foobar", ClassMap.CLASS);
        classMap.add("bar.bas", ClassMap.CLASSPATH, ClassMap.SUBPACKAGE);
        classPackages.put("Foobar", classMap);
    }
    
    @Test
    public void testCorrect() {
        String result = new OutputSimilarClasses(classPackages).get(target);

        Assert.assertEquals("[{'word':'Bara', 'menu':'bar.bara', 'type': 'c'},{'word':'Barabaz', 'menu':'bar', 'type': 'c'},]", result);
    }

    @Test
    public void testCorrectUknownTarget() {
        Assert.assertEquals("[]", new OutputSimilarClasses(classPackages).get("Tar"));
    }

    @Test
    public void testNullTarget() {
        Assert.assertEquals("[]", new OutputSimilarClasses(classPackages).get(null));
    }

    @Test
    public void testNullPackages() {
        Assert.assertEquals("[]", new OutputSimilarClasses(null).get(target));
    }

}
