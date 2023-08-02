public class GNE_BusinessRoleConfig
{

    // various maps
    public Map<String, Id> roleNames { get; set; }
    public Map<Id, Set<String>> roleUsers { get; set; }
    public Map<Id, Set<String>> roleSets { get; set; }
    public Map<Id, Set<String>> roleGroups { get; set; }
    
    // method to check if a user is associated to a permission set
    public Boolean IsUserInPermissionSet(String userId, String permissionSetId)
    {

        // loop through roles
        for (String roleKey : roleUsers.keySet())
        {
            
            // if user is in role
            if (roleUsers.get(roleKey).contains(userId))
            {
            
                // check if permission set is part of role
                if (roleSets.get(roleKey).contains(permissionSetId))
                {
                    return (true);
                }
            }
        }
        
        // return false
        return (false);
    }
    
    // method to check if a user is associated to a public group
    public Boolean IsUserInPublicGroup(String userId, String publicGroupId)
    {

        // loop through roles
        for (String roleKey : roleUsers.keySet())
        {
            
            // if user is in role
            if (roleUsers.get(roleKey).contains(userId))
            {
            
                // check if public group is part of role
                if (roleGroups.get(roleKey).contains(publicGroupId))
                {
                    return (true);
                }
            }
        }
        
        // return false
        return (false);
    }
    
    public GNE_BusinessRoleConfig()
    {
    
        // initialize maps
        roleNames = new Map<String, Id>();
        roleUsers = new Map<Id, Set<String>>();
        roleSets = new Map<Id, Set<String>>();
        roleGroups = new Map<Id, Set<String>>();
        
        // query for user business role data
        Map<String, Set<String>> userRolesMap = new Map<String, Set<String>>();
        List<User_Business_Role_gne__c> userRoles = [SELECT Id, Business_Role_gne__c, User_gne__c FROM 
            User_Business_Role_gne__c];
        for (User_Business_Role_gne__c userRole : userRoles)
        {
            if (!userRolesMap.containsKey(userRole.Business_Role_gne__c))
            {
                userRolesMap.put(userRole.Business_Role_gne__c, new Set<String>());
            }
            if (!userRolesMap.get(userRole.Business_Role_gne__c).contains(userRole.User_gne__c))
            {
                userRolesMap.get(userRole.Business_Role_gne__c).add(userRole.User_gne__c);
            }
        }
        
        // query for active buiness role data
        for (GNE_Business_Role__c role : [SELECT Id, Name, 
            (SELECT Id, Permission_Set_Id__c FROM Permission_Sets__r WHERE Is_Active__c = true),
            (SELECT Id, Public_Group_Id__c FROM Public_Groups__r WHERE Is_Active__c = true)
            FROM GNE_Business_Role__c])
        {
            
            // initialize map entries
            if (!roleUsers.containsKey(role.Id))
            {
                // add users
                if (userRolesMap.containsKey(role.Name))
                {
                    roleUsers.put(role.Id, userRolesMap.get(role.Name));
                }
                roleNames.put(role.Name, role.Id);
                roleSets.put(role.Id, new Set<String>());
                roleGroups.put(role.Id, new Set<String>());
            }
            
            // loop through role sets
            for (GNE_Business_Role_Permission_Set__c roleSet : role.Permission_Sets__r)
            {
                if (!roleSets.get(role.Id).contains(roleSet.Permission_Set_Id__c))
                {
                    roleSets.get(role.Id).add(roleSet.Permission_Set_Id__c);
                }
            }
            
            // loop through role groups
            for (GNE_Business_Role_Public_Group__c roleGroup : role.Public_Groups__r)
            {
                if (!roleGroups.get(role.Id).contains(roleGroup.Public_Group_Id__c))
                {
                    roleGroups.get(role.Id).add(roleGroup.Public_Group_Id__c);
                }
            }
        }
    }
    
    // test method for code coverage
    static testMethod void runTests()
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
        
            // create another test user
            User u2 = new User(alias = 'u2test', email='u2test@gene.com',
                emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1[0].Id,
                timezonesidkey='America/Los_Angeles', username='u2test@gene.com');
            insert (u2);
    
            // create test permission set
            UserLicense ul = [SELECT Id FROM UserLicense WHERE Name = 'Salesforce'];
            PermissionSet ps1 = new PermissionSet(Name = 'SPCM_TEST_PS1', Label = 'SPCM_TEST_PS1', UserLicenseId = ul.Id);
            insert(ps1);
            System.assertNotEquals(ps1, null);
            
            // create test group
            Group g1 = new Group(Name = 'SPCM_TEST_G1', DeveloperName = 'SPCM_TEST_G1');
            insert(g1);
            System.assertNotEquals(g1, null);

            // create test business role
            GNE_Business_Role__c br = new GNE_Business_Role__c(Name = 'TEST_BUSINESS_ROLE');
            insert(br);
            System.assertNotEquals(br, null);
            
            // create test business role permission set
            GNE_Business_Role_Permission_Set__c brps = new GNE_Business_Role_Permission_Set__c(
                Business_Role__c = br.Id, Permission_Set__c = 'SPCM_TEST_PS1', Permission_Set_Id__c = ps1.Id);
            insert (brps);
            System.assertNotEquals(brps, null);
            
            // create test business role public group
            GNE_Business_Role_Public_Group__c brpg = new GNE_Business_Role_Public_Group__c(
                Business_Role__c = br.Id, Public_Group__c = 'SPCM_TEST_G1', Public_Group_Id__c = g1.Id);
            insert (brpg);
            System.assertNotEquals(brpg, null);
            
            // start test
            Test.startTest();
            
            // create test user business role
            User_Business_Role_gne__c ubr = new User_Business_Role_gne__c(
                Name = 'TEST_BUSINESS_ROLE', Business_Role_gne__c = 'TEST_BUSINESS_ROLE',
                Role_Assigned_Date_gne__c = Datetime.now(), User_gne__c = u1.Id, 
                User_RM_Role_Key_gne__c = 'u1test@TEST_BUSINESS_ROLE');
            insert (ubr);
            System.assertNotEquals(ubr, null);
            
            // stop test
            Test.stopTest();
            
            // create object
            GNE_BusinessRoleConfig roleConfig = new GNE_BusinessRoleConfig();
            
            // run assertions
            System.assertEquals(true, roleConfig.IsUserInPermissionSet(u1.Id, ps1.Id));
            System.assertEquals(true, roleConfig.IsUserInPublicGroup(u1.Id, g1.Id));
            System.assertEquals(false, roleConfig.IsUserInPermissionSet(u2.Id, ps1.Id));
            System.assertEquals(false, roleConfig.IsUserInPublicGroup(u2.Id, g1.Id));
        }
    }
}