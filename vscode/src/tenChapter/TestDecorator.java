package tenChapter;

public class TestDecorator {
  public static void main(String[] args) {
    // 创建被装饰类对象
    Sourceable source = new Source();
    System.out.println("----装饰前----");
    source.method();
    System.out.println("----装饰后----");
    // 创建装饰类对象，并将被装饰类当成参数传入
    Sourceable obj = new Decorator(source);
    obj.method();
  }
}

interface Sourceable { // 定义公共接口
  void method();
}

//定义被装饰类
class Source implements Sourceable {
  @Override
  public void method() {
    System.out.println("功能1");
  }
}

//定义装饰类
class Decorator implements Sourceable {
  private Sourceable source;

  public Decorator(Sourceable source) {
    this.source = source;
  }

  @Override
  public void method() {
    System.out.println("预处理功能");
    source.method();
    System.out.println("功能1的加强部分");
  }
}
