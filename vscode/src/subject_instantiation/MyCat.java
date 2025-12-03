package subject_instantiation;

class Cat {
  public Cat() {
    System.out.println("Cat is ready");
  }
}

public class MyCat extends Cat {
  public MyCat() {
    // 此处隐含调用super()，即Cat()；但写成Cat()会报错，因为子类没有继承父类的构造方法，只能用super调用
//    super();
    System.out.println("MyCat is ready");
  }

  public static void main(String[] args) {
    new MyCat();
  }
}
