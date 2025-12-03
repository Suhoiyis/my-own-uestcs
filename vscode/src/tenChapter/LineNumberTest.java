package tenChapter;

import java.io.*;

public class LineNumberTest {

  public static void main(String[] args) {
    try {
      LineNumberReader reader = new LineNumberReader(new FileReader("test.log"));
      String line;
      while ((line = reader.readLine()) != null) {
        System.out.println(reader.getLineNumber() + ":" + line);
      }
      reader.close();
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }
}
