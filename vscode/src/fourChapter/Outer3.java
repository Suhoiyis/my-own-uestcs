package fourChapter;

class Outer3 {
  private int age = 20;

  void method() {
    final int age2 = 30;// 局部内部类访问的局部变量必须加final修饰
    class Inner {
      void show() {
        System.out.println(age); // 20
        // 从局部内部类中访问方法内的临时变量age2，需要将该变量声明为final
        System.out.println(age2); // 30
      }
    }

    Inner i = new Inner();
    i.show();
  }

  public static void main(String[] ages) {
    Outer3 outer = new Outer3();
    outer.method();
  }
}
