package senvenChapter;

class FirstThread3 implements Runnable {
  @Override
  public void run() {
    try {
      System.out.println("First thread starts");
      for (int i = 0; i < 6; i++) {
        System.out.println("First " + i);
        Thread.sleep(1000);
      }
      System.out.println("First thread finished");
    }
    catch (InterruptedException e) {
    }
  }
}

class SecondThread3 implements Runnable {
  @Override
  public void run() {
    try {
      // 加Tab退格以便区分两个线程
      System.out.println("\tSecond thread starts");
      for (int i = 0; i < 6; i++) {
        System.out.println("\tSecond " + i);
        Thread.sleep(1000);
      }
      System.out.println("\tSecond thread finished");
    }
    catch (InterruptedException e) {
    }
  }
}

public class RunTest {
  public static void main(String[] args) {
    // 创建2个线程对象
    FirstThread3 first = new FirstThread3();
    SecondThread3 second = new SecondThread3();
    new Thread(first).start();
    new Thread(second).start();
  }
}
