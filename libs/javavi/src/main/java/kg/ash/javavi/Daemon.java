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
import java.util.List;

public class Daemon extends Thread {

    private int port;

    public Daemon(int port) {
        this.port = port;
    }

    public void run() {
        ServerSocket echoServer = null;
        String line;
        Socket clientSocket = null;

        while (true) {
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

            if ((ch != '"' && !slashFlag) || (ch == '"' && slashFlag)) {
                buff.append(ch);
            }

            if (slashFlag) slashFlag = false;
        }
        if (buff.length() > 0) {
            args.add(buff.toString());
        }

        return (String[])args.toArray(new String[0]);
    }

}
