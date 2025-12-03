package fiveChapter;

class PolymorphismTest {
  @SuppressWarnings("static-access")
  public static void main(String[] args) {
    Person2 p = new Man2();
    System.out.println(p.type); // 返回结果为P
    System.out.println(p.getName()); // 返回结果为Person
  }
}

class Person2 {
  String type = "P";

  static String getName() {
    return "Person";
  }

  final String getYourName() {
    return "FJ";
  }
}

class Man2 extends Person2 {
  String type = "M";

  static String getName() {
    return "Man";
  }

  String getName(String s) {
    return "Man" + s;
  }

  final String getYourName(String s) {
    return "FJ" + s;
  }
}
