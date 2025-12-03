package fiveChapter;

interface Factory { // 定义工厂接口
  Car factory();
}

class JettaFactory implements Factory {
  @Override
  public Car factory() {
    return new Jetta();
  }
}

class BenzFactory implements Factory {
  @Override
  public Car factory() {
    return new Benz();
  }
}

public class FactoryTest2 {
  public static void main(String[] args) {
    Person4 p = new Person4();
    Factory f = null;
    f = new JettaFactory();
    p.setCar(f.factory());
    p.run();
    f = new BenzFactory();
    p.setCar(f.factory());
    p.run();
  }
}
