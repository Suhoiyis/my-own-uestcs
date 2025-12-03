package sixChapter;

class Demo2 {
  int div(int a, int b) throws ArithmeticException, ArrayIndexOutOfBoundsException {// 通过throws关键字声明该方法可能抛出异常
    int[] arr = new int[a];
    System.err.println("arr[4] = " + arr[4]);
    return a / b;
  }
}

public class ExceptionDemo {
  public static void main(String[] args) {
    Demo2 d = new Demo2();
    try {
//      int x = d.div(4, 0);
      int x = d.div(5, 0);
      System.err.println("x=" + x);
    }
    catch (ArithmeticException e) {
      System.err.println(e);
//      throw new ArrayIndexOutOfBoundsException("制造数组越界的异常");
    }
    catch (ArrayIndexOutOfBoundsException e) {
      System.err.println(e);
    }
    catch (Exception e) {// 父类，写在此处是为了捕捉其他没预料到的异常 只能写在子类异常的catch块后面
      System.err.println(e);
    }
    finally {
      System.err.println("Over");
    }
  }
}
