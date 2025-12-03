package fiveChapter;

public class Test {
  public static void main(String[] args) {
    Person p = new Person();
    Man m = (Man) p;
//    Man m = new Man();
//    Person m = new Man();// 向上转型
    System.out.println(p.a);// 访问Person类的成员变量a
    System.out.println(m.a);// 访问Person类的成员变量a
    System.out.println(m.a);// 访问Man类的成员变量a
    System.out.println(p.toString()); // 执行Person类的toString方法
    System.out.println(m.toString()); // 执行Man类的toString()方法
//    System.out.println(((Man) m).toString("00")); // 执行Man类的toString(s)方法。需对m向下转型才能通过编译
  }
}

class Person {
  int a = 10;

  @Override
  public String toString() {
    return "Person";
  }
}

class Man extends Person {
  int a = 20;

  @Override
  public String toString() {// 覆盖
    return "Man";
  }

  public String toString(String s) {// 重载
    return "Man" + s;
  }
}
