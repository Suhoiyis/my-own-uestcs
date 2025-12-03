package HOMEWORK;

abstract class Person {
    public Person(String n) {
        name = n;
    }
    public abstract String getDescription();
    public String getName() {
        return name;
    }
    private String name;
}
class Employee extends Person {
    public Employee(String n, double s) {
        super(n);
        salary = s;
    }
    public double getSalary() {
        return salary;
    }
    @Override
    public String getDescription() {
        return String.format("an employee with a salary of $%.2f",
                salary);
    }
    public void raiseSalary(double byPercent) {
        double raise = salary * byPercent / 100;
        salary += raise;
    }
    private double salary;
}
class Student extends Person {
    public Student(String n, String m) {
        super(n);
        major = m;
    }
    @Override
    public String getDescription() {
        return "a student majoring in " + major;
    }
    private String major;
}
public class Second4 {
    public static void main(String[] args) {
        Person[] people = new Person[2];
        people[0] = new Employee("Harry Hacker", 50000);
        ( (Employee)people[0]).raiseSalary(10);
        people[1] = new Student("Maria Morris", "computer science");
        for (Person p:people ) {
            System.out.println(p.getName() + ", " + p.getDescription());
        }
    }
}
