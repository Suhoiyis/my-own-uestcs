package fiveChapter;

class ClassA {
  void callMe() {
    System.out.println("在ClassA中的callMe()方法!");
  }
}

class ClassB extends ClassA {
  @Override
  void callMe() {
    System.out.println("在ClassB中的callMe()方法!");
  }
}

public class TestConvert {
  public static void main(String arg[]) {
    ClassA a = new ClassB();
    a.callMe();
  }
}
