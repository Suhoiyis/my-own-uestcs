package sixChapter;

public class TestThrows02 {
  // 声明抛出异常，本方法中可以不处理异常
  public static int div(int a, int b) {
    return a / b;
  }

  // 主方法捕获调用方法抛出的异常
  public static void main(String[] args) {
    try {
      int val = div(10, 0);
      System.out.println(val);
    }
    catch (Exception e) {
      System.out.println("val = ∞");
    }
  }
}
