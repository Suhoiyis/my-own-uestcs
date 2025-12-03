package fiveChapter;

interface IIntStack {
	void push(int item);

	int peek();

	int pop();

	void printStack();

	int size();

	boolean isEmpty();
}

// 以数组作为容器的栈
class ArrayIntStack implements IIntStack {
	private int[] mArray;
	private int count;

	public ArrayIntStack(int size) {
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

	public void printStack() {
		if (isEmpty()) {
			System.out.printf("stack is Empty\n");
		}

		System.out.printf("array stack size = %d\n", size());

		int i = size() - 1;
		while (i >= 0) {
			System.out.println(mArray[i]);
			i--;
		}
	}

}

// 一个链表结点
class Node {
	int data;
	Node next; // 指向下一个结点的指针
}

// 以链表作为容器的栈
class ListIntStack implements IIntStack {
	private Node top;// 顶部结点
	private int count;

	public ListIntStack() {
		this.top = null;
		this.count = 0;
	}

	public void push(int x) {
		Node node = new Node();
		node.data = x;
		// 新结点的next变量指向顶部结点（Java没有指针，但可以理解为next封装了指向Node类型的指针）
		node.next = top;
		// 更新顶部结点位置为当前新结点
		top = node;
		count += 1;
	}

	public int peek() {
		if (isEmpty()) {
			System.out.println("The stack is empty");
			System.exit(-1);
		}
		return top.data;
	}

	public int pop() {
		if (isEmpty()) {
			System.out.println("Stack Underflow");
			System.exit(-1);
		}
		int topItem = peek();
		count -= 1;
		// 更新顶部结点位置为下一个结点
		top = top.next;
		return topItem;
	}

	public int size() {
		return this.count;
	}

	public boolean isEmpty() {
		return top == null;
	}

	public void printStack() {
		if (isEmpty()) {
			System.out.printf("stack is Empty\n");
		}

		System.out.printf("list stack size = %d\n", size());

		Node ite = top;
		while (ite != null) {
			System.out.println(ite.data);
			ite = ite.next;
		}
	}
}

// 测试代码。此例由于有多个类，把main放入哪个类从逻辑上都不太合适（尽管也能运行），故单独设置一个类。
class Main {

	public static void main(String[] args) {
		int tmp;
		IIntStack astack;
		// astack = new ArrayIntStack(10);
		astack = new ListIntStack(); // 此处可以切换栈的实现方式
		astack.push(10);
		astack.push(20);
		astack.push(30);
		tmp = astack.pop();
		System.out.println("tmp=" + tmp);
		tmp = astack.peek();
		System.out.println("tmp=" + tmp);
		astack.push(40);
		astack.printStack();
	}
}
