package tenChapter;

import java.io.*;

public class Echo {
  public static void main(String[] args) throws IOException {
    System.out.println("请输入字符串（直接输入回车结束）: ");
    BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
    String s;
    // readLine()一次读入一行字符，该行字符中不包括行结束符(即回车)
    while ((s = in.readLine()).length() != 0) {
      System.out.println(s);
    }
    System.out.println("输入结束");
  }
}
