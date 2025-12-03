package nineChapter;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class ForeachTest {
  public static void main(String[] args) {
    // 以三种方式遍历集合 List
    List<String> list = new ArrayList<>();
    list.add("Google");
    list.add("Runoob");
    list.add("Taobao");

    System.out.println("方式1：普通for循环");
    for (int i = 0; i < list.size(); i++) {
      System.out.println(list.get(i));
    }

    System.out.println("方式2：使用迭代器");
    for (Iterator<String> iter = list.iterator(); iter.hasNext();) {
      System.out.println(iter.next());
    }

    System.out.println("方式3：For-Each 循环");
    for (String str : list) {
      System.out.println(str);
    }
  }
}
