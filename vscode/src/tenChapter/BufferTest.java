package tenChapter;

import java.io.*;
import java.util.*;

public class BufferTest {
  public static void main(String args[]) {
    if (args.length == 0) {
      System.out.println("no input data file");
      System.exit(0);
    }
    try {
      int i, ms = 0;
      FileInputStream inf = new FileInputStream(new File(args[0]));
      Date before = new Date();
      for (i = 0; inf.read() > -1; i++) {
        ms = (int) (new Date().getTime() - before.getTime());
      }
      System.out.println("Read unbuffered: " + i + " Bytes " + ms + "ms");
      inf.close();
      BufferedInputStream bis = new BufferedInputStream(new FileInputStream(new File(args[0])));
      before = new Date();
      for (i = 0; bis.read() > -1; i++) {
        ms = (int) (new Date().getTime() - before.getTime());
      }
      System.out.println("Read buffered: " + i + " Bytes " + ms + "ms");
      bis.close();
    }
    catch (IOException e) {
      System.out.println("Cannot find " + args[0]);
      System.exit(-1);
    }
  }
}
