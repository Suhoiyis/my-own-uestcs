package twoThreeChapter;

public class ConstantPool3 {
  public static void main(String[] args) {
    String s0 = "hello";
    String s1 = "hello";
    String s2 = "he" + "llo";
    System.out.println(s0 == s1);
    System.out.println(s0 == s2);
  }
}
