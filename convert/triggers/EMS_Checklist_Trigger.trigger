trigger EMS_Checklist_Trigger on EMS_Checklist_gne__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {


    if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
        if (Trigger.isUpdate) {
            EMS_Checklist_Field_Updates.onBeforeUpdate(Trigger.oldMap, Trigger.new);
        }
        if (Trigger.isInsert) {
            EMS_Checklist_Field_Updates.onBeforeInsert(Trigger.new);
        }
        // validation should go after fields are updated 
        if (Trigger.isUpdate) {
            EMS_Checklist_Validation_Rules.validate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isInsert) {
            EMS_Checklist_Validation_Rules.validate(Trigger.new, new Map<Id,EMS_Checklist_gne__c>());
        }
        
    } else if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {

    }
}