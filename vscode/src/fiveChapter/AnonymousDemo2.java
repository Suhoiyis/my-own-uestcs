package fiveChapter;

public class AnonymousDemo2 {
  Polygon p2 = new Polygon() {
    @Override
    public void display() {
      System.out.println("在匿名类内部2。");
    }
  };

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
    AnonymousDemo2 an = new AnonymousDemo2();
    an.createClass();
    an.p2.display();
  }
}
