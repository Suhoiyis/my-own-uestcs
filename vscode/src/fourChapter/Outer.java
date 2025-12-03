package fourChapter;

class Outer {
  private int age = 20;

  class Inner {// 成员内部类
    void showAge() {
      System.out.println(age);
    }
  }

  public static void main(String[] ages) {
    Outer.Inner inn = new Outer().new Inner();
    inn.showAge();
  }
}
