package kg.ash.javavi;

import java.io.DataInputStream;
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
                    DataInputStream is = new DataInputStream(clientSocket.getInputStream());
                    PrintStream os = new PrintStream(clientSocket.getOutputStream())
                ) {
                    while (true) {
                        line = is.readLine();
                        if (line != null) {
                            List<String> args = new LinkedList<>();

                            /** Parse command arguments */
                            StringBuilder buff = new StringBuilder();
                            boolean quoteFlag = false;
                            boolean slashFlag = false;
                            for (char ch : line.toCharArray()) {
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

                            os.print(Javavi.makeResponse((String[])args.toArray(new String[0])));
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
    
}
