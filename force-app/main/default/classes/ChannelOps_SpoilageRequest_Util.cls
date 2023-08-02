/**********************************************************************
Purpose: Utility class for multi-purpose common functions
========================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0      Vijay      09/02/2019      INITIAL DEVELOPMENT           
***********************************************************************/
public class ChannelOps_SpoilageRequest_Util {
	
    /*********************************************************************************************
     Purpose: This method accepts the date and return date string in mm/dd/yyyy format     
    **********************************************************************************************/ 
    public static String formatDateInMMDDYYYY(Date formatDate){
        String dateStr = '';
        if(formatDate != null){
            DateTime dt = DateTime.newInstance(formatDate.year(), formatDate.month(),formatDate.day());
			dateStr = dt.format('MM/dd/yyyy');
        }
        return dateStr;
    }
}