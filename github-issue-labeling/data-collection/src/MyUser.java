import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.TreeSet;


public class MyUser {

	private static TreeSet<String> allrepoLanguages = new TreeSet<String>();
	private static TreeSet<String> allWatchedLanguages = new TreeSet<String>();
	
	private int numFollowers, numFollowing, numRepos, numWatched, numStarred;
	//private Date creationDate;
	
	//A set of languages of their public repositories
	//Change to HashMap
	private HashMap<String, Integer> repoLanguages;
	//A set of languages of the repositories they watch or have starred
	private HashMap<String, Integer> watchedLanguages;
	
	private String loginId;
	
	

	public MyUser(String loginId) {
		this.loginId = loginId;
		numFollowers=0;
		numFollowing=0;
		numRepos=0; 
		numWatched = 0;
		numStarred = 0;
		repoLanguages = new HashMap<String, Integer>();
		watchedLanguages = new HashMap<String, Integer>();
	}
	

	
	public static TreeSet<String> getAllrepoLanguages() {
		return allrepoLanguages;
	}





	public static TreeSet<String> getAllWatchedLanguages() {
		return allWatchedLanguages;
	}





	public int getNumFollowers() {
		return numFollowers;
	}



	public void setNumFollowers(int numFollowers) {
		this.numFollowers = numFollowers;
	}



	public int getNumFollowing() {
		return numFollowing;
	}



	public void setNumFollowing(int numFollowing) {
		this.numFollowing = numFollowing;
	}



	public int getNumRepos() {
		return numRepos;
	}



	public void setNumRepos(int numRepos) {
		this.numRepos = numRepos;
	}



	public int getNumWatched() {
		return numWatched;
	}



	public void setNumWatched(int numWatched) {
		this.numWatched = numWatched;
	}



	public int getNumStarred() {
		return numStarred;
	}



	public void setNumStarred(int numStarred) {
		this.numStarred = numStarred;
	}




	public HashMap<String, Integer> getRepoLanguages() {
		return repoLanguages;
	}




	public HashMap<String, Integer> getWatchedLanguages() {
		return watchedLanguages;
	}


	public String getLoginId() {
		return loginId;
	}



	public void setLoginId(String loginId) {
		this.loginId = loginId;
	}


}
