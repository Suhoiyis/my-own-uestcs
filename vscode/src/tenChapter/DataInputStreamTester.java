package tenChapter;

import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.IOException;

public class DataInputStreamTester {
  public static void main(String[] args) {
    String fileName = "data1.dat";// 文件名后缀不重要，读取data1.txt也可以
    int sum = 0;
    try {
      DataInputStream instr = new DataInputStream(new FileInputStream(fileName));
      sum += instr.readInt();
      sum += instr.readInt();
      sum += instr.readInt();
      System.out.println("The sum is: " + sum);
      instr.close();
    }
    catch (IOException iox) {
      System.out.println("Problem reading " + fileName);
    }
  }
}
