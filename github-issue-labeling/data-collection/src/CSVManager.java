import java.util.Calendar;
import java.util.Date;

public  class CSVManager
{

	private final static String QUOTE = "\"";
	private final static String ESCAPED_QUOTE = "\"\"";
	private static char[] CHARACTERS_THAT_MUST_BE_QUOTED = { ',', '"', '\n' };


	
	public static String conditionallyQuote(String s){

		for (char c : CHARACTERS_THAT_MUST_BE_QUOTED){
			if ( s.indexOf(c) != -1){
				s = QUOTE + s + QUOTE;
				break;
			}
		}
		
		return s;
		
	}
	
	public static String alwaysQuote(String s){
		s = QUOTE + s + QUOTE;
		return s;
	}
	public static String escapeQuote( String s )
	{
		if ( s.contains( QUOTE ) )
			s = s.replaceAll( QUOTE, ESCAPED_QUOTE );
		return s;
	}
	
	public static String getCSVDateFormat(Date d){
		Calendar cal = Calendar.getInstance();
	    cal.setTime(d);
	    int year = cal.get(Calendar.YEAR);
	    int month = cal.get(Calendar.MONTH)+1;
	    int day = cal.get(Calendar.DAY_OF_MONTH);
	    return month+"/"+day+"/"+year;
	}


}