package sixChapter;

public class TryTest2 {
  @SuppressWarnings({ "unused", "incomplete-switch" })
  public TryTest2() {
    for (int i = 0; i < 2; i++) {
      int k;
      try {
        System.out.println("\nOuter try block; Test Case #" + i);
        try {
          System.out.println("\tInner try block");
          switch (i) {
            case 0:
              int zero = 0;
              k = 8 / zero;
              break;
            case 1:
              int[] c = new int[3];
              k = c[5];
              break;
          }
        }
        catch (ArithmeticException e) {
          System.out.println("\tInner> " + e);
        }
        catch (ArrayIndexOutOfBoundsException e) {
          System.out.println("\tInner> " + e);
          throw e;
        }
        finally {
          System.out.println("\tInner finally block");
        }
      }
      catch (IndexOutOfBoundsException e) {
        System.out.println("Outer> " + e);
      }
      finally {
        System.out.println("Outer finally block");
      }
    }
  }

  public static void main(String[] args) {
    new TryTest2();
  }
}
