package tenChapter;

import java.io.*;

public class BufferedReaderTester {
  public static void main(String[] args) {
    String fileName = "Hello.txt", line;// 文件名后缀不重要，读取Hello.dat也可以
    try {
      BufferedReader in = new BufferedReader(new FileReader(fileName));
      line = in.readLine();// 读取一行内容
      while (line != null) {
        System.out.println(line);
        line = in.readLine();
      }
      in.close();
    }
    catch (IOException iox) {
      System.out.println("Reading Problem: " + fileName);
    }
  }
}
