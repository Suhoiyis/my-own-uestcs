package fiveChapter;

class Test3 {

  static {
    System.out.println("Run static initialization block.");
  }

  {
    System.out.println("Run nonstatic initialization block.");
  }
}

public class ClassTest3 {

  public static void main(String[] args) {
    Test3 t = new Test3();
    @SuppressWarnings({ "unused", "rawtypes" })
    Class test = t.getClass();
  }
}
