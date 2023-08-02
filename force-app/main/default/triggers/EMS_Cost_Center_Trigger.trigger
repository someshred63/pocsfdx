trigger EMS_Cost_Center_Trigger on EMS_Cost_Center_gne__c (before update, before insert, before delete, after insert, after update) {
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        EMS_Cost_Center_Field_Updates.onBeforeInsertUpdate(Trigger.new);
    } else if(Trigger.isAfter && Trigger.isUpdate) {
        EMS_Cost_Center_Child_Record_Updates.onAfterUpdate(Trigger.old, Trigger.newMap);
    }
}