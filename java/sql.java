import java.sql.*;
// package jsonparser;
import java.io.*;
// import org.json.*;
import java.io.File;
// import org.apache.commons.io.FileUtils;
// import org.json.JSONObject;


public class sql{
// private static void readJSON() throws Exception {
//     File file = new File("./tom.json");
//     String content = FileUtils.readFileToString(file, "utf-8");
    
//     // Convert JSON string to JSONObject
//     JSONObject tomJsonObject = new JSONObject(content);    
// }
    public static void main(String args[]){
	// JSONArray a = (JSONArray) parser.parse(new FileReader("/home/sabeiro/lav/media/credenza/intertino.json"));
	// String url = "jdbc:mysql:" + (String) a.get("intertino");
	// System.out.println(url);
	// String jsonData = readFile("/home/sabeiro/lav/media/credenza/intertino.json");
	// JSONObject jobj = new JSONObject(jsonData);
	// JSONArray jarr = new JSONArray(jobj.getJSONArray("keywords").toString());
	// System.out.println("Name: " + jobj.getString("name"));
	// for(int i = 0; i < jarr.length(); i++) {
	//     System.out.println("Keyword: " + jarr.getString(i));
	// }
	// JSONParser parser = new JSONParser();
        // JSONArray jsonArray = (JSONArray) parser.parse(new FileReader("/home/sabeiro/lav/media/credenza/intertino.json"));
	// for (Object o : jsonArray) {
	//     JSONObject entry = (JSONObject) o;
	//     String strName = (String) entry.get("mysql");
        //     System.out.println("Name::::" + strName);
        // }
	
        String url = "jdbc:mysql://:3306/";
        String dbName = "";
        String driver = "com.mysql.jdbc.Driver";
        String userName = "";
        String password = "";
        try{
            //Class.forName(driver).newInstance();
	    Class.forName(driver);
	    //System.out.println("Driver Loaded");
            Connection conn = DriverManager.getConnection(url+dbName,userName,password);

            Statement stmt = conn.createStatement();
            String strsql = "select date,imps from inventory_ingombri order by date;";

            ResultSet res = stmt.executeQuery(strsql);

            while(res.next()){
                System.out.println(res.getString(1)+","+res.getString(2));
            }
            res.close();
            conn.close();
        }catch(Exception e){
            e.printStackTrace();
        }

    }
}
