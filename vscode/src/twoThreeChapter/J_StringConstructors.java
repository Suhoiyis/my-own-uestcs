package twoThreeChapter;

public class J_StringConstructors {
  public static void main(String args[]) {
    String s1 = null;
    String s2 = new String();
    String s3 = "您好!";
    String s4 = new String(s3);
    System.out.println("s1: " + s1);
    System.out.println("s2: " + s2);
    System.out.println("s3: " + s3);
    System.out.println("s4: " + s4);
    System.out.println("s4: " + s4.indexOf(1));// 返回-1，不是相当于s4[1]
  }
}
