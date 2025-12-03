package senvenChapter;

public class ThreadTest2 {
  @SuppressWarnings("deprecation")
  public ThreadTest2() {
    FirstThread2 first = new FirstThread2();
    SecondThread2 second = new SecondThread2();
    first.start();
    second.start();
    try {
      System.out.println("m: First thread join");
      first.join();
      System.out.println("m: Second thread resume");
      second.resume();
    }
    catch (InterruptedException e) {
    }
  }

  public static void main(String[] args) {
    new ThreadTest2();
  }
}

class FirstThread2 extends Thread {
  @Override
  public void run() {
    try {
      System.out.println("f: First thread STARTS");
      for (int i = 0; i < 6; i++) {
        System.out.println("First " + i);
        sleep(500);
      }
      System.out.println("f: First thread FINISHES");
    }
    catch (InterruptedException e) {
    }
  }
}

class SecondThread2 extends Thread {
  @SuppressWarnings("deprecation")
  @Override
  public void run() {
    try {
      System.out.println("\t\t\t\ts: Second thread STARTS");
      for (int i = 0; i < 6; i++) {
        if (i == 4) {
          System.out.println("\t\t\t\ts: Second thread SUSPENDS");
          suspend();
        }
        System.out.println("\t\t\t\tSecond " + i);
        sleep(500);
      }
      System.out.println("\t\t\t\ts: Second thread FINISHES");
    }
    catch (InterruptedException e) {
    }
  }
}