package twoThreeChapter;

public class SwitchTest2 {
  @SuppressWarnings("incomplete-switch")
  public static void main(String args[]) {
    int testScore = 97;
    int level;
    char grade = ' ';
    level = testScore / 10;
    switch (level) {
      case 10:
      case 9:
        grade = 'A';
        break;
      case 8:
        grade = 'B';
        break;
      case 7:
        grade = 'C';
        break;
      case 6:
        grade = 'D';
        break;
      case 5:
      case 4:
      case 3:
      case 2:
      case 1:
      case 0:
        grade = 'E';
    }
    System.out.println(testScore + "  is  " + grade + "\n");
  }
}
