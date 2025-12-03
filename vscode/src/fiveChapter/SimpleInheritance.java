package fiveChapter;

class SuperClass {
  int i, j;

  void showij() {
    System.out.println("i and j: " + i + " " + j);
  }
}

class SubClass extends SuperClass {
  int k;

  void showk() {
    System.out.println("k: " + k);
  }

  void sum() {
    System.out.println("i+j+k: " + (i + j + k));
  }
}

public class SimpleInheritance {
  public static void main(String args[]) {
    SuperClass superOb = new SuperClass();
    superOb.i = 10;
    superOb.j = 20;
    System.out.println("Contents of superOb: ");
    superOb.showij();

    SubClass subOb = new SubClass();
//    subOb.i = 7;
//    subOb.j = 8;
    subOb.k = 9;

    System.out.println("Contents of subOb: ");
    subOb.showij();
    subOb.showk();

    System.out.println("Sum of i, j and k in subOb:");
    subOb.sum();
  }
}
