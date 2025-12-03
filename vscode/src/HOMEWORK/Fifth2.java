package HOMEWORK;

class Player {
    private int hp = 100; //体力
    public int getHP() {
        return hp;
    }
    public void setHP(int hp) {
        this.hp = hp;
    }
}
public class Fifth2 implements Runnable {               //Creep
    private Player1 player = new Player1();
    @Override
    public void run() {
        synchronized (this) {
            for (int i = 0; i < 3; i++) {
                System.out.println(Thread.currentThread().getName() + " attack...");
                this.attack(20);
                System.out.println(Thread.currentThread().getName() + ": 当 前 player 的 hp 值= " + player.getHP());
                if (player.getHP() <= 0) {
                    System.out.println(Thread.currentThread().getName() + ": player is dead.");
                    break;
                }
                try {
                    Thread.sleep(100);
                }
                catch (InterruptedException e) {
                }
            } /* for-loop */
            System.out.println(Thread.currentThread().getName() + " end.");
        } /* synchronized (this) */
    } /* run( ) */
    public void attack(int y) { //攻击掉血
        player.setHP(player.getHP() - y);
    }
    public static void main(String[] args) {
        Fifth2 r = new Fifth2();
        Thread ca = new Thread(r, "Creep-A");
        Thread cb = new Thread(r, "\t\t\tCreep-B");
        ca.start();
        cb.start();
    }
}