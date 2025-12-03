package nineChapter;

/**
 * Java : 数组实现的栈，能存储任意类型的数据
 */
import java.lang.reflect.Array;

public class GeneralArrayStack<T> {
	private T[] mArray;
	private int count;// 栈的实际大小

	@SuppressWarnings("unchecked")
	public GeneralArrayStack(Class<T> type, int size) {
		// 不能直接使用mArray = new T[DEFAULT_SIZE];
		mArray = (T[]) Array.newInstance(type, size);
		count = 0;
	}

	// 将val添加到栈中
	public void push(T val) {
		mArray[count++] = val;
	}

	// 返回栈顶元素
	public T peek() {
		return mArray[count - 1];
	}

	// 返回栈顶元素，并删除该元素
	public T pop() {
		T ret = mArray[count - 1];
		count--;
		return ret;
	}

	public int size() {
		return count;
	}

	public boolean isEmpty() {
		return size() == 0;
	}

	public void PrintArrayStack() {
		if (isEmpty()) {
			System.out.printf("stack is Empty\n");
		}
		System.out.printf("stack size = %d\n", size());
		int i = size() - 1;
		while (i >= 0) {
			System.out.println(mArray[i]);
			i--;
		}
	}

	public static void main(String[] args) {
		String tmp;
		GeneralArrayStack<String> astack = new GeneralArrayStack<String>(String.class, 10);
		astack.push("10");
		astack.push("20");
		astack.push("30");

		// 将栈顶元素赋给tmp，并删除栈顶元素
		tmp = astack.pop();
		System.out.println("tmp=" + tmp);
		// 只将栈顶元素赋给tmp，但不删除该元素
		tmp = astack.peek();
		System.out.println("tmp=" + tmp);
		astack.push("40");
		astack.PrintArrayStack();
	}
}
