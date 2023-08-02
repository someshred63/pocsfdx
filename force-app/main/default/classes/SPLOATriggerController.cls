public class SPLOATriggerController {
    public static void checkFileInsertion(List<ContentDocumentLink> contentDocumentLinks) {

        String docFileType;
        Boolean viewOnly = SPLOA_Link_Submitted_Request_Controller.fetchUser();  
        Set<Id> entityId = new Set<Id>();
        Set<Id> docTypeId = new Set<Id>();
        Set<String> typeofFile = new Set<String>();
        List<Contentdocument> contentDocuments =  new List<Contentdocument>();
        List<C_Ops_SPLOA_All_Documents__c> copsSploaAllDocuments = new List<C_Ops_SPLOA_All_Documents__c> ();  

        if (viewOnly == true) 
        {
            for (ContentDocumentLink cdl :contentDocumentLinks)
            {                
                docTypeId.add(cdl.ContentDocumentId);        
                entityId.add(cdl.LinkedEntityId);       
            }
            
            if (!docTypeId.isEmpty()) {
                contentDocuments = [SELECT Id, FileType FROM ContentDocument WHERE Id IN :docTypeId];
            }

            if (contentDocuments?.size() > 0) 
            {
                for(ContentDocument cd:contentDocuments)
                {
                    typeofFile.add(cd.FileType);
                    System.debug('Type of File: ' + typeofFile);
                }
            }

            System.debug('Entity Id: ' + entityId);
            if (!entityId.isEmpty()) 
            {
                copsSploaAllDocuments = [SELECT Id, Name FROM C_Ops_SPLOA_All_Documents__c WHERE Id = :entityId];         
            }    

            System.debug('copsSploaAllDocuments: ' + copsSploaAllDocuments);
            if (copsSploaAllDocuments?.size() > 0)
            {
                for (ContentDocumentLink cdl:contentDocumentLinks)
                { 
                    System.debug('File Type: ' + string.valueOf(typeofFile));
                    //if (string.valueOf(typeofFile) != '{SNOTE}')  UNKNOWN
                    if (string.valueOf(typeofFile) != '{UNKNOWN}')
                    {                                             
                        cdl.addError('You don\'t have permission to attach files.Please contact your system admin for more information.');             
                    }            
                }           
            } 
        }
    }
}