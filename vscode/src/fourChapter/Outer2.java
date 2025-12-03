package fourChapter;

class Outer2 {
  private int age = 18;

  class Inner { // 不会和Outer.java里定义的Inner内部类相冲突
    private int age = 20;

    void showAge() {
      int age = 25;
      System.out.println(age);// 25
      System.out.println(this.age);// 20
      System.out.println(Outer2.this.age);// 18
    }
  }

  public static void main(String[] ages) {
    Outer2.Inner inn = new Outer2().new Inner();
    inn.showAge();
  }
}
