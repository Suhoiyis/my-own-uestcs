package fiveChapter;

import java.util.Date;

class Person3 {
  String name;
  char gender;
  Date birthday;

  void setData(String n, char s, Date b) {
    name = n;
    gender = s;
    birthday = b;
  }
}

class Student extends Person3 {
  String stuID;
  String speciality;

  void setData(String n, char s, Date b, String id, String spec) {
    setData(n, s, b);
    stuID = id;
    speciality = spec;
  }
}

public class InheritTest2 {
  @SuppressWarnings("rawtypes")
  public static void main(String[] args) throws Exception {
    Person3 person = new Person3();
    Class t = person.getClass();
    System.out.println(t.getName());// µÈÍ¬ÓÚSystem.out.println(t)
    System.out.println(person);
    Person3 person2 = person.getClass().newInstance();
    System.out.println(person2);
    Student student = new Student();
    Class t2 = student.getClass();
    System.out.println(t == t2.getSuperclass());
    System.out.println(t2.isInstance(student));
  }

}
