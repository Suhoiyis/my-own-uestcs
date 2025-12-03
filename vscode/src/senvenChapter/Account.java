package senvenChapter;

public class Account {
  static int balance = 0;

  Account() {
    DepositThread first, second;
    first = new DepositThread(this, 1000, "#1");
    second = new DepositThread(this, 500, "\t\t\t\t#2");
    first.start();
    second.start();
    try {
      first.join();
      second.join();
    }
    catch (InterruptedException e) {
    }
    System.out.println("------------------------------");
    System.out.println("Final balance is " + balance);
  }

  synchronized void Deposit(int amount, String name) {
    System.out.println(name + " balance got is " + balance);
    System.out.println(name + " trying to deposit " + amount);
    setBalance(getBalance() + amount);
    System.out.println(name + " new balance set to " + balance);
  }

  int getBalance() {
    try {
      Thread.sleep(500);
    }
    catch (InterruptedException e) {
    }
    return balance;
  }

  void setBalance(int bal) {
    try {
      Thread.sleep(500);
    }
    catch (InterruptedException e) {
    }
    balance = bal;
  }

  public static void main(String[] args) {
    new Account();
  }
}

class DepositThread extends Thread {
  Account account;
  int amount;
  String name;

  DepositThread(Account account, int amount, String name) {
    this.account = account;
    this.amount = amount;
    this.name = name;
  }

  @Override
  public void run() {
    for (int i = 0; i < 3; i++) {
      account.Deposit(amount, name);
    }
  }
}
