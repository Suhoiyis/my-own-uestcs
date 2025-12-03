package twoThreeChapter;

public class ValueTest {
  public static void main(String[] args) {
    int realValue = 100;
    change(realValue); // Eclipse里静态方法用斜体
    System.out.println("outer: " + realValue);
  }

  static void change(int formValue) {
    formValue = 200;
    System.out.println("inner: " + formValue);
  }
}
