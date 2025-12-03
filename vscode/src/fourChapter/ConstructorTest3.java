package fourChapter;

class B {
  A a;

  B(A a) {
    this.a = a;
  }

  void showAdata() {
    System.out.printf("b's member a has data=%d\n", a.data);
  }
}

class A {
  int data = 10;

  A() {
    B b = new B(this);// this指代的是类A的对象
    b.showAdata();
  }
}

public class ConstructorTest3 {

  @SuppressWarnings("unused")
  public static void main(String[] args) {
    A a = new A();
  }
}
