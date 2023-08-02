@isTest
private class GNE_CRM_CollabGrpMembAssigner_Batch_Test {

    @testSetup
    static void initData() {
        List<User> usersToInsertList = new List<User>{
                new User(
                        ProfileId = [SELECT Id FROM Profile WHERE Name = 'GNE-Field' LIMIT 1].Id,
                        TimeZoneSidKey = 'America/Los_Angeles',
                        Email = 'us@gene.com',
                        FirstName = 'usUser',
                        External_ID_gne__c = 'ustest',
                        Alias = 'ustest',
                        Username = 'UsTest@gene.com',
                        EmailEncodingKey = 'UTF-8',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US',
                        LastName = 'User',
                        IsActive = true
                )
        };

        insert usersToInsertList;

    }

	@isTest
	private static void testAutomaticCollaborationGroupAssignment() {
        User sfa2User = [SELECT Id FROM User WHERE Username = 'UsTest@gene.com' AND isActive = true LIMIT 1];

        if (sfa2User == null) {
            System.assert(false, 'Could not find any SFA2 Users!');
        }

        User autoAddedUser = [SELECT Id, Name FROM User WHERE Id = :sfa2User.Id];
        String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
        CollaborationGroup collabGroup = new CollaborationGroup(Name = 'TESTNAME_'+ System.currentTimeMillis(), CollaborationType = 'Public');

        insert new GNE_SFA2_MCCO_CRM_Profiles__c(Name = profileName);
        insert new GNE_CRM_CollabGroupMember__c(Name = autoAddedUser.Name);
        insert collabGroup;

        Test.startTest();
        database.executebatch(new GNE_CRM_CollabGrpMembAssigner_Batch());
        Test.stopTest();

        List<CollaborationGroupMember> addedUser = [SELECT Id FROM CollaborationGroupMember WHERE MemberId = :autoAddedUser.Id AND CollaborationGroupId = :collabGroup.Id];

        System.assertEquals(1, addedUser.size());
        System.assertEquals(false, GNE_SFA2_Util.isAdminMode());
	}

    @isTest
    private static void testScheduler() {
        String jobName = 'Test Assign Collab Group Members';
        String cronExpression = '0 15 23 * * ?';

        Test.startTest();
        String jobId = System.schedule(jobName, cronExpression, new GNE_CRM_CollabGrpMembAssigner_Scheduler());
        Test.stopTest();

        CronTrigger ct = [SELECT CronJobDetail.Name FROM CronTrigger WHERE id = :jobId];

        System.assertEquals(jobName, ct.CronJobDetail.Name);
    }
}