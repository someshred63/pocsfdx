trigger CORE_Merge_Configuration_Trigger on CORE_Merge_Configuration__c (before insert, before update) {
    if(!CORE_Merge_Util.isTriggerDisabled(CORE_Merge_Configuration__c.sObjectType)) {
        CORE_Merge_Util.setInTrigger(CORE_Merge_Configuration__c.sObjectType, true);
        
        if(Trigger.isBefore && Trigger.isInsert) {
            CORE_Merge_Util.setExternalId(Trigger.new);
            CORE_Merge_Util.validateConfiguration(Trigger.new);
        } else if(Trigger.isBefore && Trigger.isUpdate) {
            CORE_Merge_Util.setExternalId(Trigger.new);
            CORE_Merge_Util.validateConfiguration(Trigger.new);
        }
        
        CORE_Merge_Util.setInTrigger(CORE_Merge_Configuration__c.sObjectType, false);
    }
}