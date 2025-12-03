package twelveChapter;

import java.io.*;
import java.net.*;

/* 上传文件，和TestUploadClient配合*/
public class TestUploadServer {
  public static void main(String[] args) throws Exception {
    ServerSocket ss = new ServerSocket(9090);
    System.out.println("服务端已开启，等待接收文件！");
    Socket s = ss.accept(); // 客户端连接服务器端
    System.out.println("正在接收来自" + s.getInetAddress().getHostAddress() + "的文件...");
    receiveFile(s);
    ss.close();
  }

  private static void receiveFile(Socket socket) throws Exception {
    byte[] buffer = new byte[1024];// buffer起缓冲作用，一次读取或写入多个字节的数据
    DataInputStream dis = new DataInputStream(socket.getInputStream());
    String oldFileName = dis.readUTF();// 首先读取文件名
    // 文件路径采用与客户端相同的路径，文件名重新命名
    String filePath = TestUploadClient.fileDir + genereateFileName(oldFileName);
    FileOutputStream fos = new FileOutputStream(new File(filePath));
    int length = 0;
    while ((length = dis.read(buffer, 0, buffer.length)) > 0) {
      fos.write(buffer, 0, length);
      fos.flush();
    }
    System.out.println("接收文件成功，另存为：" + filePath);
    dis.close();
    fos.close();
    socket.close();
  }

  private static String genereateFileName(String oldName) {
    String newName = null;
    newName = oldName.substring(0, oldName.lastIndexOf(".")) + "-2" + oldName.substring(oldName.lastIndexOf("."));
    return newName;
  }
}
