package src;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Scanner;
public class Querygrade { //输入课程名，查询该班学生成绩表页面输出
    public static void main(String[] args) {
        Scanner scan = new Scanner(System.in);
        Connection conn = null;
        Statement stmt = null;
        String url = "jdbc:postgresql://localhost:5432/gradedb";
        String username = "postgres";
        String password = "191919d";
        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(url, username, password);
            System.out.println("数据库连接成功！");
            stmt = (Statement) conn.createStatement();
            System.out.print("请输入要查询的课程名称:");
            String cname = scan.next(); //输入课程名
            String sql = "select s.sname,s.sid,g.score,g.note\r\n"
                    + "from student as s join grade as g on s.sid = g.sid\r\n"
                    + "	join course as c on g.cid = c.cid\r\n"
                    + "where c.cname = '" + cname + "'";
            ResultSet res = stmt.executeQuery(sql);
            System.out.println("查询结果为：");
            while (res.next()) {
                System.out.println(res.getString("sname") + " " + res.getString("sid") +
                        " " + res.getString("score") + " " + res.getString("note"));
            }
            stmt.close();
            conn.close();
        } catch (Exception e) {
            System.err.println(e.getClass().getName() + ":" + e.getMessage());
        }
    }
}