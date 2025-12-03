package fourChapter;

class A5 {
  A5() {
    System.out.print("hello a");
  }

  A5(int x) {
    this();
    // µÈ¼ÛÓÚSystem.out.print(String.valueOf(x))
    System.out.print(x + "");
  }

  A5(int x, int y) {
    this(x);
    System.out.print(y + "");
  }
}

public class ConstructorTest9 {
  @SuppressWarnings("unused")
  public static void main(String[] args) {
    A5 a = new A5(2, 3);
  }
}
