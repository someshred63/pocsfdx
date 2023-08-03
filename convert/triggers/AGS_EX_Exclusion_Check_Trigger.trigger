trigger AGS_EX_Exclusion_Check_Trigger on AGS_EX_Exclusion_Check_gne__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    Map<Id,Boolean> validationResults;
    if (!GNE_SFA2_Util.isAdminMode() 
        && !GNE_SFA2_Util.isTriggerDisabled('AGS_EX_Exclusion_Check_gne__c')) {
    
        if(Trigger.isBefore && Trigger.isInsert){

        } else if(Trigger.isBefore && Trigger.isUpdate) {

        } else if(Trigger.isBefore && Trigger.isDelete){

        } else if(Trigger.isAfter && Trigger.isInsert){
            AGS_EX_Exclusion_Check_Field_Updates.onAfterInsert(Trigger.new);
        } else if(Trigger.isAfter && Trigger.isUpdate){
            AGS_EX_Exclusion_Check_Field_Updates.onAfterUpdate(Trigger.new);
        } else if(Trigger.isAfter && Trigger.isDelete){
           
        }
    }
}