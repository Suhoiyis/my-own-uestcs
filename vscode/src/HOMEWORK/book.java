package HOMEWORK;

import java.util.Scanner;

public class book {
    // 两个私有属性
    private String title;
    private int pageNum;

    public book() { }

    // getTitle() 方法
    public String getTitle()
    {
        return title;
    }

    // setTitle() 方法
    public void setTitle(String title)
    {
        this.title = title;
    }

    // getPageNum() 方法
    public int getPageNum()
    {
        return pageNum;
    }

    // setPageNum() 方法
    public void setPageNum(int pageNum)
    {
        if(pageNum >0)
            this.pageNum = pageNum;
    }

    //调用infor() 方法
    public void infor()
    {
        System.out.println("书名: " + title + ", 页数: " + pageNum);
    }

    // 测试环节
    public static void main(String[] args)
    {
        // 创建两个 Book 对象
        book book1 = new book();
        book book2 = new book();

        // 通过 setTitle() 和 setPageNum() 方法为对象属性赋值
        book1.setTitle("Java 语言程序设计");
        book1.setPageNum(446);

        book2.setTitle("软件工程——实践者的研究方法");
        book2.setPageNum(327);

        // 调用 infor() 方法输出书籍信息
        book1.infor();
        book2.infor();
    }
}
