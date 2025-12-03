package fiveChapter;

public interface MyInterface {
  int x = 0; // 默认public static final,写不写都行

  int y = 0;// 字段要在定义的时候初始化

  void method1();// 默认public abstract, 写不写都行
}

interface MyInterface2 {
  int z = 0;

  void method2();
}

interface MyInterface3 extends MyInterface, MyInterface2 {// 接口可以多继承，类不行
  int w = 0;

  void method3();
}

interface MyInterface4 {
  void method4();
}

class Imp1 implements MyInterface, MyInterface2 {
  @Override
  public void method1() {

  }

  @Override
  public void method2() {

  }
}

class Imp2 implements MyInterface3, MyInterface4 {
  @Override
  public void method1() {

  }

  @Override
  public void method2() {

  }

  @Override
  public void method3() {

  }

  @Override
  public void method4() {

  }
}