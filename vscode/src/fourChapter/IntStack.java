package fourChapter;

/* 本代码仅是整数栈的功能简化版，不是实用代码 */
public class IntStack {
	private int[] mArray;
	private int count;

	public IntStack(int size) {
		mArray = new int[size];
		count = 0;// 栈的实际大小
	}

	// 将val添加到栈中
	public void push(int val) {
		mArray[count++] = val;
	}

	// 返回栈顶元素
	public int peek() {
		return mArray[count - 1];
	}

	// 返回栈顶元素，并删除该元素
	public int pop() {
		int ret = mArray[count - 1];
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
		int tmp;
		IntStack astack = new IntStack(10);

		astack.push(10);
		astack.push(20);
		astack.push(30);

		// 将“栈顶元素”赋值给tmp，并删除“栈顶元素”
		tmp = astack.pop();
		System.out.println("tmp=" + tmp);

		// 只将“栈顶”赋值给tmp，不删除该元素.
		tmp = astack.peek();
		System.out.println("tmp=" + tmp);

		astack.push(40);
		astack.PrintArrayStack();
	}
}