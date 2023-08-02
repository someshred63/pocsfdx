/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-10
*  Description: This is a helper class for GNE_SFA2_User_Trigger for handling User child record updates
*  Test class: GNE_SFA2_User_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
public with sharing class GNE_SFA2_User_Child_Record_Updates {

    public static void onAfterInsert(List<User> triggerNew) {
        updateUserDelegationsOnInsert(triggerNew);
        updateUserGroups(null, triggerNew, false);
        assignUserPermSetsByProfileConfiguration(triggerNew);
    }

    public static void onAfterUpdate(Map<Id, User> triggerOldMap, List<User> triggerNew) {
        manageViewAllBrandsGroups(triggerOldMap.values(), triggerNew);
        updateUserDelegationsOnUpdate(triggerOldMap.values(), triggerNew);
        updateUserGroups(triggerOldMap, triggerNew, true);
		if(!System.isBatch() && !System.isFuture()) {
			updateStagingAlignments(triggerOldMap, triggerNew);
		}
    }

    private static void manageViewAllBrandsGroups(List<User> triggerOld, List<User> triggerNew) {
        for (Integer i = 0; i < triggerNew.size(); i++) {
            if (triggerNew[i].View_Mode_All_Brands_gne__c && !triggerOld[i].View_Mode_All_Brands_gne__c) {
                GroupVisibilityHandler.AddUserToGroup(triggerNew[i].Id, 'GNE-View-All-Brands-Users-Data-Group');
            } else if (!triggerNew[i].View_Mode_All_Brands_gne__c && triggerOld[i].View_Mode_All_Brands_gne__c) {
                GroupVisibilityHandler.RemoveUserFromGroup(triggerNew[i].Id, 'GNE-View-All-Brands-Users-Data-Group');
            }
        }
    }

    private static void updateUserDelegationsOnInsert(List<User> triggerNew) {
        List<Id> userIDs = new List<Id>();
        for (User user : triggerNew) {
            if (user.UserType == 'Standard') {
                userIDs.add(user.Id);
            }
        }
    }

    private static void updateUserDelegationsOnUpdate(List<User> triggerOld, List<User> triggerNew) {
        List<Id> userIDs = new List<Id>();
        for (Integer i = 0; i < triggerNew.size(); i++) {
            if (triggerNew[i].UserType == 'Standard') {
                if (triggerNew[i].IsActive != triggerOld[i].IsActive || triggerNew[i].Username != triggerOld[i].Username) {
                    userIDs.add(triggerNew[i].Id);
                }
            }
        }
    }

    private static void updateUserGroups(Map<Id, User> triggerOldMap, List<User> triggerNew, Boolean isUpdate) {
        if (GNE_CM_UnitTestConfig.isSkipped('trigUserUpdateProfileGroups') || System.isBatch() || System.isFuture()) {
            return;
        }

        GNE_SFA2_User_Trigger_Helper.assignUsersToGroups(JSON.serialize(triggerOldMap), JSON.serialize(triggerNew), isUpdate);
    }

    private static void assignUserPermSetsByProfileConfiguration(List<User> triggerNew) {
        GNE_SFA2_Profile_Mapping_Utils.createUserPermSetsByMapping(triggerNew);
    }

    private static void updateStagingAlignments(Map<Id, User> triggerOldMap, List<User> triggerNew) {
        Set <String> inactivatedUsers = new Set<String>();
        for (User user : triggerNew) {
            if (!user.IsActive && triggerOldMap.get(user.Id).IsActive) {
                inactivatedUsers.add(user.External_ID_gne__c);
            }
        }
        if (!inactivatedUsers.isEmpty()) {
            setStagingRecordsAsProcessed(inactivatedUsers);
        }
    }

    @Future
    private static void setStagingRecordsAsProcessed(Set<String> usersExtIds) {
        List<Staging_User_Assignment_gne__c> stagingRecords = [SELECT Id FROM Staging_User_Assignment_gne__c WHERE Status_gne__c = 'Assigned' AND User_UnixID_gne__c IN :usersExtIds];

        String comment = 'Territory assignment removed as user has been deactivated on ' + System.now().format('MM/dd/yyyy');
        for (Staging_User_Assignment_gne__c stagingUserAssignment : stagingRecords) {
            stagingUserAssignment.Status_gne__c = GNE_Subscribe_Batch_Base.STATUS_PROCESSED;
            stagingUserAssignment.Comment_gne__c = comment;
        }
        if (!stagingRecords.isEmpty()) {
            update stagingRecords;
        }

    }

}