package fourChapter;

public class ConstructorTest2 {

  String objName;

  public ConstructorTest2(String n) {
    objName = n;
  }

  @Override // 覆盖默认的toString方法，将改写print*系列方法输出的行为（见第5章）
  public String toString() {
    return objName;
  }

  void method(ConstructorTest2 obj) {
    System.out.println(obj + "'s method is invoked");
  }

  void callMethod() {
    method(this);
  }

  public static void main(String[] args) {
    ConstructorTest2 ct = new ConstructorTest2("测试对象");
    ct.callMethod(); // 等价于ct.method(ct)，但这里不能写成ct.method(this)
  }
}
