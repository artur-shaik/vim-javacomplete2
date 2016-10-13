package kg.ash.javavi.actions;

import kg.ash.javavi.Daemon;
import kg.ash.javavi.Javavi;

public class ExecuteDaemonAction implements Action {

    private Integer daemonPort = null;
    private Integer timeoutSeconds = -1;

    @Override
    public String perform(String[] args) {
        if (Javavi.daemon != null) {
            return "";
        }

        daemonPort = Integer.valueOf(System.getProperty("daemon.port", "0"));
        if (daemonPort == 0) {
            return "Error: daemonPort is null";
        }

        Javavi.debug("Starting daemon mode");
        Javavi.daemon = new Daemon(daemonPort, timeoutSeconds);
        Javavi.daemon.start();

        return "";
    }

    private void parseArgs(String[] args) {
        for (int i = 0; i < args.length; i++) {
            switch (args[i]) {
                case "-t": {
                    timeoutSeconds = Integer.parseInt(args[i+1]);
                    break;
                }
            }
        }
    }
    
}
