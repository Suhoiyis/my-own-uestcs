package sixChapter;

public class TryTest {

  public TryTest() {
    try {
      int a[] = new int[2];
      a[4] = 3; // 抛出下标越界异常
      System.out.println("在异常处理后，会返回到这吗?");
    }
    catch (IndexOutOfBoundsException e) {
      System.err.println("Exception msg:" + e.getMessage());
      System.err.println("Exception string:" + e.toString());
      e.printStackTrace();
    }
    finally {
      System.out.println("-------------");
      System.out.println("finally");
    }
    System.out.println("No exception?");
  }

  public static void main(String[] args) {
    new TryTest();
  }
}
