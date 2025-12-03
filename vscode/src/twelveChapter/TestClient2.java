package twelveChapter;

import java.io.*;
import java.net.*;

public class TestClient2 {

  public static void main(String[] args) throws IOException {
    System.out.println("正向服务端发送信息...");
    Socket s = new Socket(InetAddress.getByName("127.0.0.1"), 8001);
    OutputStream os = s.getOutputStream();
    os.write("服务端你好，我是客户端\n".getBytes());
    if (args.length > 0 && args[0].length() > 0) {
      os.write(args[0].getBytes());
    }
    s.shutdownOutput();
    InputStream is = s.getInputStream();
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
