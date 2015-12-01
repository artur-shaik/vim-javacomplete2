package kg.ash.javavi.output;

import java.util.HashMap;
import kg.ash.javavi.Javavi;
import kg.ash.javavi.searchers.ClassMap;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class OutputClassPackagesTest {

    private String target = "Bar";
    private HashMap<String,ClassMap> classPackages;

    @Before
    public void Init() {
        Javavi.system.put("sources", "");
        ClassMap classMap = new ClassMap(target, ClassMap.CLASS);
        classMap.add("bar.baz", ClassMap.CLASSPATH, ClassMap.SUBPACKAGE);
        classMap.add("foo.bar", ClassMap.CLASSPATH, ClassMap.SUBPACKAGE);

        classPackages = new HashMap<>();
        classPackages.put(target, classMap);
    }

    @Test
    public void testCorrect() {
        Assert.assertEquals("['bar.baz.Bar','foo.bar.Bar',]", new OutputClassPackages(classPackages).get(target));
    }

    @Test
    public void testCorrectUknownTarget() {
        Assert.assertEquals("[]", new OutputClassPackages(classPackages).get("Baz"));
    }

    @Test
    public void testNullTarget() {
        Assert.assertEquals("[]", new OutputClassPackages(classPackages).get(null));
    }
    
    @Test
    public void testNullPackages() {
        Assert.assertEquals("[]", new OutputClassPackages(null).get(target));
    }
    
}
