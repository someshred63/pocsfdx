/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: Utility class for String objects.             
*******************************************************************************************/
public with sharing class iPhone_StringUtil {
    
    private static final String DEFAULT_DATETIME_FORMAT = 'yyyy-MM-dd HH:mm:ss.S';
    private static final String DEFAULT_DATE_FORMAT = 'yyyy-MM-dd'; 
        
    public static String getStringDate(DateTime dateValue) {
        return dateValue != null ? dateValue.formatGmt(DEFAULT_DATE_FORMAT) : '';
    }
    
    public static String getString(DateTime dateValue) {
        return dateValue != null ? dateValue.formatGmt(DEFAULT_DATETIME_FORMAT) : '';
    }   

    public static String getString(String value) {
        return value != null ? value : '';
    }
    
    public static String getString(Decimal value) {
        return value != null ? String.valueOf(value) : '';
    }  
        
    public static String getString(Boolean value) {
        return value != null ? String.valueOf(value) : '';
    } 
        
    public static Boolean hasValue(String val) {
        if(val == null || val.trim() == '')
            return false;
        return true;    
    }
    
    public static List<String> buildStringList(List<SObject> sObjects, String fieldName) {
        List<String> resultList = new List<String>();
        for(SObject sObj: sObjects) {
            resultList.add(String.valueOf(sObj.get(fieldName)));
        }       
        return resultList;
    }   
    
    public static Set<String> buildStringSet(List<SObject> sObjects, String fieldName) {
        
        Set<String> resultSet = new Set<String>();
        for(SObject sObj: sObjects) {
            resultSet.add(String.valueOf(sObj.get(fieldName)));
        }       
        return resultSet;
    }   
}