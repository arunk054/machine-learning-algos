import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.Closeable;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.Map;

import org.kohsuke.github.GHIssue;
import org.kohsuke.github.GHRepository;
import org.kohsuke.github.GHUser;
import org.kohsuke.github.GitHub;

import research.coordinst.divider.GhIssueIterator;


public class TempMiner {

	public static String repoName = "twbs/bootstrap";
	public static String classLabel = "css";
	public static String inputFile = "complete_dataset_ids.txt";
	public static String outputCSVFile = "complete_dataset_v1.csv";
	
	public static void main(String[] args) {
		

		System.out.println("Your Github Password should be the first command line argument");
		System.out.println();
		
		ArrayList<MyInstance> instances   = new ArrayList<MyInstance>();
		
		//Read my file containing issue ids,
		BufferedReader brIds = null;
		GitHub github = null;
		//open the file
		try{
				brIds = new BufferedReader(new FileReader(new File(TempMiner.inputFile)));

				github = GitHub.connectUsingPassword("arunk054", args[0]);
				System.out.println(github.getMyself());
				System.out.println("---------------");
				GHRepository targetRepo = github.getRepository(TempMiner.repoName);
				System.out.println("Looking into the issue at : "+targetRepo.getFullName());
				System.out.println("----------------");
				System.out.println();
				
				//Read each issue from the file
				String line = null;
				
				while ((line = brIds.readLine())!= null) {
					int issueId = 0;
					try{
						issueId = Integer.parseInt(line);
					} catch (NumberFormatException e) {
						//
						System.out.println("Incorrect ID in file: "+line);
						continue;
					}
					System.out.println("Reading issue Id: "+issueId);
					
					//Look up the GHIssue object on github
					GHIssue issue = targetRepo.getIssue(issueId);
					
					//Create an Instance
					MyInstance instance = new MyInstance(issueId, (issue.getTitle()==null)?"":issue.getTitle());
					
					//Populate all objects in that instance
					instance.setBody((issue.getBody()==null)?"":issue.getBody());
					instance.setCreationDate(issue.getCreatedAt());
					instance.setClosingDate(issue.getClosedAt());
					instance.setNoOfComments(issue.getCommentsCount());
					instance.updateNumberOfHoursToClose();
					//Populate labels
					instance.addLabels(issue.getLabels());
					//Add the user
					GHUser  ghUser = issue.getUser();
					instance.initializeCreatedByUser(ghUser.getLogin());
					MyUser user = instance.getCreatedByUser();
					//populate fields within this user
					user.setNumFollowers(ghUser.getFollowersCount());
					user.setNumFollowing(ghUser.getFollowingCount());
					//Populate the repo languages and num repos
					Map<String,GHRepository> repositories = ghUser.getRepositories();
					user.setNumRepos(repositories.size());
					for (GHRepository repo: repositories.values()){
						
						if (repo != null ){
							
							if (repo.getLanguage() != null && !repo.getLanguage().isEmpty()){
								MyUser.getAllrepoLanguages().add(repo.getLanguage());
								Integer val = null;
								if ((val= user.getRepoLanguages().get(repo.getLanguage())) != null){
									user.getRepoLanguages().put(repo.getLanguage(),val+1);
								} else {
									user.getRepoLanguages().put(repo.getLanguage(),1);
								}
							}
						}
					}
					
					//Populate the watched repo languages and num watched
					repositories = ghUser.getWatchedRepositories();					
					user.setNumWatched(repositories.size());
					for (GHRepository repo: repositories.values()){
						
						if (repo.getLanguage() != null && !repo.getLanguage().isEmpty()){
							MyUser.getAllWatchedLanguages().add(repo.getLanguage());
							
							Integer val = null;
							if ((val= user.getWatchedLanguages().get(repo.getLanguage())) != null){
								user.getWatchedLanguages().put(repo.getLanguage(),val+1);
							} else {
								user.getWatchedLanguages().put(repo.getLanguage(),1);
							}
						}

					}
					
					repositories = ghUser.getStarredRepositories();					
					user.setNumStarred(repositories.size());
					for (GHRepository repo: repositories.values()){
						
						if (repo.getLanguage() != null && !repo.getLanguage().isEmpty()){
							MyUser.getAllWatchedLanguages().add(repo.getLanguage());
							Integer val = null;
							if ((val= user.getWatchedLanguages().get(repo.getLanguage())) != null){
								user.getWatchedLanguages().put(repo.getLanguage(),val+1);
							} else {
								user.getWatchedLanguages().put(repo.getLanguage(),1);
							}
						}
						
					}	
					instances.add(instance);
				}
			
		} catch(IOException e){
			e.printStackTrace();
		} finally{
			closeQuietly(brIds);
		}
		
		
		//Open an output file to write
		BufferedWriter csvOutput = null ;
		System.out.println("Writing to csv File: "+outputCSVFile);
		try {
			csvOutput = new BufferedWriter(new FileWriter(new File(TempMiner.outputCSVFile)));
			
			//Write the attribute headers to the file
			
			AttributeNames attrNames = new AttributeNames();
			for (Iterator iterator = attrNames.getNames().iterator(); iterator.hasNext();) {
				String attrName = (String) iterator.next();
				csvOutput.write(CSVManager.alwaysQuote(attrName));
				if (iterator.hasNext()){
					csvOutput.write(",");
				}
			}
			csvOutput.write("\n");
			//Iterate through instance list and write each instance to the file
			
			for (Iterator iterator = instances.iterator(); iterator.hasNext();) {
				String csvRecord = "";	
				MyInstance myInstance = (MyInstance) iterator.next();
				System.out.println("Writing record: "+ myInstance.getIssueId());
				//Build the CSV Record
				csvRecord+=myInstance.getIssueId();
				csvRecord+=",";
				csvRecord+=myInstance.getNoOfComments();
				csvRecord+=",";
				csvRecord+=CSVManager.getCSVDateFormat(myInstance.getCreationDate());
				csvRecord+=",";
				csvRecord+=CSVManager.getCSVDateFormat(myInstance.getClosingDate());
				csvRecord+=",";
				csvRecord+=myInstance.getNumberOfHoursToClose();
				csvRecord+=",";
				csvRecord+=myInstance.getCreatedByUser().getLoginId();
				csvRecord+=",";
				//All languages of all repos
				for (String langName: MyUser.getAllrepoLanguages()){
					Integer numLanguages = myInstance.getCreatedByUser().getRepoLanguages().get(langName);
					if (numLanguages == null) {
						csvRecord+="0";		
					}else {
						//We could convert to binary later
						csvRecord+=numLanguages.toString();
					}
					csvRecord+=",";
				}
				//All languages of all repos
				for (String langName: MyUser.getAllWatchedLanguages()){
					Integer numLanguages = myInstance.getCreatedByUser().getWatchedLanguages().get(langName);
					if (numLanguages == null) {
						csvRecord+="0";
					}else {
						//We could convert to binary later
						csvRecord+=numLanguages.toString();
					}
					csvRecord+=",";
				}
				csvRecord+=myInstance.getCreatedByUser().getNumFollowers();
				csvRecord+=",";
				csvRecord+=myInstance.getCreatedByUser().getNumFollowing();
				csvRecord+=",";
				csvRecord+=myInstance.getCreatedByUser().getNumRepos();
				csvRecord+=",";
				csvRecord+=myInstance.getCreatedByUser().getNumWatched();
				csvRecord+=",";
				csvRecord+=myInstance.getCreatedByUser().getNumStarred();
				csvRecord+=",";
				csvRecord+=CSVManager.alwaysQuote(CSVManager.escapeQuote(myInstance.getTitle()));
				csvRecord+=",";
				csvRecord+=CSVManager.alwaysQuote(CSVManager.escapeQuote(myInstance.getBody()));
				csvRecord+=",";
				csvRecord+=Boolean.valueOf(myInstance.getLabels().contains(TempMiner.classLabel));
				
				csvOutput.write(csvRecord);
				csvOutput.write("\n");
			}
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally{
			System.out.println("End writing to csv file");
			System.out.println("Closing file");
			closeQuietly(csvOutput);
		}
		
	}
	
	private static void closeQuietly(Closeable resource){
		try {
			if (resource!=null)
				resource.close();
		} catch (IOException e) {
			// Do nothing
			e.printStackTrace();
		}
	}
	
	
	
	
}


