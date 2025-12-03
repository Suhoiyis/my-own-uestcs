package senvenChapter;

class Clerk { // 售货员
  public int product = 0;

  public synchronized void addProduct() {
    if (product >= 5) {
      try {
        wait();
      }
      catch (InterruptedException e) {
        e.printStackTrace();
      }
    }
    else {
      product++;
      System.out.println("生产者生产了第" + product + "个产品");
      notifyAll();
    }
  }

  public synchronized void getProduct() {
    if (this.product <= 0) {
      try {
        wait();
      }
      catch (InterruptedException e) {
        e.printStackTrace();
      }
    }
    else {
      System.out.println("\t\t\t消费者取走了第" + product + "个产品");
      product--;
      notifyAll();
    }
  }
}

class Consumer implements Runnable { // 消费者
  Clerk clerk;
  int Trades = 20; // 最大交易次数

  public Consumer(Clerk clerk) {
    this.clerk = clerk;
  }

  @Override
  public void run() {
    for (int i = 0; i < Trades; i++) {
      try {
        Thread.sleep((int) Math.random() * 1000);// 这样才有利于产生连续的生产或消费
      }
      catch (InterruptedException e) {
      }
      clerk.getProduct();
    }
  }
}

class Productor implements Runnable { // 生产者
  Clerk clerk;
  int Trades = 20;

  public Productor(Clerk clerk) {
    this.clerk = clerk;
  }

  @Override
  public void run() {
    for (int i = 0; i < Trades; i++) {
      try {
        Thread.sleep((int) Math.random() * 1000);
      }
      catch (InterruptedException e) {
      }
      clerk.addProduct();
    }
  }
}

public class TestProduct {
  public static void main(String[] args) {
    Clerk clerk = new Clerk();
    Thread productorThread = new Thread(new Productor(clerk));
    Thread consumerThread = new Thread(new Consumer(clerk));
    productorThread.start();
    consumerThread.start();
  }
}
