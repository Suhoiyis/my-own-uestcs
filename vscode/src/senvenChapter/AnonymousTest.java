package senvenChapter;

public class AnonymousTest {
  private String message;

  public AnonymousTest(String message) {
    this.message = message;
  }

  public static void main(String args[]) {
    AnonymousTest r1 = new AnonymousTest("Hello");
    new Thread(new Runnable() {// 匿名类实现Runnable接口（见第5章课件资料片）
      @Override
      public void run() { // 匿名类覆盖run方法
        for (int i = 0; i < 5; i++) {
          System.out.println(r1.message + String.valueOf(i));
        }
      }
    }).start(); // 创建Thread实例后立即启动
  }
}
