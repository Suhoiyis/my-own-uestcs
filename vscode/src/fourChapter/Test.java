package fourChapter;

interface Demo {
  void show();
}

class Outer6 {

  private class Inner implements Demo {
    @Override
    public void show() {
      System.out.println("密码备份文件");
    }
  }

  public Demo getInner() { // getInner方法封装了对内部类的访问
    // 此处可以增加一些判断语句，起到数据安全的作用
    return new Inner();
  }
}

class Test {
  public static void main(String[] args) {
    Outer6 outer = new Outer6();
    // Outer6.Inner d = new Outer6().new Inner();不能直接访问内部类
    Demo d = outer.getInner();
    d.show(); // 多态（第五章详细介绍）
  }
}
