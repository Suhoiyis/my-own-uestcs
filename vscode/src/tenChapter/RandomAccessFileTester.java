package tenChapter;

import java.io.RandomAccessFile;

class Employee {
  char[] name = { '\u0000', '\u0000', '\u0000', '\u0000', '\u0000', '\u0000', '\u0000', '\u0000' };// unicode字符
  int age;

  public Employee(String name, int age) throws Exception {
    if (name.toCharArray().length > 8) {
      System.arraycopy(name.toCharArray(), 0, this.name, 0, 8);
    }
    else {
      System.arraycopy(name.toCharArray(), 0, this.name, 0, name.toCharArray().length);
    }
    this.age = age;
  }
}

public class RandomAccessFileTester {
  String Filename;

  public RandomAccessFileTester(String Filename) {
    this.Filename = Filename;
  }

  public void writeEmployee(Employee e, int n) throws Exception {
    RandomAccessFile ra = new RandomAccessFile(Filename, "rw");
    ra.seek(n * 20); // 将位置指示器移到指定位置上，n从0开始
    for (int i = 0; i < 8; i++) {
      ra.writeChar(e.name[i]);
    }
    ra.writeInt(e.age);
    ra.close();
  }

//RandomAccessFileTester类的部分成员2（左边显示不下）
  public void readEmployee(int n) throws Exception {
    char buf[] = new char[8];
    RandomAccessFile ra = new RandomAccessFile(Filename, "r");
    ra.seek(n * 20);
    for (int i = 0; i < 8; i++) {
      buf[i] = ra.readChar();
    }
    System.out.print("name:");
    System.out.println(buf);
    System.out.println("age:" + ra.readInt());
    ra.close();
  }

  public static void main(String[] args) throws Exception {
    RandomAccessFileTester t = new RandomAccessFileTester("employeeInfo.txt");
    Employee e1 = new Employee("范闲", 18);
    Employee e2 = new Employee("haitangduoduo", 20);
    Employee e3 = new Employee("穿越的女博士叶轻眉", 30);
    t.writeEmployee(e1, 0);
    t.writeEmployee(e2, 1);
    t.writeEmployee(e3, 2);
    System.out.println("第一个雇员信息");
    t.readEmployee(0);
    System.out.println("第二个雇员信息");
    t.readEmployee(1);
    System.out.println("第三个雇员信息");
    t.readEmployee(2);
  }
}
