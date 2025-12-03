package fiveChapter;

class Test5 {
  static {
    System.out.println("Run static initialization block.");
  }

  {
    System.out.println("Run nonstatic initialization block.");
  }
}

public class ClassTest {
  public static void main(String[] args) {
    @SuppressWarnings({ "rawtypes" })
    Class t = Test5.class;
    System.out.println(t);
  }
}
