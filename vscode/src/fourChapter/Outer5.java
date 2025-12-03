package fourChapter;

interface Inner {
  void show();
}

class Outer5 {
  void method() {
    new Inner() {
      @Override
      public void show() {
        System.out.println("HelloWorld");
      }
    }.show();
  }

  public static void main(String[] args) {
    Outer5 o = new Outer5();
    o.method();
  }
}
