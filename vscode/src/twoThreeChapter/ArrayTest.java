package twoThreeChapter;

public class ArrayTest {
  public static void main(String[] args) {
    int[] a = new int[2];// a={0,0,0}
    int[] b = a;
    b[0] = b[0] + 1;// a=b={1,0,0}
    System.out.println(a[0]);// 1
    int n = 0;
    int m = n;
    m = m + 1;// m=1,n=0
    System.out.println(n);
  }
}
