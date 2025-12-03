package tenChapter;

import java.io.*;

class FileStreamTest {
  public static void main(String[] args) {
    if (args.length != 1) {
      System.err.println("no input data file");
      System.exit(-1);
    }
    File file = new File(args[0]);
    try {
      FileInputStream in = new FileInputStream(file);
      int c;
      int i = 0;// 记录总行数
      while ((c = in.read()) > -1) {
        if ((char) c == '\n') {
          i++;
        }
        System.out.print((char) c);
      }
      in.close();
      System.out.println("\n---------\ninput is finished");
      System.out.println("File " + args[0] + " has Lines: " + (i + 1));
    }
    catch (FileNotFoundException e) {
      System.err.println(file + " is not found");
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }
}
