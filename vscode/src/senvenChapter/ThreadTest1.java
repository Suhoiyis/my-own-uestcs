package senvenChapter;

class FirstThread extends Thread {
  @Override
  public void run() {
    try {
      System.out.println("First thread starts");
      for (int i = 0; i < 6; i++) {
        System.out.println("First " + i);
        sleep(1000);
      }
      System.out.println("First thread finishes");
    }
    catch (InterruptedException e) {
    }
  }
}

class SecondThread extends Thread {
  @Override
  public void run() {
    try {
      System.out.println("\tSecond thread starts"); // 加退格以便区分显示这两个线程
      for (int i = 0; i < 6; i++) {
        System.out.println("\tSecond " + i);
        sleep(1000);
      }
      System.out.println("\tSecond thread finishes");
    }
    catch (InterruptedException e) {
    }
  }
}

class ThreadTest1 {
  public static void main(String[] args) {
    FirstThread first = new FirstThread();
    SecondThread second = new SecondThread();
    first.start();
    second.start();
  }
}
