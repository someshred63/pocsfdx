trigger GNE_Calculate_BrandZipId_beforeInsertUpdate on Zip_to_Territory_gne__c (before insert, before update, before delete, after undelete) {
    if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isTriggerDisabled('GNE_Calculate_BrandZipId_beforeInsertUpdate')) {
        if(Trigger.isBefore && Trigger.isInsert) {
            GNE_Zip2TerritoryTriggerHandler.calculateBrandZip();
            GNE_Zip2TerritoryTriggerHandler.updateUSPSAddress();
        } else if(Trigger.isBefore && Trigger.isUpdate) {
            GNE_Zip2TerritoryTriggerHandler.calculateBrandZip();
            GNE_Zip2TerritoryTriggerHandler.updateUSPSAddress();
        } else if(Trigger.isBefore && Trigger.isDelete) {
            GNE_Zip2TerritoryTriggerHandler.createOTRDeletedRecordOnDeleted();
        } else if(Trigger.isAfter && Trigger.isInsert) {

        } else if(Trigger.isAfter && Trigger.isUpdate) {

        } else if(Trigger.isAfter && Trigger.isDelete) {

        } else if(Trigger.isAfter && Trigger.isUndelete) {

        }
    }
}