package twoThreeChapter;

public class StringTest2 {

  String a;

  public StringTest2() {
    a = "Hello, World";
  }

  public static void main(String args[]) {
    StringTest2 st = new StringTest2();
    System.out.println(st.a.replace("Hello", "ÄãºÃ"));
    System.out.println(st.a);
  }
}
