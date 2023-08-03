trigger GNE_CRM_340B_Email_Trigger on GNE_CRM_340B_Email__c (before insert, before update, after insert, after update) {
    
    if (Trigger.isBefore) {
        GNE_CRM_340B_Email_TriggerHandler.updateCaseAssignedStatus(Trigger.new);
        GNE_CRM_340B_Email_TriggerHandler.updateParentCase(Trigger.new);
    }
    
    if (Trigger.isAfter) {
        GNE_CRM_340B_Email_TriggerHandler.assignEmailToCase(Trigger.new);
        GNE_CRM_340B_Email_TriggerHandler.updateParentCase(Trigger.new);
    }

}