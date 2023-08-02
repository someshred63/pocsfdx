global class GNE_CRM_CollabGrpMembAssigner_Batch implements Database.Batchable<SObject>, Database.Stateful {
    global Boolean isAdminModeModified;

    global Database.QueryLocator start(Database.BatchableContext context) {
        Set<String> profileNames = new Set<String>();
        isAdminModeModified = false;

        for (GNE_SFA2_MCCO_CRM_Profiles__c p : GNE_SFA2_MCCO_CRM_Profiles__c.getAll().values()) {
            profileNames.add(p.Name);
        }

        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN :profileNames];

        return Database.getQueryLocator([SELECT Id FROM CollaborationGroup WHERE OwnerId IN (SELECT ID FROM User WHERE ProfileId IN :profiles)]);
    }

    global void execute(Database.BatchableContext context, List<CollaborationGroup> scope) {
        if (isAdminModeEnabled() == false) {
            isAdminModeModified = true;
            switchAdminMode(true);
        }

        Set<String> userNames = new Set<String>();
        Map<Id, Set<Id>> userGroups = new Map<Id, Set<Id>>();

        for (GNE_CRM_CollabGroupMember__c u : GNE_CRM_CollabGroupMember__c.getAll().values()) {
            userNames.add(u.name);
        }

        for (User u : [SELECT Id FROM User WHERE Name IN :userNames]) {
            userGroups.put(u.Id, new Set<Id>());
        }

        for (CollaborationGroupMember m : [SELECT CollaborationGroupId, MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId IN :scope AND MemberId IN :userGroups.keySet()]) {
            userGroups.get(m.MemberId).add(m.CollaborationGroupId);
        }

        List<CollaborationGroupMember> membersToAdd = new List<CollaborationGroupMember>();

        for (CollaborationGroup grp : scope) {
            for (Id userId : userGroups.keySet()) {
                if (userGroups.get(userId).contains(grp.Id) == false) {
                    CollaborationGroupMember cgm = new CollaborationGroupMember();
                    cgm.CollaborationGroupId = grp.Id;
                    cgm.MemberId = userId;
                    cgm.CollaborationRole = 'Standard';
                    cgm.NotificationFrequency = 'N';
                    membersToAdd.add(cgm);
                }
            }
        }

        insert membersToAdd;
    }

    global void finish(Database.BatchableContext context) {
        if (isAdminModeModified) {
            switchAdminMode(false);
        }
    }

    private Boolean isAdminModeEnabled() {
        List<GNE_SFA2_Admin_Mode__c> adminModeSetting = [SELECT Id, GNE_SFA2_Is_Admin_Mode__c FROM GNE_SFA2_Admin_Mode__c WHERE SetupOwnerId = :UserInfo.getUserId() LIMIT 1];
        return !adminModeSetting.isEmpty() && adminModeSetting.get(0).GNE_SFA2_Is_Admin_Mode__c;
    }

    private void switchAdminMode(Boolean isAdminMode) {
        Id currentUserId = UserInfo.getUserId();
        List<GNE_SFA2_Admin_Mode__c> adminModeSetting = [SELECT Id, SetupOwnerId, GNE_SFA2_Is_Admin_Mode__c FROM GNE_SFA2_Admin_Mode__c WHERE SetupOwnerId = :currentUserId LIMIT 1];

        if (adminModeSetting.isEmpty()) {
            insert new GNE_SFA2_Admin_Mode__c(SetupOwnerId = currentUserId, GNE_SFA2_Is_Admin_Mode__c = isAdminMode);
        } else {
            adminModeSetting.get(0).GNE_SFA2_Is_Admin_Mode__c = isAdminMode;
            update adminModeSetting;
        }
    }
}