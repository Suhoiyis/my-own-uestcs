package subject_instantiation;

class TestPro {
  public TestPro() {
    System.out.println("TestPro");
  }
}

public class Test extends TestPro {
  private int a = 1;
  private int b = a + 1;

  public Test(int var) {
    System.out.println(a);
    System.out.println(b);
    this.a = var;
    System.out.println(a);
    System.out.println(b);
  }

  {
    b += 2;
  }

  public static void main(String[] args) {
    new Test(10);
  }
}
