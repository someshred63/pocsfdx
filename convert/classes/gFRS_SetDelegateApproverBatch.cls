/**
* @author GFRS Dev Team
* @date 29/08/2013
* @description gFRS_SetDelegateApproverBatch class - batch job for set user delegation for approval processes. 
* Should be scheduled every hour. Example usage:
* String CRON_EXP = '0 0 * * * ?';
* gFRS_SetDelegateApproverBatch sch = new gFRS_SetDelegateApproverBatch();
* system.schedule('gFRS Set Delegate Approver Batch', CRON_EXP, sch);
*/
global with sharing class gFRS_SetDelegateApproverBatch implements Database.Batchable<sObject>, Schedulable {
   
    global void execute(SchedulableContext sc)
    {
        Type t = Type.forName('gFRS_SetDelegateApproverBatch');
        Database.Batchable<sObject> batch = (Database.Batchable<sObject>)t.newInstance();
        Database.executeBatch(batch);
    } 
    
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        string query= 'select Username__c, Delegated_User__c from GNE_User_Delegation__c where Is_Delegation_Active__c=\'Yes\' and RecordType.Name =\'GFRS\'';    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
       if(scope.Size()>0)
       {
            Type t = Type.forName('gFRS_SetDelegateApprover');
            gFRS_ISetDelegateApprover classInstance = (gFRS_ISetDelegateApprover)t.newInstance();
            classInstance.processDelegateApprovers((List<GNE_User_Delegation__c>)scope);
           
            //gFRS_SetDelegateApprover setDelegateApprover = new gFRS_SetDelegateApprover();
            //setDelegateApprover.processDelegateApprovers((List<GNE_User_Delegation__c>)scope);
       }
       else
       {
           system.debug('No delegation set. End Job');
       }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('Set delegation execution ended successfully');
    }
    
}