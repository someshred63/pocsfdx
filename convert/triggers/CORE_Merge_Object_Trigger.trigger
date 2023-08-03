trigger CORE_Merge_Object_Trigger on CORE_Merge_Object__c (before insert, before update, before delete) {
    if(!CORE_Merge_Util.isTriggerDisabled(CORE_Merge_Object__c.sObjectType)) {
        CORE_Merge_Util.setInTrigger(CORE_Merge_Object__c.sObjectType, true);
        
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            CORE_Merge_Util.setExternalId(Trigger.new);
            CORE_Merge_Util.setExternalId(Trigger.new, String.valueOf(CORE_Merge_Object__c.Name), String.valueOf(CORE_Merge_Object__c.External_Id_calc_gne__c));
        } else if(Trigger.isBefore && Trigger.isDelete) {
            CORE_Merge_Util.blockDelete(Trigger.old);
        }
        
        CORE_Merge_Util.setInTrigger(CORE_Merge_Object__c.sObjectType, false);
    }
}