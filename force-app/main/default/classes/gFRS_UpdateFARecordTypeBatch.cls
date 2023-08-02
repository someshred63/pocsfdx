/**
* @author ADMD Team
* @date 25/04/2013
* @description gFRS_UpdateFARecordTypeBatch class - update for FA record type SFDC-1996.
* Should be executed post deployment steps of release 3.1.0 (R1 2013).
* Database.executeBatch(new gFRS_UpdateFARecordTypeBatch());
*/
global without sharing class gFRS_UpdateFARecordTypeBatch implements Database.Batchable<sObject>
{
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        string query= 'select Id, RecordTypeId from GFRS_Funding_Allocation__c';    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        id idPaymentType;
        id idRefundType;
         
        for (RecordType rt :[SELECT Id, Name FROM RecordType WHERE SObjectType = 'GFRS_Funding_Allocation__c' AND DeveloperName IN ('Payment', 'Refund')])
        {
            if (rt.Name == 'Payment') idPaymentType = rt.Id;
            if (rt.Name == 'Refund') idRefundType = rt.Id;
        } 
        
        GFRS_Funding_Allocation__c[] arrFA =(GFRS_Funding_Allocation__c[]) scope ; 
        //Array for update
        GFRS_Funding_Allocation__c[] arrFAupd = new GFRS_Funding_Allocation__c[]{};
        
        if(arrFA.Size()>0)
        {
            system.debug('Update FA record types');
            for (GFRS_Funding_Allocation__c fa : arrFA)
            {
                 System.debug('Id->' + fa.id +' fa.RecordTypeId->' + idPaymentType );
                 fa.RecordTypeId=idPaymentType;
                 arrFAupd.Add(fa); 
            }
        
            system.debug('Call update for arrFAupd size for update->' + arrFAupd.Size());
            update arrFAupd;
        }
        else
        {
            system.debug('nothing to update');
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('gFRS_UpdateFARecordTypeBatch execution ended');
    }
}