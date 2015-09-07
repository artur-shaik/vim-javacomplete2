package kg.ash.javavi;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;
import java.io.PrintStream;
import java.lang.StringBuilder;
import java.lang.Thread;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.LinkedList;
import java.util.Timer;
import java.util.TimerTask;
import java.util.List;

public class Daemon extends Thread {

    private int port;
    private int timeoutSeconds;
    private Timer timeoutTimer = new Timer();
    private TimerTask timeoutTask;

    public Daemon(int port, int timeoutSeconds) {
        this.port = port;
        this.timeoutSeconds = timeoutSeconds;
    }

    public void run() {
        ServerSocket echoServer = null;
        String line;
        Socket clientSocket = null;

        while (true) {
            if (timeoutSeconds > 0) {
                timeoutTask = new TimeoutTask();
                timeoutTimer.schedule(timeoutTask, timeoutSeconds * 1000);
            }

            try {
                if (echoServer == null) {
                    echoServer = new ServerSocket(port);
                }
            } catch (IOException e) {
                System.out.println(e);
                break;
            }   

            try {
                clientSocket = echoServer.accept();

                if (timeoutTask != null) timeoutTask.cancel();

                try (
                    BufferedReader is = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
                    PrintStream os = new PrintStream(clientSocket.getOutputStream())
                ) {
                    while (true) {
                        String[] request = parseRequest(is.readLine());
                        if (request != null) {
                            os.print(Javavi.makeResponse(request));
                        } 

                        break;
                    }
                } catch (Exception e) {

                }
            } catch (IOException e) {
                System.out.println(e);
                break;
            }
        }
    }

    public String[] parseRequest(String request) {
        if (request == null) return null;

        List<String> args = new LinkedList<>();

        StringBuilder buff = new StringBuilder();
        boolean quoteFlag = false;
        boolean slashFlag = false;
        for (char ch : request.toCharArray()) {
            if (quoteFlag) {
                if (ch == '\\') {
                    if (slashFlag) {
                        buff.append("\\");
                    }
                    slashFlag = true;
                    continue;
                }
                if (ch == '"' && !slashFlag) {
                    quoteFlag = false;
                    continue;
                }
            }

            if (ch == '"' && !slashFlag) quoteFlag = true;

            if (!quoteFlag) {
                if (ch == ' ') {
                    if (buff.length() > 0) {
                        args.add(buff.toString());
                        buff = new StringBuilder();
                    }
                    continue;
                }
            }

            if ((ch != '"' && !slashFlag) || ((ch == '"' || ch == 'n') && slashFlag)) {
                if (slashFlag && ch != '"') {
                    buff.append('\\');
                }
                buff.append(ch);
            }

            if (slashFlag) slashFlag = false;
        }
        if (buff.length() > 0) {
            args.add(buff.toString());
        }

        return (String[])args.toArray(new String[0]);
    }

    class TimeoutTask extends TimerTask {
        public void run() {
            System.out.println("Shutdown by timeout timer.");
            System.exit(0);
        }
    }

}
