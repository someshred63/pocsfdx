trigger FCR_VisitTrigger on Visit_gne__c (after insert, after update) {
    if (GNE_SFA2_Util.isAdminMode() ) return;
    
    if(Trigger.isAfter && Trigger.isInsert) {
        FCR_VisitTriggerHandler.onAfterInsert();
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        FCR_VisitTriggerHandler.onAfterUpdate();
    }
}