package oneChapter;

public class Car {
  public String brand;
  public String color;
  public double price;

  public static void main(String[] args) {
    Car myCar = new Car();
    myCar.brand = "Honda CIVIC";
    myCar.color = "green";
    myCar.price = 119900;
    myCar.run();
    myCar.brake();
    myCar.priceChange();
    System.out.println("The new price is " + myCar.price);
  }

  public void brake() {
    System.out.println("The car is stopping!");
  }

  public boolean run() {
    boolean ifAccident = false;
    return ifAccident;
  }

  public double priceChange() {
    return price = price * 1.1;
  }
}
