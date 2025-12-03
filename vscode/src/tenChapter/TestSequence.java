package tenChapter;

import java.io.*;

public class TestSequence {
  public static void main(String[] args) throws IOException {
    InputStream in1 = new FileInputStream(new File("t1.txt"));// 多态
    InputStream in2 = new FileInputStream(new File("t2.txt"));

    SequenceInputStream si = new SequenceInputStream(in1, in2);
    OutputStream ou = new FileOutputStream(new File("t3.txt"));
    int c = 0;
    // SequenceInputStream是一个字节一个字节读，要判断是否读完了
    while ((c = si.read()) != -1) {
      // 一个字节一个字节写
      ou.write(c);
    }
    System.out.println("输出到t3.txt完毕");
    si.close();
    ou.close();
    in2.close();
    in1.close();
  }
}
