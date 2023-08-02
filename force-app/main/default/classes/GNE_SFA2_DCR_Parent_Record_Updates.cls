public without sharing class GNE_SFA2_DCR_Parent_Record_Updates {
	public static void onAfterInsert(List<Change_Request_gne__c> triggerNew) {
		
	}
	
	public static void onAfterUpdate(List<Change_Request_gne__c> triggerOld, List<Change_Request_gne__c> triggerNew) {
		updateRecordsForApprovedDCRs(triggerOld, triggerNew);
	}
	
	public static void onAfterDelete(List<Change_Request_gne__c> triggerOld) {}
	
	private static void updateRecordsForApprovedDCRs(List<Change_Request_gne__c> triggerOld, List<Change_Request_gne__c> triggerNew) {
		Set<Id>accountIds = new Set<Id>();
		for(Change_Request_gne__c crNew : triggerNew) {
			if(crNew.Account_gne__c != null){
				accountIds.add(crNew.Account_gne__c);
			}
		}
		Map<Id, Account> accountMap = new Map<Id, Account>([SELECT id, recordType.developerName FROM Account WHERE id in :accountIds]);
		Map<Id,Change_Request_gne__c> crsForParentUpdates = new Map<Id,Change_Request_gne__c>();
            
		if(GNE_SFA2_DCR_Util.isParentUpdateEnabled()) {
			Integer idx = 0;
			
			for(Change_Request_gne__c crNew : triggerNew) {
				String accountRecordType = accountMap.get(crNew.Account_gne__c).recordType.developerName;
				Change_Request_gne__c crOld = triggerOld[idx++];
				
				if(!GNE_SFA2_DCR_Util.isApprovedForParentUpdate(crOld, accountRecordType) && GNE_SFA2_DCR_Util.isApprovedForParentUpdate(crNew, accountRecordType) && GNE_SFA2_DCR_Util.isValidForParentUpdate(crNew)) {
					crsForParentUpdates.put(crNew.Id, crNew);
				}
			}
		}
		
		if(!crsForParentUpdates.isEmpty()) {
			Map<Id,List<GNE_SFA2_DCR_Util.DmlResult>> sResults = GNE_SFA2_DCR_Util.updateParentRecords(crsForParentUpdates.values());
			
			for(Id crId : sResults.keySet()) {
				List<GNE_SFA2_DCR_Util.DmlResult> dmlResults = sResults.get(crId); 
				Change_Request_gne__c crNew = crsForParentUpdates.get(crId);
				
				for(GNE_SFA2_DCR_Util.DmlResult dmlr : dmlResults) {
                    if(!dmlr.isSuccess()) {
                        for(Database.Error err : dmlr.getErrors()) {
                            if(err!=null){
                                crNew.addError(err.getMessage());
                            }
                        }
                    }    
		      	}
			}
		}
	}
}