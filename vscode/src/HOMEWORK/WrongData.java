package HOMEWORK;

class WrongData extends Exception {
    public WrongData(String message) {
        super(message);
    }
}

class Score {
    private double[] scores;

    // score数组
    public Score(double[] scores) {
        this.scores = scores;
    }

    // 分数检查方法
    private void check() throws WrongData {
        for (double score : scores) {
            if (score < 0 || score > 100) {
                throw new WrongData("分数错误");
            }
        }
    }

    // 最高分
    public double max() {
        double max = scores[0];
        for (int i = 1; i < scores.length; i++) {
            if (scores[i] > max) {
                max = scores[i];
            }
        }
        return max;
    }

    // 最低分
    public double min() {
        double min = scores[0];
        for (int i = 1; i < scores.length; i++) {
            if (scores[i] < min) {
                min = scores[i];
            }
        }
        return min;
    }

    // 平均分
    public double average() {
        double sum = 0;
        for (double score : scores) {
            sum += score;
        }
        return sum / scores.length;
    }


    public static void main(String[] args) {
        double[] Scores1 = {85, 86, 87.5, 92.5, 94, 95};
        double[] Scores2 = {-20, 102, 88};

        try {
            Score Score1s = new Score(Scores1);
            Score1s.check();
            System.out.println("合法分数: 最小值=" + Score1s.min() + ", 最大值=" + Score1s.max() + ", 平均值=" + Score1s.average());
        } catch (WrongData e) {
            System.out.println(e.getMessage());
        }

        try {
            Score Score2s = new Score(Scores2);
            Score2s.check();
            System.out.println("非法分数: 最小值=" + Score2s.min() + ", 最大值=" + Score2s.max() + ", 平均值=" + Score2s.average());
        } catch (WrongData e) {
            System.out.println(e.getMessage());
        }
    }
}
