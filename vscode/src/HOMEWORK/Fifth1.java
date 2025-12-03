package HOMEWORK;

public class Fifth1 implements Runnable {
    public void run() {
        synchronized (this) {
            try {
                for (int i = 0; i < 3; i++) {
                    System.out.println(i);
                    Thread.sleep(100);
                    if (i == 1) {
                        throw new InterruptedException("打断了");
                    }
                }
            }
            catch (InterruptedException e) {
                System.out.println(e.getMessage());
            }
            finally {
                System.out.println("in finally");
            }
        }
    }
    public static void main(String[] args) {
        Fifth1 m1 = new Fifth1();
        Thread t1 = new Thread(m1);
        Thread t2 = new Thread(m1);
        t1.start();
        t2.start();
    }
}