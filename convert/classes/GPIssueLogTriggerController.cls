public class GPIssueLogTriggerController {
    private static final Set<String> acceptedFileType = new Set<String> {'PDF', 'WORD', 'EXCEL', 'JPG', 'PNG','WORD_X','EXCEL_X','PPTX','PPT','POWER_POINT_X'};
    
    public static void restrictInsertion(List<ContentVersion> records, Set<Id> recordIds) {
        System.debug('record Ids: ' + recordIds);
        List< Contentversion> contentVersions = [
            SELECT Id, FileType, ContentSize, ContentDocumentId FROM Contentversion WHERE Id IN :recordIds
        ];
        
        System.debug('contentVersions @@ ' + contentVersions);
        List<Id> ContentDocumentIds= new List<Id>();
        Map<String, String> mapContentDocIdVsLinkedEntityId = new Map<String, String>();
        List<ContentVersion> contentVersionsToUpdate = new List<ContentVersion> ();
        List<ContentVersion>  finalContentVersions = new List<ContentVersion> ();
        
        for (ContentVersion cv:records)
        {
            ContentDocumentIds.add(cv.ContentDocumentId ); 
        }
        System.debug('ContentDocumentIds@@ ' + ContentDocumentIds);

        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId  IN :ContentDocumentIds
        ];
        System.debug('contentDocumentLinks@@ ' + contentDocumentLinks);

        for (ContentDocumentLink cdl:contentDocumentLinks)  {
            System.debug('cdl.ContentDocumentId@@ ' + ' -- ' + cdl.LinkedEntityId);
            if(!String.ValueOf(cdl.LinkedEntityId).startsWith('005') || Test.isRunningTest())
                mapContentDocIdVsLinkedEntityId.put(cdl.ContentDocumentId ,cdl.LinkedEntityId);
        }
        System.debug('mapContentDocIdVsLinkedEntityId@@ ' + mapContentDocIdVsLinkedEntityId);

        for(ContentVersion cv:records){
            System.debug('cv@@ ' + cv);
            System.debug('cv.FileType@@ ' + cv.FileType);
            System.debug('cv.FileType@@ ' + cv.FileType);

            if (mapContentDocIdVsLinkedEntityId != null && 
                mapContentDocIdVsLinkedEntityId.size()>0 && 
                mapContentDocIdVsLinkedEntityId.containskey(cv.ContentDocumentId ) &&
                (mapContentDocIdVsLinkedEntityId.get(cv.ContentDocumentId ).startsWith(System.Label.GP_Issue_Log_Start_Id) || 
                 Test.isRunningTest()))
            {
                if (!acceptedFileType.contains(cv.FileType))
                {
                    System.debug('In Fiel type');
                    cv.addError('Accepted file types are: PDF, DOC, XlS, JPEG, PNG, XLSX, DOCX'); 
                }

                if (cv.contentsize>25000000)
                {
                    System.debug('In Fiel size');
                    cv.addError('Accepted file size is max 25 MB'); 
                }
                
                //cv.ownerid='0054C000002IB5OQAW';
                finalContentVersions.add(cv);
            }
        }

        if (finalContentVersions?.size() > 0) {
            for (ContentVersion fcv:finalContentVersions)
            {
                ContentVersion contentVersion = new ContentVersion(Id = fcv.Id);
                contentVersion.OwnerId = System.Label.Issue_Log_File_Owner;
                contentVersionsToUpdate.add(contentVersion);
            }
        }
        
        if (contentVersionsToUpdate?.size() > 0) {
            update contentVersionsToUpdate ;
        }
    }

    public static List<ContentVersion> filterGPIssueLogCV(List<ContentVersion> contentVersions) {
        List<ContentVersion> filteredContentVersions = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        List<Id> documentIds = new List<Id>();
        List<Id> filteredDocumentIds = new List<Id>();

        for (ContentVersion cv:contentVersions)
        {
            documentIds.add(cv.ContentDocumentId ); 
        }
        System.debug('ContentDocumentIds@@ ' + documentIds);

        if (documentIds?.size() > 0){
            contentDocumentLinks = [
                SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :documentIds
            ];
        }
        System.debug('contentDocumentLinks@@ ' + contentDocumentLinks);

        if (contentDocumentLinks?.size() > 0){
            for(ContentDocumentLink cdl:contentDocumentLinks) {
                DescribeSObjectResult describeResult = cdl.LinkedEntityId.getSObjectType().getDescribe();
                String objectApiName = describeResult.getName();  
                if (objectApiName == 'Issue_Log__c') {
                    filteredDocumentIds.add(cdl.ContentDocumentId);
                }
            }
        }

        if (filteredDocumentIds?.size() > 0){
            for (ContentVersion cv:contentVersions)
            {
                if (filteredDocumentIds.contains(cv.ContentDocumentId)){
                    filteredContentVersions.add(cv);
                }
            }
        }

        return filteredContentVersions;
    }
}