package senvenChapter;

class TestThread extends Thread {
  private int time = 0;

  public TestThread(Runnable r, String name) {
    super(r, name);
  }

  public int getTime() {
    return time;
  }

  public int increaseTime() {
    return ++time;
  }
}

public class DemoThread implements Runnable {
  public DemoThread() {
    TestThread testthread1 = new TestThread(this, "A");
    TestThread testthread2 = new TestThread(this, "B");
    testthread2.start();
    testthread1.start();
  }

  public static void main(String[] args) {
    new DemoThread();
  }

  @Override
  public void run() {
    TestThread t = (TestThread) Thread.currentThread();
    try {
      if (!t.getName().equalsIgnoreCase("A")) {
        synchronized (this) {
          wait();// 先让除了线程A的其他线程(即线程B)进入阻塞态
        }
      }
      while (true) {
        // 本句不能放进synchronized块中，否则有一定概率死锁
        System.out.println("@time in thread" + t.getName() + "=" + t.increaseTime());
        if (t.getTime() % 2 == 0) {
          System.out.println("***********************");
          synchronized (this) {// 线程A唤醒线程B，然后阻塞自己，反之亦然
            notify();
            if (t.getTime() == 8) {
              break;
            }
            wait();
            // notify和wait方法都需放到同步代码块或方法中才能使用
          }
        }
      }
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }
}
