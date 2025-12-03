package twelveChapter;

import java.io.*;
import java.net.*;

/*UDP聊天程序，多线程*/

public class TestUDP {
  public static void main(String[] args) {
    // 运行接收端和发送端线程，开始通话，谁写在前面都行
    new Thread(new Receiver()).start();
    new Thread(new Sender()).start();
  }
}

class Sender implements Runnable {
  @Override
  public void run() {
    try {
      DatagramSocket ds = new DatagramSocket();

      // 通过控制台标准输入
      BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
      String line = null;
      DatagramPacket dp = null;
      do {
        line = br.readLine();
        byte[] buf = line.getBytes();
        dp = new DatagramPacket(buf, buf.length, InetAddress.getByName("127.0.0.1"), 9090);
        ds.send(dp);
      } while (!line.equals("exit"));
      ds.close();
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }
}

class Receiver implements Runnable {
  @Override
  public void run() {
    try {
      DatagramSocket ds = new DatagramSocket(9090);
      byte[] buf = new byte[1024];// 可以接收中文
      DatagramPacket dp = new DatagramPacket(buf, buf.length);
      String line = null;
      do {
        ds.receive(dp);
        line = new String(buf, 0, dp.getLength());
        System.out.println(line);
      } while (!line.equals("exit"));
      ds.close();
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }
}
