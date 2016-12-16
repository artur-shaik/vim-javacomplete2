package kg.ash.javavi;

import java.io.IOException;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.annotation.Resource;
import javax.ejb.EJB;
import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebService;
import javax.transaction.HeuristicMixedException;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

import static java.text.MessageFormat.format;
/**
 *
 * @author Artur Shaikhullin <ashaihullin@gmail.com>
 */

@WebService(serviceName = "ResourceClassForClassFetcherTest")
@InterceptorRefs({
    @InterceptorRef("authStack"),
    @InterceptorRef("loggingStack")
})
public class ResourceClassForClassFetcherTest {

    @Resource(attr = Attr.SOME_ATTR)
    private UserTransaction tx;

    @ParentAnnotation({
        @ChildAnnotation
    })
	private static final Logger logger = Logger.getLogger(ResourceClassForClassFetcherTest.class.getName());
    private static final HashMap<String, Long> hashMap1 = new HashMap();
    private static final HashMap<String, Long> hashMap2 = new HashMap();

	@EJB private BeanClass1 bean1;
	@EJB private BeanClass2 bean2;

    @AnnotationForConstractor
    public ResourceClassForClassFetcherTest() {

    }

	private TestClass getTestClass(SomeClass source, String hash) throws TestClassForbiddenException {
		try {
            TestClass testClass = bean1.getByUniq(format());
            String result = StaticClassName.staticMethod();
            String result2 = AnotherStatic.staticReference;
            return testClass;
		} catch (TestClassForbiddenException ex) {
			logger.warn(String.format("Wrong testClass: %s %s", format(hash), source));
			throw ex;
		}
	}

	/**
	 * @param testClassID
	 * @param username
	 * @param hash
	 * @return TestResponse
	 * @throws kg.ash.test.exceptions.TestException
	 */
	@WebMethod(operationName = "test")
	public TestResponse test(
			@WebParam(name = "testClassID", fake = FakeAttr.ATTR) final String testClassID,
			@WebParam(name = "username") final String username,
			@WebParam(name = "hash") final HashLine hash) throws TestException {

        List<Map> myList = new ArrayList<>();
        Set<Map.Entry> mySet = new HashSet<>();
        Map.Entry.Fake<HashMap.Iterator> e;
		logger.info(String.format("Test(id: %s, username: %s, hash: %s)", testClassID, username, hash));
        Map.Entry e;
		logger.info(ar);
		return ar;
	}

    private class InnerClass {
        private unusualClassName UnusualObjectName;
    }
    
}
