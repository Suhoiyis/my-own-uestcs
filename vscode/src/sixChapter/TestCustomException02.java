package sixChapter;

public class TestCustomException02 {

  public static int div(int a, int b) throws DivException {
    if (0 == b) {
      throw new DivException("除数不能为0！");
    }
    return a / b;
  }

  public static void main(String[] args) {
    try {
      int val = div(10, 0);
      System.out.println(val);
    }
    catch (DivException e) { // 此处写为catch（Exception e）也可以
      System.out.println(e.getMessage());
    }
  }
}
