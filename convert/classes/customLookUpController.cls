public class customLookUpController {
@AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        String sQuery='';
        string profile = 'GNE-GFRS-External Applicant';
        string profile2 = 'GNE-GFRS-External Requestor';
        string status='Closed';
        string External_Status='Denied';
        
        string profiles = Label.gFRS_Internal_Profiles;
        List<String> profilesList = profiles.split(',');
        List < sObject > returnList = new List < sObject > ();
        if(ObjectName == 'user'){
             //sQuery =  'select id, Name,Email from ' +ObjectName + ' where profile.name != \'' + String.escapeSingleQuotes(profile) +'\' and profile.name != \'' + String.escapeSingleQuotes(profile2) +'\' and Name LIKE: searchKey order by createdDate DESC limit 5';
             sQuery =  'select id, Name,Email from ' +ObjectName + ' where profile.name IN: profilesList' + 
             ' and Name LIKE: searchKey order by createdDate DESC limit 5';
        }else if(ObjectName == 'gFRS_Cost_Center_Code__c'){               
        	 sQuery =  'select id, Name, Cost_Center__c from ' +ObjectName + 
             ' where Cost_Center__c LIKE: searchKey order by createdDate DESC limit 5'; 
        }else if(ObjectName == 'gFRS_Ltng_Application__c'){               
        	 sQuery =  'select id, Name  from ' +ObjectName + ' where  Name LIKE: searchKey ' + 
             'AND Is_Offline_LOA_Required__c = true AND Sub_Status__c = \'Approved-Awaiting LOA\' ' + // GFRS-1072
             'order by createdDate DESC limit 100'; 
        }
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @AuraEnabled
    public static List < sObject > fetchLookUpValues1(String searchKeyWord, String ObjectName,String recdType) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        String sQuery='';
        string profile = 'GNE-GFRS-External Applicant';
        string profile2 = 'GNE-GFRS-External Requestor';
        Boolean value = True;
        string closed = 'Closed';
        List < sObject > returnList = new List < sObject > ();
        if(ObjectName == 'user'){
             sQuery =  'select id, Name,Email from ' +ObjectName + ' where profile.name != \'' + String.escapeSingleQuotes(profile) +
             '\' and profile.name != \'' + String.escapeSingleQuotes(profile2) +
             '\' and Name LIKE: searchKey order by createdDate DESC limit 5';
        }else if(ObjectName == 'gFRS_Cost_Center_Code__c'){               
        	 sQuery =  'select id, Name, Cost_Center__c from ' +ObjectName + 
             ' where Cost_Center__c LIKE: searchKey order by createdDate DESC limit 5'; 
        }else if(ObjectName == 'gFRS_Ltng_Application__c'){               
        	 //sQuery =  'select id,Name,RecordType.Name,Status__c  from ' +ObjectName + ' where (Status__c != \''+ String.escapeSingleQuotes(value)+'\' and Status__c != \''+ String.escapeSingleQuotes(closed)+'\' ) and RecordType.Name=:recdType and  Name LIKE: searchKey order by createdDate DESC limit 100'; 
        	 sQuery =  'select id,Name,RecordType.Name,Status__c  from ' +ObjectName + 
             ' where (Is_Offline_LOA_Required__c =:value ) and RecordType.Name=:recdType and  Name LIKE: searchKey ' + 
             'AND Is_Offline_LOA_Required__c = true AND Sub_Status__c = \'Approved-Awaiting LOA\' ' + // GFRS-1072
             'order by createdDate DESC limit 100'; 

        }
        List < sObject > lstOfRecords = Database.query(sQuery);
        system.debug('results' +lstOfRecords);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}