/**********************************************************************
Purpose: GCS_CustomLookupController class is used to get lookup field.
========================================================
History                                                            
-------                                                             
VERSION  AUTHOR        DATE            DETAIL                       
1.0     Raheem       18/09/2020      INITIAL DEVELOPMENT

***********************************************************************/
public class GCS_CustomLookupController {
    
      @AuraEnabled(cacheable=true)  
   public static List<sobject> getUserResults(String searchKey, String objectName) {  
     string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
     string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+'And IsActive=true';
     return Database.query('SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+'And IsActive=true limit 10');  
   } 
}