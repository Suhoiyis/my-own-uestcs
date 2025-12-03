package senvenChapter;

import java.util.concurrent.*;

public class TestCallable {
  public static void main(String[] args) {
    Callable<Integer> myCallable = new SubThread3();
    FutureTask<Integer> ft = new FutureTask<>(myCallable);

    for (int i = 0; i < 4; i++) {
      System.out.println(Thread.currentThread().getName() + ":" + i);
      if (i == 1) {
        Thread thread = new Thread(ft);
        thread.start();
      }
    }
    System.out.println("主线程for循环执行完毕..");
    try {
      int sum = ft.get(); // 取得新创建线程中的call()方法返回值
      System.out.println("sum = " + sum);
    }
    catch (InterruptedException e) {
      e.printStackTrace();
    }
    catch (ExecutionException e) {
      e.printStackTrace();
    }
  }
}

class SubThread3 implements Callable<Integer> {
  private int i = 0;

  @Override
  public Integer call() throws Exception {
    int sum = 0;
    for (i = 0; i < 3; i++) {
      System.out.println(Thread.currentThread().getName() + ":  " + i);
      sum += i;
    }
    return sum;
  }
}
