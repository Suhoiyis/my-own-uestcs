package HOMEWORK;

class Rect {
    double width;
    double height;

    public Rect(double width, double height) {
        this.width = width;
        this.height = height;
    }

    public Rect() {
        this.width = 10;
        this.height = 10;
    }

    public double area() {
        return width * height;
    }

    public double perimeter() {
        return 2 * (width + height);
    }
}

class PlainRect extends Rect {
    double startX;
    double startY;

    public PlainRect(double startX, double startY, double width, double height) {
        super(width, height);
        this.startX = startX;
        this.startY = startY;
    }

    public PlainRect() {
        super();
        this.startX = 0;
        this.startY = 0;
    }

    public boolean isInside(double x, double y) {
        return x >= startX && x <= (startX + width) && y < startY && y >= (startY - height);
    }
}

public class Second6 {
    public static void main(String[] args) {
        // 创建一个左上角坐标为（10，10），长为 20，宽为 10 的 PlainRect 对象
        PlainRect rect = new PlainRect(10, 10, 20, 10);
        System.out.println("矩形面积为：" + rect.area());
        System.out.println("矩形周长为：" + rect.perimeter());

        double x = 25.5;
        double y = 13;
        boolean inside = rect.isInside(x, y);
        if (inside) {
            System.out.println("点(" + x + ", " + y + ")在矩形内。");
        } else {
            System.out.println("点(" + x + ", " + y + ")不在矩形内。");
        }
    }
}
