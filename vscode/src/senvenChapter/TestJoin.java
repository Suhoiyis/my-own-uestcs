package senvenChapter;

public class TestJoin {
  public static void main(String[] args) throws Exception {
    SubThread4 st = new SubThread4(); // 创建SubThread4实例
    Thread t = new Thread(st, "线程1"); // 创建并开启线程

    for (int i = 1; i < 6; i++) {
      System.out.println(Thread.currentThread().getName() + ":" + i);
      if (i == 2) {
        t.start();
        t.join(); // 线程插队
      }
    }
  }
}

class SubThread4 implements Runnable {
  @Override
  public void run() { // 重写run()方法
    for (int i = 1; i < 6; i++) {
      System.out.println(Thread.currentThread().getName() + ":" + i);
    }
  }
}
