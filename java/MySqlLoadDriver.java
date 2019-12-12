/* MySqlLoadDriver.java
 - Copyright (c) 2015, HerongYang.com, All Rights Reserved.
 */
import java.sql.*;
import java.util.*;
public class MySqlLoadDriver {
  public static void main(String [] args) {
    Connection con = null;
    try {
      System.out.println("Before loading SQLServerDriver:");
      listDrivers();

// Load the MySQL JDBC driver
      Class.forName("com.mysql.jdbc.Driver") ;
 
      System.out.println("After loading SQLServerDriver:");
      listDrivers();

    } catch (Exception e) {
      System.err.println("Exception: "+e.getMessage());
    }
  }
  private static void listDrivers() {
    Enumeration driverList = DriverManager.getDrivers();
    while (driverList.hasMoreElements()) {
      Driver driverClass = (Driver) driverList.nextElement();
      System.out.println("   "+driverClass.getClass().getName());
    }
  }
}
