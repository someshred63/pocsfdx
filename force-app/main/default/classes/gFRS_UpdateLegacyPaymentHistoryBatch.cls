/**
* @author ADMD Team
* @date 19/04/2013
* @description gFRS_UpdateLegacyPaymentHistoryRecords class - lagecy update for payment records SFDC-1996.
* Should be executed post deployment steps of release 3.1.0 (R1 2013).
* Database.executeBatch(new gFRS_UpdateLagacyPaymentHistoryRecords());
*/
global without sharing class gFRS_UpdateLegacyPaymentHistoryBatch implements Database.Batchable<sObject>
{
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        string query= 'select Id, Funding_Allocation__c, Grant__c, Payment_Type__c, RecordTypeId, RecordType.Name, Status__c from GFRS_Payment_History__c where Funding_Allocation__c=null';    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        //Array for update
        GFRS_Payment_History__c[] arrPayHistForUpd = new  GFRS_Payment_History__c[]{};

        //Get payment history for update
        GFRS_Payment_History__c[] arrPayHist = (GFRS_Payment_History__c[]) scope ;
        
        if(arrPayHist.Size()>0)
        {
        System.debug('arrPayHist created number records for update->'+arrPayHist.Size());  
        //create list of Hist ids for update. 
        Set<Id> setOfIds = gFRS_ObjectUtil.createIdFieldSet(arrPayHist, 'Grant__c' );
        
        //get faFor update  
        gFRS_Funding_Allocation__c[] arrFA = [select Grant_Request__c, Id from gFRS_Funding_Allocation__c where Grant_Request__c in : setOfIds] ; 
        
        system.debug('arrFA created number records for update->'+arrFA.Size());  
        
        system.debug('create map of Ids. First Id from Fuding Requests 2nd from FA.');
        
        Map<id, id> mapFA = new Map<id,id>();
        
        for(gFRS_Funding_Allocation__c fa : arrFA)
        {
            mapFA.put(fa.Grant_Request__c, fa.Id);
        
        }
        system.debug('mapFA created Size()->' + mapFA.Size());
        system.debug('Loop through payemnt history records.');
        
        for (gFRS_Payment_History__c payRec : arrPayHist)
        {
                 id myid = mapFA.get(payRec.Grant__c);
                 System.debug('get myid->' +payRec.Grant__c + ' value->' + myid );
                 payRec.Funding_Allocation__c =myid;
                 system.debug('added FA id ->' + myid);
                 arrPayHistForUpd.Add(payRec); 
        }
        
            system.debug('arrPayHistForUpd size for update->' + arrPayHistForUpd.Size());
            update arrPayHistForUpd;
        }
        else
        {
            system.debug('nothing to update');
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('gFRS_UpdateLagacyPaymentHistoryRecords execution ended');
    }
}