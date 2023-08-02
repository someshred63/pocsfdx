public class GNE_SFA2_LibContentArchive_Scheduler implements Schedulable{
    public void execute(SchedulableContext SC) {
       //please note that user running this class should be a member of all libraries
       List<ContentVersion> allContentVersions = [ SELECT Id, CreatedDate, ContentDocumentId, IsLatest, Title, PRC_Expiration_Date__c 
                                                   FROM ContentVersion
                                                   WHERE ContentDocument.IsArchived = false AND
                                                         IsLatest = true AND
                                                         PRC_Expiration_Date__c <= :system.today() ];
       if (!allContentVersions.isEmpty()) {
       	   Set<Id> docIds = new Set<Id>{};
           for (ContentVersion dv : allContentVersions) {
               docIds.add(dv.ContentDocumentId);
           }
       	   
           List<ContentDocument> allContentDocuments = [ SELECT Id FROM ContentDocument WHERE Id IN :docIds ];
           for (ContentDocument cd : allContentDocuments) {
               cd.IsArchived = true;
           }
           update allContentDocuments;
       }
    }
}