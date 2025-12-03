package twoThreeChapter;

public class StringTest {

  String a, b;

  public StringTest() {
    a = "Hello,";
    b = a;
    a += "World";
  }

  public static void main(String args[]) {
    StringTest st = new StringTest();
    System.out.println(st.a);
    System.out.println(st.b);
  }
}
