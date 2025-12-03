package fiveChapter;

class MySuperClass3 {
  int x;

  void setX() {
    x = 10;
  }
}

class MySubClass3 extends MySuperClass3 {
  int x;

  @Override
  void setX() {
    super.setX();// 调用父类的方法，控制的也是父类的变量
    this.x = 100;
  }

  String getMessage() {
    return "super.x = " + super.x + ", sub.x = " + this.x;
  }
}

public class HideTest3 {
  public static void main(String[] args) {
    MySubClass3 sc = new MySubClass3();
    sc.setX(); // 执行子类的setX()
    System.out.println(sc.getMessage());
  }
}
