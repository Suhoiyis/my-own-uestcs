package subject_instantiation;

class Cat3 {
  public Cat3(String s) {
    System.out.println("Cat is " + s);
  }
}

public class MyCat3 extends Cat3 {
  public MyCat3() {
    super("ready");
    System.out.println("MyCat is ready");
  }

  public static void main(String[] args) {
    new MyCat3();
  }
}
