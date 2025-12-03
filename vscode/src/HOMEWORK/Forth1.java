package HOMEWORK;

public class Forth1 {
    void doSomething(int i) {
        try {
            switch (i) {
                case 0:
                    int a[] = new int[2];
                    a[2] = 2;
                    System.out.println("case 0");
                    break;
                case 1:
                    int x = 0;
                    int y = 2 / x;
                    System.out.println("case 1");
                    break;
                default:
                    System.out.println("default");
            }
        } catch (IndexOutOfBoundsException e) {
            System.out.println("数组下标越界");
        } catch (ArithmeticException e) {
            System.out.println("被零除");
        } finally {
            System.out.println("finally");
        }
    }
    public static void main(String[] args) {
        Forth1 t = new Forth1();
        for (int i = 0; i < 3; i++) {
            t.doSomething(i);
        }
    }
}
