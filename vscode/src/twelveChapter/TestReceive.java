package twelveChapter;

import java.net.*;

/* UDP网络程序示例, 教材例子略加修改,和TestSend配套 */
public class TestReceive {
  public static void main(String[] args) throws Exception {
    DatagramSocket ds = new DatagramSocket(8081);
    byte[] by = new byte[1024]; // byte数组存储中文字符也没问题
    DatagramPacket dp = new DatagramPacket(by, by.length);
    System.out.println("等待接收数据...");
    // 等待接收客户端DatagramPacket，没有接收到该线程会处于阻塞态
    ds.receive(dp);
    String str = new String(dp.getData(), 0, dp.getLength());
    System.out.println(str + "-->" + dp.getAddress().getHostAddress() + ":" + dp.getPort());
    ds.close();
  }
}
