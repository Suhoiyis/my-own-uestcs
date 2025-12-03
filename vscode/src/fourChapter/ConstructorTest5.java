package fourChapter;

class Student2 {
  int rollno;
  String name;
  float fee;

  Student2(int r, String n, float f) {
    rollno = r;// 写成this.rollno = r也不影响
    name = n;
    fee = f;
  }

  void display() {
    System.out.println(rollno + " " + name + " " + fee);
  }
}

public class ConstructorTest5 {
  public static void main(String args[]) {
    Student2 s1 = new Student2(111, "Lilei", 5000f);
    Student2 s2 = new Student2(112, "Yaomin", 6000f);
    s1.display();
    s2.display();
  }
}
