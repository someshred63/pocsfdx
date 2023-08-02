trigger EMS_Speaker_Role_Trigger on EMS_Speaker_Role_gne__c (before insert, before update, after insert, after update) {
    if(Trigger.isAfter && Trigger.isInsert) {
         EMS_Speaker_Role_Child_Record_Updates.onAfterInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        EMS_Speaker_Role_Child_Record_Updates.onAfterUpdate(Trigger.new);
    }

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        EMS_Speaker_Role_Field_Updates.onBeforeInsertUpdate(Trigger.new);
    }
}