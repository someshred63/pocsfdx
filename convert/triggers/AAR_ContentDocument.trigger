trigger AAR_ContentDocument on ContentDocument (before delete) {
    private static final Id RECORD_TYPE_ID_CON_ADVOCACY = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advocacy').getRecordTypeId();    
    private static final Id RECORD_TYPE_ID_ACC_ADVOCACY = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advocacy').getRecordTypeId();    
    public static final String PROFILE_TYPE_GNE_AAR_ReadOnly_USER = 'AAR-Read Only User';
    String profileName = GNE_AAR_Trigger_Helper.getCurrentUserProfileName();
    system.debug('entering to the logic and RECORD_TYPE_ID_ACC_ADVOCACY*****'+RECORD_TYPE_ID_ACC_ADVOCACY);
    set<Id> linkedId = new set<Id> ();
    set<Id> entityId = new set<Id> ();
    set<String> typeofFile = new set<String> ();
    List<Account> accList = new List<Account> ();
    List<Contact> conList = new List<Contact> ();
    List<ContentDocumentLink> linkList = new List<ContentDocumentLink> ();
    for (ContentDocument att :Trigger.old)
    {            
        if(profileName==PROFILE_TYPE_GNE_AAR_ReadOnly_USER){ 
        typeofFile.add(att.FileType);            
            linkedId.add(att.Id);                
        }
    }
    system.debug('Type of the file*****'+typeofFile);
    system.debug('String Type of the file*****'+string.valueOf(typeofFile));
    if(!linkedId.isEmpty()){
        linkList =[select ContentDocumentId,LinkedEntityId from ContentDocumentLink where ContentDocumentId IN : linkedId];
        system.debug('linkList*****'+linkList);
    }
    if(!linkList.isEmpty()){
        for(ContentDocumentLink conLink : linkList){
            entityId.add(conLink.LinkedEntityId);            
        }
    }
    if(!entityId.isEmpty()){
        accList = [SELECT Id, name FROM Account where Id =:entityId and recordType.Id=:RECORD_TYPE_ID_ACC_ADVOCACY]; 
        conList = [SELECT Id, name FROM Contact where Id =:entityId and recordType.Id=:RECORD_TYPE_ID_CON_ADVOCACY];  
    }
    List<ContentDocument> cdList = [SELECT Id FROM ContentDocument where Id IN: Trigger.oldMap.keySet()];
    if(accList.size() > 0 || conList.size() > 0)
    {
        for(ContentDocument cd: cdList)
        {                
            ContentDocument  actualRecord = Trigger.oldMap.get(cd.Id); 
            if(string.valueOf(typeofFile)=='{SNOTE}') {
            actualRecord.addError('Read Only User not allowed to delete Notes');
            }                    
            //if(string.valueOf(typeofFile)=='{TEXT}')  {
            else {            
            actualRecord.addError('Read Only User not allowed to delete Files');      
            }            
        }           
    }       
}