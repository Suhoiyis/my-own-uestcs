package oneChapter;

public class VariableTest {
  int x = 10, y = 100;

  int max(int a, int b) {
    // return a > b ? a : b;
    if (minOrEqual(a, b)) {// 类中方法直接访问
      return b;
    } else {
      return a;
    }
  }

  boolean minOrEqual(int a, int b) {
    return a <= b;// 直接访问实例字段
  }

  public static void main(String args[]) {
    int z;
    VariableTest h = new VariableTest();// main方法是静态，要先初始化Hello对象
    // System.out.println("h.x = " + x + ", h.y = " + y);//非法
    System.out.println("h.x = " + h.x + ",  h.y = " + h.y);
    z = h.max(h.x, h.y);
    System.out.println("Max value = " + z);

    // System.out.println("Max value = " + MyString.w);//非法
    System.out.println("Static variable = " + MyString.v);// 合法
    MyString ms = new MyString();
    System.out.println("Instance variable = " + ms.w);
  }
}

class MyString {
  String w = "Hello";
  static String v = "Static Hello";
}
