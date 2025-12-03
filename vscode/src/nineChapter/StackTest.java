package nineChapter;

// 直接调用集合框架中的Stack泛型类
import java.util.Stack;

public class StackTest {

	public static void main(String[] args) {
		int tmp = 0;
		Stack<Integer> astack = new Stack<Integer>();

		// push、pop、peek方法是Stack类中自带的方法
		astack.push(10);
		astack.push(20);
		astack.push(30);

		tmp = astack.pop();
		System.out.println("tmp=" + tmp);
		tmp = (int) astack.peek();
		System.out.println("tmp=" + tmp);
		astack.push(40);
		// size和empty方法是Stack类中自带的方法
		System.out.printf("stack size = %d\n", astack.size());
		while (!astack.empty()) {
			tmp = (int) astack.pop();
			System.out.printf("tmp=%d\n", tmp);
		}
	}
}
