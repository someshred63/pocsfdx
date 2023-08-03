trigger Executed_LOA_ContentDocumentLink on ContentDocumentLink (after insert) {
    Map<Id,ContentDocumentLink> cdlMap = new Map<Id,ContentDocumentLink>();
    List<gFRS_Ltng_Application__c> appRecords = new List<gFRS_Ltng_Application__c>();
    set<Id> contentDocId = new set<Id> ();    
    
    if(Trigger.isAfter && Trigger.isInsert){

        for (ContentDocumentLink att :Trigger.new)
        {                
            contentDocId.add(att.ContentDocumentId);            
        }
        
        if(!contentDocId.isEmpty()){
            cdlMap = new Map<Id,ContentDocumentLink>([SELECT ContentDocumentId,Id,LinkedEntityId,ContentDocument.Title FROM ContentDocumentLink where ContentDocumentId IN :contentDocId]);
        }      
        
        for(ContentDocumentLink CDL : cdlMap.values()){
            DescribeSObjectResult describeResult = CDL.LinkedEntityId.getSObjectType().getDescribe();
            String label = describeResult.getLabel();
            
            if(label == 'gFRS Application' && CDL.ContentDocument.Title.contains('Executed LOA')){
                gFRS_Ltng_Application__c appRec = new gFRS_Ltng_Application__c();
                appRec.Id 							= CDL.LinkedEntityId;
                appRec.Executed_LOA_Document_ID__c 	= CDL.ContentDocumentId;
                
                appRecords.add(appRec);
            }
        }
        
        if(appRecords.size() > 0){
            update appRecords;
        }        
    }
}