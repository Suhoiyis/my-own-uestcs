package twoThreeChapter;

/* Java课程第一个代码，注意文件名要改为“显示Hello的类.java�? */
public class 显示Hello的类 {

  String 一个字符串变量;

  public 显示Hello的类() {
    一个字符串变量 = "Hello, World!";
  }

  public String 加文字的方法() {
    return 一个字符串变量 + "信软OK";
  }

  public static void main(String args[]) {
    显示Hello的类 该类的一个实例 = new 显示Hello的类();
    System.out.println(该类的一个实例.一个字符串变量);
    System.out.println(该类的一个实例.加文字的方法());
  }

}