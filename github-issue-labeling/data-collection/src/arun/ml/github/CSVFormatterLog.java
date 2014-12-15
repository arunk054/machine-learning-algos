package arun.ml.github;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import au.com.bytecode.opencsv.CSV;
import au.com.bytecode.opencsv.CSVReadProc;
import au.com.bytecode.opencsv.CSVWriter;

public class CSVFormatterLog {

	
	public static void main(String[] args) {
		
		String source = "complete_dataset_v1.csv";
		 CSVRecordCounter cc = CSVRecordCounter.getRecordCounter(source);
		System.out.println(cc.getNumAttributes() +" "+cc.getNumRecords());
		
		try {
			writeToNewCSVFile(source,"complete_dataset_v2.csv");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}


	}
	
	public static void writeToNewCSVFile(String sourceFileName, String destinationFileName) throws IOException{
		CSV csv = CSV.separator(',').quote('"').escape(CSVWriter.NO_ESCAPE_CHARACTER).create();
		
		BufferedWriter bw = new BufferedWriter(new FileWriter(new File(destinationFileName)));
		CSVModifierLangNominal csvExt = new CSVModifierLangNominal(csv);
		csv.read(sourceFileName, csvExt);
		CSVWriter cw = new CSVWriter(bw);
		cw.writeAll(csvExt.getRecords());
		cw.close();
		
	}
}


class CSVModifierLog implements CSVReadProc{
	CSV csv;

	
	
	ArrayList<String[]> records;
	HashSet<Integer> indicesOfLang;
	int indexOfLog;
	
	public CSVModifierLog(CSV csv) {
		this.csv = csv;
		records = new ArrayList<String[]>();
		indexOfLog = -1;
		indicesOfLang = new HashSet();
	}
	
	public List<String[]> getRecords() {
		// TODO Auto-generated method stub
		return records;
	}

	@Override
	public void procRow(int rowIndex, String... values) {
		//Generic implementation to accommodate more than 1 log column
		int maxLogColumn = 1;
		String[] newValues = new String[values.length+maxLogColumn];
		int logColumnFound = 0;
		
		if (rowIndex ==0){
			for (int i = 0; i < values.length; i++) {
//				if (values[i].contains("REPO_")|| values[i].contains("WATCH_")){
//					indicesOfLang.add(i);
//				} else
				if (values[i].equalsIgnoreCase("number_of_hours_to_close")) {
					indexOfLog = i;
					newValues[i+logColumnFound]=values[i];
					newValues[i+logColumnFound+1]="log_"+values[i];
					logColumnFound++;
				} else {
					newValues[i+logColumnFound]=values[i];
				}
			}
			records.add(newValues);
			return;
		}
		
		for (int i = 0; i < values.length; i++) {
			if (indexOfLog == i) {
				newValues[i+logColumnFound] = values[i];
				try {
					double d = Math.log(Integer.parseInt(values[i])+1);
					newValues[i+logColumnFound+1] = String.valueOf(d);
				} catch (NumberFormatException e) {
					newValues[i+logColumnFound+1] = values[i];
					e.printStackTrace();
				}
				logColumnFound++;
				
			} else {
				newValues[i+logColumnFound] = values[i];
			}
				
//				else if (indicesOfLang.contains(i)){
//				try {
//					if (Integer.parseInt(values[i]) > 0) {
//						values[i] = "1";
//					} else {
//						values[i] = "0";
//					}
//				} catch (NumberFormatException e) {
//					// TODO Auto-generated catch block
//					e.printStackTrace();
//				}
//			}
			
		}
		records.add(newValues);
		
	}

	
}
