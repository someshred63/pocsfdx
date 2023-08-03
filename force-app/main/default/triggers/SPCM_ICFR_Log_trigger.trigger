trigger SPCM_ICFR_Log_trigger on SPCM_ICFR_Log__c (before insert, before update, after update) {
    
    if (SPCM_ICFRLogUtils.skipTriggerActions) {
    	return;
    }
    
    // before event
    if (Trigger.isBefore)
    {
        // insert
        if (Trigger.isInsert)
        {
            SPCM_ICFRLogUtils.UpdateActivationTimeline(Trigger.new);
        }
    
        // update
        if (Trigger.isUpdate)
        {
            SPCM_ICFRLogUtils.UpdateActivationTimeline(Trigger.new);
            SPCM_ICFRLogUtils.ValidateRequiredFields(Trigger.new);
        }
    }
    
    if (Trigger.isAfter)
    {
    	if (Trigger.isUpdate) 
    	{
    		SPCM_ICFRLogUtils.UpdateExpectedApprovedActivationDate(Trigger.new);
    	}
    }
}