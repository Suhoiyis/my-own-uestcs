package eightChapter;

import java.util.Scanner;

public class TestScanner {
  public static void main(String[] args) {
    // System.in代表标准输入，就是键盘输入
    Scanner sc = new Scanner(System.in);
    System.out.println("请输入内容，当内容为exit时程序结束。");
    while (sc.hasNext()) {
      String s = sc.next();
      if (s.equals("exit")) { // 判断输入内容是否与exit相等
        break;
      }
      System.out.println("输入的内容为：" + s);
    }
    sc.close(); // 释放资源
  }
}
