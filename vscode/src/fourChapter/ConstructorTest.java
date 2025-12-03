package fourChapter;

public class ConstructorTest {
  void showID() {
    // prints same reference ID
    System.out.println(this);
  }

  public static void main(String args[]) {
    ConstructorTest obj = new ConstructorTest();
    // prints the reference ID
    System.out.println(obj);// 这里不能写成System.out.println(this)
    obj.showID();
  }
}
