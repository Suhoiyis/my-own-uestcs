package senvenChapter;

public class TestTicket1 {
  public static void main(String[] args) {
    Ticket1 ticket = new Ticket1();
    Thread t1 = new Thread(ticket);
    Thread t2 = new Thread(ticket);
    Thread t3 = new Thread(ticket);
    t1.start();
    t2.start();
    t3.start();
  }
}

class Ticket1 implements Runnable {
  private int ticket = 5;

  @Override
  public void run() {
    for (int i = 0; i < 100; i++) {
      if (ticket > 0) {
        try {
          Thread.sleep(100);
        }
        catch (InterruptedException e) {
          e.printStackTrace();
        }
        System.out.println("卖出第" + ticket + "张票，还剩" + --ticket + "张票");
      }
    }
  }
}
