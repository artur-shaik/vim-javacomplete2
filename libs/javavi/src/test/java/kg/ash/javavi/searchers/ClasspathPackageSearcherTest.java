package kg.ash.javavi.searchers;

import java.util.List;

import org.junit.Assert;
import org.junit.Ignore;
import org.junit.Test;

public class ClasspathPackageSearcherTest {

    @Ignore
    @Test
    public void testGetEntries() {
        List<PackageEntry> entries = new ClasspathPackageSearcher().loadEntries();
        Assert.assertTrue(entries.size() > 0);
    }

}
