package twoThreeChapter;

public class PrimeNumber {
  public static void main(String args[]) {
    System.out.println("Prime numbers between 100 and 200");
    int n = 0;
    outLoop: for (int i = 101; i < 200; i += 2) {
      int k = (int) Math.sqrt(n);
      for (int j = 3; j <= k; j += 2) {
        if (i % j == 0) {
          continue outLoop;
        }
      }
      System.out.print("  " + i);
      n++;
      if (n < 10) {
        continue;
      }
      System.out.println();
      n = 0;
    }
  }
}
