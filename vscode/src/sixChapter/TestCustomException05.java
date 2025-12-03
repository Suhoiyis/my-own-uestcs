package sixChapter;

public class TestCustomException05 {
  public static int div(int a, int b) throws DivException {
    try {
      if (0 == b) {
        throw new DivException("除数不能为0！");
      }
      return a / b;
    }
    catch (DivException e) {
      System.out.println(e); // 如果改为e.getMessage()则只输出"除数不能为0！"
      throw new DivException("除数为0时为无穷大！");
    }
  }

  public static void main(String[] args) {
    int val;
    try {
      val = div(10, 0);
      System.out.println(val);
    }
    catch (DivException e) {
      System.out.println(e);
      System.out.println("val = ∞");
    }

  }
}
