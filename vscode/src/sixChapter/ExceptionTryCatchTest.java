package sixChapter;

import java.io.IOException;

public class ExceptionTryCatchTest {
  public void doSomething() throws IOException {
    System.out.println("do somthing");
  }

  public static void main(String[] args) {
    ExceptionTryCatchTest etct = new ExceptionTryCatchTest();
    try {
      etct.doSomething();
    }
    catch (IOException e) {

    }
    catch (Exception e) {

    }

  }

}
