import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;


public class Instance {

	
	ArrayList<Integer> labelIndices;
	HashSet<Integer> featureTitleIndices;
	public Instance() {
		// TODO Auto-generated constructor stub
		labelIndices = new ArrayList<Integer>();
		featureTitleIndices = new HashSet<Integer>();
	}
	
	public void addFeatureTitle(String title){
		//Split title
		if (title == null)
			return;
		String arr[] = title.split(" ");
		
		//For each word, add it to the datamodel
		for (int i = 0; i < arr.length; i++) {
			arr[i] = arr[i].trim();
			arr[i] = arr[i].toLowerCase();
			//TODO use all forms of delimiter
			//Also check for ? at the end
			if (arr[i].length() < 3)
				continue;
			featureTitleIndices.add(DataModel.getInstance().addFeatureWord(arr[i]));
		}
	}
	
	public void addLabel(String label){
		int index = DataModel.getInstance().addLabel(label);
		labelIndices.add(index);
	}
	
	@Override
	public String toString() {
		String s = "";
		s = "labels: ";
		for (Iterator iterator = labelIndices.iterator(); iterator.hasNext();) {
			Integer in = (Integer) iterator.next();
			s+=in+", ";
		}
		s+="Features: ";
		for (Iterator iterator = featureTitleIndices.iterator(); iterator.hasNext();) {
			Long ln = (Long) iterator.next();
			s+= " "+ ln;
		}
		return s;
	}
}
