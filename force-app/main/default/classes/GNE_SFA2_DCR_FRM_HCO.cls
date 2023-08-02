public with sharing class GNE_SFA2_DCR_FRM_HCO {
	
	public static void onAfterUpdate(List<Change_Request_gne__c> triggerOld, List<Change_Request_gne__c> triggerNew) {
		insertMergeRecords(triggerOld, triggerNew);
	}   
	
	private static void insertMergeRecords(List<Change_Request_gne__c> triggerOld, List<Change_Request_gne__c> triggerNew) {
		Set<Id> accountIds = new Set<Id>();
		for (Change_Request_gne__c crNew : triggerNew) {
			if (crNew.Account_gne__c != null) {
				accountIds.add(crNew.Account_gne__c);
			}
		}
		Map<Id, Account> accountMap = new Map<Id, Account>([SELECT id, recordType.developerName FROM Account WHERE id in :accountIds]);
		List<CORE_Merge_Candidate__c> candidates = new List<CORE_Merge_Candidate__c>();
        Set<Id> accountsIds = new Set<Id>();    
		Integer idx = 0;
		Map<Id, Change_Request_gne__c>	changeRequestsToProcess = new Map<Id, Change_Request_gne__c>();
		for (Change_Request_gne__c crNew : triggerNew) {
			String accountRecordType = accountMap.get(crNew.Account_gne__c).recordType.developerName;
			Change_Request_gne__c crOld = triggerOld[idx++];
			if (crNew.Type_gne__c == GNE_SFA2_DCR_Util.HCO_REMOVE_DUPLICATE_ORGANIZATION_TYPE && accountRecordType == GNE_SFA2_DCR_Util.FRM_ACCOUNT_RT && !GNE_SFA2_DCR_Util.isApprovedForParentUpdate(crOld, accountRecordType) && GNE_SFA2_DCR_Util.isApprovedForParentUpdate(crNew, accountRecordType)) {
				changeRequestsToProcess.put(crNew.Id, crNew);
			}
		}
		List<CORE_Merge_Candidate__c> mergeCandidates = new List<CORE_Merge_Candidate__c>();
		Map<Id, List<Account>> crToAccounts = getAccountsPerCR(changeRequestsToProcess.values());
		Map<String, CORE_Merge_Object__c> mergeObjects = GNE_FRM_DST_MatchLoserTriggerHandler.fetchMergeObjectsMap();
		
		for (Id crId : crToAccounts.keySet()) {
			List<Account> accounts = crToAccounts.get(crId);
			Account winner = crToAccounts.get(crId).remove(0);
			mergeCandidates.addAll(createFrmHcoMergeCandidates(winner, accounts, mergeObjects.get('Account-US'), mergeObjects.get('Address-US')));
		}
		if (!mergeCandidates.isEmpty()) {
			Database.insert(mergeCandidates, false);
		}
	}
	
	
	private static Map<Id, List<Account>> getAccountsPerCR(List<Change_Request_gne__c> crs) {
		Map<Id, List<Account>> crToAccounts = new Map<Id, List<Account>>();
		Map<Id, Set<Id>> crToAccountIds = new Map<Id, Set<Id>>();
		Set<Id> allAccountIds = new Set<Id>(); 
		for (Change_Request_gne__c cr : crs) {
			Set<Id> accountsIds = new Set<Id>();
			accountsIds.add(cr.Account_gne__c);
			if (cr.Duplicate_Account_2_gne__c != null) {
				accountsIds.add(cr.Duplicate_Account_2_gne__c);
			}
			if (cr.Duplicate_Account_3_gne__c != null) {
				accountsIds.add(cr.Duplicate_Account_3_gne__c);
			}
			if (cr.Duplicate_Account_4_gne__c != null) {
				accountsIds.add(cr.Duplicate_Account_4_gne__c);
			}
			if (cr.Duplicate_Account_5_gne__c != null) {
				accountsIds.add(cr.Duplicate_Account_5_gne__c);
			}
			crToAccountIds.put(cr.Id, accountsIds);
			allAccountIds.addAll(accountsIds); 
		}
		Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT id, createddate, (SELECT id FROM Address_vod__r) FROM Account WHERE Id in :allAccountIds ORDER BY Createddate]);
		for (Change_Request_gne__c cr : crs) {
			List<Account> accounts = new List<Account>();
			for (Id accId : crToAccountIds.get(cr.Id)) {
				accounts.add(accountsMap.get(accId));
			}
			accounts = (List<Account>)GlobalUtils.qsort(accounts, new AccountComparator()); 
			crToAccounts.put(cr.Id, accounts);
		}
		return crToAccounts;
	}
	
	private static List<CORE_Merge_Candidate__c> createFrmHcoMergeCandidates(Account winner, List<Account> loosers, CORE_Merge_Object__c accountMergeObject, CORE_Merge_Object__c addressMergeObject) {
		List<CORE_Merge_Candidate__c> result = new List<CORE_Merge_Candidate__c>();
		result.add(createCandidate(accountMergeObject, winner.Id, winner.Id));
		for (Address_vod__c address : winner.Address_vod__r) {	
			result.add(createCandidate(addressMergeObject, winner.Address_vod__r.get(0).Id, address.Id));
		}
		for (Account looser : loosers) {
			result.add(createCandidate(accountMergeObject, winner.Id, looser.Id));
			if (!winner.Address_vod__r.isEmpty() && !looser.Address_vod__r.isEmpty()) {
				for (Address_vod__c address : looser.Address_vod__r) {
					result.add(createCandidate(addressMergeObject, winner.Address_vod__r.get(0).Id, address.Id));
				}
			}
		}
		return result;
	}
	
	private static CORE_Merge_Candidate__c createCandidate(CORE_Merge_Object__c mergeObj, String winnerId, String loserId) {
        return new CORE_Merge_Candidate__c(
            Merge_Object_gne__c = mergeObj.Id,
            Merge_Object_gne__r = mergeObj,
            Status_gne__c = CORE_Merge_Util.CANDIDATE_STATUS_LOADED,
            Type_gne__c         = 'Merge',
            Source_gne__c       = 'Manual', 
            Id_gne__c           = loserId,
            Master_Id_gne__c    = winnerId
        );
    }
			
	class AccountComparator implements GlobalUtils.ObjectComparator {
		public Integer compare(Object object1, Object object2) {
			Datetime d1 = ((Account)object1).createddate;
			Datetime d2 = ((Account)object2).createddate; 
			return d1 > d2 ? 1 : d1 == d2 ? 0 : -1;
		}
	}
}