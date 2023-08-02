global with sharing class gFRS_FIE_Record_Sharing_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    global String query;
    global SET<Id> requestIds;
    
    global gFRS_FIE_Record_Sharing_Batch(SET<Id> requestIds) {
        this.requestIds=requestIds;
    }
    
	global Database.Querylocator start(Database.BatchableContext BC){     

        system.debug('@@ in sharing batch');
    	query = 'SELECT Id, Name, Record_Type_Name__c, Status__c, Financial_Approver_1__c, Financial_Approver_1__r.isactive FROM GFRS_Funding_Request__c WHERE Id =: requestIds ';
    	system.debug('@@ Query : '+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
		system.debug('@@ in sharing execute');
        List<GFRS_Funding_Request__Share> fundReqShareList = new List<GFRS_Funding_Request__Share>();

        try{
                for(GFRS_Funding_Request__c obj : (List<GFRS_Funding_Request__c>)scope){
                    GFRS_Funding_Request__Share fundReqShare = new GFRS_Funding_Request__Share();
                    fundReqShare.ParentId = obj.Id;
                    fundReqShare.UserOrGroupId = obj.Financial_Approver_1__c;
                    fundReqShare.AccessLevel = 'Read';
                    fundReqShare.RowCause = 'Manual';
                    fundReqShareList.add(fundReqShare);
                    
                }

                insert fundReqShareList;
        }
        catch (Exception ex) {
            system.debug('@@ Error while sharing the record with Financial Approver 1 :' +ex.getMessage());
        }  
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}