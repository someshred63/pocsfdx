trigger CFAR_PicklistValue on CFAR_Picklist_Value_gne__c (after update) {

	if (CFAR_ConfigUtil.isTriggerEnabled(new List<String> {'CFAR_PicklistValue', 'CFAR_Picklist_Value_gne__c'})) {
		
		Set<Id> pvIdsWithChangedName = new Set<Id>();

		for (CFAR_Picklist_Value_gne__c pv : trigger.New) {
			if (pv.Name != trigger.oldMap.get(pv.Id).Name) {
				pvIdsWithChangedName.add(pv.Id);
			}
		}

		if (!pvIdsWithChangedName.isEmpty()) {
			System.enqueueJob(new CFAR_QueueableTrialPicklistsUpdate(pvIdsWithChangedName, trigger.oldMap, trigger.newMap));
		}
	}
}