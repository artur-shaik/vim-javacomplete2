package kg.ash.javavi;

import org.junit.Assert;
import org.junit.Test;

public class TargetParserTest {
    
    @Test
    public void testParse() {
        TargetParser parser = new TargetParser("");
        Assert.assertEquals("", parser.parse(""));
        Assert.assertEquals("java.util.List", parser.parse("java.util.List"));
        Assert.assertEquals(0, parser.getTypeArguments().size());

        Assert.assertEquals("java.util.List", parser.parse("java.util.List<java.util.List<HashMap<String,BigDecimal>>>"));
        Assert.assertEquals(1, parser.getTypeArguments().size());
        Assert.assertEquals("java.util.List<HashMap<String,BigDecimal>>", parser.getTypeArguments().get(0));

        Assert.assertEquals("java.util.HashMap", parser.parse("java.util.HashMap<(kg.ash.demo.String|java.lang.String),java.math.BigDecimal>"));
        Assert.assertEquals(2, parser.getTypeArguments().size());
        Assert.assertEquals("java.lang.String", parser.getTypeArguments().get(0));
        Assert.assertEquals("java.math.BigDecimal", parser.getTypeArguments().get(1));
    }

    @Test
    public void testTypeArgumentsToString() {
        TargetParser parser = new TargetParser("");
        parser.parse("java.util.List");
        Assert.assertEquals("", parser.getTypeArgumentsString());
        parser.parse("java.util.List<java.math.BigDecimal>");
        Assert.assertEquals("<java.math.BigDecimal>", parser.getTypeArgumentsString());
        parser.parse("java.util.List<SomeClass>");
        Assert.assertEquals("<java.lang.Object>", parser.getTypeArgumentsString());
        parser.parse("java.util.HashMap<(kg.ash.demo.String|java.lang.String),java.math.BigDecimal>");
        Assert.assertEquals("<java.lang.String,java.math.BigDecimal>", parser.getTypeArgumentsString());
    }
}
