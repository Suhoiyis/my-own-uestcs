package fourChapter;

class Outer4 {
  int age = 10;
  static int age2 = 20;

  static class Inner {
    void method() {
      // System.out.println(age); // ´íÎó
      System.out.println(age2); // ÕıÈ·, ÏÔÊ¾20
    }
  }

  public static void main(String[] args) {
    Outer4.Inner inner = new Outer4.Inner();
    inner.method();
  }
}
