package kg.ash.javavi.output;

import java.util.HashMap;
import kg.ash.javavi.searchers.ClassMap;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class OutputClassPackagesTest {

    private String target = "Bar";
    private HashMap<String,ClassMap> classPackages;

    @Before
    public void Init() {
        ClassMap classMap = new ClassMap(target);
        classMap.add("bar.baz", ClassMap.CLASSPATH, ClassMap.SUBPACKAGE);
        classMap.add("foo.bar", ClassMap.CLASSPATH, ClassMap.SUBPACKAGE);

        classPackages = new HashMap<>();
        classPackages.put(target, classMap);
    }

    @Test
    public void testCorrect() {
        Assert.assertEquals("['foo.bar.Bar','bar.baz.Bar',]", new OutputClassPackages(classPackages).get(target));
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
