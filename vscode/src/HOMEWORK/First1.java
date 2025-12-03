package HOMEWORK;

public class First1
{

    public static void main(String[] args) { int[][] a = { { 1, 2 }, { 4, 5 }, { 7, 8 } };
        System.out.println("数组 a 一维长度：" + a.length);
        System.out.println("数组 a 二维长度：" + a[0].length);

        int[][] d = new int[3][];
        d[0] = new int[3];
        d[1] = new int[4];
        d[2] = new int[5];
        for (int i = 0; i < d.length; i++) {
            for (int j = 0; j < d[i].length; j = j + 2) { d[i][j] = i + j;
            }
        }
        System.out.println("数组 d 中的元素：");
        for (int[] oneDimArr : d)
        {
            for (int element : oneDimArr)
            {
                System.out.print(element + " ");
            }
            System.out.println();
        }
    }
}