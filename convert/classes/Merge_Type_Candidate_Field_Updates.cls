public with sharing class Merge_Type_Candidate_Field_Updates {
	public static void onBeforeInsert(List<Merge_Type_Candidate_Stage_gne__c> triggerNew) {
		setMergeType(triggerNew);
		GNE_SFA2_ExternalIdUpdater.setExternalId(triggerNew);
	}
	
	public static void onBeforeUpdate(List<Merge_Type_Candidate_Stage_gne__c> triggerOld, List<Merge_Type_Candidate_Stage_gne__c> triggerNew) {
		GNE_SFA2_ExternalIdUpdater.setExternalId(triggerNew);
		GNE_SFA2_ExternalIdUpdater.setExternalId(triggerNew,
			String.valueOf(Merge_Type_Candidate_Stage_gne__c.Merge_Type_External_Id_gne__c),
			String.valueOf(Merge_Type_Candidate_Stage_gne__c.Merge_Type_External_Id_calc_gne__c)
		);
	}
	
	private static void setMergeType(List<Merge_Type_Candidate_Stage_gne__c> triggerNew) {
		List<Merge_Type_Candidate_Stage_gne__c> recWithParentToUpdate = new List<Merge_Type_Candidate_Stage_gne__c>();
		Set<String> parentExternalIds = new Set<String>();
		List<Merge_Type_Candidate_Stage_gne__c> recWithParentExternalIdToUpdate = new List<Merge_Type_Candidate_Stage_gne__c>();
		
		for(Merge_Type_Candidate_Stage_gne__c recNew : triggerNew) {
			if(recNew.Merge_Type_ref_gne__c == null && String.isNotBlank(recNew.Merge_Type_External_Id_gne__c)) {
				recWithParentToUpdate.add(recNew);
				parentExternalIds.add(recNew.Merge_Type_External_Id_gne__c);
			} else if(recNew.Merge_Type_ref_gne__c!=null) {
				recWithParentExternalIdToUpdate.add(recNew);
			}
		}
		
		if(!parentExternalIds.isEmpty()) {
			Map<String,Id> parentExternalIdToSfdcId = new Map<String,Id>();
			
			for(Merge_Type_gne__c mt : [SELECT Id, Unique_Name_gne__c FROM Merge_Type_gne__c WHERE Unique_Name_gne__c IN :parentExternalIds]) {
				parentExternalIdToSfdcId.put(mt.Unique_Name_gne__c.toUpperCase(), mt.Id);
			}
			
			for(Merge_Type_Candidate_Stage_gne__c recNew : recWithParentToUpdate) {
				recNew.Merge_Type_ref_gne__c = parentExternalIdToSfdcId.get(recNew.Merge_Type_External_Id_gne__c.toUpperCase());
			}
		}
		
		GNE_SFA2_ExternalIdUpdater.setExternalId(recWithParentExternalIdToUpdate,
			String.valueOf(Merge_Type_Candidate_Stage_gne__c.Merge_Type_External_Id_gne__c),
			String.valueOf(Merge_Type_Candidate_Stage_gne__c.Merge_Type_External_Id_calc_gne__c)
		);
	}
}