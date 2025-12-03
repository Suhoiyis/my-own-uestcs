package sixChapter;

public class TestCustomException03 {

  public static int div(int a, int b) throws DivException {
    if (0 == b) {
      throw new DivException("除数不能为0！");
    }
    return a / b;
  }

  public static void main(String[] args) throws DivException { // 此处throws DivException不可省略，否则通不过编译
    int val = div(10, 0);
    System.out.println(val);
  }
}
