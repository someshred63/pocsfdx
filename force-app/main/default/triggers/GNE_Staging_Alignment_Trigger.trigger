trigger GNE_Staging_Alignment_Trigger on Staging_Alignment_gne__c (before insert, before update) {
  if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isTriggerDisabled('GNE_Staging_Alignment_Trigger')) {
    GNE_SFA2_ExternalIdUpdater.setExternalId(trigger.new);
  }
}