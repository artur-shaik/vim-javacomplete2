package kg.ash.javavi.actions;

import kg.ash.javavi.Javavi;
import kg.ash.javavi.searchers.ClassNameMap;
import mockit.Mock;
import mockit.MockUp;
import mockit.integration.junit4.JMockit;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(JMockit.class)
public class ClassRecompileActionTest {

    @Test
    public void testRecompilationCommandBuild() {

        final ClassNameMap classMap = new ClassNameMap("foo.bar.Test");
        classMap.setJavaFile("/path/to/src/foo/bar/Test.java");
        classMap.setClassFile("/another/path/target/foo/bar/Test.class");

        new MockUp<ClassRecompileAction>() {
            @Mock
            private ClassNameMap findClass(String className, String name) {
                return classMap;
            }

            @Mock
            private void execute(String command) {
                Assert.assertEquals("javac -cp " + System.getProperty("java.class.path") + " -d /another/path/target " + classMap.getJavaFile(), command);
            }
        };

        Javavi.system.put("compiler", "javac");
        new ClassRecompileAction().perform(new String[]{classMap.getName()});

    }
    
    @Test
    public void testBadTargetClass() {

        final ClassNameMap classMap = new ClassNameMap("foo.bar.Test");
        classMap.setJavaFile("/path/to/src/foo/bar/Test.java");
        classMap.setClassFile("/bar/Test.class");

        new MockUp<ClassRecompileAction>() {
            @Mock
            private ClassNameMap findClass(String className, String name) {
                return classMap;
            }

            @Mock
            private void execute(String command) {
                Assert.fail();
            }
        };

        new ClassRecompileAction().perform(new String[]{classMap.getName()});

    }
    
    @Test
    public void testBadSrcFile() {

        final ClassNameMap classMap = new ClassNameMap("baz.Test");
        classMap.setJavaFile("/bar/baz/Test.java");
        classMap.setClassFile("/another/path/target/foo/bar/Test.class");

        new MockUp<ClassRecompileAction>() {
            @Mock
            private ClassNameMap findClass(String className, String name) {
                return classMap;
            }

            @Mock
            private void execute(String command) {
                Assert.fail();
            }
        };

        new ClassRecompileAction().perform(new String[]{classMap.getName()});

    }
    
}
