package kg.ash.javavi.actions;

import java.util.HashMap;

import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;

import kg.ash.javavi.searchers.ClassNameMap;
import kg.ash.javavi.searchers.JavaClassMap;
import mockit.Mock;
import mockit.MockUp;
import mockit.integration.junit4.JMockit;

@RunWith(JMockit.class)
public class GetClassesArchiveNamesActionTest {

    @Test
    public void testArchiveNamesFetch() {
        new MockUp<GetClassesArchiveNamesAction>() {
            @Mock
            private HashMap<String, JavaClassMap> getClassPackages() {
                HashMap<String, JavaClassMap> map = new HashMap<>();
                JavaClassMap jc = new ClassNameMap("List");
                jc.add("java.util", JavaClassMap.SOURCETYPE_CLASSPATH, JavaClassMap.TYPE_SUBPACKAGE, "/dir/lib.jar");
                map.put("List", jc);
                jc = new ClassNameMap("HashMap");
                jc.add("java.util", JavaClassMap.SOURCETYPE_CLASSPATH, JavaClassMap.TYPE_SUBPACKAGE, "/dir/lib.jar");
                map.put("HashMap", jc);
                return map;
            }
        };
        
        GetClassesArchiveNamesAction action = new GetClassesArchiveNamesAction();
        String result = action.perform(new String[]{"java.util.List,java.util.HashMap"});
        Assert.assertEquals("[['/dir/lib.jar',['java.util.List','java.util.HashMap',]],]", result);
    }

    @Test
    public void testNoResult() {
        new MockUp<GetClassesArchiveNamesAction>() {
            @Mock
            private HashMap<String, JavaClassMap> getClassPackages() {
                return new HashMap<>();
            }
        };
        
        GetClassesArchiveNamesAction action = new GetClassesArchiveNamesAction();
        String result = action.perform(new String[]{"java.util.List,java.util.HashMap"});
        Assert.assertEquals("[]", result);
    }

    @Test
    public void testEmptyRequest() {
        new MockUp<GetClassesArchiveNamesAction>() {
            @Mock
            private HashMap<String, JavaClassMap> getClassPackages() {
                return new HashMap<>();
            }
        };
        
        GetClassesArchiveNamesAction action = new GetClassesArchiveNamesAction();
        String result = action.perform(new String[]{""});
        Assert.assertEquals("[]", result);
    }

    @Test
    public void testNoArgs() {
        new MockUp<GetClassesArchiveNamesAction>() {
            @Mock
            private HashMap<String, JavaClassMap> getClassPackages() {
                return new HashMap<>();
            }
        };
        
        GetClassesArchiveNamesAction action = new GetClassesArchiveNamesAction();
        String result = action.perform(new String[0]);
        Assert.assertEquals("[]", result);
    }
}
