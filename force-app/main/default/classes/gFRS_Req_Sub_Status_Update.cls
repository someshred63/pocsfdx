/**
Class Name : gFRS_Req_Sub_Status_Update 
Purpose/Overview : To updated the sub-status of funding request if 'Baseline date' = today's date
Author: Sudhakar
*/

global class gFRS_Req_Sub_Status_Update implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {      
        Date todayDate = Date.today() ;
        String AmtPaidFlag = 'Yes';
        String AllocQuery = 'Select Id, Baseline_Date__c, Grant_Request__c from gFRS_Copay_Funding_Allocation__c where Amount_Paid_Flag__c = :AmtPaidFlag and Baseline_Date__c = :todayDate';
        return Database.getQueryLocator(AllocQuery);
    }
   
    global void execute(Database.BatchableContext BC, List<gFRS_Copay_Funding_Allocation__c> scope)
    {  
        set<id> ReqIDs = new set<id>();
        for(gFRS_Copay_Funding_Allocation__c FA : Scope)
        {  
            ReqIDs.add(FA.Grant_Request__c);
        }
       
       List<gFRS_Copay_Funding_Request__c> FundReq1 = new List<gFRS_Copay_Funding_Request__c>();
       List<gFRS_Copay_Funding_Request__c> FundReq = [SELECT Id, Name, Sub_Status__c, External_Sub_status__c FROM gFRS_Copay_Funding_Request__c Where ID in :ReqIDs];
       
       For(gFRS_Copay_Funding_Request__c req : fundreq)
       {
           req.Sub_Status__c            =  'Payment Initiated';
           req.External_Sub_status__c   =  'Approved';
                    
           FundReq1.add(req);
       }
       
       update FundReq1;
       
    }
    
    global void finish(Database.BatchableContext BC) {
    }   
}