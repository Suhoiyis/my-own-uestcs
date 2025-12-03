package fourChapter;

class Person {
  private static int count; // 保存对象创建的个数
  private static String ClassName = "Person";

  public Person() {
    count++;
  }

  public static void say(int i) {
    System.out.printf("第%d次say: ", i);
    System.out.println(ClassName + "实例化次数：" + count);
  }
}

public class StaticMethod {

  public static void main(String[] args) {
    Person.say(1);
    new Person();
    new Person();
    new Person();
    Person.say(2);

  }
}