package twelveChapter;

import java.io.*;
import java.net.*;

/* 简单的TCP网络程序,和TestServer配套*/
public class TestClient {
  public static void main(String[] args) throws IOException {
    System.out.println("正在发送数据...");
    Socket s = new Socket(InetAddress.getByName("127.0.0.1"), 9090);
    OutputStream os = s.getOutputStream();// 此套接字的输出流表示客户端向服务器发送的数据流
    os.write("服务端你好，我是客户端！".getBytes());
    s.shutdownOutput();// 显式地告诉服务端发送完毕
    InputStream is = s.getInputStream();// 此套接字的输入流表示服务器向客户端发送的数据流
    byte[] b = new byte[20];
    int len;
    while ((len = is.read(b)) != -1) {
      String str = new String(b, 0, len);
      System.out.print(str);
    }
    is.close();
    os.close();
    s.close();
  }
}
