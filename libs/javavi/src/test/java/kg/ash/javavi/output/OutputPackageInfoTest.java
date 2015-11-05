package kg.ash.javavi.output;

import java.util.HashMap;
import kg.ash.javavi.searchers.ClassMap;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class OutputPackageInfoTest {

    private String target = "foo.bar";
    private HashMap<String,ClassMap> classPackages;

    @Before
    public void Init() {
        ClassMap classMap = new ClassMap(target, ClassMap.CLASS);
        classMap.add("baz", ClassMap.CLASSPATH, ClassMap.SUBPACKAGE);
        classMap.add("bax", ClassMap.CLASSPATH, ClassMap.SUBPACKAGE);
        classMap.add("Bat", ClassMap.CLASSPATH, ClassMap.CLASS);

        classPackages = new HashMap<>();
        classPackages.put(target, classMap);
    }

    @Test
    public void testCorrect() {
        OutputPackageInfo opi = new OutputPackageInfo(classPackages);
        String result = opi.get(target);

        Assert.assertEquals(String.format("{'%s':{'tag':'PACKAGE','subpackages':['bax','baz',],'classes':['Bat',]},}", target), result);
    }
    
    @Test
    public void testCorrectUknownTarget() {
        Assert.assertEquals("{}", new OutputPackageInfo(classPackages).get("foo.baa"));
    }
    
    @Test
    public void testNullTarget() {
        Assert.assertEquals("{}", new OutputPackageInfo(classPackages).get(null));
    }
    
    @Test
    public void testNullPackages() {
        Assert.assertEquals("{}", new OutputPackageInfo(null).get(target));
    }
}
