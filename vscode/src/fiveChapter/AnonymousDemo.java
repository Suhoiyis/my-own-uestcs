package fiveChapter;

class Polygon {
  public void display() {
    System.out.println("在 Polygon 类内部");
  }
}

public class AnonymousDemo {
  public void createClass() {
    Polygon p1 = new Polygon() {
      @Override
      public void display() {
        System.out.println("在匿名类内部。");
      }
    };
    p1.display();
  }

  public static void main(String[] args) {
    AnonymousDemo an = new AnonymousDemo();
    an.createClass();
  }
}
