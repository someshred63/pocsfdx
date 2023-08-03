trigger GNE_clearOldDataAfterETLUpdate_STGZip2Terr on Staging_Zip_2_Terr_gne__c (before update, before insert) {
    if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isTriggerDisabled('GNE_clearOldDataAfterETLUpdate_STGZip2Terr')) {
        if(Trigger.isBefore && Trigger.isInsert) {
            GNE_Staging_Zip_2_Terr_TriggerHandler.runValidation();
        } else if(Trigger.isBefore && Trigger.isUpdate) {
            GNE_Staging_Zip_2_Terr_TriggerHandler.clearOldData();
        } else if(Trigger.isBefore && Trigger.isDelete) {

        } else if(Trigger.isAfter && Trigger.isInsert) {

        } else if(Trigger.isAfter && Trigger.isUpdate) {

        } else if(Trigger.isAfter && Trigger.isDelete) {

        }
    }
}