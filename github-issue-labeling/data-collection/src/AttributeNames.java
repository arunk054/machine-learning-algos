import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;


public class AttributeNames {

	
	private ArrayList<String> names;
	
	private static final String PREFIX_REPO = "REPO_";
	private static final String PREFIX_WATCH = "WATCH_";
	
	public AttributeNames() {
		names=new ArrayList<String>();
		//Populate the attribute names
		names.add("issue_id");
		names.add("number_of_comments");
		names.add("creation_date");
		names.add("closing_date");
		names.add("number_of_hours_to_close");
		names.add("created_by");
		
		//All languages of all repos
		for (String langName: MyUser.getAllrepoLanguages()){
			names.add(PREFIX_REPO+langName);
		}
		//All languages of all watched and starred
		for (String langName: MyUser.getAllWatchedLanguages()){
			names.add(PREFIX_WATCH+langName);
		}
		
		names.add("number_of_followers");
		names.add("number_of_following");
		names.add("number_of_repos");
		names.add("number_of_watched");
		names.add("number_of_starred");
		
		names.add("title");
		names.add("body");
		names.add("IS_Label_CSS");
	}

	public ArrayList<String> getNames() {
		return names;
	}

	public void setNames(ArrayList<String> names) {
		this.names = names;
	}
	
	
	
	
}
