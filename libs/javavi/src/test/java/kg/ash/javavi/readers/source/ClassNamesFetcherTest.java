package kg.ash.javavi.readers.source;

import com.github.javaparser.ast.CompilationUnit;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.junit.Assert;
import org.junit.Test;

public class ClassNamesFetcherTest {

    private String testClassDeclarationPath = 
        "src/test/resources/kg/ash/javavi/ClassWithClasses.java";
    private String fetcherTestClassdeclarationPath = 
        "src/test/resources/kg/ash/javavi/ResourceClassForClassFetcherTest.java";

    @Test
    public void testClassnamesFetch() throws Exception {
        CompilationUnit cu = CompilationUnitCreator
            .createFromFile(testClassDeclarationPath);
        ClassNamesFetcher parser = new ClassNamesFetcher(cu);
        Set<String> result = parser.getNames();

        Assert.assertTrue(result.contains("BigDecimal"));
        Assert.assertTrue(result.contains("String"));
        Assert.assertTrue(result.contains("List"));
        Assert.assertTrue(result.contains("ArrayList"));
        Assert.assertTrue(result.contains("LinkedList"));
        Assert.assertEquals(5, result.size());
    }

    @Test
    public void testClassnamesFetchComplex() {
        String waitFor = "UserTransaction, TestException, WebService, " 
            + "HashMap, TestResponse, Resource, TestClass, String, " 
            + "Logger, WebMethod, TestClassForbiddenException, Long, " 
            + "EJB, BeanClass1, InterceptorRefs, InterceptorRef, BeanClass2, "
            + "WebParam, HashSet, Set, List, Map, Attr, ArrayList, HashLine, "
            + "SomeClass, unusualClassName, FakeAttr, StaticClassName, " 
            + "AnotherStatic, ParentAnnotation, ChildAnnotation, format, "
            + "AnnotationForConstractor";
        Set<String> waitForList = new HashSet<String>();
        waitForList.addAll(Arrays.asList(waitFor.split(", ")));

        CompilationUnit cu = CompilationUnitCreator
            .createFromFile(fetcherTestClassdeclarationPath);
        ClassNamesFetcher parser = new ClassNamesFetcher(cu);
        Set<String> result = parser.getNames();

        Assert.assertEquals(waitForList, result);
    }

}
