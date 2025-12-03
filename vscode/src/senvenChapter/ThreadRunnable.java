package senvenChapter;

class ThreadRunnable implements Runnable {
  private String message;

  public ThreadRunnable(String message) {
    this.message = message;
  }

  @Override
  public void run() {
    for (int i = 0; i < 5; i++) {
      System.out.println(message + String.valueOf(i));
    }
  }

  public static void main(String args[]) {
    ThreadRunnable r1 = new ThreadRunnable("Hello");
    Thread t1 = new Thread(r1);// 创建一个线程对象；但本例不能叫单线程程序，因为main方法所在的主线程也是一个线程
    t1.start();
  }
}
