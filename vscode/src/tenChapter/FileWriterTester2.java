package tenChapter;

import java.io.*;

public class FileWriterTester2 {
  public static void main(String[] args) {
    String fileName = "Hello2.txt";
    try {
      // 构造方法的第二个参数设为true，在原文件中追加写入
      FileWriter writer = new FileWriter(fileName, true);
      writer.write("Hello!\n");
      writer.write("This is my first text file,\n");
      writer.write("输入一行中文也可以\n");
      writer.close();
      System.out.println("保存完毕");
    }
    catch (IOException iox) {
      System.out.println("Writing problem: " + fileName);
    }
  }
}
