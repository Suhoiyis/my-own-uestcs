package subject_instantiation;

class CatPro {
  public CatPro() {
    System.out.println("CatPro is ready");
  }
}

class Cat6 {
  CatPro cp = new CatPro();

  public Cat6() {
    System.out.println("Cat is ready");
  }
}

class MyCatPro2 {
  public MyCatPro2() {
    System.out.println("MyCatPro is ready");
  }
}

public class MyCat6 extends Cat6 {
  MyCatPro2 mcp = new MyCatPro2();

  public MyCat6() {
    System.out.println("MyCat is ready");
  }

  public static void main(String[] args) {
    new MyCat6();
  }
}
