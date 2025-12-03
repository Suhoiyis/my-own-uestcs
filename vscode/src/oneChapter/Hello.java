package oneChapter;

public class Hello {
	int x = 10, y = 100;

	/**
	 * @param a
	 * @param b
	 * @return
	 */
	int max(int a, int b) {
		return (a > b) ? a : b;
	}

	public static void main(String args[]) {// main方法也可以放在另一个单独的类中，但没有必要。且这时Hello类就不能为public了。
		int z;
		Hello h = new Hello();
		// q: what does the println function do?

		System.out.println("h.x = " + h.x + ",  h.y = " + h.y);
		z = h.max(h.x, h.y);
		System.out.println("Max value = " + z);
	}
}
