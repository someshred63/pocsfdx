/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-03
*  Description: This is a helper class for handling Contact child records updates
*  Test class: GNE_SFA2_Contact_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_Contact_Child_Record_Updates {
    

    public static void onAfterInsert(List<Contact> triggerNew) {
        if(!GNE_SFA2_Util.isMergeMode()){
        	createContactJunctions(triggerNew);
        }
    }

    public static void onBeforeUpdate(List<Contact> triggerOld, List<Contact> triggerNew) {
        if(!GNE_SFA2_Util.isMergeMode()){
            recalculateContactJunctions(triggerOld, triggerNew);
        }
    }

    public static void onBeforeDelete(List<Contact> triggerOld) {}
    
    public static void onAfterDelete(List<Contact> triggerOld) {
        if(!GNE_SFA2_Util.isMergeMode()){
            deleteRelatedAffiliations(triggerOld);
        }
    }
    
    private static void createContactJunctions(List<Contact> triggerNew) {
		Set<Id> accountIds = new Set<Id>();
		for(Contact c : triggerNew) {
			accountIds.add(c.AccountId);
		}
		
		List<Contact_To_TSF_gne__c> junctionsToInsert = GNE_SFA2_Contact_Trigger_Helper.prepareContactJunctions(triggerNew, accountIds);
		if(!junctionsToInsert.isEmpty()) {
			insert junctionsToInsert;
		}
	}
	
	private static void recalculateContactJunctions(List<Contact> triggerOld, List<Contact> triggerNew) {
		Set<Id> contactIds = new Set<Id>();
		Map<Id, Id> changedAccountIds = new Map<Id, Id>();
		
		for(Integer i = 0; i < triggerNew.size(); i++) {
			if(triggerNew[i].AccountId != triggerOld[i].AccountId) {
				contactIds.add(triggerNew[i].Id);
				changedAccountIds.put(triggerNew[i].AccountId, triggerOld[i].AccountId);
			}
		}
		
		if(!changedAccountIds.isEmpty()) {
			delete [SELECT Id FROM Contact_To_TSF_gne__c WHERE Contact_gne__c IN : contactIds AND TSF_gne__r.Account_vod__c IN : changedAccountIds.values()];
			
			List<Contact_To_TSF_gne__c> junctionsToInsert = GNE_SFA2_Contact_Trigger_Helper.prepareContactJunctions(triggerNew, changedAccountIds.keySet());
			if(!junctionsToInsert.isEmpty()) {
				insert junctionsToInsert;
			}
		}
	}

    private static void deleteRelatedAffiliations(List<Contact> contacts) {
        List<Affiliation_vod__c> affiliationsToDelete = [ SELECT Id FROM Affiliation_vod__c WHERE To_Contact_vod__c in :contacts ];
        delete affiliationsToDelete;
    }
}