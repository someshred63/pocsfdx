/**********************************************************************************************************************
Purpose: ROBOCOPS-130
System shall change Processed record status to Expired at 24 months from Processed Date.   
=======================================================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0     Raju Manche  9/17/2020      INITIAL DEVELOPMENT

***********************************************************************************************************************/
public class SPLOA_UpdateStatusToExpiredBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        C_Ops_Captcha_Property__c captcha =[SELECT Id,Active__c,Months_to_Expired__c FROM C_Ops_Captcha_Property__c WHERE Active__c = true LIMIT 1];
        Integer monthsExpire = Integer.valueOf(captcha.Months_to_Expired__c);
        
        DateTime expirydate = System.now().addMonths(-monthsExpire);
        system.debug('expirydate****'+expirydate);
        String query = 'SELECT Id, Name, C_Ops_SPLOA_Request_Status__c, Processed_Date__c '+
            'FROM C_Ops_SPLOA_Request__c '+
            'WHERE C_Ops_SPLOA_Request_Status__c = \'Processed\' AND Processed_Date__c <:expirydate';
        system.debug('query****'+query);
        return Database.getQueryLocator( query );
    }
    
    public void execute(Database.BatchableContext bc, List<C_Ops_SPLOA_Request__c> scope){
        List<C_Ops_SPLOA_Request__c> requestList = new List<C_Ops_SPLOA_Request__c>();
        system.debug('scope****'+scope);
        system.debug('Entering****');
        for (C_Ops_SPLOA_Request__c request: scope) {
            C_Ops_SPLOA_Request__c newRequest = new C_Ops_SPLOA_Request__c();
            newRequest.Id = request.id; 
            newRequest.C_Ops_SPLOA_Request_Status__c = 'Expired';
            requestList.add(newRequest);
        }
        update requestList;
    }    
    
    public void finish(Database.BatchableContext bc){
    }    
    
}