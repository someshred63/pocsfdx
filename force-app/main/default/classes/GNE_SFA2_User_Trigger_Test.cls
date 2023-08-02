/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-15
*  Description: This is a test class for GNE_SFA2_User_Trigger_Test trigger
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
public with sharing class GNE_SFA2_User_Trigger_Test {
    
    private static Integer BATCH_SIZE = 10;
    
    private static List<User> prepareTestUsers(boolean viewAllMode, String profileName) {
        List<User> testUsers = new List<User>();
        Profile p = [ SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            User u = new User(
                alias = 'shr' + String.valueOf(i), 
                email='test_user@roche.com',
                emailencodingkey='UTF-8',
                firstname='firstName',
                lastname='lastName' + String.valueOf(i),
                languagelocalekey='en_US',
                localesidkey='en_US',
                profileid = p.Id,
                timezonesidkey='America/Los_Angeles',
                View_Mode_All_Brands_gne__c = viewAllMode,              
                username='test_user@roche.com' + String.valueOf(i)
            );
            testUsers.add(u);
        }
        
        User currentUser = [ SELECT Id FROM User WHERE Id = :Userinfo.getUserID() LIMIT 1 ];
        System.runAs(currentUser) {
            insert testUsers;
        }
        return testUsers;
    }
    
    private static List<User> prepareTestUsers(boolean viewAllMode, String profileName, Userrole role) {
        List<User> testUsers = new List<User>();
        Profile p = [ SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            User u = new User(
                alias = 'shr' + String.valueOf(i), 
                email='test_user@roche.com',
                emailencodingkey='UTF-8',
                firstname='firstName',
                lastname='lastName' + String.valueOf(i),
                languagelocalekey='en_US',
                localesidkey='en_US',
                profileid = p.Id,
                timezonesidkey='America/Los_Angeles',
                View_Mode_All_Brands_gne__c = viewAllMode,              
                username='test_user@roche.com' + String.valueOf(i),
                userroleid = role.Id
            );
            testUsers.add(u);
        }
        
        User currentUser = [ SELECT Id FROM User WHERE Id = :Userinfo.getUserID() LIMIT 1 ];
        System.runAs(currentUser) {
            insert testUsers;
        }
        return testUsers;
    }
    
    public static testMethod void testValidationRulesEmailOnUpdateNotAdmin() {
        GNE_SFA2_Util.switchAdminMode(false);
        GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_User_Trigger', false);
        //GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
        GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
        User sfa2User = GNE_SFA2_Util.selectSFA2User();
        if(sfa2USer != null) {
            System.runAs(sfa2User) {
		        List <User> testUsers = prepareTestUsers(false, 'System administrator');
		        for (User testUser: testUsers) {
		            testUser.Email = 'updatedmail@roche.com';
		        }
		        Test.startTest();
		        try {
		            update testUsers;
		            System.assert(false, 'User should not be updated!');
		        } catch (DMLException ex) {
		            System.assert(ex.getMessage().contains(System.Label.User_Email_Update), ex.getMessage());
		            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', ex.getDmlStatusCode(0));
		        }
		        Test.stopTest();
            }
        } else {
            System.assert(false, 'Could not find any SFA2 Users!');
        }
    }
    
    public static testMethod void testValidationRulesEmailOnUpdateAdmin() {
        GNE_SFA2_Util.switchAdminMode(false);
        GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_User_Trigger', false);
        List<User> testUsers = prepareTestUsers(false, 'System administrator');
        
        for(User testUser : testUsers) {
            testUser.Email = 'updatedmail@roche.com';
        }
        Test.startTest();
        try {
            update testUsers;
        } catch(DMLException ex) {
            System.assert(false, 'Email should be updated for admin user');
        }
        Test.stopTest();
                
        testUsers = [ SELECT Email FROM User WHERE Id IN :testUsers ];
        for(User testUser : testUsers) {
            System.assertEquals(testUser.Email, 'updatedmail@roche.com');
        }
    }
    
    public static testMethod void testValidationRulesCanadaProfileGroup1() {
        GNE_SFA2_Util.switchAdminMode(false);
        GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_User_Trigger', false);
        GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
        List<Profile> canadianProfiles = [ SELECT Id, Name FROM Profile WHERE Name in :GNE_SFA2_Canadian_Users__c.getAll().keySet()];
        UserRole canadianRole = [ SELECT Id FROM UserRole WHERE Name = 'Canada Standard User' LIMIT 1 ];
        UserRole nonCanadianRole = [ SELECT Id FROM UserRole WHERE Name = 'Standard User' LIMIT 1 ];
        List<User> testUsers = prepareTestUsers(false, canadianProfiles[0].Name, canadianRole);
        
        for(User testUser : testUsers) {
            testUser.UserRoleId = nonCanadianRole.Id; 
        }
        Test.startTest();
        try {
            User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            System.runAs(currentUser) {
                update testUsers;
            }
            System.assert(false, 'User should not be updated!');
        } catch(DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Canada_Profile_Role), ex.getMessage());
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
        }
        Test.stopTest();
    }
    
    public static testMethod void testValidationRulesCanadaProfileGroup2() {
        GNE_SFA2_Util.switchAdminMode(false);
        GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_User_Trigger__c', false);

        List<Profile> nonCanadianProfiles = [ SELECT Id, Name FROM Profile WHERE (NOT Name Like '%Canada%') and UserLicense.Name = 'Salesforce' ];
        UserRole canadianRole = [ SELECT Id FROM UserRole WHERE Name = 'Canada Standard User' LIMIT 1 ];
        UserRole nonCanadianRole = [ SELECT Id FROM UserRole WHERE Name = 'Standard User' LIMIT 1 ];
        List<User> testUsers = prepareTestUsers(false, nonCanadianProfiles[0].Name, nonCanadianRole);
        
        for(User testUser : testUsers) {
            testUser.UserRoleId = canadianRole.Id; 
        }
        Test.startTest();
        try {
            User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            System.runAs(currentUser) {
                update testUsers;
            }   
            System.assert(false, 'User should not be updated!');
        } catch(DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Canada_Role_Profile), ex.getMessage());
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
        }
        Test.stopTest();
    }
    
    public static testMethod void testFederationIdentifierUpdateUserFieldUpdatesOnInsert() {
        GNE_SFA2_Util.switchAdminMode(false);
        GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_User_Trigger', false);
        Test.startTest();
        List<User> testUsers = prepareTestUsers(false, 'System administrator');
        Test.stopTest();
        
        testUsers = [ SELECT federationIdentifier, username FROM User WHERE Id IN :testUsers ];
        for(User testUser : testUsers) {
            System.assertNotEquals(null, testUser.FederationIdentifier);
            System.assertEquals(testUser.username, testUser.FederationIdentifier);
        }
    }
    
    public static testMethod void testCompanyNameUpdateUserFieldUpdatesOnInsert() {
        GNE_SFA2_Util.switchAdminMode(false);
        GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_User_Trigger', false);
        Test.startTest();
        List<User> testUsers = prepareTestUsers(false, 'System administrator');
        Test.stopTest();
        
        testUsers = [ SELECT CompanyName, username FROM User WHERE Id IN :testUsers ];
        for(User testUser : testUsers) {
            System.assertNotEquals(null, testUser.CompanyName);
            System.assertEquals('Genentech', testUser.CompanyName);
        }
    }
    
    public static testMethod void testExternalIdUpdateUserFieldUpdatesOnInsert() {
        GNE_SFA2_Util.switchAdminMode(false);
        GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_User_Trigger', false);
        Test.startTest();
        List<User> testUsers = prepareTestUsers(false, 'System administrator');
        Test.stopTest();
        
        testUsers = [ SELECT External_ID_gne__c, Alias FROM User WHERE Id IN :testUsers ];
        for(User testUser : testUsers) {
            System.assertNotEquals(null, testUser.External_ID_gne__c);
            System.assertNotEquals(null, testUser.Alias);
            
            System.assertEquals('test_user', testUser.External_ID_gne__c);
            System.assertEquals('test_us', testUser.Alias);
        }
    }
    
    public static testMethod void testExternalIdUpdateUserFieldUpdatesOnUpdate() {
        GNE_SFA2_Util.switchAdminMode(false);
        GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_User_Trigger', false);
        Test.startTest();
        List<User> testUsers = prepareTestUsers(false, 'System administrator');
        testUsers = [ SELECT External_ID_gne__c, Alias, Username FROM User WHERE Id IN :testUsers ];
        for(User testUser : testUsers) {
            System.assertNotEquals(null, testUser.External_ID_gne__c);
            System.assertNotEquals(null, testUser.Alias);
            
            System.assertEquals('test_user', testUser.External_ID_gne__c);
            System.assertEquals('test_us', testUser.Alias);
        }
        
        for(User testUser : testUsers) {
            testUser.Username = testUser.Username.replace('test', 'test2');
        }
        
        User currentUser = [ SELECT Id FROM User WHERE Id = :Userinfo.getUserID() LIMIT 1 ];
        System.runAs(currentUser) {
            update testUsers;
        }
        
        Test.stopTest();
        testUsers = [ SELECT External_ID_gne__c, Alias FROM User WHERE Id IN :testUsers ];
        for(User testUser : testUsers) {
            System.assertNotEquals(null, testUser.External_ID_gne__c);
            System.assertNotEquals(null, testUser.Alias);
            
            System.assertEquals('test2_user', testUser.External_ID_gne__c);
            System.assertEquals('test2_u', testUser.Alias);
        }
    }
    
    /**************
    * code responsible for updating user delegations is commented, so this tests are pointless
    *
    *************/
    /*public static testMethod void testUserDelegationsChildRecordUpdatesOnInsert() {
    	Test.startTest();
        List<User> testUsers = prepareTestUsers(false, 'System administrator');
        Test.stopTest();
                
        List<String> userNames = new List<String>();
        for(User user : testUsers) {
         	userNames.add(user.Username);
        }
                
        List<GNE_User_Delegation__c> userDelegations = [ SELECT Id, Name FROM GNE_User_Delegation__c WHERE Name IN :userNames];
        System.assertEquals(BATCH_SIZE, userDelegations.size());
    }
    
    public static testMethod void testUserDelegationsChildRecordUpdatesOnUpdate() {
        
        Test.startTest();       
        List<User> testUsers = prepareTestUsers(false, 'System administrator');
                
        List<String> oldUserNames = new List<String>();
        for(User user : testUsers) {
        	oldUserNames.add(user.Username);
        }
                
        for(User user : testUsers) {
        	user.FirstName = 'changedFirstName';
        }
                
        update testUsers;
                
                
        List<String> newUserNames = new List<String>();
        for(User user : testUsers) {
        	newUserNames.add(user.username);
        }
        Test.stopTest();
        List<GNE_User_Delegation__c> userDelegations = [ SELECT Id FROM GNE_User_Delegation__c WHERE Name IN :oldUserNames];
                
        userDelegations = [ SELECT Id FROM GNE_User_Delegation__c WHERE Name IN :newUserNames];
    	System.assertEquals(BATCH_SIZE, userDelegations.size());
    }*/
    
    public static testMethod void testAddViewAllModeUserChildRecordUpdatesOnUpdate() {
        Test.startTest();
        List<User> testUsers = prepareTestUsers(false, 'System administrator');
        
        for(User user : testUsers) {
            user.View_Mode_All_Brands_gne__c = true;
        }
        
        update testUsers;
        Test.stopTest();
        
        List<Group> viewAllGroup = [ SELECT Id FROM Group WHERE Name = 'GNE-View-All-Brands-Users-Data-Group' LIMIT 1];
        List<GroupMember> groupMemberships = [ SELECT Id FROM GroupMember WHERE GroupId = :viewAllGroup[0].Id AND UserOrGroupId IN :testUsers ];    
        System.assertEquals(BATCH_SIZE, groupMemberships.size());
    }
    
    public static testMethod void testRemoveViewAllModeUserChildRecordUpdatesOnUpdate() {
        List<User> testUsers = prepareTestUsers(false, 'System administrator');

        for(User user : testUsers) {
            user.View_Mode_All_Brands_gne__c = true;
        }
        
        update testUsers;
        
        
        List<Group> viewAllGroup = [ SELECT Id FROM Group WHERE Name = 'GNE-View-All-Brands-Users-Data-Group' LIMIT 1];
        List<GroupMember> groupMemberships = [ SELECT Id FROM GroupMember WHERE GroupId = :viewAllGroup[0].Id AND UserOrGroupId IN :testUsers ];    
        System.assertEquals(BATCH_SIZE, groupMemberships.size());
        
        for(User user : testUsers) {
            user.View_Mode_All_Brands_gne__c = false;
        }
        
        Test.startTest();
        update testUsers;
        Test.stopTest();
        
        groupMemberships = [ SELECT Id FROM GroupMember WHERE GroupId = :viewAllGroup[0].Id AND UserOrGroupId IN :testUsers ];  
        System.assertEquals(0, groupMemberships.size());
    }
    
    public static testMethod void testEmailNotificationOnInsert() {
        BATCH_SIZE = 201;
        GNE_CM_UnitTestConfig.skipTriggerForTests('trigUserUpdateProfileGroups');
        GNE_SFA2_Util.insertUserCountNotificationCustomSettings(100, 200, 'test_email@roche.com');
        Test.startTest();
        List<User> testUsers = prepareTestUsers(false, 'System administrator');
        Test.stopTest();
    }
}