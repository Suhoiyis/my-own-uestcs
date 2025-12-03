package tenChapter;

public class PrintFormat {
  public static void main(String[] args) {
    double d = 3.1415926;
    System.out.printf("%.2f\n", d); // 显示两位小数3.14
    System.out.printf("%.4f\n", d); // 显示4位小数3.1416，\n是换行标志
    System.out.printf("My name is %s. Age is %d\n", "FangJ", 41);// 依次使用后面参数替换
    int n = 12345000;
    System.out.printf("n=%d, hex=%08x\n", n, n); // 把一个整数格式化成十六进制，并用0补足8位
  }
}