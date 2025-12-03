package subject_instantiation;

class Person {
  protected String name, address;

//  Person() { // 这一步不是什么都不做，至少两个成员不会再为null了
//    this("", "");
//  }

  Person(String aName, String anAddress) {
    name = aName;
    address = anAddress;
  }
}

class Employee extends Person {
  protected int employeeNumber;

  public Employee() {
    // 此处不会隐含调用Person()
    this(1); // 调用本类构造方法
  }

  public Employee(int aNumber) {
    // 此处不会隐含调用Person()
    this(null, null, aNumber); // 调用本类构造方法
  }

  public Employee(String aName, String anAddress, int aNumber) {
    super(aName, anAddress); // 调用父类构造方法
    employeeNumber = aNumber;
  }
}

public class ConstructorTest {
  public static void main(String[] args) {
    Employee em = new Employee();
    System.out.printf("name=%s, address=%s, employeeNumber=%d\n", em.name, em.address, em.employeeNumber);
    Employee em2 = new Employee(10);
    System.out.printf("name=%s, address=%s, employeeNumber=%d\n", em2.name, em2.address, em2.employeeNumber);
    Employee em3 = new Employee("a", "b", 10);
    System.out.printf("name=%s, address=%s, employeeNumber=%d\n", em3.name, em3.address, em3.employeeNumber);
  }
}
