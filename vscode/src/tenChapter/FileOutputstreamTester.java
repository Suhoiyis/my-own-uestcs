package tenChapter;

import java.io.DataOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class FileOutputstreamTester {
  public static void main(String[] args) {
    String fileName = "data1.dat";// 文件名后缀不重要，输出data1.txt也可以
    int value0 = 255, value1 = 0, value2 = -1;
    try {
      DataOutputStream out = new DataOutputStream(new FileOutputStream(fileName));
      out.writeInt(value0);
      out.writeInt(value1);
      out.writeInt(value2);
      out.close();
      System.out.println("Successfully saved");
    }
    catch (IOException iox) {
      System.out.println("Problem writing " + fileName);
    }

  }
}
