package subject_instantiation;

class MyCatPro {
  public MyCatPro() {
    System.out.println("MyCatPro is ready");
  }
}

public class MyCat5 {
  MyCatPro myCatPro;// 注意这里不是继承，是关联关系；myCatPro是实例成员

  public MyCat5() {
    // 尽管这里没有调用MyCatPro的构造方法
    myCatPro = new MyCatPro();
    System.out.println("MyCat is ready");
  }

  public static void main(String[] args) {
    new MyCat5();
  }
}
