package twelveChapter;

import java.util.*;
import java.io.*;
import java.net.*;

public class ServerChat {
  final static int SERVER_PORT = 8001;

  public static void main(String[] args) throws IOException {
    Server server;
    byte[] serverReceive = new byte[256];
    byte[] serverSend = new byte[256];
    boolean quit = false;
    byte ch;
    int i = 0;
    server = new Server(SERVER_PORT);
    while (!quit) {
      System.out.println("\tReceive:");
      i = 0;
      while ((ch = (byte) server.in.read()) != '\n') {// 从客户机读取数据
        serverReceive[i] = ch;
        i++;
      }
      System.out.println("\t" + new String(serverReceive, 0, i));
      if (new String(serverReceive, 0, i).indexOf("quit") == -1) {
        System.out.println("Send:");
        i = 0;
        while ((ch = (byte) System.in.read()) != '\n') {// 此处停顿，等待用户输入
          serverSend[i] = ch;
          i++;
        }
        serverSend[i] = '\n';
        server.out.println(new String(serverSend, 0, i));// 向客户机发送数据
      }
      else {
        quit = true;
      }
    }
  }
}

class Server {
  private ServerSocket serverSocket;
  private Socket socket;
  public DataInputStream in;
  public PrintWriter out;

  public Server(int port) throws IOException {
    serverSocket = new ServerSocket(port);
    System.out.println("--- Chat Server is on_line! ---");
    socket = serverSocket.accept();// 此处等待
    in = new DataInputStream(socket.getInputStream());// 客户机到服务器的输入流
    out = new PrintWriter(socket.getOutputStream(), true);// 服务器到客户机的输出流
    out.println("Chat Server:  " + new Date());
  }
}
