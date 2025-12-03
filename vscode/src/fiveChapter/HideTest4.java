package fiveChapter;

/* 试验程序，不保证能运行 */
class MySuperClass4 {
  int x = 1;

  int getX() {
    return x;
  }
}

class MySubClass4 extends MySuperClass4 {
//  @Override
//  double getX() { // double并不是int的子类型
//    return x + 1.0;
//  }

}

public class HideTest4 {
  public static void main(String[] args) {
    MySubClass4 sc = new MySubClass4();
    System.out.println(sc.getX());
  }
}
