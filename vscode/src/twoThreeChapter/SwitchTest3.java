package twoThreeChapter;

public class SwitchTest3 {

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
      default:
        grade = 'E';
    }
    System.out.println(testScore + " is " + grade + "\n");
  }

}
