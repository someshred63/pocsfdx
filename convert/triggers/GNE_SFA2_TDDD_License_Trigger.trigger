/**
 * Created by kozminsl on 27.03.2019.
 */

trigger GNE_SFA2_TDDD_License_Trigger on TDDD_License_gne__c (after delete) {

    if (
            !GNE_SFA2_Util.isAdminMode() &&
                    !GNE_SFA2_Util.isTriggerDisabled('GNE_SFA2_TDDD_License_Trigger') &&
                    !GNE_SFA2_Util.isMergeMode()) {
        if (Trigger.isAfter && Trigger.isDelete) {
            GNE_SFA2_Deleted_Records_Util.onAfterDelete(Trigger.old, TDDD_License_gne__c.getSObjectType());
        }
    }
}