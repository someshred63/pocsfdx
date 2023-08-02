global without sharing class autoContactAffiliationHandler{

    /**
     * @newContacts - List of New Contacts as passed to Trigger 
     * @oldContacts - List of Old Contacts as passed to Trigger. Each maybe null if called from insert
     *
     * Called on update or insert of contact. Builds affiliation to parent of contact realtime for first contact 
     * in list. If there are more they are spawned to run asynchronously and avoid Govenor limits of trigger
     */
    public static boolean onContactUpdate(List<Contact> oldContacts, List<Contact> newContacts){
        Map<Id, Id> oldConsParents = new Map<Id,Id>();
        Map<Id, Id> newConsParents = new Map<Id,Id>();
        List<Id> contactIds = new List<Id>();
         
        if (userUsesContactAffiliations()){
            for(Integer contactIdx=0; contactIdx < newContacts.size(); contactIdx++){
                if (oldContacts != null){
                   oldConsParents.put(oldContacts[contactIdx].Id, oldContacts[contactIdx] != null ? oldContacts[contactIdx].AccountId : null);
                }
                newConsParents.put(newContacts[contactIdx].Id, newContacts[contactIdx] != null ? newContacts[contactIdx].AccountId : null);
                
                // First on if updated below sychronously
                if (contactIdx > 0){
                	contactIds.add(newContacts[contactIdx].Id);
                }
             }
             
             if (newContacts.size() > 0){
               Id oldContactAccountId = oldContacts != null ? oldContacts[0].AccountId : null;
               buildAffiliationAccount2Contact(null, newContacts[0].Id, oldContactAccountId, newContacts[0].AccountId);
             }
           
             if (newContacts.size() > 1){
               spawnUpdateContactsAffils(contactIds, oldConsParents, newConsParents);
             }
          }
          return true;                
    }
    
    /**
     * userUsesContactAffiliations
     * @return true if Users Profile is one that uses Contact Affiliation
     */
    private static boolean userUsesContactAffiliations(){
        String userProfileName = [select Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name.toUpperCase();
        if ((userProfileName.indexOf('GNE-SFA') > -1 && !userProfileName.startsWithIgnoreCase('GNE-SFA-OPS') ) || userProfileName.indexOf('GNE-TLS') > -1
          || userProfileName.indexOf('MEDAFFAIRS') > -1 || userProfileName.indexOf('CANADA') > -1
          || userProfileName.indexOf('GNE-MCCO') > -1){
           return true;
         }else{
           return false;
         }
    }    
    
    /**
     * spawnUpdateContactsAffils
     * @contacts - Array of Contacts being updated
     * @oldParent - Array of Ids of Parent Accounts(May be null if insert triggered0
     * @newParent - Array of Ids of new Parent Accounts
     *
     * Call this method to update a single contacts affiliation to its parent accounts
     */
    @future 
    static void spawnUpdateContactsAffils(List<Id> contactIds, Map<Id,Id> oldConsParents, Map<Id,Id> newConsParents){
        boolean success = true;
        List<Affiliation_vod__c> affils = new List<Affiliation_vod__c>();
        for(Id conId: contactIds){
             if (!buildAffiliationAccount2Contact(affils, conId, oldConsParents.get(conId), newConsParents.get(conId))){
             	success = false;
             }
        }
        if (affils.size() > 0){
            insert affils;
        }
    }
    
    /**
     * buildAffiliationAccount2Contact - Check for to contact from account and to account from contact affiliations for this
     * account and contact. If either do not exist, create. Otherwise leave as they may have other related information
     *
     * @affils - Affiliation container to add updates to
     * @conId - ContactId to be affiliated with Account
     * @oldAcctId - AccountId to affiliate with contact
     * @newAcctId - AccountId to affiliate with contact
     * 
     * @return - true if succeed
     */
    private static boolean buildAffiliationAccount2Contact(List<Affiliation_vod__c> affils, Id conId, Id oldAcctid, Id acctid){
        if (acctId != null){
            // First look for pre existing affiliaiton        
            List<Affiliation_vod__c> affilsTo = [select From_Account_vod__c, From_Account_vod__r.name, To_Contact_vod__c, To_Contact_vod__r.Name From Affiliation_vod__c where from_account_vod__c = :acctid and  to_contact_vod__c = :conId];
            List<Affiliation_vod__c> affilsFrom = [select To_Account_vod__c, To_Account_vod__r.name,  From_Contact_vod__c, From_Contact_vod__r.Name From Affiliation_vod__c where to_account_vod__c = :acctid and  from_contact_vod__c = :conId];
            
            // Testing showed an inverse affiliation is automatically created for each of the above affils so this creates a duplicate.
             if(affilsFrom.size() == 0){
                Affiliation_vod__c affilFrom = new Affiliation_vod__c();
                affilFrom.Affiliation_Type_gne__c = 'AFFILIATION';
                affilFrom.To_Account_vod__c = acctid;
                affilFrom.From_Contact_vod__c = conId;
                if (affils == null){
                  insert affilFrom;
                }else{
                   affils.add(affilFrom);
                }
            }
            
            // Logic Moved to Affiliation Trigger.
         	/*
            // If affiliaiton already exists these is nothing to do, otherwise create new one(s)
            if (affilsTo.size() == 0){
                Affiliation_vod__c affilTo = new Affiliation_vod__c();
                affilTo.Affiliation_Type_gne__c = 'EMPLOYED BY';
                affilTo.From_Account_vod__c = acctid;
                affilTo.To_Contact_vod__c = conId;
                if (affils == null){
                  insert affilTo;
                }else{
                  affils.add(affilTo);
                }
            }
           	*/
        }
        
        // Delete all old Affiliations for this contact
        // Account with too may contact cause this to blow up. Disabled for now -DRB
		if (oldAcctid != null && oldAcctid != acctId){
     		List<Affiliation_vod__c> oldAffils = [select Id, From_Account_vod__c, To_Account_vod__c, From_Contact_vod__c, To_Contact_vod__c From Affiliation_vod__c where ((Affiliation_Type_gne__c = 'AFFILIATION' or Affiliation_Type_gne__c = '' or Affiliation_Type_gne__c = null ) and ((from_account_vod__c = :oldAcctid and  to_contact_vod__c = :ConId) OR  (to_account_vod__c = :oldAcctid and  from_contact_vod__c = :ConId)))];
		    if (oldAffils.size()>0){
		         delete oldAffils;
		    }
		}            
        return true;
    }

    /**
    * This is an @future annotated method which will check the Role of the User entered Affiliation.
    * If the Role is 'Top Payer 1' then this method will check to see if an Affiliation of that same
    * type exists, if it does then the method will set the Role for that Affiliation record to 'Affiliated With'.
    * The method will perform the same checks for 'Top Payer 2' and Top Payer 3'.
    */
    @future 
    public static void updateTopPayerAffiliations (String from_Account, String to_Account, String role) {
        List<Affiliation_vod__c> aff_ToUpdate = new List<Affiliation_vod__c>();
        List<Affiliation_vod__c> affs = new List<Affiliation_vod__c>([Select id from Affiliation_vod__c where From_Account_vod__c =:from_Account and To_Account_vod__c !=:to_Account and Role_vod__c =: role]);
            //Check to see if one exists
            if (affs.size() > 0) {
              for (Affiliation_vod__c a_x : affs) {
                Affiliation_vod__c newAff = new Affiliation_vod__c(id=a_x.Id);
                newAff.Role_vod__c = 'Affiliated With';
                aff_ToUpdate.add(newAff);
              }
            }
 
            if (aff_ToUpdate.size() > 0) {  
                update aff_ToUpdate;
            }
    }
}