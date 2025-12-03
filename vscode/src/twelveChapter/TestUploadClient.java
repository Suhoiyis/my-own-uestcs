package twelveChapter;

import java.io.*;
import java.net.*;

/* 上传文件，和TestUploadServer配合*/
public class TestUploadClient {
  public static final String fileDir = "c:/Users/ThinkPad/eclipse-workspace/MyTest/src/twelveChapter/";

  public static void main(String[] args) throws Exception {
    String fileName = "java.png";
    String filePath = fileDir + fileName;
    System.out.println("正在发送文件：" + filePath);
    Socket socket = new Socket(InetAddress.getByName("127.0.0.1"), 9090);
    if (socket != null) {
      sendFile(socket, filePath);
      System.out.println("发送成功!");
    }
  }

  private static void sendFile(Socket socket, String filePath) throws Exception {
    byte[] bytes = new byte[1024];
    BufferedInputStream bis = new BufferedInputStream(new FileInputStream(new File(filePath)));
    DataOutputStream dos = new DataOutputStream(new BufferedOutputStream(socket.getOutputStream()));
    // 首先发送文件名 客户端发送使用writeUTF方法，服务器端应该使用readUTF方法
    dos.writeUTF(getFileName(filePath));
    int length = 0;
    while ((length = bis.read(bytes, 0, bytes.length)) > 0) {// 发送文件的内容
      dos.write(bytes, 0, length);
      dos.flush();
    }
    bis.close();
    dos.close();
    socket.close();
  }

  private static String getFileName(String filePath) {
    String[] parts = filePath.split("/");// 注意路径分隔符要统一
    return parts[parts.length - 1];
  }
}
