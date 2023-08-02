/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2013-08-02
*  Description: This is a helper class for handling TSF trigger.
*  Test class: GNE_SFA2_TSF_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_TSF_Trigger_Helper {
	
	private static Boolean inTSFTrig = false;
	
	public static Map<String,Address_vod__c> prepareAddressMap(List<TSF_vod__c> triggerNew) {
		Map<String,Address_vod__c> result = new Map<String,Address_vod__c>();
		Set<Id> accountIds = new Set<Id>();
		Set<String> terrNames = new Set<String>();
		Map<String,DateTime> newestCompletedDatesMap = new Map<String,DateTime>();
		
		for(TSF_vod__c tsf : triggerNew) {
			accountIds.add(tsf.Account_vod__c);
			
			if(String.isNotBlank(tsf.Territory_vod__c)) {
				terrNames.add(tsf.Territory_vod__c);
			}
		}
		
		for(Address_vod__c addr : [
				SELECT
					Id,
					Account_vod__c,
					Primary_vod__c,
					(SELECT Call_Datetime_vod__c, Territory_vod__c 
					 FROM Call2_vod__r
					 WHERE Completed_gne__c = true 
					 	AND Parent_Call_vod__c = null
						AND Territory_vod__c IN :terrNames
						AND Call_Datetime_vod__c <> null
					 ORDER BY Call_Datetime_vod__c DESC
					 LIMIT 1
					)
					FROM
						Address_vod__c
					WHERE Inactive_vod__c = false
						AND Account_vod__c IN :accountIds
					ORDER BY Account_vod__c, Primary_vod__c DESC, LastModifiedDate DESC
		]) {
			if(!result.containsKey(addr.Account_vod__c)) {
				result.put(addr.Account_vod__c, addr);
			}
			
			if(!addr.Call2_vod__r.isEmpty()) {
				String terrName = addr.Call2_vod__r[0].Territory_vod__c.toUpperCase();
				DateTime completedDate = addr.Call2_vod__r[0].Call_Datetime_vod__c;
				String key = addr.Account_vod__c + '_' + terrName;
				
				if(!newestCompletedDatesMap.containsKey(key) || completedDate>newestCompletedDatesMap.get(key)) {
					newestCompletedDatesMap.put(key, completedDate);
					result.put(key, addr);
				}
			}
		}
		
		return result;
	}
	
	public static Map<Id, Map<String, Date>> prepareLastInteractionDateFromCompletedInteractionsMap(List<TSF_vod__c> triggerNew) {
		Set<Id> accountIds = new Set<Id>();
		Set<String> territoryNames = new Set<String>();
		for (TSF_vod__c tsf : triggerNew) {
			accountIds.add(tsf.Account_vod__c);
			territoryNames.add(tsf.Territory_vod__c);
		}
		Map<Id, Map<String, Date>> result = new Map<Id, Map<String, Date>>();
		for(Call2_vod__c call : [SELECT Account_vod__c, Territory_vod__c, Call_Date_vod__c
									FROM Call2_vod__c
									WHERE Account_vod__c IN : accountIds AND Territory_vod__c IN : territoryNames AND Completed_gne__c = true
									ORDER BY Call_Date_vod__c DESC]) {
			if (!result.containsKey(call.Account_vod__c)) {
				result.put(call.Account_vod__c, new Map<String, Date>());
			}
			Map<String, Date> terrToDate = result.get(call.Account_vod__c);
			if (!terrToDate.containsKey(call.Territory_vod__c)) {
				result.get(call.Account_vod__c).put(call.Territory_vod__c, call.Call_Date_vod__c);
			}
		}
		return result;
	}
	
	public static void setTSFTrig(Boolean p_inTSFTrig) {
        inTSFTrig = p_inTSFTrig;
    }
    
    public static Boolean inTSFTrig() {
        return inTSFTrig;
    }
    
    public static List<Contact_To_TSF_gne__c> prepareContactJunctions(List<TSF_vod__c> triggerNew, Set<Id> accountIds) {
		List<Contact_To_TSF_gne__c> result = new List<Contact_To_TSF_gne__c>();
		Map<Id, List<Contact>> accountToContacts = new Map<Id, List<Contact>>();
		for(Contact c : [SELECT Id, AccountId FROM Contact WHERE AccountId IN : accountIds]) {
			Id accountId = c.AccountId;
			if(!accountToContacts.containsKey(accountId)) {
				accountToContacts.put(accountId, new List<Contact>{c});
			} else {
				accountToContacts.get(accountId).add(c);
			}
		}
		
		for(TSF_vod__c tsf : triggerNew) {
			if(accountToContacts.containsKey(tsf.Account_vod__c)) {
				for(Contact c : accountToContacts.get(tsf.Account_vod__c)) {
					result.add(new Contact_To_TSF_gne__c(TSF_gne__c = tsf.Id, Contact_gne__c = c.Id));
				}
			}
			
		}
		
		return result;
	}
}