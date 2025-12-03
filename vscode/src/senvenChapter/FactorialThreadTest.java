package senvenChapter;

class FactorialThreadTest {
  public static void main(String[] args) {
    System.out.println("main thread starts");
    // 计算某个整数的阶乘，在新线程中完成
    FactorialThread t = new FactorialThread(10);
    t.start(); // 将自动调用run()方法，结果是将同时运行两个线程：当前线程（执行main方法）和新线程（执行run方法）
    System.out.println("main thread ends");
  }
}

class FactorialThread extends Thread {
  private int num; // 阶乘的整数

  public FactorialThread(int num) {
    this.num = num;
  }

  @Override
  public void run() {// 线程的行为通过run方法体现；但一个线程可能涉及多个方法，因为run内部可能还会调用别的方法
    int i = num;
    int result = 1;
    System.out.println("new thread started");
    while (i > 0) {
      result = result * i;
      i = i - 1;
    }
    System.out.println("The factorial of " + num + " is " + result);
    System.out.println("new thread ends");
  }
}
