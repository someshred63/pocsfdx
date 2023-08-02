trigger GNE_Staging_MCE_Trigger on Staging_MCE_gne__c (before insert, before update, after insert, after update, after delete, after undelete) {
  if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isTriggerDisabled('GNE_Staging_MCE_Trigger')) {
    if(Trigger.isBefore) {
        GNE_SFA2_ExternalIdUpdater.setExternalId(trigger.new);
    } else if(Trigger.isAfter) {
        GNE_Subscribe_MCE_Scheduler.scheduleDeltaRefresh();
    }
  }
}