package HOMEWORK;

public class First2 {

    public static void main(String[] args) { int[] s = { 1, 2, 3, 4, 5 };

        change1(s);

        System.out.println("调用 change1(s)后的输出：");
        for (int i : s)
        {
            System.out.print(" " + i);
        }

        System.out.println(); change2(s);

        System.out.println("调用 change2(s)后的输出：");

        for (int i : s)
        {
            System.out.print(" " + i);
        }
        System.out.println();
    }

    private static void change1(int[] s)
    {   s[0] = 6;
        s[4] = 7;
    }

    private static void change2(int[] s)
    {    s[2] = 8;
        s = new int[] { 5, 4, 3, 2, 1 };
    }
}

