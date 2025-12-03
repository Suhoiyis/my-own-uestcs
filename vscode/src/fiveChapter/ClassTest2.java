package fiveChapter;

class Test6 {
  static {
    System.out.println("Run static initialization block.");
  }

  {
    System.out.println("Run nonstatic initialization block.");
  }
}

public class ClassTest2 {
  @SuppressWarnings("unused")
  public static void main(String[] args) {
    try {
      @SuppressWarnings("rawtypes")
      Class t = Class.forName("fiveChapter.Test6");
    }
    catch (ClassNotFoundException e) {
      e.printStackTrace();
    }
  }
}
