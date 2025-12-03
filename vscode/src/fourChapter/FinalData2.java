package fourChapter;

class Value {
  int i = 1;
}

public class FinalData2 {

  final Value v1 = new Value();
  static final Value v2 = new Value();

  final int[] a = { 1, 2, 3 };

  public static void main(String[] args) {
    FinalData2 fd1 = new FinalData2();
    // v1.i++; // Error: Cannot make a static reference to the non-static field v1（注意main是静态方法）
    // fd1.v1 = new Value(); // Error: Can't change handle
    // fd1.v2 = new Value();
    fd1.v1.i++; // v1's data member isn't constant!
    v2.i = v2.i + 10;
    System.out.printf("v1 = %d\n", fd1.v1.i);
    System.out.printf("v2 = %d\n", v2.i);

    // fd1.a = new int[3]; // Error: Can't change handle
    for (int i = 0; i < fd1.a.length; i++) {
      fd1.a[i]++; // a's member isn't constant!
    }
    System.out.printf("a = {%d,%d,%d}\n", fd1.a[0], fd1.a[1], fd1.a[2]);
  }
}