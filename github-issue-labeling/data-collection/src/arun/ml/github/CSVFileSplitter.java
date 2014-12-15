
package arun.ml.github;


import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import au.com.bytecode.opencsv.CSV;
import au.com.bytecode.opencsv.CSVReadProc;
import au.com.bytecode.opencsv.CSVWriteProc;
import au.com.bytecode.opencsv.CSVWriter;

public class CSVFileSplitter {

	
	//This program extracts a set of records from a csv file
	
	public static void main(String[] args) {
		
		String source = "complete_dataset_v4.csv";
		
		 CSVRecordCounter cc = CSVRecordCounter.getRecordCounter(source);
		System.out.println(cc.getNumAttributes() +" "+cc.getNumRecords());

		
		try {
			writeToNewCSVFile(source, 1, 400, "development_data_v4.csv");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		try {
			writeToNewCSVFile(source, 401, 2900, "cross_validation_data_v4.csv");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		try {
			writeToNewCSVFile(source, 2901, cc.getNumRecords(), "final_test_data_v4.csv");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	
	
	
	public static void writeToNewCSVFile(String sourceFileName, int startRecordIndex, int endRecordIndex, String destinationFileName) throws IOException{
		CSV csv = CSV.separator(',').quote('"').escape(CSVWriter.NO_ESCAPE_CHARACTER).create();
		
		BufferedWriter bw = new BufferedWriter(new FileWriter(new File(destinationFileName)));
		CSVExtracter csvExt = new CSVExtracter(startRecordIndex, endRecordIndex, csv);
		csv.read(sourceFileName, csvExt);
		CSVWriter cw = new CSVWriter(bw);
		System.out.println("Writing Number of records : "+(csvExt.getRecords().size()-1));
		cw.writeAll(csvExt.getRecords());
		cw.close();
		
	}
	
	
	
	
}


class CSVExtracter implements CSVReadProc{

	
	int startRecord, endRecord;
	CSV csv;
	
	
	
	ArrayList<String[]> records;
	
	public CSVExtracter(int startRecord, int endRecord, CSV csv) {
		this.startRecord = startRecord;
		this.endRecord = endRecord;
		this.csv = csv;
		records = new ArrayList<String[]>();
	}
	
	@Override
	public void procRow(int rowIndex, String... values) {
		//recordnum = row index
		
		//If header, write the row
		
//		for (int i = 0; i < values.length; i++) {
			//values[i]= values[i].replaceAll("\"", " ").replaceAll("\\n", " ");
			
//		}
		
		if (rowIndex ==0){
			//csv.write(outStream, myCSVWriter);
			records.add(values);
		} else if (rowIndex >= startRecord && rowIndex <= endRecord ){
			//write to file
			//csv.write(outStream, myCSVWriter);
			records.add(values);
		}
		
		
	}
	
	public ArrayList<String[]> getRecords(){
		return records;
	}
	
	
}


