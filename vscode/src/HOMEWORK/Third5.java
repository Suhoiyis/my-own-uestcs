package HOMEWORK;

interface IShape {
    double area();
    square zoom(double factor);
}

class square implements IShape {
    private double side;

    public square(double side) {
        if (side <= 0) {
            System.out.println("错误，边长必须为正数！");
        } else {
            this.side = side;
        }
    }

    @Override
    public double area() {
        return side * side;
    }

    @Override
    public square zoom(double factor) {
        if (factor <= 0) {
            System.out.println("错误，缩放因子必须是正数！");
            return null;
        }
        return new square(side * factor);
    }

    @Override
    public String toString() {
        return String.format("正方形的边长:%.2f; 正方形的面积:%.2f", side, area());
    }
}

class SquareTest {
    public static void main(String[] args) {
        square s1 = new square(10);
        System.out.println(s1);
        square s2 = s1.zoom(0.25);
        if (s2!= null) {
            System.out.println(s2);
        }
    }
}
