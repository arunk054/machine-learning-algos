package arun.ml.github;

import au.com.bytecode.opencsv.CSV;
import au.com.bytecode.opencsv.CSVReadProc;
import au.com.bytecode.opencsv.CSVWriter;

class CSVRecordCounter implements CSVReadProc {

	private int numRecords =0, numAttributes=0;
	
	@Override
	public void procRow(int rowIndex, String... arg1) {
		if (rowIndex > 0)
			numRecords++;
		else {
			for (String s : arg1){
				numAttributes++;
			}
			
		}
		
	}
	
	public int getNumRecords(){
		return numRecords;
	
	}
	
	public int getNumAttributes(){
		return numAttributes;
	}
	
	public static CSVRecordCounter getRecordCounter(String CSVFileName) {
		CSV csv = CSV.separator(',').quote('"').escape(CSVWriter.NO_ESCAPE_CHARACTER).create();
		CSVRecordCounter recCounter = new CSVRecordCounter();
		csv.read(CSVFileName, recCounter);
		return recCounter;
		
	}

}
