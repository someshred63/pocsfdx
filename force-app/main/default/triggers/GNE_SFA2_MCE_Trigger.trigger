trigger GNE_SFA2_MCE_Trigger on MCE_gne__c (after delete) {
  if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isTriggerDisabled('GNE_SFA2_MCE_Trigger')) {
    if(Trigger.isAfter && Trigger.isDelete){
      GNE_SFA2_Deleted_Records_Util.onAfterDelete(Trigger.old, MCE_gne__c.getSObjectType());            
    }
  }
}