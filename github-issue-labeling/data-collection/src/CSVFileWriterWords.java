import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;


public class CSVFileWriterWords {
	
	BufferedWriter bw;
	int maxFeatureVal; 
	String labelValue;
	ArrayList<String> labels;
	public CSVFileWriterWords(String fileName, int maxFeatureVal, ArrayList<String> labels, String labelValue) throws IOException {
		// TODO Auto-generated constructor stub
		bw = new BufferedWriter(new FileWriter(new File(fileName)));
		
		this.maxFeatureVal = maxFeatureVal;
		this.labels = labels;
		this.labelValue = labelValue;
	}
	
	//Write header
	public void writeHeader(){
		String s = "";
		for (int i = 0; i < maxFeatureVal; i++) {
			s+="word_"+i+",";
		}
		//Add the label: TODO : functionality to add more labels
		for (Iterator iterator = labels.iterator(); iterator.hasNext();) {
			String label = (String) iterator.next();
			
			if (label.equals(labelValue)){
				s+=label;
				break;
			}
//			if (iterator.hasNext()){
//				s+=",";
//			}
		}
		try {
			bw.write(s+"\n");
		} catch (IOException e) {
			System.out.println("Error: "+ e);
			
		}
		
	}
	
	public void writeInstance(Instance instance){
		String s="";
		for (int i = 0; i < maxFeatureVal; i++) {
			if (instance.featureTitleIndices.contains(i)){
				s+="1,";
			}else {
				s+="0,";
				
			}
			
		}
		
		int index = labels.indexOf(labelValue);
		
		if (instance.labelIndices.contains(index)){
			s+="Yes";
		}else{
			s+="No";
		}
		
//		int len = labels.size();
//		for (int i = 0; ;) {
//			if (instance.labelIndices.contains(i)){
//				s+="Yes";
//			}else{
//				s+="No";
//			}
//			if (i<len-1){
//				s+=",";
//			} else {
//				break;
//			}
//			i++;
//			
//		}
		s+="\n";
		
		try {
			bw.write(s);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	
	public void close(){
		try {
			bw.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	

}
