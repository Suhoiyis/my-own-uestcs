package fourChapter;

import java.util.LinkedList;
import java.util.Scanner;

/*
 * 学生信息类：一个StudentInfo对象对应一个学生的多门课的成绩信息。
 * 该类存储学号、姓名、课程、成绩的信息，并提供添加、修改的功能。
 * 注意同一个文件夹或包下（比如fourChapter）不能有同名的类定义。
*/

class StudentInfo {
	int id; // 学号
	String stuName; // 姓名
	String course[]; // 该生所选课程（本例仅为演示而简化，实际不要这么设计，最好用可变长数组或链表）
	float score[]; // 该生每门课成绩

	StudentInfo() {
		id = 0;
		stuName = "";
		course = new String[] { "语文", "数学", "英语" };// 本例为演示程序，仅有三门课，实际程序中不要写死
		score = new float[3];
	}

	// 添加学生信息
	void addInfo() {
		Scanner s = new Scanner(System.in);
		System.out.println("请输入学号：");
		id = s.nextInt(); // 尚未检查学号是否重复
		System.out.println("请输入姓名：");
		stuName = s.next();
		System.out.println("请输入语文成绩：");
		float tmp = s.nextFloat();
		while (tmp < 0 || tmp > 100) { // 尚没考虑输入不是数字的情况1
			System.out.println("成绩输入错误，请重新输入：");
			tmp = s.nextFloat();// 如果不是数字，会触发InputMismatchException异常，但本例不处理
		}
		score[0] = tmp;
		System.out.println("请输入数学成绩：");
		tmp = s.nextFloat();
		while (tmp < 0 || tmp > 100) {
			System.out.println("成绩输入错误，请重新输入：");
			tmp = s.nextFloat();
		}
		score[1] = tmp;
		System.out.println("请输入英语成绩：");
		tmp = s.nextFloat();
		while (tmp < 0 || tmp > 100) {
			System.out.println("成绩输入错误，请重新输入：");
			tmp = s.nextFloat();
		}
		score[2] = tmp;
		// s.close(); 静态的输入流在被关闭后，若又在其他地方被继续被使用，会触发NoSuchElementException异常

	}

	// 修改学生信息
	void modify() {
		Scanner s = new Scanner(System.in);
		String selected;
		for (;;) {
			System.out.println("***请选择要修改的项目：***");
			System.out.println("   a:姓名");
			System.out.println("   b:语文成绩");
			System.out.println("   c:数学成绩");
			System.out.println("   d:英语成绩");
			System.out.println("   e:返回主菜单");
			selected = s.nextLine();
			switch (selected) {
				case "a":
					System.out.println("请输如更新后的姓名：");
					stuName = s.nextLine();
					break;
				case "b":
					System.out.println("请输入更新后的语文成绩：");
					score[0] = s.nextFloat();
					s.nextLine();// 吸收掉本输入行的回车符，否则会影响下一次输入
					break;
				case "c":
					System.out.println("请输入更新后的数学成绩：");
					score[1] = s.nextFloat();
					s.nextLine();
					break;
				case "d":
					System.out.println("请输入更新后的英语成绩：");
					score[2] = s.nextFloat();
					s.nextLine();
					break;
				case "e":
					return;
				default:
					System.out.println("输入错误，请重新输入！");
					break;
			}
		}
	}

	public String toString() {
		String s = "学号：" + id + "，姓名：" + stuName + "，";
		for (int i = 0; i < 3; i++) {
			s += course[i] + "：" + score[i] + "，";
		}
		return s.substring(0, s.length() - 1);// 去掉最后一个逗号;
	}
}

/*
 * 运行测试类
 */
public class CourseManager {
	// 本类只有一个main入口方法。当然把main方法放在StudentInfo类中也可以，但为了体现功能上的独立性，单独放在一个类中更好。
	public static void main(String[] args) {
		int selected; // 选择的功能选项
		LinkedList<StudentInfo> stuList = new LinkedList<>(); // LinkedList是Java自带的链表类，采用它便于增加和删除信息。当然也可以用别的集合类来实现。关于集合类的介绍见第9章课件。
		Scanner scanner = new Scanner(System.in);
		int idt; // 存储学号
		for (;;) {
			System.out.println("------学生程序管理系统，请选择功能：------");
			System.out.println("        1:添加一个学生信息");
			System.out.println("        2:按学号查询学生信息");
			System.out.println("        3:按学号删除学生信息");
			System.out.println("        4:按学号修改学生信息");
			System.out.println("        5:显示所有学生信息");
			System.out.println("        0:退出程序");
			selected = scanner.nextInt();
			switch (selected) {
				case 1:
					stuList.add(new StudentInfo());
					stuList.getLast().addInfo();
					System.out.println("已增加一条记录");
					break;
				case 2:
					System.out.println("请输入要查询的学生的学号：");
					idt = scanner.nextInt();
					int i;
					for (i = 0; i < stuList.size(); i++) {
						if (stuList.get(i).id == idt) {
							System.out.println(stuList.get(i));
							break;
						}
					}
					if (i == stuList.size()) {
						System.out.printf("没有找到学号为%d的学生信息\n", idt);
					}
					break;
				case 3:
					System.out.println("请输入要删除的学生的学号：");
					idt = scanner.nextInt();
					int oriSize = stuList.size();
					for (i = 0; i < stuList.size(); i++) {
						if (stuList.get(i).id == idt) {
							stuList.remove(i);
							System.out.printf("已删除学号为%d的学生信息\n", idt);
							break;
						}
					}
					if (oriSize == stuList.size()) {
						System.out.printf("没有找到学号为%d的学生\n", idt);
					}
					break;
				case 4:
					System.out.println("请输入要修改信息的学生的学号：");
					idt = scanner.nextInt();
					for (i = 0; i < stuList.size(); i++) {
						if (stuList.get(i).id == idt) {
							stuList.get(i).modify();
							System.out.println("修改已保存！");
							break;
						}
					}
					if (i == stuList.size()) {
						System.out.printf("没有找到学号为%d的学生\n", idt);
					}
					break;
				case 5:
					if (stuList.isEmpty()) {
						System.out.println("尚没有学生成绩记录");
					} else {
						System.out.println("所有学生信息如下：");
						for (StudentInfo stu : stuList) {
							System.out.println(stu);
						}
					}
					break;
				case 0:
					scanner.close();
					return;
				default:
					System.out.println("输入错误，请重新输入！");
					break;
			}
		}
	}
}
