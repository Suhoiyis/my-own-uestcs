package twoThreeChapter;

public class SwitchTest {

  public static void main(String args[]) {
    int testScore = 97;
    char grade = 'E';
    if (testScore >= 90) {
      grade = 'A';
    }
    else if (testScore >= 80) {
      grade = 'B';
    }
    else if (testScore >= 70) {
      grade = 'C';
    }
    else {
      grade = 'D';
    }
    System.out.println(testScore + " is " + grade + "\n");
  } // Êä³ö: 97 is A
}
