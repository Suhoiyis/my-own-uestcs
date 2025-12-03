package subject_instantiation;

class Print {
  Print(String s) {
    System.out.print(s + " ");
  }
}

abstract class Print2 {
  void printaaa(String s) {
    System.out.print(s + " ");
  }

  public Print2() {
    @SuppressWarnings("unused")
    int a = 2;
  }
}

class Parent {
  static Print obj1 = new Print("1");
  Print obj2 = new Print("2");

  static {
    new Print("3");
  }

  {
    @SuppressWarnings("unused")
    Print obj3 = new Print("4");
  }

  Parent() {
    new Print("5");
  }
}

public class Child extends Parent {
  static {
    new Print("a");
  }

  Child() {
    @SuppressWarnings("unused")
    Print obj1 = new Print("b");
  }

  {
    new Print("c");
  }

  Print obj2 = new Print("d");
  static Print obj3 = new Print("e");

  public static void main(String[] args) {
    new Child();
    new Child();
  }
}
