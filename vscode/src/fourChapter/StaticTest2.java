package fourChapter;

public class StaticTest2 {

  @SuppressWarnings("unused")
  public static void main(String[] args) {
    Point p1 = new Point(1, 1);
    Point p2 = new Point(2, 3);
    Point p3 = new Point(4, 5);
    System.out.printf("¶ÔÏóÊı=%d\n", Point.pointCount);// 3
  }

}

@SuppressWarnings("unused")
class Point {

  private int x;
  private int y;
  public static int pointCount = 0;

  public Point(int x, int y) {
    this.x = x;
    this.y = y;
    pointCount++;
  }
}
