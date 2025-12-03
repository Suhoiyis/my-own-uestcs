package twoThreeChapter;

public class Ex1_1 {
  public static void main(String args[]) {
    final int PRICE = 30;
    final double PI = 3.141592654;
    int num, total;
    double v, r, h;
    num = 10;
    total = num * PRICE;
    System.out.println(total);
    r = 2.5;
    h = 3.2;
    v = PI * r * r * h;
    System.out.println(v);
  }
}
