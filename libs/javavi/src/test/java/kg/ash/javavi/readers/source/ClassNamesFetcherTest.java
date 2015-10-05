package kg.ash.javavi.readers.source;

import java.util.Set;

import org.junit.Assert;
import org.junit.Test;

import com.github.javaparser.ast.CompilationUnit;

public class ClassNamesFetcherTest {

    @Test
    public void testClassnamesFetch() throws Exception {
        CompilationUnit cu = CompilationUnitCreator.createFromFile("src/test/resources/kg/ash/javavi/ClassWithClasses.java");
        ClassNamesFetcher parser = new ClassNamesFetcher(cu);
        Set<String> result = parser.getNames();

        Assert.assertTrue(result.contains("BigDecimal"));
        Assert.assertTrue(result.contains("String"));
        Assert.assertTrue(result.contains("List"));
        Assert.assertTrue(result.contains("ArrayList"));
        Assert.assertTrue(result.contains("LinkedList"));
        Assert.assertEquals(5, result.size());
    }

}
