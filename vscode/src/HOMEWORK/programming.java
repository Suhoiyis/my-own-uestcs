package HOMEWORK;

import java.util.Scanner;

class Book
{
    // 两个私有属性
    private String title;
    private int pageNum;

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public int getPageNum() {
        return pageNum;
    }

    public void setPageNum(int pageNum) {
        if (pageNum > 0)
        {
            this.pageNum = pageNum;
        }
    }

    public void infor()
    {
        System.out.println("书名: " + title + ", 页数: " + pageNum);
    }
}

public class programming
{
    public static void main(String[] args)
    {
        Scanner scanner = new Scanner(System.in);
        Book book1 = new Book();
        Book book2 = new Book();

        // 获取 book1 的属性
        System.out.println("请输入 book1 的书名:");
        book1.setTitle(scanner.nextLine());

        System.out.println("请输入 book1 的页数:");
        book1.setPageNum(scanner.nextInt());

        scanner.nextLine(); // 消耗换行符

        // 获取 book2 的属性
        System.out.println("请输入 book2 的书名:");
        book2.setTitle(scanner.nextLine());

        System.out.println("请输入 book2 的页数:");
        book2.setPageNum(scanner.nextInt());

        scanner.close();

        // 输出 book1 的信息
        book1.infor();

        // 输出 book2 的信息
        book2.infor();
    }
}
