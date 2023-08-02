/**********************************************************************************************************************
Purpose: ContactTriggerHandler class is used to implement the business logic on DML events.
=======================================================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0     Vijay       05/14/2021      INITIAL DEVELOPMENT
            
***********************************************************************************************************************/
public class ContactTriggerHandler {
    private static Boolean isBeforeUpdate = false;
    private static Boolean isAfterUpdate = false;
    
    /*********************************************************************************************
     Purpose: This method accepts the list of contacts and process the before insert business logic
    **********************************************************************************************/    
    public void onBeforeInsert(List<Contact> contactList){
        Id gcsContactRecordTypeId = GCS_Util.getContactReocrdTypeId(GCS_Util.GCS_CONTACT_RECORDTYPE_DEV_NAME);
        List<Contact> gcsContacts = new List<Contact>(); 
        for(contact con:contactList){
            if(con.RecordTypeId == gcsContactRecordTypeId && con.AccountId == null){ 
               gcsContacts.add(con);
            }            
        }
        if(!gcsContacts.isEmpty()){
        	assignDefaultGCSAccountOnContact(gcsContacts);  
        }
    }
    
    /*********************************************************************************************
     Purpose: This method accepts the list of contacts, old contact map and new contact map
              and process the before update business logic
    **********************************************************************************************/    
    public void onBeforeUpdate(List<Contact> contactList, Map<Id,Contact> oldContactMap, Map<Id,Contact> newContactMap){
        Id gcsContactRecordTypeId = GCS_Util.getContactReocrdTypeId(GCS_Util.GCS_CONTACT_RECORDTYPE_DEV_NAME);
        if(!isBeforeUpdate){
            List<Contact> gcsContacts = new List<Contact>(); 
            for(contact con:contactList){
                if(con.RecordTypeId == gcsContactRecordTypeId && con.AccountId == null){ 
                   gcsContacts.add(con);
                }            
            }
            if(!gcsContacts.isEmpty()){
                assignDefaultGCSAccountOnContact(gcsContacts);  
            }
        }
        isBeforeUpdate = true;
    }

    /*********************************************************************************************
     Purpose: This method accepts the list of contacts and assign default GCS account
    **********************************************************************************************/    
    public void assignDefaultGCSAccountOnContact(List<contact> contactList){
        List<Account> accountList = [select Id,Name from Account where Name =: GCS_Util.GCS_DEFAULT_ACCOUNT LIMIT 1];       
        if(!accountList.isEmpty()){
            for(contact con:contactList){
            	con.AccountId = accountList[0].id;
            }
        }
    }
}