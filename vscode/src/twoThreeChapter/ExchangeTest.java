package twoThreeChapter;

class ExchangeTest {

  public static void main(String[] args) {
    Integer a = new Integer(1);
    Integer b = new Integer(2);
    exchange(a, b);
    System.out.printf("a=%d\n", a);
    System.out.printf("b=%d\n", b);
  }

  static void exchange(Integer i, Integer j) {
    int temp;
    temp = i;
    i = j;
    j = temp;
  }

}
