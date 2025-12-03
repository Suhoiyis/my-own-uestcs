package fourChapter;

public class FinalData {

  // Cannot be compile-time constants:
  // random()返回[0,1)之间的随机浮点数
  final int I4 = (int) (Math.random() * 20); // 返回[0,20]之间的随机整数
  static final int I5 = (int) (Math.random() * 20); // I5只计算一次

  FinalData() {
//    I5 = (int) (Math.random() * 30);//非法
  }

  public void print(String id) {
    System.out.println(id + ": " + "I4 = " + I4 + ", I5 = " + I5);
  }

  public static void main(String[] args) {
    FinalData fd1 = new FinalData();
    fd1.print("fd1");
    Math.sin(30);
    FinalData fd2 = new FinalData();
    fd2.print("fd2");
  }
}
