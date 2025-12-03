package fourChapter;

class A3 {
  // 无参构造方法
  A3() {
    System.out.println("hello a");
  }

  // 参数化构造方法
  A3(int x) {
    this(); // 调用默认构造方法。注意this()必须是构造方法中的第一个语句。
    System.out.println(x);
  }
}

public class ConstructorTest7 {
  @SuppressWarnings("unused") // 不加会弹出一个警告, eclipse自动会加
  public static void main(String[] args) {
    A3 a = new A3(10);
  }
}
