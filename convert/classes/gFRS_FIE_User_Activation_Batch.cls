global with sharing class gFRS_FIE_User_Activation_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    global String query;
    global set<Id> reqIds;
	global Database.Querylocator start(Database.BatchableContext BC){     

        system.debug('@@ in batch');
    	query = 'SELECT Id, Name, Record_Type_Name__c, Status__c, OwnerId, Financial_Approver_1__c, Financial_Approver_1__r.isactive FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c  in (\'Field Initiated Exhibits\',\'Corporate Memberships\',\'Exhibits & Other Promos\',\'Sci/Pipeline Exhibits & Other Non-Promo\') AND Status__c in (\'HC Compliance\',\'Decision\') AND Financial_Approver_1__r.isactive = false ';
    	system.debug('@@ Query : '+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
		system.debug('@@ in execute');
        List<User> userList = new List<User>();
        set<User> userSet = new set<User>();
        map<Id,Id> reqMap 	= new map<Id,Id>();
        reqIds = new set<Id>();
        List<GFRS_Funding_Request__Share> fundReqShareList = new List<GFRS_Funding_Request__Share>();
        
        for(GFRS_Funding_Request__c obj : (List<GFRS_Funding_Request__c>)scope){
            if(obj.Financial_Approver_1__c != obj.OwnerId){
                reqMap.put(obj.Id, obj.Financial_Approver_1__c);
                reqIds.add(obj.Id);
            } else {
                reqMap.put(obj.Id, obj.Financial_Approver_1__c);
            }
            
        }
		
        try{
            if(reqMap.size() > 0){
                userList = [SELECT Id, Name, isactive FROM USER WHERE Id =: reqMap.values()];
                map<Id,User> userMap = new map<Id,User>(userList);
                
                userList = new List<User>();
                
                for(GFRS_Funding_Request__c obj : (List<GFRS_Funding_Request__c>)scope){
                    
                    User userRec = new User();
                    userRec = userMap.get(obj.Financial_Approver_1__c);
                    userRec.isactive = true;
                    userList.add(userRec);
                    userSet.addAll(userList);
                    userList = new List<User>();
                    userList.addAll(userSet);
                    
                }
                
                update userList;
                //insert fundReqShareList;
            }
        }
        catch (Exception ex) {
            system.debug('@@ Error while activating Financial Approver 1 :' +ex.getMessage());
        }  
    }
    
    global void finish(Database.BatchableContext BC){
        
        if(reqIds.size() > 0){
            gFRS_FIE_Record_Sharing_Batch sharingBatch = new gFRS_FIE_Record_Sharing_Batch(reqIds);
            //sharingBatch.requestIds = reqIds;
            Database.executeBatch(sharingBatch);            
        }

    }
    
}