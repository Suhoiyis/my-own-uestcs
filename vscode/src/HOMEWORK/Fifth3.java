package HOMEWORK;

class Player1 {
    private int hp = 100; // 体力

    public int getHP() {
        return hp;
    }

    public void setHP(int hp) {
        this.hp = hp;
    }

    // 新增的同步方法
    public synchronized void beAttacked(int y) {
        for (int i = 0; i < 3; i++) {
            System.out.println(Thread.currentThread().getName() + " attack...");
            this.setHP(this.getHP() - y);
            System.out.println(Thread.currentThread().getName() + ": 当前 player 的 hp 值= " + this.getHP());
            if (this.getHP() <= 0) {
                System.out.println(Thread.currentThread().getName() + ": player is dead.");
                break;
            }
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
            }
        }
        System.out.println(Thread.currentThread().getName() + " end.");
    }
}

public class Fifth3 implements Runnable {   //Creep
    private Player1 player = new Player1();

    @Override
    public void run() {
        player.beAttacked(20);
    }

    public static void main(String[] args) {
        Fifth3 r = new Fifth3();
        Thread ca = new Thread(r, "Creep-A");
        Thread cb = new Thread(r, "\t\t\tCreep-B");
        ca.start();
        cb.start();
    }
}