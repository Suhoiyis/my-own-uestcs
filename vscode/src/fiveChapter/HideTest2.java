package fiveChapter;

class MySuperClass2 {
  int x;

  void setX() {
    x = 10;
  }
}

class MySubClass2 extends MySuperClass2 {
  int x;

  void setX(String s) { // 重载父类的方法
    System.out.println(s);
    x = 100;// 可以写成this.x = 100
  }

  String getMessage() {
    return "super.x = " + super.x + ", sub.x = " + x;
  } // 最后一个x可以写成this.x
}

public class HideTest2 {
  public static void main(String[] args) {
    MySubClass2 sc = new MySubClass2();
    sc.setX(); // 执行父类的setX()方法
    System.out.println(sc.getMessage());
    sc.setX("改变子类的变量");// 执行子类的setX(s)方法
    System.out.println(sc.getMessage());
  }
}
