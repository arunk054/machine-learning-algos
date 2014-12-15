import java.io.IOException;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.kohsuke.github.GHIssue;
import org.kohsuke.github.GHIssue.Label;
import org.kohsuke.github.GHIssue.PullRequest;
import org.kohsuke.github.GHIssueState;
import org.kohsuke.github.GHRepository;
import org.kohsuke.github.GHUser;
import org.kohsuke.github.GitHub;
import org.kohsuke.github.PagedIterable;


public class MineIssues {
	public static void main(String[] args) throws IOException {
		HashSet<String> createdBy = new HashSet<String>();
		HashMap<String, Integer> totalLanguages = new HashMap<String, Integer>();
		HashSet<String> usersWithoutRepo;
		System.out.println("---");
		GitHub github = GitHub.connectUsingPassword("arunk054", "mandai21");
		GHUser a = github.getMyself();
		
		System.out.println(a);
		System.out.println(a.getCreatedAt());
		System.out.println(a.getName());
		System.out.println("---------------");
		GHRepository r = github.getRepository("twbs/bootstrap");
		PagedIterable<GHIssue>  issueList = r.listIssues(GHIssueState.CLOSED);
		
		int i = 0;
		int count = 0;
		
		for (GHIssue ghIssue : issueList) {
			
			//System.out.println(ghIssue.getTitle());
			Collection<Label> c = ghIssue.getLabels();
			if (c.size() == 0)
				continue;
			for (Iterator iterator = c.iterator(); iterator.hasNext();) {
				Label l = (Label) iterator.next();
				//System.out.println(l.getName());
			}
			PullRequest pr =  ghIssue.getPullRequest();
			if (pr != null)
				continue;

			//System.out.println(ghIssue.getCreatedAt());
			//System.out.println(ghIssue.getCreatedAt());
			System.out.println(ghIssue.getNumber());
			//System.out.println(ghIssue.getUser().getLogin());
			
			//System.out.println();
			//System.out.println("-----------------------");
			if (++i>2){
				break;	
			}
			//this if can never happen
//			if (ghIssue.getUser() == null || ghIssue.getUser().getLogin() == null){
//				System.out.println("######## Null"+ ghIssue.getNumber());
//			}
			boolean isPresent = false;
			if (ghIssue.getUser().getRepositories().size() ==0 ){
				count++;//
				isPresent= true;
				System.out.println("user:");
			} else {
				for (Map.Entry<String, GHRepository> entry: ghIssue.getUser().getRepositories().entrySet()){
					if (entry.getValue().getLanguage() == null || entry.getValue().getLanguage().isEmpty()){
						
					} else {
						isPresent = true;
						System.out.println(entry.getValue().getLanguage());
						if (totalLanguages.get(entry.getValue().getLanguage()) == null) {
							totalLanguages.put(entry.getValue().getLanguage(),1);
							
						} else {
							totalLanguages.put(entry.getValue().getLanguage(),totalLanguages.get(entry.getValue().getLanguage())+1);
							
						}
					}
					
	
				}
			}
			if (isPresent == false)
				count++;
			createdBy.add(ghIssue.getUser().getLogin());
		}
		//System.out.println(issueList.size());
		//GHRepository r =  github.getRepository("arunk054/temp-repo1");
		//r.delete();
		
		System.out.println();
		System.out.println("---------------------");
		System.out.println(i);
		System.out.println("Users:"+createdBy.size());
		System.out.println("count: "+count);
		System.out.println("size: "+totalLanguages.size());
		System.out.println("=== Printing languages: -=====");
		for (Map.Entry<String, Integer> entry: totalLanguages.entrySet()){
			System.out.println(entry.getKey() +": "+entry.getValue());
		}
		
		

		
	}
}
