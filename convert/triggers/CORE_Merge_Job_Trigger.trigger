trigger CORE_Merge_Job_Trigger on CORE_Merge_Job__c (before insert, before delete) {
    if(!CORE_Merge_Util.isTriggerDisabled(CORE_Merge_Job__c.sObjectType)) {
        CORE_Merge_Util.setInTrigger(CORE_Merge_Job__c.sObjectType, true);
        
        if(Trigger.isBefore && Trigger.isInsert) {
            CORE_Merge_Util.setExternalId(Trigger.new, String.valueOf(CORE_Merge_Job__c.Name), String.valueOf(CORE_Merge_Job__c.External_Id_calc_gne__c));
        } else if(Trigger.isBefore && Trigger.isDelete) {
            CORE_Merge_Util.blockDelete(Trigger.old);
        }
        
        CORE_Merge_Util.setInTrigger(CORE_Merge_Job__c.sObjectType, false);
    }
}