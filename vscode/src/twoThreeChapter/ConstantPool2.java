package twoThreeChapter;

public class ConstantPool2 {
  public static void main(String[] args) {
    int n = 0;
    int m = n;
    int a = 1;
    System.out.println(m == n);// Êä³ötrue
    m = m + 1;
    System.out.println(m == n);// Êä³öfalse
    System.out.println(m == a);// Êä³ötrue
  }
}
