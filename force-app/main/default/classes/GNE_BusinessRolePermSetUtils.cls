public class GNE_BusinessRolePermSetUtils
{

    // method to handle business role permission set activations (insert and update)
    @future
    public static void HandleActivations(Set<Id> activeIds)
    {

        // create config object
        GNE_BusinessRoleConfig roleConfig = new GNE_BusinessRoleConfig();
            
        // loop through records
        List<PermissionSetAssignment> permSetAssignments = new List<PermissionSetAssignment>();
        for (GNE_Business_Role_Permission_Set__c record : [SELECT Id, Business_Role__c, Permission_Set_Id__c FROM 
            GNE_Business_Role_Permission_Set__c WHERE Id IN :activeIds])
        {
        
            // if external role exists in config role users map
            if (roleConfig.roleUsers.containsKey(record.Business_Role__c))
            {
            
                // add all users for role to permission set
                for (String userId : roleConfig.roleUsers.get(record.Business_Role__c))
                {
                    permSetAssignments.add(new PermissionSetAssignment(AssigneeId = userId, 
                        PermissionSetId = record.Permission_Set_Id__c));
                }
            }
        }
        
        // perform inserts, ignoring duplicate errors
        if (permSetAssignments.size() > 0)
        {
            Database.insert(permSetAssignments, false);
        }
    }
    
    // method to handle business role permission set inactivations
    @future
    public static void HandleInactivations(Set<Id> inactiveIds)
    {
        
        // create config object
        GNE_BusinessRoleConfig roleConfig = new GNE_BusinessRoleConfig();
        Map<Id, Set<String>> userPermissionsToDelete = new Map<Id, Set<String>>();
        
        // loop through records
        for (GNE_Business_Role_Permission_Set__c record : [SELECT Id, Business_Role__c, Permission_Set_Id__c FROM 
            GNE_Business_Role_Permission_Set__c WHERE Id IN :inactiveIds])
        {
            
            // loop through external role users
            if (roleConfig.roleUsers.containsKey(record.Business_Role__c))
            {
                for (String userId : roleConfig.roleUsers.get(record.Business_Role__c))
                {
                
                    // if user not in permission set then add to map of user permissions to delete
                    if (!roleConfig.IsUserInPermissionSet(userId, record.Permission_Set_Id__c))
                    {
                        if (!userPermissionsToDelete.containsKey(userId))
                        {
                            userPermissionsToDelete.put(userId, new Set<String>());
                        }
                        if (!userPermissionsToDelete.get(userId).contains(record.Permission_Set_Id__c))
                        {
                            userPermissionsToDelete.get(userId).add(record.Permission_Set_Id__c);
                        }
                    }
                }
            }
        }
       
        // if there are permission set assignments to delete
        if (userPermissionsToDelete.size() > 0)
        {
            
            // query for existing permission set assignments for users
            List<PermissionSetAssignment> psaDeletes = new List<PermissionSetAssignment>();
            for (PermissionSetAssignment psa : [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment
                WHERE AssigneeId IN :userPermissionsToDelete.keySet()])
            {
                if (userPermissionsToDelete.containsKey(psa.AssigneeId) &&
                    userPermissionsToDelete.get(psa.AssigneeId).contains(psa.PermissionSetId))
                {
                    psaDeletes.add(psa);
                }
            }          
            if (psaDeletes.size() > 0)
            {
                delete (psaDeletes);
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
    
            // create test permission set
            UserLicense ul = [SELECT Id FROM UserLicense WHERE Name = 'Salesforce'];
            PermissionSet ps1 = new PermissionSet(Name = 'SPCM_TEST_PS1', Label = 'SPCM_TEST_PS1', UserLicenseId = ul.Id);
            insert(ps1);
            System.assertNotEquals(ps1, null);
            
            // create test business role
            GNE_Business_Role__c br1 = new GNE_Business_Role__c(Name = 'TEST_BUSINESS_ROLE1');
            insert(br1);
            System.assertNotEquals(br1, null);
    
            // create test user business role
            User_Business_Role_gne__c ubr1 = new User_Business_Role_gne__c(
                Name = 'TEST_BUSINESS_ROLE1', Business_Role_gne__c = 'TEST_BUSINESS_ROLE1',
                Role_Assigned_Date_gne__c = Datetime.now(), User_gne__c = u1.Id, 
                User_RM_Role_Key_gne__c = 'u1test@TEST_BUSINESS_ROLE1');
            insert (ubr1);
            System.assertNotEquals(ubr1, null); 
    
            // start test
            Test.startTest();
    
            // create test business role permission set
            GNE_Business_Role_Permission_Set__c brps1 = new GNE_Business_Role_Permission_Set__c(
                Business_Role__c = br1.Id, Permission_Set__c = 'SPCM_TEST_PS1', Permission_Set_Id__c = ps1.Id,
                Is_Active__c = true);
            insert (brps1);            
            System.assertNotEquals(brps1, null);
        
            // stop test
            Test.stopTest();
        
            // run assertions
            List<PermissionSetAssignment> psa1 = [SELECT Id FROM PermissionSetAssignment WHERE
                PermissionSetId = :ps1.Id AND AssigneeId = :u1.Id];
            System.assertEquals(psa1.size(), 1);
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
    
            // create test permission set
            UserLicense ul = [SELECT Id FROM UserLicense WHERE Name = 'Salesforce'];
            PermissionSet ps1 = new PermissionSet(Name = 'SPCM_TEST_PS1', Label = 'SPCM_TEST_PS1', UserLicenseId = ul.Id);
            insert(ps1);
            System.assertNotEquals(ps1, null);
            
            // create permission set assignment
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ps1.Id,
                AssigneeId = u1.Id);
            insert(psa1);
            System.assertNotEquals(psa1, null);
            
            // create test business role
            GNE_Business_Role__c br1 = new GNE_Business_Role__c(Name = 'TEST_BUSINESS_ROLE1');
            insert(br1);
            System.assertNotEquals(br1, null);
    
            // create test user business role
            User_Business_Role_gne__c ubr1 = new User_Business_Role_gne__c(
                Name = 'TEST_BUSINESS_ROLE1', Business_Role_gne__c = 'TEST_BUSINESS_ROLE1',
                Role_Assigned_Date_gne__c = Datetime.now(), User_gne__c = u1.Id, 
                User_RM_Role_Key_gne__c = 'u1test@TEST_BUSINESS_ROLE1');
            insert (ubr1);
            System.assertNotEquals(ubr1, null); 
    
            // start test
            Test.startTest();
    
            // create test business role permission set
            GNE_Business_Role_Permission_Set__c brps1 = new GNE_Business_Role_Permission_Set__c(
                Business_Role__c = br1.Id, Permission_Set__c = 'SPCM_TEST_PS1', Permission_Set_Id__c = ps1.Id,
                Is_Active__c = true);
            insert (brps1);            
            System.assertNotEquals(brps1, null);
            
            // inactivate business role permission set
            brps1.Is_Active__c = false;
            update(brps1);
        
            // stop test
            Test.stopTest();
        
            // run assertions
            List<PermissionSetAssignment> psa2 = [SELECT Id FROM PermissionSetAssignment WHERE
                PermissionSetId = :ps1.Id AND AssigneeId = :u1.Id];
            System.assertEquals(psa2.size(), 0);
        }
    }
}