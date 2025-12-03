package twoThreeChapter;

public class ConstantPool5 {
  public static void main(String[] args) {
    String one = "someString";
    String two = new String("someString");
    System.out.println(one.equals(two));
    System.out.println(one == two);
  }
}
