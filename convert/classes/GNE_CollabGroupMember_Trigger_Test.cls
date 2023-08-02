@isTest(SeeAllData=true)
private class GNE_CollabGroupMember_Trigger_Test {

    private static Set<String> chatterPermissionSetNames = GNE_Chatter_Permission_Set_Name__c.getAll().keySet();

    static testMethod void myUnitTest() {
        String ownerProfileName = 'System Administrator';
        String profileName = 'GNE-MedAffairs-MCL';
        String domain = 'gene.com';
        PermissionSet chatterPermission = [SELECT Id FROM PermissionSet WHERE Name IN : chatterPermissionSetNames LIMIT 1];
        Profile ownerProfile = [SELECT Id FROM Profile WHERE Name = :ownerProfileName];
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];

        User testUser = createTestUser(ownerProfile);
        User memberUser1 = createTestUser(profile);
        User memberUser2 = createTestUser(profile);
        User memberUser3 = createTestUser(profile);

        insert new List<User> {testUser, memberUser1, memberUser2, memberUser3};

        PermissionSetAssignment permission = new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = chatterPermission.Id);
        insert permission;

        //user has permission
        CollaborationGroup cGroup;
        System.runAs(testUser) {
            cGroup = new CollaborationGroup(CollaborationType = 'Public', Name = 'test group2', OwnerId = testUser.Id);
            insert cGroup;
        }

        Integer countBefore = [SELECT count() FROM CollaborationGroupMember];
        system.runAs(testUser) {
            CollaborationGroupMember cGroupMember = new CollaborationGroupMember(CollaborationGroupId = cGroup.Id, MemberId = memberUser1.id);
            insert cGroupMember;
        }
        Integer countAfter = [SELECT count() FROM CollaborationGroupMember];
        system.assertEquals(countBefore + 1, countAfter);


        //no permission
        delete permission;

        countBefore = [SELECT count() FROM CollaborationGroupMember];
        system.runAs(testUser) {
            try {
                CollaborationGroupMember cGroupMember = new CollaborationGroupMember(CollaborationGroupId = cGroup.Id, MemberId = memberUser2.id);
                insert cGroupMember;
                System.assert(false, 'Exception should be thrown and this line should not be achieved');
            } catch (DmlException e) {
                System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , e.getDmlStatusCode(0) );
            }
        }
        countAfter = [SELECT count() FROM CollaborationGroupMember];
        system.assertEquals(countBefore, countAfter);
    }

    public static User createTestUser(Profile p ) {
        User u = new User();
        String username = GlobalUtils.getRandomAlphaNumeric(10, 'tu-', '@' + 'gene.com');
        u.Username = username;
        u.Email = username;
        u.LastName = username;
        u.Alias = 'test';
        u.CommunityNickname = username;
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId = p.Id;
        return u;
    }
}