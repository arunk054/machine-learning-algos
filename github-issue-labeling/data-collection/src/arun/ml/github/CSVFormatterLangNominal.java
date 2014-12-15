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

public class CSVFormatterLangNominal {

	
	public static void main(String[] args) {
		
		String source = "complete_dataset_v2.csv";
		 CSVRecordCounter cc = CSVRecordCounter.getRecordCounter(source);
		System.out.println(cc.getNumAttributes() +" "+cc.getNumRecords());
		
		try {
			writeToNewCSVFile(source,"complete_dataset_v4.csv");
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


class CSVModifierLangNominal implements CSVReadProc{
	CSV csv;

	
	
	ArrayList<String[]> records;
	HashSet<Integer> indicesOfLang;
	
	public CSVModifierLangNominal(CSV csv) {
		this.csv = csv;
		records = new ArrayList<String[]>();
		indicesOfLang = new HashSet();
	}
	
	public List<String[]> getRecords() {
		// TODO Auto-generated method stub
		return records;
	}

	@Override
	public void procRow(int rowIndex, String... values) {
		
		if (rowIndex ==0){
			for (int i = 0; i < values.length; i++) {
				if (values[i].contains("REPO_")|| values[i].contains("WATCH_")){
					indicesOfLang.add(i);
				} 
			}
			records.add(values);
			return;
		}
		
		for (int i = 0; i < values.length; i++) {
			if (indicesOfLang.contains(i)){
				try {
					if (Integer.parseInt(values[i]) > 0) {
						values[i] = "true";
					} else {
						values[i] = "false";
					}
				} catch (NumberFormatException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			
		}
		records.add(values);
	}

	
}
