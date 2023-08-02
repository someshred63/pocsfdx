trigger EDM_Classification_Request_Trigger on EDM_Classification_Request_gne__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    Map<Id,Boolean> validationResults;
    if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isTriggerDisabled('EDM_Classification_Request_gne__c')) {
    
        if(Trigger.isBefore && Trigger.isInsert){

        } else if(Trigger.isBefore && Trigger.isUpdate) {
            EDM_Set_Updated_By_Field.onBeforeUpdate(Trigger.oldMap,Trigger.new);
        } else if(Trigger.isBefore && Trigger.isDelete){

        } else if(Trigger.isAfter && Trigger.isInsert){
            
        } else if(Trigger.isAfter && Trigger.isUpdate){
            EDM_Classification_Request_Email_Notif.onAfterUpdate(Trigger.old,Trigger.new);
            EDM_Nomination_Status_Update.onAfterUpdateClassification(Trigger.oldMap,Trigger.new);
        } else if(Trigger.isAfter && Trigger.isDelete){
           
        }

    }

}