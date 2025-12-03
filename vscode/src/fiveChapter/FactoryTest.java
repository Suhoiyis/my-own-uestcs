package fiveChapter;

class CarFactory {
  static Car factory(String carName) {
    if (carName.equals("Jetta")) {
      return new Jetta();
    }
    else if (carName.equals("Benz")) {
      return new Benz();
    }
    else {
      System.out.println("Î´Öª³µÐÍ");
      return null;
    }
  }
}

public class FactoryTest {
  public static void main(String[] args) {
    Person4 p = new Person4();
    p.setCar(CarFactory.factory("Jetta"));
    p.run();
    p.setCar(CarFactory.factory("Benz"));
    p.run();
  }
}
