import java.io.FileReader;
import java.util.Iterator;
 
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

class json {
    @SuppressWarnings("unchecked")
    public static void main(String[] args) {
        JSONParser parser = new JSONParser();
        try {
            Object obj = parser.parse(new FileReader("/home/sabeiro/lav/media/credenza/intertino.json"));
            JSONObject jsonObject = (JSONObject) obj;
            String name = (String) jsonObject.get("Name");
            String author = (String) jsonObject.get("Author");
            JSONArray companyList = (JSONArray) jsonObject.get("Company List");
            System.out.println("Name: " + name);
            System.out.println("Author: " + author);
            System.out.println("\nCompany List:");
            Iterator<String> iterator = companyList.iterator();
            while (iterator.hasNext()) {
                System.out.println(iterator.next());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }    
    public static void main2(String[] args){
	JSONParser parser = new JSONParser();
	String s = "[0,{\"1\":{\"2\":{\"3\":{\"4\":[5,{\"6\":7}]}}}}]";
	try{
	    Object obj = parser.parse(s);
	    JSONArray array = (JSONArray)obj;
			
	    System.out.println("The 2nd element of array");
	    System.out.println(array.get(1));
	    System.out.println();

	    JSONObject obj2 = (JSONObject)array.get(1);
	    System.out.println("Field \"1\"");
	    System.out.println(obj2.get("1"));    

	    s = "{}";
	    obj = parser.parse(s);
	    System.out.println(obj);

	    s = "[5,]";
	    obj = parser.parse(s);
	    System.out.println(obj);

	    s = "[5,,2]";
	    obj = parser.parse(s);
	    System.out.println(obj);
	}catch(ParseException pe){
		
	    System.out.println("position: " + pe.getPosition());
	    System.out.println(pe);
	}
    }
}





