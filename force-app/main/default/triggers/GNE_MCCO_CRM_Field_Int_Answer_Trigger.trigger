trigger GNE_MCCO_CRM_Field_Int_Answer_Trigger on GNE_MCCO_CRM_Field_Intelligence_Answer__c (after insert, before update) {
	if(Trigger.isBefore && Trigger.isUpdate){
		GNE_MCCO_CRM_Field_Int_Answer_Field_Upd.onBeforeUpdate(Trigger.new);
	} else if(Trigger.isAfter && Trigger.isInsert){
		GNE_MCCO_CRM_Field_Int_Answer_Field_Upd.onAfterInsert(Trigger.new);
	}
}