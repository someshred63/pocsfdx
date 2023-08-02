/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-03
*  Description: This is a helper class used in GNE_SFA2_Contact_Trigger
*  Test class: GNE_SFA2_Contact_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_Contact_Trigger_Helper {
	public static Map<Id, Contact> contactsMap = new Map<Id, Contact>();
	
	public static void createContactsMap(List<Contact> contactsList) {
		contactsMap = new Map <Id,Contact> ([SELECT Id, (SELECT Id FROM  Call2_vod__r), (SELECT Id FROM  Affiliation_vod__r) 
                                       FROM Contact WHERE Id in :contactsList]);
	}
	
	public static List<Contact_To_TSF_gne__c> prepareContactJunctions(List<Contact> triggerNew, Set<Id> accountIds) {
		List<Contact_To_TSF_gne__c> result = new List<Contact_To_TSF_gne__c>();
		Map<Id, List<TSF_vod__c>> accountToTSFs = new Map<Id, List<TSF_vod__c>>();
		for(TSF_vod__c tsf : [SELECT Id, Account_vod__c FROM TSF_vod__c WHERE Account_vod__c IN : accountIds]) {
			Id accountId = tsf.Account_vod__c;
			if(!accountToTSFs.containsKey(accountId)) {
				accountToTSFs.put(accountId, new List<TSF_vod__c>{tsf});
			} else {
				accountToTSFs.get(accountId).add(tsf);
			}
		}
		
		for(Contact c : triggerNew) {
			if(accountToTSFs.containsKey(c.AccountId)) {
				for(TSF_vod__c tsf : accountToTSFs.get(c.AccountId)) {
					result.add(new Contact_To_TSF_gne__c(TSF_gne__c = tsf.Id, Contact_gne__c = c.Id));
				}
			}
		}
		
		return result;
	}
}