trigger AGS_EX_Exclusion_Request_Trigger on AGS_EX_Exclusion_Request_gne__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    Map<Id,Boolean> validationResults;
    if (!GNE_SFA2_Util.isAdminMode()) {
    
        if(Trigger.isBefore && Trigger.isInsert){

        } else if(Trigger.isBefore && Trigger.isUpdate) {

        } else if(Trigger.isBefore && Trigger.isDelete){

        } else if(Trigger.isAfter && Trigger.isInsert){
            EDM_Nomination_Status_Update.onAfterInsertExclusion(Trigger.new);
        } else if(Trigger.isAfter && Trigger.isUpdate){
            EDM_Nomination_Status_Update.onAfterUpdateExclusion(Trigger.oldMap,Trigger.new);
        } else if(Trigger.isAfter && Trigger.isDelete){
           
        }
    }
}