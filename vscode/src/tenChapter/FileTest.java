package tenChapter;

import java.io.File;

public class FileTest {
  public static void main(String[] args) {
    File f = new File("MyFile.txt");
    if (f.exists()) {
      f.delete();
    }
    else {
      try {
        f.createNewFile();
      }
      catch (Exception e) {
        System.out.println(e.getMessage());
      }
    }
  }
}