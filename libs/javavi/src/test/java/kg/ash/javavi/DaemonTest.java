package kg.ash.javavi;

import org.junit.Assert;
import org.junit.Test;

public class DaemonTest {

    @Test
    public void testParseLine() {
        Daemon daemon = new Daemon(0, -1);
        Assert.assertArrayEquals(new String[]{"-v"}, daemon.parseRequest("-v"));
        Assert.assertArrayEquals(new String[]{"-E", "java.util.List"}, daemon.parseRequest("-E \"java.util.List\""));
        Assert.assertArrayEquals(new String[]{"-E", "java.util.List"}, daemon.parseRequest("-E java.util.List"));
        Assert.assertArrayEquals(new String[]{"-E", "java.util.List<HashMap<String,Integer>>"}, daemon.parseRequest("-E java.util.List<HashMap<String,Integer>>"));
        Assert.assertArrayEquals(new String[0], daemon.parseRequest(""));
        Assert.assertArrayEquals(new String[]{"-E", ""}, daemon.parseRequest("-E \"\""));
        Assert.assertEquals("\\\\n", daemon.parseRequest("\"\\\\n\"")[0]);
    }

}
