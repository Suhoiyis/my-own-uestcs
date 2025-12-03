package twelveChapter;

import java.io.*;
import java.net.*;

/* 简单的TCP网络程序*/

public class TestServer {
  public static void main(String[] args) throws IOException {
    ServerSocket ss = new ServerSocket(9090);
    System.out.println("等待接收数据...");
    Socket s = ss.accept();
    InputStream is = s.getInputStream();// 此套接字的输入流表示客户端发给服务器的数据流
    byte[] b = new byte[20];
    int len;
    while ((len = is.read(b)) != -1) {
      String str = new String(b, 0, len);
      System.out.print(str);
    }
    OutputStream os = s.getOutputStream();// 此套接字的输出流表示服务器发给客户端的数据流
    os.write("服务端已收到信息！".getBytes());
    os.close();
    is.close();
    s.close();
    ss.close();
  }
}
