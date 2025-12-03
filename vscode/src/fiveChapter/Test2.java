package fiveChapter;

class Test2 {
  public static void main(String[] args) {
    Animal a = new Dog();
    a.eat();
    if (a instanceof Cat) {// 判断a是否是Cat类型或其子类型，因为catchMouse是Cat类特有的方法
      Cat c = (Cat) a;
      c.catchMouse();
    }
  }
}

class Animal {
  void eat() {
  }
}

class Dog extends Animal {
  void guard() {
  }
}

class Cat extends Animal {
  void catchMouse() {
  }
}
