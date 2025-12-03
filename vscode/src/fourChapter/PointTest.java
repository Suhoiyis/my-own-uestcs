package fourChapter;

public class PointTest {

  public static void main(String[] args) {
    Point2 p = new Point2();
    p.show();
    p.x = 100;
    p.y = 200;
    p.show();
  }

}

class Point2 {
  int x = 1;
  int y = 2;

  // 构造方法名要和类名一致
  Point2() {
    x = 10;
    y = 20;
  }

  void show() {
    final int c;
    c = x + y;
//    c = 100;
    System.out.printf("x=%d, y=%d, c=%d\n", x, y, c);
  }
}