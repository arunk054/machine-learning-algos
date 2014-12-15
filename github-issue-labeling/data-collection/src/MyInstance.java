import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.concurrent.TimeUnit;

import org.kohsuke.github.GHIssue.Label;



//Defines an instance in my dataset.

public class MyInstance {

	
	private int issueId, noOfComments;
	private String title, body;
	private MyUser createdByUser;

	//Write Date to CSV file in MM/DD/YY format
	private Date creationDate, closingDate;
	private ArrayList<String> labels;
	
	private int numberOfHoursToClose;
	
	public int getNumberOfHoursToClose() {
		return numberOfHoursToClose;
	}


	public void updateNumberOfHoursToClose() {
		if (this.closingDate == null || this.creationDate == null) {
			System.out.println("Error: closing date or creation date missing");
			numberOfHoursToClose = 0;
			return;
		}
		long diff = this.closingDate.getTime() - this.creationDate.getTime();
		TimeUnit requiredUnit = TimeUnit.HOURS;
		this.numberOfHoursToClose = (int) requiredUnit.convert(diff, TimeUnit.MILLISECONDS);
	}


	public MyInstance(int issueId2, String title) {
		this.issueId = issueId2;
		this.title = title;
		this.noOfComments=0;
		this.labels = new ArrayList<String>();
	}
	
	public void addLabels(Collection<Label> collection){
		if (collection == null)
			return;
		
		for(Label label: collection){
			this.labels.add(label.getName());
		}
	}
	public ArrayList<String> getLabels(){
		return this.labels;
		
	}
	public int getIssueId() {
		return issueId;
	}

	public void setIssueId(int issueId) {
		this.issueId = issueId;
	}

	public int getNoOfComments() {
		return noOfComments;
	}

	public void setNoOfComments(int noOfComments) {
		this.noOfComments = noOfComments;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getBody() {
		return body;
	}

	public void setBody(String body) {
		this.body = body;
	}

	public MyUser getCreatedByUser() {
		return createdByUser;
	}

	public void initializeCreatedByUser(String loginId) {
		this.createdByUser = new MyUser(loginId);
	}

	public Date getCreationDate() {
		return creationDate;
	}

	public void setCreationDate(Date date) {
		this.creationDate = date;
	}

	public Date getClosingDate() {
		return closingDate;
	}

	public void setClosingDate(Date issueClosingDate) {
		this.closingDate = issueClosingDate;
	}


	
}
