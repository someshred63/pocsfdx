trigger GNE_SFA2_Territory2_Trigger on Territory2 (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isTriggerDisabled('GNE_SFA2_Territory2_Trigger__c') && !GNE_SFA2_Territory2_Trigger_Helper.isSubscribePrevMode) {
        if (!GNE_SFA2_Territory2_Trigger_Helper.isSubscribeMode && !GNE_SFA2_Territory2_Trigger_Helper.inTrigger) {
            if (!GNE_SFA2_Territory2_Trigger_Helper.runOnlyAfterEvents) {
                if (Trigger.isBefore && Trigger.isInsert) {
                    GNE_SFA2_Territory2_Trigger_Logic.populateExternalIds(Trigger.new);
                    GNE_SFA2_Territory2_Trigger_Logic.externalIdsValidation(Trigger.new);
                    GNE_SFA2_Territory2_Trigger_Logic.nameValidation(Trigger.new);
                } else if (Trigger.isBefore && Trigger.isUpdate) {
                    GNE_SFA2_Territory2_Trigger_Logic.populateExternalIds(Trigger.new);
                    GNE_SFA2_Territory2_Trigger_Logic.externalIdsValidation(Trigger.new);
                    GNE_SFA2_Territory2_Trigger_Logic.nameValidation(Trigger.new);
                }
            }

            if (Trigger.isAfter && Trigger.isUpdate) {
                GNE_SFA2_Territory2_Trigger_Helper.setInTrigger(true);
                GNE_SFA2_Territory2_Trigger_Logic.checkCorrectnessExtIds(Trigger.new);
                GNE_SFA2_Territory2_Trigger_Helper.setInTrigger(false);
            }
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            GNE_SFA2_Territory2_Trigger_Logic.updateRepStagingData(trigger.newMap, trigger.oldMap);
        }

        if (!Test.isRunningTest()) {
            if (Trigger.isAfter && Trigger.isInsert) {
                GNE_SFA2_Territory2_Trigger_Logic.createTerritoryGroups(trigger.newMap);
            } else if (Trigger.isAfter && Trigger.isDelete) {
                GNE_SFA2_Territory2_Trigger_Logic.deleteTerritoryGroups(trigger.oldMap);
            } else if (Trigger.isAfter && Trigger.isUpdate) {
                GNE_SFA2_Territory2_Trigger_Logic.deleteTerritoryGroupsForInactiveTerritories(trigger.newMap);
                GNE_SFA2_Territory2_Trigger_Logic.deleteUsersFromInactiveTerritories(trigger.newMap);
                GNE_SFA2_Territory2_Trigger_Logic.updateGroupHierarchy(JSON.serialize(Trigger.newMap), JSON.serialize(Trigger.oldMap));
                GNE_SFA2_Territory2_Trigger_Logic.updateTsfes(Trigger.newMap, Trigger.oldMap);
                GNE_SFA2_Territory2_Trigger_Logic.updateStagingUserAssignments(Trigger.newMap, Trigger.oldMap);

            }
        }
    }
}