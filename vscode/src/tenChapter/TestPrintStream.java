package tenChapter;

import java.io.*;

public class TestPrintStream {
  public static void main(String[] args) throws Exception {
    // 创建PrintStream对象，将打印信息输出到FileOutputStream对象关联的输出文件
    PrintStream ps = new PrintStream(new FileOutputStream("print.txt"), true);// 文件名后缀不重要，存成print.dat也可以
    ps.print(203);
    ps.println("@uestc.edu.cn");
    ps.print("信软学院");
    ps.close();
    System.out.println("保存成功！");
  }
}
