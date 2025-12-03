package HOMEWORK;

interface Ia {
    int max(int[] a);
}

interface Ib {
    int min(int[] a);
}

class Test2 implements Ia, Ib {


    public int max(int[] a) {
        int maxValue = a[0];
        for (int value : a) {
            if (value > maxValue) {
                maxValue = value;
            }
        }
        return maxValue;
    }


    public int min(int[] a) {
        int minValue = a[0];
        for (int value : a) {
            if (value < minValue) {
                minValue = value;
            }
        }
        return minValue;
    }

    public static void main(String[] args) {
        Test2 test2 = new Test2();
        int[] scores = {88, 89, 82, 90, 98};
        int maxScore = test2.max(scores);
        int minScore = test2.min(scores);
        System.out.println("最高分：" + maxScore);
        System.out.println("最低分：" + minScore);
    }
}
