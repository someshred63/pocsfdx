global with sharing class gFRS_Ltng_Internal_Record_Sharing_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    global String query;
    global SET<Id> requestIds;
    
    global gFRS_Ltng_Internal_Record_Sharing_Batch(SET<Id> requestIds) {
        this.requestIds=requestIds;
    }
    
	global Database.Querylocator start(Database.BatchableContext BC){     

        system.debug('@@ in sharing batch');
    	query = 'SELECT Id, Name, OwnerId, Record_Type_Name__c, Status__c, Legal_Approver__c, Business_Approver__c, Finance_Approver__c, Finance_Manager__c FROM gFRS_Ltng_Application__c WHERE Id =: requestIds ';
    	system.debug('@@ Query : '+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
		system.debug('@@ in sharing execute');
        List<gFRS_Ltng_Application__Share> fundReqShareList = new List<gFRS_Ltng_Application__Share>();

        try{
                for(gFRS_Ltng_Application__c obj : (List<gFRS_Ltng_Application__c>)scope){
                    
                    if(obj.Record_Type_Name__c == 'Field Exhibits'){
                        if(obj.Business_Approver__c != null && obj.Business_Approver__c != obj.OwnerId){
                            gFRS_Ltng_Application__Share fundReqShare = new gFRS_Ltng_Application__Share();
                            fundReqShare.ParentId = obj.Id;
                            fundReqShare.UserOrGroupId = obj.Business_Approver__c;
                            fundReqShare.AccessLevel = 'Read';
                            fundReqShare.RowCause = 'Manual';
                            fundReqShareList.add(fundReqShare);
                        }
                        
                        if(obj.Legal_Approver__c != null && obj.Legal_Approver__c != obj.OwnerId){
                            gFRS_Ltng_Application__Share fundReqShareFIE1 = new gFRS_Ltng_Application__Share();
                            fundReqShareFIE1.ParentId = obj.Id;
                            fundReqShareFIE1.UserOrGroupId = obj.Legal_Approver__c;
                            fundReqShareFIE1.AccessLevel = 'Read';
                            fundReqShareFIE1.RowCause = 'Manual';
                            fundReqShareList.add(fundReqShareFIE1);
                        }
                    } else {
                        gFRS_Ltng_Application__Share fundReqShare1 = new gFRS_Ltng_Application__Share();
                        gFRS_Ltng_Application__Share fundReqShare2 = new gFRS_Ltng_Application__Share();
                        gFRS_Ltng_Application__Share fundReqShare3 = new gFRS_Ltng_Application__Share();
                        gFRS_Ltng_Application__Share fundReqShare4 = new gFRS_Ltng_Application__Share();
                        
                        if(obj.Business_Approver__c != null && obj.Business_Approver__c != obj.OwnerId){
                            fundReqShare1.ParentId = obj.Id;
                            fundReqShare1.UserOrGroupId = obj.Business_Approver__c;
                            fundReqShare1.AccessLevel = 'Read';
                            fundReqShare1.RowCause = 'Manual';
                            fundReqShareList.add(fundReqShare1);
                        }
                        
                        if(obj.Finance_Approver__c != null && obj.Finance_Approver__c != obj.OwnerId){
                            fundReqShare2.ParentId = obj.Id;
                            fundReqShare2.UserOrGroupId = obj.Finance_Approver__c;
                            fundReqShare2.AccessLevel = 'Read';
                            fundReqShare2.RowCause = 'Manual';
                            fundReqShareList.add(fundReqShare2);
                        }
                        
                        if(obj.Finance_Manager__c != null && obj.Finance_Manager__c != obj.OwnerId){
                            fundReqShare3.ParentId = obj.Id;
                            fundReqShare3.UserOrGroupId = obj.Finance_Manager__c;
                            fundReqShare3.AccessLevel = 'Edit';
                            fundReqShare3.RowCause = 'Manual';
                            fundReqShareList.add(fundReqShare3);
                        }
                        
                        if(obj.Legal_Approver__c != null && obj.Legal_Approver__c != obj.OwnerId){
                            fundReqShare4.ParentId = obj.Id;
                            fundReqShare4.UserOrGroupId = obj.Legal_Approver__c;
                            fundReqShare4.AccessLevel = 'Read';
                            fundReqShare4.RowCause = 'Manual';
                            fundReqShareList.add(fundReqShare4);
                        }
                    }
                    
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