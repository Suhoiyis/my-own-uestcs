package fiveChapter;

abstract class Car {
  abstract void run(); // 设立一种规范，让子类来实现
}

class Benz extends Car {
  @Override
  public void run() {
    System.out.println("Benz在行驶");
  }
}

class Jetta extends Car {
  @Override
  public void run() {
    System.out.println("Jetta在行驶");
  }
}

class Person4 {
  private Car car;

  void setCar(Car car) { // 方法的传入参数体现多态
    this.car = car;
  }

  void run() { // 定义多态，以后不管传入Car的什么子类都可以，run方法本身不用变化
    car.run();
  }
}

public class PolyTest {

  public static void main(String[] args) {
    Person4 p = new Person4();
    // 运用多态，以后不管程序员创建任何Car的子类，Person类本身不用做任何修改，直接setCar方法即可
    Jetta jt = new Jetta();
    p.setCar(jt);
    p.run();
    Benz benz = new Benz();
    p.setCar(benz);
    p.run();
  }
}
