import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

import org.kohsuke.github.GHIssue;
import org.kohsuke.github.GHIssue.Label;
import org.kohsuke.github.GHIssue.PullRequest;
import org.kohsuke.github.GHIssueState;
import org.kohsuke.github.GHRepository;
import org.kohsuke.github.GHUser;
import org.kohsuke.github.GitHub;
import org.kohsuke.github.PagedIterable;


public class IssueCollector1 {
	
	public static void main(String[] args) throws IOException {
		GitHub github = GitHub.connectUsingPassword("arunk054", "mandai21");
		GHUser a = github.getMyself();
		System.out.println("Github User:"+a.getName());
		
		GHRepository r = github.getRepository("twbs/bootstrap");
		//ALl closed issues
		PagedIterable<GHIssue>  issueList = r.listIssues(GHIssueState.CLOSED);
		int i = 0;
		System.out.println();
		for (GHIssue ghIssue : issueList) {
			if (ghIssue.getPullRequest() != null){
				//Its a PR, so skip
				continue;
			}
			i++;
			System.out.println("Reading Issue " + i+ ": " +ghIssue.getTitle());
			//Create new instance
			Instance record = new Instance();
			
			record.addFeatureTitle(ghIssue.getTitle());
			
			Collection<Label> c = ghIssue.getLabels();
			for (Iterator iterator = c.iterator(); iterator.hasNext();) {
				Label l = (Label) iterator.next();
				System.out.println("Label: "+ l.getName());
				record.addLabel(l.getName());
			}
			
			DataModel.getInstance().addInstance(record);
			System.out.println();
			System.out.println("-----------------------");
			
			if (i>999){
				break;	
			}
			
		}
		//System.out.println(issueList.size());
		//GHRepository r =  github.getRepository("arunk054/temp-repo1");
		//r.delete();
		
		String labelValue = "js";
		int labelIndex = DataModel.getInstance().getLabels().indexOf(labelValue);
		String fileName = "data1.csv";
		System.out.println("");
		System.out.println("Writing to file : "+ fileName);
		CSVFileWriterWords cw = new CSVFileWriterWords(fileName, DataModel.getInstance().getCurWordId(), DataModel.getInstance().getLabels(),labelValue);
		cw.writeHeader();
		
		ArrayList<Instance> instances = DataModel.getInstance().getInstances();
		for (Iterator iterator = instances.iterator(); iterator.hasNext();) {
			Instance instance = (Instance) iterator.next();
			cw.writeInstance(instance);
			//System.out.println(instance);
		}
		System.out.println("finished writing");
		cw.close();
		
	}
}
