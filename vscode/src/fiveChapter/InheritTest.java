package fiveChapter;

class Father {
  int a;
}

class Child2 extends Father {
  String a; // 同名就会覆盖

  Child2() {
//    a = 100; // Error，并不会因为赋值为100就会“自动推断”到父类的整型变量a；子类中调用的a都是指本类中的成员；这里只有使用super.a = 100才能编译通过
  }

  public void printChild() {
    System.out.printf("father's a=%d, child's a=%f", super.a, this.a);
  }
}

public class InheritTest {
  public static void main(String[] args) {
    Child2 child = new Child2();
    child.printChild();
  }
}
