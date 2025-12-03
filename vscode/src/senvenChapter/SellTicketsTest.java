package senvenChapter;

public class SellTicketsTest {
  public static void main(String[] args) {
    SellTickets t = new SellTickets();
    new Thread(t).start();
    new Thread(t).start();
    new Thread(t).start();
  }
}

class SellTickets implements Runnable {
  private int tickets = 10; // 共享数据

  @Override
  public void run() {
    while (tickets > 0) {
      System.out.println(Thread.currentThread().getName() + " is selling ticket " + tickets--);
// 3个线程同时对ticket做减法，可能造成数据不一致
    }
  }
}
