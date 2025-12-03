package sixChapter;

public class TestCustomException04 {
  public static int div(int a, int b) throws DivException {
    try {
      if (0 == b) {
        throw new DivException("除数不能为0！");
      }
      return a / b;
    }
    catch (DivException e) {
      System.out.println(e);
      return -1; // 由于div返回int型，此处必须return一个整型，否则报错
    }
  }

  public static void main(String[] args) throws DivException {
    int val = div(10, 0);
    System.out.println(val);
  }
}
