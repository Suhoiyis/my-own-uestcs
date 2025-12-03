package subject_instantiation;

class Cat2 {
  public Cat2() {
//    System.out.println("Cat is ready");
  }
}

public class MyCat2 extends Cat2 {
  public MyCat2() {
    // 此处隐含调用super()
    System.out.println("MyCat is ready");
  }

  public static void main(String[] args) {
    new MyCat2();
  }
}
