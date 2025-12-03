package senvenChapter;

public class LambdaTest {
  private String message;

  public LambdaTest(String message) {
    this.message = message;
  }

  public static void main(String args[]) {
    LambdaTest r1 = new LambdaTest("Hello");
    new Thread(() -> {// lambda表达式实现Runnable接口（见第5章课件资料片）
      for (int i = 0; i < 5; i++) {
        System.out.println(r1.message + String.valueOf(i));
      }
    } // lambda表达式可以作为对象传递
    ).start();
  }
}
