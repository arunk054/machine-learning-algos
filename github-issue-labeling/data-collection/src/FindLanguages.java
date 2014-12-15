import java.io.IOException;
import java.util.Iterator;
import java.util.Map;

import org.kohsuke.github.GHRepository;
import org.kohsuke.github.GHUser;
import org.kohsuke.github.GitHub;


public class FindLanguages {

	
	public static void main(String[] args) throws IOException {
		GitHub github = GitHub.connectUsingPassword("arunk054", "mandai21");
		GHUser a = github.getMyself();
		System.out.println(a);
		System.out.println(a.getName());
		System.out.println("---------------");
		Map<String, GHRepository> repos = a.getRepositories();
		
		for (Map.Entry<String, GHRepository> entry: repos.entrySet()){
			System.out.println(entry.getKey()+" : "+entry.getValue().getLanguage());
		
		}
		System.out.println(a.getPublicRepoCount());
		System.out.println("-----");
		a = github.getUser("conradwt");
		 repos = a.getRepositories();
		 
		 System.out.println(a.getPublicRepoCount());
		for (Map.Entry<String, GHRepository> entry: repos.entrySet()){
			System.out.println(entry.getKey()+" : "+entry.getValue().getLanguage());
		}
		
		

	}
}
