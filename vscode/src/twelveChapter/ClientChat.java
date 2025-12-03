package twelveChapter;

import java.io.*;
import java.net.*;

public class ClientChat {
  public static void main(String[] args) throws IOException {
    Client client;
    byte[] clientReceive = new byte[256];
    byte[] clientSend = new byte[256];
    boolean quit = false;
    byte ch;
    int i = 0;
    client = new Client("localhost", 8001);// 要和服务器的端口保持一致
    while (!quit) {
      System.out.println("\tReceive:");
      i = 0;
      while ((ch = (byte) client.in.read()) != '\n') { // 客户端从服务器取回数据
        clientReceive[i] = ch;
        i++;
      }
      System.out.println("\t" + new String(clientReceive, 0, i));
      System.out.println("Send:");
      i = 0;
      while ((ch = (byte) System.in.read()) != '\n') {// 此处停顿，等待用户输入
        clientSend[i] = ch;
        i++;
      }
      clientSend[i] = (byte) '\n';
      client.out.println(new String(clientSend, 0, i));// 客户端向服务器发送数据
      if (new String(clientSend, 0, i).indexOf("quit") != -1) {
        quit = true;
      }
    }
  }
}

class Client {
  private Socket clientSocket;
  public DataInputStream in;
  public PrintWriter out;

  public Client(String host, int port) throws UnknownHostException, IOException {
    clientSocket = new Socket(host, port);
    in = new DataInputStream(clientSocket.getInputStream());// 客户端从服务器取回数据
    out = new PrintWriter(clientSocket.getOutputStream(), true);// 客户端向服务器发送数据
  }
}
