package subject_instantiation;

class Cat4 {
  protected String name;

  public Cat4() {
    name = "Cat";
  }

  public Cat4(String name) {
    this.name = name;
  }
}

class MyCat4 extends Cat4 {
  public MyCat4(String name) {
    super(name); // 此处不能写为Cat(name);
    // 如果显式调用了super()，不管带没带参数，都不会再隐含调用无参super()了；如果把此句注释掉，则最后输出"Cat"
  }

  public static void main(String[] args) {
    MyCat4 son = new MyCat4("Lucy");
    System.out.println(son.name);
  }
}
