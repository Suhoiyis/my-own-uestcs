package tenChapter;

import java.io.*;

public class BufferedWriterTester {
  public static void main(String[] args) throws IOException {
    String fileName = "Hello3.txt";// 文件名后缀不重要，存成Hello.dat也可以
    BufferedWriter out = new BufferedWriter(new FileWriter(fileName));
    out.write("Hello!");
    out.newLine();
    out.write("This is another text file using BufferedWriter,");
    out.newLine();
    out.write("所以我能用newLine()开一个新行");
    out.close();
    System.out.println("保存完毕");
  }
}
