trigger CFAR_ContactTrigger on CFAR_Contact_gne__c (after update) {
	if (CFAR_ConfigUtil.isTriggerEnabled(new List<String>{'CFAR_ContactTrigger','CFAR_Contact_gne__c'})){
		if(!CFAR_Utils.hasAlreadyProcessedContact()) {
			if (trigger.isAfter && trigger.isUpdate) {
				CFAR_Utils.handleUserAssignmentUnassignmentOnContact(trigger.oldMap, trigger.newMap);
			}
		}
	}
}