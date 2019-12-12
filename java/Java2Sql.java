package test;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Java2Sql {
    public static void main(String args[]) {
        Connection connection = null;
        try {
            Class.forName("com.mysql.jdbc.Driver");
            connection = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/test", "username", "pwd"); // Test DB
            System.out.println("Connected.");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (SQLException e) {
            e.printStackTrace();
        }

    }
}
