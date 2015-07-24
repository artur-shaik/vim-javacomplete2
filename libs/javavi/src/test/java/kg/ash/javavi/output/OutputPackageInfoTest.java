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
        ClassMap classMap = new ClassMap(target);
        classMap.add("baz", ClassMap.CLASSPATH, ClassMap.SUBPACKAGE);
        classMap.add("bax", ClassMap.CLASSPATH, ClassMap.SUBPACKAGE);
        classMap.add("Bat", ClassMap.CLASSPATH, ClassMap.CLASS);

        classPackages = new HashMap<>();
        classPackages.put(target, classMap);
    }

    @Test
    public void testCorrect() {
        OutputPackageInfo opi = new OutputPackageInfo(target);
        String result = opi.get(classPackages);

        Assert.assertEquals(String.format("{'%s':{'tag':'PACKAGE','subpackages':['baz','bax',],'classes':['Bat',]},}", target), result);
    }
    
    @Test
    public void testCorrectUknownTarget() {
        OutputPackageInfo opi = new OutputPackageInfo("foo.baa");
        String result = opi.get(classPackages);

        Assert.assertEquals("{}", result);
    }
    
    @Test
    public void testNullTarget() {
        OutputPackageInfo opi = new OutputPackageInfo(null);
        String result = opi.get(classPackages);

        Assert.assertEquals("{}", result);
    }
    
    @Test
    public void testNullPackages() {
        OutputPackageInfo opi = new OutputPackageInfo(target);
        String result = opi.get(null);

        Assert.assertEquals("{}", result);
    }
}
