package sixChapter;

//情况1:
public class TestThrows01 {
//声明抛出异常，本方法不处理异常(这里不声明也可以，因ArithmeticException是标准库中的异常类)
  public static int div(int a, int b) throws ArithmeticException {
    return a / b;
  }

//主方法也声明抛出异常，让JVM处理，JVM只能终止程序
  public static void main(String[] args) throws ArithmeticException {
    // main()后面throws ArithmeticException可以省略，因ArithmeticException是标准库中的异常类
    int val = div(10, 0);
    System.out.println(val);
  }
}
