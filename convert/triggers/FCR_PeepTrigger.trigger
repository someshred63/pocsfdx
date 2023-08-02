trigger FCR_PeepTrigger on FCR_Peep_gne__c (after update) {
    if (GNE_SFA2_Util.isAdminMode() ) return;

    if(Trigger.isAfter && Trigger.isUpdate) {
        FCR_PeepTriggerHandler.onAfterUpdate();
    }
}