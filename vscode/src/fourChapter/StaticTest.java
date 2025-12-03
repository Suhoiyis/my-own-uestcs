package fourChapter;

public class StaticTest {

  public static int a;
  int b;
  // 静态块
  static {
    a = 2;
  }
  {
    b = 10;
  }

  // 静态变量a在所有该类的对象中共享
  StaticTest() {
    a = 3;
  }

  @SuppressWarnings("unused")
  public static void main(String[] args) {
//    StaticTest s1 = new StaticTest();
    System.out.printf("a=%d\n", StaticTest.a);
    StaticTest s1 = new StaticTest();
    System.out.printf("a=%d\n", StaticTest.a);
    StaticTest st = new StaticTest();
    System.out.printf("b=%d\n", st.b);
  }
}
