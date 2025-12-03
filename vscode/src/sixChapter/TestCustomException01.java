package sixChapter;

//自定义异常，继承Exception类
@SuppressWarnings("serial")
class DivException extends Exception {
  public DivException() {
    super();
  }

  public DivException(String message) {
    super(message);
  }
}

public class TestCustomException01 {

  public static int div(int a, int b) {
    try {
      if (0 == b) {
        throw new DivException("除数不能为0！");
      }
      return a / b;
    }
    catch (DivException e) {
      System.out.println(e); // 如果改为e.getMessage()则只输出"除数不能为0！"
      return -1;
    }
  }

  public static void main(String[] args) {
    int val = div(10, 0);
    System.out.println(val);
  }
}
