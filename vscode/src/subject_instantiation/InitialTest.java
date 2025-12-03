package subject_instantiation;

public class InitialTest {

  InitialTest() {
    System.out.println("a");
  }

  static int num = 4;
  int a = 5;

  {
    System.out.println("b");
    System.out.println(a);
  }

  static {
    System.out.println("c");
    num += 3;
    System.out.println(num);
  }

  static void run() // 静态方法，调用的时候才加载, 注意d最后没有打印
  {
    System.out.println("d");
  }

  public static void main(String[] args) {
    new InitialTest();
    new InitialTest();
  }
}