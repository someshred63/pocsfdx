@isTest
private class AGS_INF_Deactivation_Test {
    
    private static final String USERNAME = 'infu@gene.com.' + UserInfo.getUserId();
    
    private static final String INFU_PROFILE = 'GNE-INFREQUENT-USER';
    
    @testSetup
    public static void setupActiveInfrequentUser() {
        insert new User(
            ProfileId           = [SELECT Id FROM Profile WHERE Name = :INFU_PROFILE LIMIT 1].Id,
            TimeZoneSidKey      = 'America/Los_Angeles',
            Email               = 'infu@gene.com',
            FirstName           = 'Infrequent',
            External_ID_gne__c  = 'infutest',
            Alias               = 'infutest',
            Username            = USERNAME,
            EmailEncodingKey    = 'UTF-8',
            LanguageLocaleKey   = 'en_US',
            LocaleSidKey        = 'en_US',
            LastName            = 'User',
            IsActive            = true
        );
    }
    
    @isTest
    public static void testInfrequentUserShouldBeDeactivated() {
        // given
        final AGS_INF_Deactivation batchUnderTest = new AGS_INF_Deactivation(
            'SELECT Id FROM User WHERE Username = \'' + USERNAME + '\''
        );
        // when
        Test.startTest();
        Database.executeBatch(batchUnderTest, 1);
        Test.stopTest();
        // then
        final User deactivatedUser = [SELECT IsActive, Profile.Name FROM User WHERE Username = :USERNAME LIMIT 1];
        System.assertEquals(INFU_PROFILE, deactivatedUser.Profile.Name, deactivatedUser);
        System.assertEquals(false, deactivatedUser.IsActive, deactivatedUser);
    }
}