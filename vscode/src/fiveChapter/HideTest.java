package fiveChapter;

class MySuperClass {
  int x;

  void setX() {
    x = 10;// 该x占据父类对象的存储空间
  }

  String getMessage() {
    return "my x = " + x;
  }
}

class MySubClass extends MySuperClass {
  int x;// 隐藏父类的字段

  @Override
  void setX() { // 覆盖父类的方法
    super.x = 50;// 该x占据子类对象的存储空间
    x = 100;
  }

  @Override
  String getMessage() {// 覆盖父类的方法
    return "super.x = " + super.x + ", sub.x = " + x;
  }
}

public class HideTest {
  public static void main(String[] args) {
    MySuperClass su = new MySuperClass();
    su.setX();// 调用父类的方法
    MySubClass sc = new MySubClass();
    sc.setX(); // 调用子类的方法
    System.out.println(su.getMessage());
    System.out.println(sc.getMessage());
  }
}
