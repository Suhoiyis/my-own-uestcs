package twoThreeChapter;

public class StringTest3 {

  String a;

  public StringTest3() {
    a = "Hello, World";
  }

  public static void main(String args[]) {
    StringTest3 st = new StringTest3();
    System.out.println(st.a.replace("Hello", "你好"));
    System.out.println(st.a);
    st.a = st.a.replace("Hello", "你好");
    System.out.println(st.a);
  }

}