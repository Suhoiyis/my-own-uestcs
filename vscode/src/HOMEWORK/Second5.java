package HOMEWORK;

interface Perarea {
    double get_area();
    double get_perimeter();
}

class Rectangle implements Perarea {
    private double length;
    private double width;

    public Rectangle(double length, double width) {
        this.length = length;
        this.width = width;
    }

    @Override
    public double get_area() {
        return length * width;
    }

    @Override
    public double get_perimeter() {
        return 2 * (length + width);
    }
}

class Circle implements Perarea {
    private double radius;

    public Circle(double radius) {
        this.radius = radius;
    }

    @Override
    public double get_area() {
        return Math.PI * radius * radius;
    }

    @Override
    public double get_perimeter() {
        return 2 * Math.PI * radius;
    }
}

public class Second5 {
    public static void main(String[] args) {
        Rectangle rectangle = new Rectangle(10, 5);
        System.out.println("长方形的面积：" + rectangle.get_area());
        System.out.println("长方形的周长：" + rectangle.get_perimeter());

        Circle circle = new Circle(5);
        System.out.println("圆的面积：" + circle.get_area());
        System.out.println("圆的周长：" + circle.get_perimeter());
    }
}
