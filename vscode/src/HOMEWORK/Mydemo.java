package HOMEWORK;

public class Mydemo
{

    static int a = 2;
    static int b = 3;

    static void callme()
    {
        System.out.println("callme a = " + a);
        System.out.println("callme b = " + b);
    }

    void resetAB(int i, int j)
    {
        a += i;
        b += j;
    }

    public static void main(String args[]) { Mydemo obj = new Mydemo();
        Mydemo obj1 = new Mydemo();
        obj.resetAB(4,5);
        obj1.resetAB(2,3);
        Mydemo.callme();
        System.out.println("Mydemo.a="+ Mydemo.a);
        System.out.println("Mydemo.b="+ Mydemo.b);
        System.out.println("obj1.a = " + obj1.a);
        System.out.println("obj1.b = " + obj1.b);
    }
}




