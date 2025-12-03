package fourChapter;

import fiveChapter.Child_B;

public class Father_A {
  public int a = 10;
  private int b = 20; // 这么设置的目的就是不希望用户直接控制该变量
  public int c = 30;

  protected int getB() { // 方法内可以加入一些安全判断条件。getB()为默认或protected访问权限，子类也可以调用
    return b;
  }

  public static void main(String[] args) {
    Child_B cb = new Child_B();
    cb.tryVariables();
    Child_B.class.getName();
  }
}

//class Child_B extends Father_A {
//  void tryVariables() {
//    System.out.println(a); // 允许
////    System.out.println(b); // 不允许
//    System.out.println(getB());// 允许
//    System.out.println(c); // 允许
//  }
//
//}