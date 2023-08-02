public class GNE_BusinessRolePubGroupUtils
{

    // method to handle business role user activations (insert and update)
    @future
    public static void HandleActivations(Set<Id> activeIds)
    {

        // create config object
        GNE_BusinessRoleConfig roleConfig = new GNE_BusinessRoleConfig();
            
        // loop through records
        List<GroupMember> groupMembers = new List<GroupMember>();
        for (GNE_Business_Role_Public_Group__c record : [SELECT Id, Business_Role__c, Public_Group_Id__c FROM 
            GNE_Business_Role_Public_Group__c WHERE Id IN :activeIds])
        {
        
            // if external role exists in config role users map
            if (roleConfig.roleUsers.containsKey(record.Business_Role__c))
            {
            
                // add all users for role to public group
                for (String userId : roleConfig.roleUsers.get(record.Business_Role__c))
                {
                    groupMembers.add(new GroupMember(UserOrGroupId = userId, 
                        GroupId = record.Public_Group_Id__c));
                }
            }
        }
        
        // perform inserts, ignoring duplicate errors
        if (groupMembers.size() > 0)
        {
            Database.insert(groupMembers, false);
        }
    }
    
    // method to handle external role user inactivations
    @future
    public static void HandleInactivations(Set<Id> inactiveIds)
    {
        
        // create config object
        GNE_BusinessRoleConfig roleConfig = new GNE_BusinessRoleConfig();
        Map<Id, Set<String>> userGroupsToDelete = new Map<Id, Set<String>>();
        
        // loop through records
        for (GNE_Business_Role_Public_Group__c record : [SELECT Id, Business_Role__c, Public_Group_Id__c FROM 
            GNE_Business_Role_Public_Group__c WHERE Id IN :inactiveIds])
        {
            
            // loop through external role users
            if (roleConfig.roleUsers.containsKey(record.Business_Role__c))
            {
                for (String userId : roleConfig.roleUsers.get(record.Business_Role__c))
                {
              
                    // if user not in public group then add to map of user groups to delete
                    if (!roleConfig.IsUserInPublicGroup(userId, record.Public_Group_Id__c))
                    {
                        if (!userGroupsToDelete.containsKey(userId))
                        {
                            userGroupsToDelete.put(userId, new Set<String>());
                        }
                        if (!userGroupsToDelete.get(userId).contains(record.Public_Group_Id__c))
                        {
                            userGroupsToDelete.get(userId).add(record.Public_Group_Id__c);
                        }
                    }
                }
            }
        }

        // if there are group members to delete
        if (userGroupsToDelete.size() > 0)
        {
            
            // query for existing group members for users
            List<GroupMember> gmDeletes = new List<GroupMember>();
            for (GroupMember gm : [SELECT Id, UserOrGroupId, GroupId FROM GroupMember
                WHERE UserOrGroupId IN :userGroupsToDelete.keySet()])
            {
                if (userGroupsToDelete.containsKey(gm.UserOrGroupId) &&
                    userGroupsToDelete.get(gm.UserOrGroupId).contains(gm.GroupId))
                {
                    gmDeletes.add(gm);
                }
            }          
            if (gmDeletes.size() > 0)
            {
                delete (gmDeletes);
            }
        }
    }

    // test method for code coverage
    static testMethod void runInsertTests()
    {
    
        // create test user to avoid mix dml issue
        List<Profile> p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u1 = new User(alias = 'u1test', email='u1test@gene.com',
            emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1[0].Id,
            timezonesidkey='America/Los_Angeles', username='u1test@gene.com');
        insert (u1);
    
        // run as test user
        System.runAs(u1)
        {
    
            // create test group
            UserLicense ul = [SELECT Id FROM UserLicense WHERE Name = 'Salesforce'];
            Group g1 = new Group(Name = 'SPCM_TEST_G1', DeveloperName = 'SPCM_TEST_G1');
            insert(g1);
            System.assertNotEquals(g1, null);
        
            // create test business role
            GNE_Business_Role__c br1 = new GNE_Business_Role__c(Name = 'TEST_BUSINESS_ROLE1');
            insert(br1);
            System.assertNotEquals(br1, null);

            // create test business role public group
            GNE_Business_Role_Public_Group__c brpg1 = new GNE_Business_Role_Public_Group__c(Business_Role__c = br1.Id, 
                Public_Group__c = 'SPCM_TEST_G1', Public_Group_Id__c = g1.Id, Is_Active__c = true);
            insert (brpg1);
            System.assertNotEquals(brpg1, null);
            
            // start test
            Test.startTest();
            
            // create test user business roles
            User_Business_Role_gne__c ubr1 = new User_Business_Role_gne__c(
                Name = 'TEST_BUSINESS_ROLE1', Business_Role_gne__c = 'TEST_BUSINESS_ROLE1',
                Role_Assigned_Date_gne__c = Datetime.now(), User_gne__c = u1.Id, 
                User_RM_Role_Key_gne__c = 'u1test@TEST_BUSINESS_ROLE1');
            insert (ubr1);
            System.assertNotEquals(ubr1, null); 

            // stop test
            Test.stopTest();
        
            // run assertions
            List<GroupMember> gm1 = [SELECT Id FROM GroupMember WHERE GroupId = :g1.Id AND
                UserOrGroupId = :u1.Id];
            System.assertEquals(gm1.size(), 1);
        }
    }
    
    // test method for code coverage
    static testMethod void runInactivateTests()
    {
    
        // create test user to avoid mix dml issue
        List<Profile> p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u1 = new User(alias = 'u1test', email='u1test@gene.com',
            emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1[0].Id,
            timezonesidkey='America/Los_Angeles', username='u1test@gene.com');
        insert (u1);
    
        // run as test user
        System.runAs(u1)
        {
    
            // create test group
            UserLicense ul = [SELECT Id FROM UserLicense WHERE Name = 'Salesforce'];
            Group g1 = new Group(Name = 'SPCM_TEST_G1', DeveloperName = 'SPCM_TEST_G1');
            insert(g1);
            System.assertNotEquals(g1, null);
            
            // create test group member
            GroupMember gm1 = new GroupMember(GroupId = g1.Id, UserOrGroupId = u1.Id);
            insert(gm1);
            System.assertNotEquals(gm1, null);
            
            // create test business role
            GNE_Business_Role__c br1 = new GNE_Business_Role__c(Name = 'TEST_BUSINESS_ROLE1');
            insert(br1);
            System.assertNotEquals(br1, null);

            // create test user business roles
            User_Business_Role_gne__c ubr1 = new User_Business_Role_gne__c(
                Name = 'TEST_BUSINESS_ROLE1', Business_Role_gne__c = 'TEST_BUSINESS_ROLE1',
                Role_Assigned_Date_gne__c = Datetime.now(), User_gne__c = u1.Id, 
                User_RM_Role_Key_gne__c = 'u1test@TEST_BUSINESS_ROLE1');
            insert (ubr1);
            System.assertNotEquals(ubr1, null);
            
            // start test
            Test.startTest();
            
            // create test business role public group
            GNE_Business_Role_Public_Group__c brpg1 = new GNE_Business_Role_Public_Group__c(Business_Role__c = br1.Id, 
                Public_Group__c = 'SPCM_TEST_G1', Public_Group_Id__c = g1.Id, Is_Active__c = true);
            insert (brpg1);
            System.assertNotEquals(brpg1, null);
            
            // inactivate business role public group
            brpg1.Is_Active__c = false;
            update(brpg1);

            // stop test
            Test.stopTest();
        
            // run assertions
            List<GroupMember> gm2 = [SELECT Id FROM GroupMember WHERE GroupId = :g1.Id AND
                UserOrGroupId = :u1.Id];
            System.assertEquals(gm2.size(), 0);
        }
    }
}