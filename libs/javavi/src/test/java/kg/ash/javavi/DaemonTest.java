package kg.ash.javavi;

import org.junit.Assert;
import org.junit.Test;

public class DaemonTest {

    @Test
    public void testParseLine() {
        Daemon daemon = new Daemon(0, -1);
        Assert.assertEquals(new String[]{"-v"}, daemon.parseRequest("-v"));
        Assert.assertEquals(new String[]{"-E", "java.util.List"}, daemon.parseRequest("-E \"java.util.List\""));
        Assert.assertEquals(new String[]{"-E", "java.util.List"}, daemon.parseRequest("-E java.util.List"));
        Assert.assertEquals(new String[]{"-E", "java.util.List<HashMap<String,Integer>>"}, daemon.parseRequest("-E java.util.List<HashMap<String,Integer>>"));
        Assert.assertEquals(new String[]{"-E"}, daemon.parseRequest("-E \"\""));
        Assert.assertEquals(new String[0], daemon.parseRequest(""));
        Assert.assertEquals("\\\\n", daemon.parseRequest("\"\\\\n\"")[0]);
    }
    
}
