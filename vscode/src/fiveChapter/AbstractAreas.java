package fiveChapter;

abstract class Figure {
  double dim1;
  double dim2;

  Figure(double a, double b) {
    dim1 = a;// 在不同的图形中a和b指代的量不一样
    dim2 = b;
  }

  final void show() {
    System.out.println("This is a abstract class");
  }

  abstract double area();// 计算面积要根据具体的图形来定
}

class Rectangle extends Figure {
  Rectangle(double a, double b) {
    super(a, b);// a,b指代长宽
  }

  @Override
  double area() {
    System.out.println("Inside Area for Rectangle.");
    return dim1 * dim2;
  }
}

class Triangle extends Figure {
  Triangle(double a, double b) {
    super(a, b);// a,b指代底和高
  }

  @Override
  double area() {
    System.out.println("Inside Area for Triangle.");
    return dim1 * dim2 / 2;
  }
}

class AbstractAreas {
  public static void main(String args[]) {
    // Figure f = new Figure(10, 10); // illegal now
    Rectangle r = new Rectangle(10, 5);
    Triangle t = new Triangle(10, 5);
    Figure figref; // this is OK, no object is created
    figref = r;// 多态
    System.out.println("Area is " + figref.area());
    figref = t;
    System.out.println("Area is " + figref.area());
  }
}
