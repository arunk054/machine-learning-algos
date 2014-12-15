import java.util.ArrayList;
import java.util.HashMap;


public class DataModel {

	
	public HashMap<String, Integer> getFeatureWordsMap() {
		return featureWordsMap;
	}

	public ArrayList<String> getLabels() {
		return labels;
	}
	HashMap<String, Integer> featureWordsMap;
	ArrayList<String> labels;
	int curWordId;
	public int getCurWordId() {
		return curWordId;
	}
	ArrayList<Instance> instances;
	private static DataModel dataModel;
	public DataModel() {
		// TODO Auto-generated constructor stub
		featureWordsMap = new HashMap<String, Integer>();
		labels = new ArrayList<String>();
		instances = new ArrayList<Instance>();
	}
	
	public static DataModel getInstance(){
		if (dataModel == null)
			dataModel = new DataModel();
		return dataModel;
	}
	
	public void initialize(){
		curWordId = 0;
		featureWordsMap = new HashMap<String, Integer>();
	}
	
	public int addFeatureWord(String word){
		Integer val = featureWordsMap.get(word);
		if (val != null) {
			return val.intValue();
		} else {
			//System.out.println("Adding feature: "+word +", ID : "+curWordId);
		}
		featureWordsMap.put(word,curWordId);
		curWordId++;
		
		return curWordId	-1;
	}
	
	public int addLabel(String label){
		
		if (labels.contains(label)) {
			
			return labels.indexOf(label);
		} else {
			System.out.println("Added new Label: "+label +" Index = "+labels.size());
			labels.add(label);
			return labels.size() - 1;
		}
	}
	
	public void addInstance(Instance ins){
		instances.add(ins);
	}
	public ArrayList<Instance> getInstances(){
		return instances;
	}
	
}
