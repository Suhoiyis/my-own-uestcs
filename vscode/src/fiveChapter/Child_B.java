package fiveChapter;

import fourChapter.Father_A;

public class Child_B extends Father_A {
  public void tryVariables() {
    System.out.println(a); // 允许
//  System.out.println(b); // 不允许
    System.out.println(getB());// 允许
    System.out.println(c); // 允许
  }

}
