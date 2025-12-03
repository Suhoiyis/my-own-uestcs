package twoThreeChapter;

public class ForeachTest {
  public static void main(String[] args) {
    int[] array = { 1, 2, 3, 4 };
    for1(array);
    foreach1(array);
    int[][] array2 = { { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 } };
    foreach2(array2);
  }

  static void for1(int[] a) {
    System.out.println("使用标准for遍历一维数组");
    for (int i = 0; i < a.length; i++) {
      System.out.print(a[i] + " ");
    }
    System.out.println();
  }

  static void foreach1(int[] data) {
    System.out.println("使用foreach遍历一维数组");
    for (int element : data) {
      System.out.print(element + " ");
    }
    System.out.print("\n");
  }

  static void foreach2(int[][] data2) {
    System.out.println("使用foreach遍历二维数组");
    for (int[] row : data2) {
      for (int element : row) {
        System.out.print(element + " ");
      }
      System.out.print("\n");
    }
  }
}
