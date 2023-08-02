global class GNE_SFA2_AccountShareBatch implements Database.Batchable<sObject>, Database.Stateful {
	private Boolean runMultipleTimes = true;

	global GNE_SFA2_AccountShareBatch() {}
	global GNE_SFA2_AccountShareBatch(Boolean runMultipleTimes) {
		this.runMultipleTimes = runMultipleTimes;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		DateTime lastProcessExecutionTime = getLastProcessExecutionTime(bc);
        String query = 'SELECT Id, Territory_vod__c, Account_vod__c FROM TSF_vod__c WHERE LastModifiedDate >= :lastProcessExecutionTime';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		List<TSF_vod__c> tsfs = (List<TSF_vod__c>)scope;
   		Set<String> territoriesNames = new Set<String>();
   		Map<String, List<String>> acctToTerritoryMap = new Map<String, List<String>>();
   		Map<Id, Id> terrIdToGroupIdMap = new Map<Id, Id>();
   		Map<String, Id> terrNameToTerrIdMap = new Map<String, Id>();
   		List<ObjectTerritory2Association> territoryAssociations = new List<ObjectTerritory2Association>();
   		for(TSF_vod__c tsf : tsfs) {
   			territoriesNames.add(tsf.Territory_vod__c);
   			if(!acctToTerritoryMap.containsKey(tsf.Account_vod__c)) {
   				acctToTerritoryMap.put(tsf.Account_vod__c, new List<String>{tsf.Territory_vod__c});
   			} else {
   				acctToTerritoryMap.get(tsf.Account_vod__c).add(tsf.Territory_vod__c);
   			}
   		}

   		terrNameToTerrIdMap = getTerritories(territoriesNames);
        List<Group> groups = territoriesNames.isEmpty() ? new List<Group>() : GNE_SFA2_SBC_DAO.getTerritoryGroups(new Set<Id>(terrNameToTerrIdMap.values()));
        for (Group grp : groups) {
            terrIdToGroupIdMap.put(grp.RelatedId, grp.Id);
        }

   		Set<String> acctsSharesKeys = getAccountsSharesKeys(new List<String>(acctToTerritoryMap.keySet()), terrIdToGroupIdMap.values());

		for(String acctId : acctToTerritoryMap.keySet()) {
			for(String terrName : acctToTerritoryMap.get(acctId)) {
				Id terrId = terrNameToTerrIdMap.get(terrName);
				if(terrIdToGroupIdMap.containsKey(terrId)) {
					Id groupId = terrIdToGroupIdMap.get(terrId);
					String key = acctId + '_' + groupId;
					if(!acctsSharesKeys.contains(key)) {
						ObjectTerritory2Association territoryAssociation = new ObjectTerritory2Association(ObjectId = acctId, Territory2Id = terrId, AssociationCause='Territory2Manual');
                    	territoryAssociations.add(territoryAssociation);
					}
				}
			}
		}

   		if(!territoryAssociations.isEmpty()) {
   			insert territoryAssociations;
   		}
	}

	global void finish(Database.BatchableContext BC) {
		if(this.runMultipleTimes) {
			GNE_Batch_Runner.scheduleBatchBasedOnSettings(
					new GNE_SFA2_AccountShare_Scheduler(),
					'GNE_SFA2_AccountShare', 'GNE SFA2 Account Share');
		}

		System.debug('Account Share batch finished.');
	}

	private static Map<String, Id> getTerritories(Set<String> territoriesNames) {
		Map<String, Id> result = new Map<String, Id>();
		for(Territory2 terr : [SELECT Id, Name FROM Territory2 WHERE Name IN : territoriesNames]) {
			result.put(terr.Name, terr.Id);
		}
		return result;
	}

	private static Set<String> getAccountsSharesKeys(List<Id> acctsIds, List<Id> groupsIds) {
		Set<String> result = new Set<String>();
		for(AccountShare acctShare : [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN : acctsIds AND UserOrGroupId IN : groupsIds]) {
			String key = acctShare.AccountId + '_' + acctShare.UserOrGroupId;
			result.add(key);
		}
		return result;
	}

	private static System.Type getSelfClass() {
        return GNE_SFA2_AccountShareBatch.class;
    }

	private static DateTime getLastProcessExecutionTime(Database.BatchableContext bc) {
        DateTime result = null;
        Id currentJobId = bc != null ? bc.getJobId() : null;

        for(AsyncApexJob job : [SELECT CreatedDate
                                FROM AsyncApexJob
                                WHERE ApexClass.Name = :getSelfClass().getName()
                                    AND Id != :currentJobId
                                    AND ParentJobId = null
                                    AND JobType = 'BatchApex'
                                    AND Status = 'Completed'
                                    AND NumberOfErrors = 0
                                ORDER BY CreatedDate desc
                                LIMIT 1]) {
            result = job.CreatedDate;
        }

        return result != null ? result : DateTime.now().addDays(-60);
    }

}