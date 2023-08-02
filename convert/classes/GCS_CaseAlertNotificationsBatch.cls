/**********************************************************************************************************************
Purpose: GCS_CaseAlertNotificationsBatch class is used At 12noon, for GCS cases with category of "Order" that are not in 
status of "Closed" or "Peer Review," the case status will change to "Alert" And send notification to GCS case owners
=======================================================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0     Raheem       29/07/2020      INITIAL DEVELOPMENT

***********************************************************************************************************************/
public class GCS_CaseAlertNotificationsBatch implements Database.Batchable <sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc){        
        //DateTime rightNow =  DateTime.now();
        //DateTime d24hAgo = rightNow.addHours(-24);

        Time myTime = Time.newInstance(12, 0, 0, 0);
        DateTime fromDateTime = DateTime.newInstance(Date.today()-1, myTime);
        DateTime toDateTime = DateTime.newInstance(Date.today(), myTime);
        String developerName = GCS_Util.GCS_CASE_RECORDTYPE_DEV_NAME;
        String query = 'SELECT Id, CaseNumber, subject,Status,Owner.Name, Owner.Email, IsEscalated FROM Case WHERE RecordType.DeveloperName=\''+ developerName +'\'' 
                        +'And GCS_Category__c=\'Order\' AND Status NOT IN (\'Closed\', \'Peer Review\', \'Alert\', \'Closed.Merged\')'
                        +' AND IsEscalated = False AND LastModifiedDate >=:fromDateTime AND LastModifiedDate <= :toDateTime';
                    
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Case> caseList){     
        list<Case> caseUpdatelist = new list<case>();
        List<FeedItem> feedItemList = New List<FeedItem>();

        for(Case caseObj : caseList){
            caseObj.Status='Alert';
            caseObj.IsEscalated = true;
            caseUpdatelist.add(caseObj); 
        }

        if(caseUpdatelist .size()>0){
           List<Database.SaveResult> results = Database.update(caseUpdatelist, false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    for (Database.Error err : result.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Error Update failed: ' + result.getId() + ';' + '; ' + err.getMessage());
                    }
                }
            }
           system.debug('caseUpdatelist'+caseUpdatelist);
        }        
    }
    
    public void finish(Database.BatchableContext bc){
    }
}