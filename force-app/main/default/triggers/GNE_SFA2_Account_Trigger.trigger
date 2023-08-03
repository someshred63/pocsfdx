trigger GNE_SFA2_Account_Trigger on Account (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    GNE_SFA2_S2S_Util.startDebugAction('accountTrigger', 'Mode: ' + (Trigger.isBefore ? 'before ' : 'after ') + (Trigger.isInsert ? 'insert' : Trigger.isUpdate ? 'update' : Trigger.isDelete ? 'delete' : '???'));
    
    if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isTriggerDisabled('GNE_SFA2_Account_Trigger__c') && !GNE_SFA2_Account_Trigger_Helper.inAccountTrig()) {
    
        GNE_SFA2_Account_Trigger_Helper.setAccountTrig(true);
        
        if(Trigger.isBefore && Trigger.isInsert){
            GNE_SFA2_Account_Trigger_Helper.clearFailedValidations();
            
            if(!GNE_SFA2_Account_Trigger_Helper.isValidationDisabled()) {
              GNE_SFA2_Account_Validation_Rules.onBeforeInsert(Trigger.new);
            }
            
            GNE_SFA2_Account_Field_Updates.onBeforeInsert(Trigger.new);
        } else if(Trigger.isBefore && Trigger.isUpdate) {
            GNE_SFA2_Account_Trigger_Helper.clearFailedValidations();
            
            if(!GNE_SFA2_Account_Trigger_Helper.isValidationDisabled()) {
              GNE_SFA2_Account_Validation_Rules.onBeforeUpdate(Trigger.old, Trigger.new);
            }
            
            GNE_SFA2_Account_Field_Updates.onBeforeUpdate(Trigger.old, Trigger.new);
        } else if(Trigger.isBefore && Trigger.isDelete){
            GNE_SFA2_Account_Trigger_Helper.clearFailedValidations();
            
            if(!GNE_SFA2_Account_Trigger_Helper.isValidationDisabled()) {
              GNE_SFA2_Account_Validation_Rules.onBeforeDelete(Trigger.old);
            }
            
            GNE_SFA2_Account_Field_Updates.onBeforeDelete(Trigger.old);
        } else if(Trigger.isAfter && Trigger.isInsert){
            GNE_SFA2_Account_Child_Record_Updates.onAfterInsert(Trigger.old, Trigger.new);
        } else if(Trigger.isAfter && Trigger.isUpdate){
            GNE_SFA2_Account_Child_Record_Updates.onAfterUpdate(Trigger.old, Trigger.new);
            //GNE_SFA2_Account_Email_Notifications.onAfterUpdate(Trigger.old, Trigger.new);
        } else if(Trigger.isAfter && Trigger.isDelete){
            GNE_SFA2_Account_Child_Record_Updates.onAfterDelete(Trigger.old);
            GNE_SFA2_Deleted_Records_Util.onAfterDelete(Trigger.old, Account.getSObjectType());            
        }
        GNE_SFA2_Account_Trigger_Helper.setAccountTrig(false);
    }
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        GNE_SFA2_FieldsChangeTimeStampHandler.onChange(Trigger.old, Trigger.new, String.valueOf(Account.REST_AccInfo_Fields_LastModDate_gne__c), GNE_SFA2_Account_Trigger_Helper.getInfoServiceTrackedFields());
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        GNE_SFA2_FieldsChangeTimeStampHandler.onChange(Trigger.old, Trigger.new, String.valueOf(Account.iPhone_Fields_LastModifiedDate_gne__c), GNE_SFA2_Account_Trigger_Helper.getIPhoneTrackedFields());
        GNE_SFA2_AccountTriggerHandlerLogic.updateMDMSynchStatus();
    }
    
    //insert notification
    if(Trigger.isAfter && Trigger.isUpdate){
        GNE_SFA2_Notification_Handler.createNotificationOnAccountUpdate(Trigger.old, Trigger.new);
    }

    GNE_SFA2_S2S_Util.endDebugAction('accountTrigger', 'Mode: ' + (Trigger.isBefore ? 'before ' : 'after ') + (Trigger.isInsert ? 'insert' : Trigger.isUpdate ? 'update' : Trigger.isDelete ? 'delete' : '???'));
}