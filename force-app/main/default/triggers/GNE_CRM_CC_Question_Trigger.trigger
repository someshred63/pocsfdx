trigger GNE_CRM_CC_Question_Trigger on GNE_CRM_CC_Question__c (before insert, before update) {
	GNE_CRM_CC_Field_Updates.setExternalIdValue(Trigger.new);
}