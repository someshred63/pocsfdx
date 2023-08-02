trigger SPCM_ICFR_Log_Settings_trigger on SPCM_ICFR_Log_Settings__c (before insert, before update, before delete) {

	if (Trigger.isBefore) {
		// insert
		/*****
		* @author Wojciech Jaskula
		*
		* @Description: Trigger action prevents to insert more than 1 record , also validates if there is {ARG} value to replace proper CMS id value in icfr log
		*/
		if (Trigger.isInsert) {
			SPCM_ICFRLogUtils.validateFieldArgumments(Trigger.new);
			SPCM_ICFRLogUtils.preventInsertingRecords(Trigger.new);
		}
		/*****
		* @author Wojciech Jaskula
		*
		* @Description: Trigger action validates if there is {ARG} value to replace proper CMS id value in icfr log
		*/
		if (Trigger.isUpdate) {
			SPCM_ICFRLogUtils.validateFieldArgumments(Trigger.new);
		}
		/*****
		* @author Wojciech Jaskula
		*
		* @Description: Trigger action prevents to delete record
		*/
		if (Trigger.isDelete) {
			SPCM_ICFRLogUtils.preventDeleteingIcfrLogSettingRecord(Trigger.old);
		}
	}

}