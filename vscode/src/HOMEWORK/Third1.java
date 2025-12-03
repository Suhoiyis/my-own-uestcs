package HOMEWORK;

class ClassA {
    int result = -1;
    void fun(int x, int y){
        result += x+y;
    }
    public ClassA() {
        System.out.println("Constructing Class A");
    }
    {
        System.out.println("Class A");
    }
}
public class Third1 extends ClassA {
    void fun(double x, double y) {
        result = (int) (y-x);
    }
    void show(){
        System.out.println(result);
    }
    public Third1() {
        System.out.println("Constructing Class B");
        fun(10,20);
        show();
    }
    {
        result = 1;
        System.out.println("Class B");
    }
    public static void main(String[] args) {
        Third1 Obj = new Third1();
    }
}