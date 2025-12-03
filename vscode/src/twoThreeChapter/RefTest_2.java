package twoThreeChapter;

public class RefTest_2 {
  public static void main(String[] args) {
    Person youngPerson = new Person();
    youngPerson.setAge(17);
    change(youngPerson);
    System.out.println("outer: " + youngPerson.getAge());
  }

  static void change(Person aPerson) {
    aPerson = new Person();
    aPerson.setAge(18);
    System.out.println("inner: " + aPerson.getAge());
  }

  static class Person {
    private Integer age;

    public Integer getAge() {
      return age;
    }

    public void setAge(Integer age) {
      this.age = age;
    }
  }
}
