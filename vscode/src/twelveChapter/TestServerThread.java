package twelveChapter;

import java.io.*;
import java.net.*;

public class TestServerThread {
  public static void main(String[] args) throws IOException {
    ServerSocket ss = null;
    Socket s = null;
    ss = new ServerSocket(8001);
    System.out.println("服务端已运行...");
    for (int i = 0; i < 3; i++) {
      s = ss.accept();
      new Thread(new TestThread(s), "线程" + i).start();
    }
    ss.close();
  }
}

/* 本类是一个多线程的包装类，包装服务端同客户端连接后返回的socket */
class TestThread implements Runnable {
  private Socket socket = null; // 接收连接后服务端的socket

  public TestThread(Socket client) {
    this.socket = client;
  }

  @Override
  public void run() {
    BufferedReader br = null; // 用于接收客户端信息
    PrintStream ps = null; // 向客户端的输出流
    try {
      br = new BufferedReader(new InputStreamReader(socket.getInputStream()));
      ps = new PrintStream(socket.getOutputStream());
      boolean flag = true; // 标记客户端是否发送完毕
      while (flag) {
        System.out.println(Thread.currentThread().getName() + ":等待接收信息...");
        Thread.sleep(5000);// 模拟网络延迟
        String str = br.readLine();
        if (str == null || "".equals(str)) {
          flag = false; // 一次读一行，当检测到输入信息为空时，服务端终止
        }
        else {
          System.out.println(Thread.currentThread().getName() + "接收到信息:" + str);
          ps.println("服务端" + Thread.currentThread().getName() + " 已收到信息：" + str);
        }
      }
      br.close();
      ps.close();
      socket.close();
      System.out.println(Thread.currentThread().getName() + ":无新的消息，关闭");
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }
}