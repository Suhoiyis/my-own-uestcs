package fourChapter;

class A4 {
  A4() {
    this(5);
    System.out.println("hello a");
  }

  A4(int x) {
    System.out.println(x);
  }
}

public class ConstructorTest8 {
  @SuppressWarnings("unused")
  public static void main(String[] args) {
    A4 a = new A4();
  }
}
