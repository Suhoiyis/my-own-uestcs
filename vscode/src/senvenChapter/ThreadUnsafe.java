package senvenChapter;

public class ThreadUnsafe implements Runnable {
  private int x = 0;

  void addSelf() {
    x++;
  }

  @Override
  public void run() {
    for (int i = 0; i < 10000; i++) {// 次数要设大一点效果才好
      addSelf();
    }
    System.out.println("finally from " + Thread.currentThread().getName() + ", x= " + x);
  }

  public static void main(String[] args) {
    ThreadUnsafe tf = new ThreadUnsafe();
    new Thread(tf, "Thread-A").start();
    new Thread(tf, "Thread-B").start();
  }
}