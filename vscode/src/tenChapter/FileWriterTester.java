package tenChapter;

import java.io.*;

//在项目根目录下创建文本文件Hello.txt，并往里写入若干行文本
public class FileWriterTester {
  public static void main(String[] args) throws IOException {
    String fileName = "Hello.txt";
    FileWriter writer = new FileWriter(fileName);
    writer.write("Hello!\n");
    writer.write("This is my first text file,\n");
    writer.write("输入一行中文也可以\n");
    writer.close();// close方法清空流里的内容并关闭它；如果不调用该方法，可能系统还没有完成所有数据的写操作，程序就结束了
    System.out.println("保存完毕");
  }
}
