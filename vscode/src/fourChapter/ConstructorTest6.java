package fourChapter;

class A2 {
  A2 getA2() {
    return this;
  }

  void msg() {
    System.out.println("Hello java");
  }
}

public class ConstructorTest6 {
  public static void main(String[] args) {
    new A2().getA2().msg();
    // 其实等价于new A2().msg()，这么写只是为了展示概念
  }
}
