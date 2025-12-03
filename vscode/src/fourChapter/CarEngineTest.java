package fourChapter;

class Car {
  double price = 10000;
  String color = "red";
  String brand = "Honda";
  Engine myEngine = new Engine();

  void brake() {
  }

  boolean run() {
    return false;
  }
}

class Engine {
  String model = "Earth Dreams";
  double displacement = 2.0;
  double power = 200;

  boolean start() {
    return false;
  }

  boolean idle() {
    return true;
  }

  void stop() {
  }
}

public class CarEngineTest {

  public static void main(String[] args) {
    Car myCar = new Car();
    System.out.printf("my car's engine is %s\n", myCar.myEngine.model);
  }

}
