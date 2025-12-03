package senvenChapter;

class Player {
  private int hp = 100;

  public int getHP() {
    return hp;
  }

  public void setHP(int hp) {
    this.hp = hp;
  }

}

public class Creep implements Runnable {
  private Player player = new Player();

  @Override
  public void run() {
    synchronized (this) {
      for (int i = 0; i < 3; i++) {
        System.out.println(Thread.currentThread().getName() + " attack...");
        this.attack(20);
        System.out.println(Thread.currentThread().getName() + ": 当前player的hp值= " + player.getHP());
        if (player.getHP() <= 0) {
          System.out.println(Thread.currentThread().getName() + ": player is dead.");
          break;
        }
        try {
          Thread.sleep(100);
        }
        catch (InterruptedException e) {
        }
      }
      System.out.println(Thread.currentThread().getName() + " end.");
    }
  }

  public void attack(int y) {
    player.setHP(player.getHP() - y);
  }

  public static void main(String[] args) {
    Creep r = new Creep();
    Thread ca = new Thread(r, "Creep-A");
    Thread cb = new Thread(r, "\t\t\tCreep-B");
    ca.start();
    cb.start();
  }
}
