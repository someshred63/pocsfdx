/************************************************************
*  @author: Sudhanshu Jain,Saama Technologies
*  Date: 08-February-2010 
*  Description: Utility class for UpdateSpeakerContractsBA class
*                          
*  Modification History
*  Date        Name        Description
*                
*************************************************************/
public class UpdateSpeakerContracts_Utility {
public static Boolean IsBrandAffiliationsUpdated = false; 
public static Date stringToDate(String s){
      //String temp ='';
      System.debug('Sud s: '+ s);
      // Date String is in the format yyyy-mm-dd
      String[] stringDate = s.split('-');
      Integer y =  Integer.valueOf(stringDate[0]);
      Integer m = Integer.valueOf(stringDate[1]);
      //String str_date = stringDate[2].substring(0,2);
      //System.debug('Sud : '+ str_date);
      //temp = stringDate[2];
      Integer d = Integer.valueOf(stringDate[2]);
      return date.newInstance(y,m,d);
}
public static String dateConvert(Date d){
    //String dd = d.format('yyyy-MM-dd');
    System.debug('Sud date: '+ d);
String str_date =  String.valueOf(d);
String stringDate = str_date.subString(0,10);
return stringDate;
}

}