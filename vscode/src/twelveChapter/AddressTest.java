package twelveChapter;

import java.net.*;

class AddressTest {
  @SuppressWarnings("unused")
  public static void main(String[] args) {
    InetAddress someHost;
    String input = null;
    input = "www.uestc.edu.cn";
    try {
      if (input == null) {
        someHost = InetAddress.getLocalHost();
      }
      else {
        someHost = InetAddress.getByName(input);
      }
      System.out.println("Use \"getHostName()\":" + someHost.getHostName());
      System.out.println("Use \"getHostAddress()\":" + someHost.getHostAddress());
      byte[] addr = someHost.getAddress();
      System.out.println("Use \"getAddress()\":" + addr[0] + "." + addr[1] + "." + addr[2] + "." + addr[3]);
      System.out.println("Converted address:" + (addr[0] & 0xff) + "." + (addr[1] & 0xff) + "." + (addr[2] & 0xff) + "." + (addr[3] & 0xff));
    }
    catch (UnknownHostException e) {
      e.printStackTrace();
    }
  }
}
