trigger GNE_UserPreference_Trigger on User_Preference_gne__c (before insert, before update) {
    if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isMergeMode() && !GNE_SFA2_Util.isTriggerDisabled('GNE_UserPreference_Trigger')) {
        GNE_SFA2_ExternalIdUpdater.setExternalId(trigger.new, String.valueOf(User_Preference_gne__c.External_Id_gne__c), String.valueOf(User_Preference_gne__c.Unique_Key_Calc_gne__c));
    }
}