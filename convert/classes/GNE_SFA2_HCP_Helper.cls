public without sharing class GNE_SFA2_HCP_Helper {

	/*Return map: accountId -> list of user territories with this this account (only top territories, records from child territoies not included).*/
	public static Map<Id, List<String>> getUserPersonAccounts(String userId, List<String>territories){
		Map<Id, List<String>>result = new Map<Id, List<String>>();
		Map<Id, RecordType>recordTypes = new Map<Id, RecordType>([SELECT Id FROM RecordType WHERE SobjectType='Account' AND IsPersonType=True]);
		for(TSF_vod__c tsf : [SELECT Account_vod__c, Territory_vod__c FROM TSF_vod__c WHERE Territory_vod__c In :territories AND Address_vod__c <> null AND Account_vod__c <> null AND External_Id_vod__c <> null AND Account_vod__r.RecordTypeId In :recordTypes.keySet()]){
			if(!result.containsKey(tsf.Account_vod__c)){
				result.put(tsf.Account_vod__c, new List<String>());
			}
			result.get(tsf.Account_vod__c).add(tsf.Territory_vod__c);
		 }
		 return result;
	}

	public static void hideAccounts(List<String>tsfIds, Id territoryId){
		Set<Id>addressIds = new Set<Id>();
		for(TSF_vod__c tsf:  [SELECT Id, Account_vod__c, Address_vod__c, Territory_vod__c FROM TSF_vod__c WHERE Id IN :tsfIds]){
			addressIds.add(tsf.Address_vod__c);
		}
		List<String>childTerritories = getTerritoriesHierarchicalNames(territoryId);
		List<TSF_vod__c>tsfes = [SELECT id, Account_vod__c,  Address_vod__c, Territory_vod__c FROM TSF_vod__c WHERE Address_vod__c in :addressIds AND Territory_vod__c in :childTerritories];
		List<Sharing_Mgmt_gne__c>sharingManagments = new List<Sharing_Mgmt_gne__c>();
    	for(TSF_vod__c tsf: tsfes){
			sharingManagments.add(new Sharing_Mgmt_gne__c(Object_Name_gne__c = 'AccountShare', Account_Id_gne__c = tsf.Account_vod__c, Territory_Name_gne__c = tsf.Territory_vod__c, Territory_Id_gne__c = territoryId, Schedule_Date_Time_gne__c = System.Today(), Operation_gne__c = 'Delete', Status_gne__c = 'New'));
    	}
		insert sharingManagments;
    	delete tsfes;
	}

	public static List<Territory2> getUserTopTerritories(Id userId){
		return [SELECT Id, Name FROM Territory2 WHERE Id in (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :userId)];
	}

	public static List<String> getTerritoriesHierarchicalNames(String territoryId){
		List<String> result = new List<String>();
		if (String.isNotBlank(territoryId)){
			List<Territory2> parent = new List<Territory2>([Select Id, Name From Territory2 Where Id = :territoryId]);
			if (parent.size() > 0){
				Set<Territory2> childrens = new Set<Territory2>();
				GNE_SFA2_Util.getChildrenTerritories(parent, childrens);
				result.add(parent.get(0).Name);
				if (childrens.size() > 0){
					for (Territory2 children : childrens){
						result.add(children.Name);
					}
				}
			}
		}
		return result;
	}

	public static List<Id> getTerritoriesHierarchicalIds(String territoryId){
		List<Id> result = new List<Id>();
		if (String.isNotBlank(territoryId)){
			List<Territory2> parent = new List<Territory2>([Select Id, Name From Territory2 Where Id = :territoryId]);
			if (parent.size() > 0){
				Set<Territory2> childrens = new Set<Territory2>();
				GNE_SFA2_Util.getChildrenTerritories(parent, childrens);
				result.add(parent.get(0).Id);
				if (childrens.size() > 0){
					for (Territory2 children : childrens){
						result.add(children.Id);
					}
				}
			}
		}
		return result;
	}

}