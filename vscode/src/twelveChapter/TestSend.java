package twelveChapter;

import java.net.*;

/* UDP网络程序示例, 教材例子略加修改 */
public class TestSend {
  public static void main(String[] args) throws Exception {
    // 发送端的套接字端口不能和接收端一样；这里可以不指定
    DatagramSocket ds = new DatagramSocket(8090);
    byte[] by = "求真求实，大气大为".getBytes();
    // 指定接收端IP为本地地址，端口号与接收端的套接字一致
    DatagramPacket dp = new DatagramPacket(by, 0, by.length, InetAddress.getByName("127.0.0.1"), 8081);// 127.0.0.1可以替换成localhost
    System.out.println("正在发送数据...");
    ds.send(dp);
    ds.close();
  }
}
