package HOMEWORK;

public class Triangle {
    private double sideA;
    private double sideB;
    private double sideC;

    public static class NotTriangle extends Exception {
        public NotTriangle(String message) {
            super(message);
        }
    }

    public Triangle(double a, double b, double c) throws NotTriangle {
        if (!isValid(a, b, c)) {
            throw new NotTriangle("非三角形");
        }
        this.sideA = a;
        this.sideB = b;
        this.sideC = c;
    }

    private boolean isValid(double a, double b, double c) {
        return (a + b > c) && (a + c > b) && (b + c > a) && (a > 0) && (b > 0) && (c > 0);
    }

    public double area() throws NotTriangle {
        double s = (sideA + sideB + sideC) / 2;
        return Math.sqrt(s * (s - sideA) * (s - sideB) * (s - sideC));
    }

    public static void main(String[] args) {
        try {
            Triangle t1 = new Triangle(3.0, 4.0, 5.0);
            System.out.println("三角形面积: " + t1.area());
        } catch (NotTriangle e) {
            System.out.println(e.getMessage());
        }

        try {
            Triangle t2 = new Triangle(1.0, 1.0, 2.0);
            System.out.println("三角形面积: " + t2.area());
        } catch (NotTriangle e) {
            System.out.println(e.getMessage());
        }
    }
}
