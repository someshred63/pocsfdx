public class GNE_UserBusinessRoleUtils
{
	private static final Map<String, SobjectType> SPCM_LEVEL_APPROVERS = new Map<String, SobjectType> {
		'C-Ops Contract Manager' => SPCM_Level_1_Approver__c.SobjectType
	};

    // static variable to allow for disabling of future calls
    // (mainly for testing and to void calling a future method from 
    // another future method which will fail)
    public static boolean DisableFutureCalls { get; set; }
    static 
    {
        DisableFutureCalls = false;
    }
    
    // method to handle before insert event
    public static void HandleBeforeInsert(List<User_Business_Role_gne__c> records)
    {

        // loop through records
        List<GNE_Business_Role_User_History__c> historyInserts = new List<GNE_Business_Role_User_History__c>();
        for (User_Business_Role_gne__c record : records)
        {
            
            // create history record
            historyInserts.add(new GNE_Business_Role_User_History__c(User__c = record.User_gne__c,
                Business_Role_Name__c = record.Business_Role_gne__c,
                Start_Date__c = record.Role_Assigned_Date_gne__c
                ));
        }
        
        // insert history records
        if (historyInserts.size() > 0)
        {
            insert(historyInserts);
        }
    }
    
    // method to handle after insert event
    public static void HandleAfterInsert(List<User_Business_Role_gne__c> records)
    {
    
        // get record ids
        List<String> recordIds = new List<String>();
        for (User_Business_Role_gne__c record : records)
        {
            recordIds.add(record.Id);
        }
        
        // run business role assignment (future async call) if not disabled
        if (recordIds.size() > 0 && !DisableFutureCalls)
        {
            try
            {
                GNE_UserBusinessRoleUtils.AssignBusinessRole(recordIds);
                GNE_UserBusinessRoleUtils.AssignLevelApprovers(recordIds);
            }
            catch (AsyncException ae)
            { }
        }
    }
    
    // method to handle before delete event
    public static void HandleBeforeDelete(List<User_Business_Role_gne__c> records)
    {
        
        // query for open history records (i.e. no end date)
        Map<String, GNE_Business_Role_User_History__c> historyMap = new Map<String, GNE_Business_Role_User_History__c>();
        for (GNE_Business_Role_User_History__c userHistory : [SELECT Id, User__c, Business_Role_Name__c,
            Start_Date__c, End_Date__c FROM GNE_Business_Role_User_History__c WHERE End_Date__c = NULL])
        {
            
            // add record to map (use user, business role name and start date as key
            String key = userHistory.User__c + userHistory.Business_Role_Name__c + userHistory.Start_Date__c;
            historyMap.put(key, userHistory);
        }
        
        // loop through records
        List<GNE_Business_Role_User_History__c> historyUpdates = new List<GNE_Business_Role_User_History__c>();
        for (User_Business_Role_gne__c record : records)
        {
            
            // if open history found
            String key = record.User_gne__c + record.Business_Role_gne__c + record.Role_Assigned_Date_gne__c;
            if (historyMap.containsKey(key))
            {
                
                // set end date and add to update list
                GNE_Business_Role_User_History__c historyRecord = historyMap.get(key);
                historyRecord.End_Date__c = DateTime.now();
                historyUpdates.add(historyRecord);
            }
        }
        
        // update history records
        if (historyUpdates.size() > 0)
        {
            update(historyUpdates);
        }       
    }    
    
    // method to handle after delete event
    public static void HandleAfterDelete(List<User_Business_Role_gne__c> records)
    {
        // get delete record data
        List<String> deletedData = new List<String>();
        for (User_Business_Role_gne__c record : records)
        {
            deletedData.add(record.Business_Role_gne__c + ';' + record.User_gne__c);
        }
        
        // run business role assignment (future async call) if not disabled
        if (deletedData.size() > 0 && !DisableFutureCalls)
        {
            try
            {
                GNE_UserBusinessRoleUtils.UnassignBusinessRole(deletedData);
                GNE_UserBusinessRoleUtils.UnAssignLevelApprovers(deletedData);
            }
            catch (AsyncException ae)
            { }
        }
    }
    
    @future
    public static void AssignLevelApprovers(List<String> recordIds)
    {
    	List<User_Business_Role_gne__c> records = [SELECT Id, User_gne__r.Name, Business_Role_gne__c FROM 
            										User_Business_Role_gne__c WHERE Id IN :recordIds];
    	Map<SObjectType, Set<User>> spcmLevelApprovers = new Map<SObjectType, Set<User>>();
	    for (User_Business_Role_gne__c record : records)
        {
        	if (SPCM_LEVEL_APPROVERS.containsKey(record.Business_Role_gne__c)) 
        	{
        		if (!spcmLevelApprovers.containsKey(SPCM_LEVEL_APPROVERS.get(record.Business_Role_gne__c))) 
        		{
        			spcmLevelApprovers.put(SPCM_LEVEL_APPROVERS.get(record.Business_Role_gne__c), new Set<User>());
        		}
        		spcmLevelApprovers.get(SPCM_LEVEL_APPROVERS.get(record.Business_Role_gne__c)).add(record.User_gne__r);
        	}
        }
        
        if (!spcmLevelApprovers.isEmpty()) 
		{
			List<SObject> upsertSPCMLevelApprovers = new List<SObject>();
			for (SObjectType objectType : spcmLevelApprovers.keySet()) 
			{
				Map<Id, User> users = new Map<Id, User>(new List<User>(spcmLevelApprovers.get(objectType)));
				Set<Id> userIds = users.keySet();
				for (SObject record : Database.query('SELECT Id, User__c, Is_Active__c ' + 
													   'FROM ' + objectType.getDescribe().getName() + ' ' +
													   'WHERE User__c in :userIds'))
			   	{		
			   		if (record.get('Is_Active__c') == null || ((Boolean)record.get('Is_Active__c')) == false ){
						record.put('Is_Active__c', true);
						upsertSPCMLevelApprovers.add(record);		   			
			   		}
			   		users.remove((Id)record.get('User__c'));
			   	}
			   	
				for (User record : users.values()) 
				{
					SObject spcmApprovalLevel = objectType.newSObject();
					spcmApprovalLevel.put('User__c', record.Id);
					spcmApprovalLevel.put('Is_Active__c', true);
					spcmApprovalLevel.put('Name', record.Name);
					upsertSPCMLevelApprovers.add(spcmApprovalLevel);
				}
			}
			upsert upsertSPCMLevelApprovers;
		}
    	
    }
    
    // method to assign permission sets and public groups (future annotated to
    //    avoid MIXED_DML exceptions)
    @future
    public static void AssignBusinessRole(List<String> recordIds)
    {

        // retrieve record details
        List<User_Business_Role_gne__c> records = [SELECT Id, User_gne__r.Name, Business_Role_gne__c FROM 
            User_Business_Role_gne__c WHERE Id IN :recordIds];
        
        // create config object
        GNE_BusinessRoleConfig roleConfig = new GNE_BusinessRoleConfig();
            
        // create permission set assignments and group members
        List<PermissionSetAssignment> permSetAssignments = new List<PermissionSetAssignment>();
        List<GroupMember> groupMembers = new List<GroupMember>();
        for (User_Business_Role_gne__c record : records)
        {
            // if business role exists in config name map
            String roleId = '';
            if (roleConfig.roleNames.containsKey(record.Business_Role_gne__c))
            {
                roleId = roleConfig.roleNames.get(record.Business_Role_gne__c);
            }
        
            // if business role exists in config role sets map
            if (roleId != '' && roleConfig.roleSets.containsKey(roleId))
            {
            
                // add all permission sets for role to user
                for (String permissionSetId : roleConfig.roleSets.get(roleId))
                {
                    permSetAssignments.add(new PermissionSetAssignment(AssigneeId = record.User_gne__c, 
                        PermissionSetId = permissionSetId));
                }
            }
            
            // if external role exists in config role groups map
            if (roleId != '' && roleConfig.roleGroups.containsKey(roleId))
            {
            
                // add all public groups for role to user
                for (String groupId : roleConfig.roleGroups.get(roleId))
                {
                    groupMembers.add(new GroupMember(UserOrGroupId = record.User_gne__c, 
                        GroupId = groupId));
                }
            }
        }
	
        // perform inserts, ignoring duplicate errors
        if (permSetAssignments.size() > 0)
        {
            Database.insert(permSetAssignments, false);
        }
        if (groupMembers.size() > 0)
        {
            Database.insert(groupMembers, false);
        }
    }
    
    @future
    public static void UnAssignLevelApprovers(List<String> deletedData)
    {
    	Map<SObjectType, Set<String>> spcmLevelApprovers = new Map<SObjectType, Set<String>>();
        for (String deletedRecord : deletedData)
        {
        	String roleName = deletedRecord.substring(0, deletedRecord.indexOf(';'));
            String userId = deletedRecord.substring(deletedRecord.indexOf(';') + 1);
        	
        	if (SPCM_LEVEL_APPROVERS.containsKey(roleName)) 
        	{
        		if (!spcmLevelApprovers.containsKey(SPCM_LEVEL_APPROVERS.get(roleName))) 
        		{
        			spcmLevelApprovers.put(SPCM_LEVEL_APPROVERS.get(roleName), new Set<String>());
        		}
        		spcmLevelApprovers.get(SPCM_LEVEL_APPROVERS.get(roleName)).add(userId);
        	}
        }
        
        if (!spcmLevelApprovers.isEmpty()) 
		{
			List<SObject> deactivateSPCMLevelApprovers = new List<SObject>();
			for (SObjectType objectType : spcmLevelApprovers.keySet()) 
			{
				Set<String> userIds = spcmLevelApprovers.get(objectType);
				for (SObject record : Database.query('SELECT Id ' + 
													   'FROM ' + objectType.getDescribe().getName() + ' ' +
													   'WHERE User__c in :userIds'))
			   	{		
					record.put('Is_Active__c', false);
			   		deactivateSPCMLevelApprovers.add(record);
			   	}
			}
			update deactivateSPCMLevelApprovers;
		}
    
    }
    
    
    // method to usassign permission sets and public groups (future annotated to
    //    avoid MIXED_DML exceptions)
    @future
    public static void UnassignBusinessRole(List<String> deletedData)
    {
        // parse out deleted data into map
        Map<String, Set<String>> deletedRoleUsers = new Map<String, Set<String>>();
        for (String deletedRecord : deletedData)
        {
            // parse out business role name and user id
            String roleName = deletedRecord.substring(0, deletedRecord.indexOf(';'));
            String userId = deletedRecord.substring(deletedRecord.indexOf(';') + 1);
            
            // add role and users to map
            if (!deletedRoleUsers.containsKey(roleName))
            {
                deletedRoleUsers.put(roleName, new Set<String>());
            }
            if (!deletedRoleUsers.get(roleName).contains(userId))
            {
                deletedRoleUsers.get(roleName).add(userId);
            }
        }
        
        // create config object
        GNE_BusinessRoleConfig roleConfig = new GNE_BusinessRoleConfig();
        Map<Id, Set<String>> userPermissionsToDelete = new Map<Id, Set<String>>();
        Map<Id, Set<String>> userGroupsToDelete = new Map<Id, Set<String>>();
        
        // loop through roles
        for (String roleName : deletedRoleUsers.keySet())
        {
            
            // loop through users
            for (String userId : deletedRoleUsers.get(roleName))
            {
            
                // get role id
                String roleId = '';
                if (roleConfig.roleNames.containsKey(roleName))
                {
                    roleId = roleConfig.roleNames.get(roleName);
                }
                
                // loop through external role permission sets
                if (roleId != '' && roleConfig.roleSets.containsKey(roleId))
                {
                    for (String permissionSetId : roleConfig.roleSets.get(roleId))
                    {
                    
                        // if user not in permission set then add to map of user permissions to delete
                        if (!roleConfig.IsUserInPermissionSet(userId, permissionSetId))
                        {
                            if (!userPermissionsToDelete.containsKey(userId))
                            {
                                userPermissionsToDelete.put(userId, new Set<String>());
                            }
                            if (!userPermissionsToDelete.get(userId).contains(permissionSetId))
                            {
                                userPermissionsToDelete.get(userId).add(permissionSetId);
                            }
                        }
                    }
                }
                
                // loop through external role public groups
                if (roleId != '' && roleConfig.roleGroups.containsKey(roleId))
                {
                    for (String groupId : roleConfig.roleGroups.get(roleId))
                    {
                  
                        // if user not in public group then add to map of user groups to delete
                        if (!roleConfig.IsUserInPublicGroup(userId, groupId))
                        {
                            if (!userGroupsToDelete.containsKey(userId))
                            {
                                userGroupsToDelete.put(userId, new Set<String>());
                            }
                            if (!userGroupsToDelete.get(userId).contains(groupId))
                            {
                                userGroupsToDelete.get(userId).add(groupId);
                            }
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
            GNE_Business_Role__c br1 = new GNE_Business_Role__c(Name = 'TEST_BUSINESS_ROLE');
            insert(br1);
            System.assertNotEquals(br1, null);
        
            // create test business role permission set
            GNE_Business_Role_Permission_Set__c brps1 = new GNE_Business_Role_Permission_Set__c(
                Business_Role__c = br1.Id, Permission_Set__c = 'SPCM_TEST_PS1', Permission_Set_Id__c = ps1.Id);
            insert (brps1);
            System.assertNotEquals(brps1, null);
            
            // create test business role public group
            GNE_Business_Role_Public_Group__c brpg1 = new GNE_Business_Role_Public_Group__c(
                Business_Role__c = br1.Id, Public_Group__c = 'SPCM_TEST_G1', Public_Group_Id__c = g1.Id);
            insert (brpg1);
            System.assertNotEquals(brpg1, null);
        
            // start test
            Test.startTest();
            
            // create test user business roles
            User_Business_Role_gne__c ubr1 = new User_Business_Role_gne__c(
                Name = 'TEST_BUSINESS_ROLE', Business_Role_gne__c = 'TEST_BUSINESS_ROLE',
                Role_Assigned_Date_gne__c = Datetime.now(), User_gne__c = u1.Id, 
                User_RM_Role_Key_gne__c = 'u1test@TEST_BUSINESS_ROLE');
            insert (ubr1);
            System.assertNotEquals(ubr1, null);
            User_Business_Role_gne__c ubr2 = new User_Business_Role_gne__c(
                Name = 'TEST_BUSINESS_ROLE2', Business_Role_gne__c = 'TEST_BUSINESS_ROLE2',
                Role_Assigned_Date_gne__c = Datetime.now(), User_gne__c = u1.Id, 
                User_RM_Role_Key_gne__c = 'u1test@TEST_BUSINESS_ROLE2');
            insert (ubr2);
            System.assertNotEquals(ubr2, null);
            
            // end test
            Test.stopTest();
            
            // run assertions
            List<PermissionSetAssignment> psa1 = [SELECT Id FROM PermissionSetAssignment WHERE
                PermissionSetId = :ps1.Id AND AssigneeId = :u1.Id];
            System.assertEquals(psa1.size(), 1);
            List<GroupMember> gm1 = [SELECT Id FROM GroupMember WHERE
                GroupId = :g1.Id AND UserOrGroupId = :u1.Id];
            System.assertEquals(gm1.size(), 1);
        }
    }
    
    // test method for code coverage
    static testMethod void runDeleteTests()
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
            
            // create test permission set assignment
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ps1.Id, 
                AssigneeId = u1.Id);
            insert(psa1);
            System.assertNotEquals(psa1, null);
            
            // create test group
            Group g1 = new Group(Name = 'SPCM_TEST_G1', DeveloperName = 'SPCM_TEST_G1');
            insert(g1);
            System.assertNotEquals(g1, null);
            
            // create test group member
            GroupMember gm1 = new GroupMember(GroupId = g1.Id, UserOrGroupId = u1.Id);
            insert(gm1);
            System.assertNotEquals(gm1, null);
            
            // create test business role
            GNE_Business_Role__c br1 = new GNE_Business_Role__c(Name = 'TEST_BUSINESS_ROLE');
            insert(br1);
            System.assertNotEquals(br1, null);
        
            // create test business role permission set
            GNE_Business_Role_Permission_Set__c brps1 = new GNE_Business_Role_Permission_Set__c(
                Business_Role__c = br1.Id, Permission_Set__c = 'SPCM_TEST_PS1', Permission_Set_Id__c = ps1.Id);
            insert (brps1);
            System.assertNotEquals(brps1, null);
            
            // create test business role public group
            GNE_Business_Role_Public_Group__c brpg1 = new GNE_Business_Role_Public_Group__c(
                Business_Role__c = br1.Id, Public_Group__c = 'SPCM_TEST_G1', Public_Group_Id__c = g1.Id);
            insert (brpg1);
            System.assertNotEquals(brpg1, null);
        
            // start test
            Test.startTest();
            
            // create test user business role
            User_Business_Role_gne__c ubr1 = new User_Business_Role_gne__c(
                Name = 'TEST_BUSINESS_ROLE', Business_Role_gne__c = 'TEST_BUSINESS_ROLE',
                Role_Assigned_Date_gne__c = Datetime.now(), User_gne__c = u1.Id, 
                User_RM_Role_Key_gne__c = 'u1test@TEST_BUSINESS_ROLE');
            insert (ubr1);
            System.assertNotEquals(ubr1, null);
            
            // delete user business role
            delete(ubr1);
            
            // end test
            Test.stopTest();
            
            // run assertions
            List<PermissionSetAssignment> psa2 = [SELECT Id FROM PermissionSetAssignment WHERE
                PermissionSetId = :ps1.Id AND AssigneeId = :u1.Id];
            System.assertEquals(psa2.size(), 0);
            List<GroupMember> gm2 = [SELECT Id FROM GroupMember WHERE
                GroupId = :g1.Id AND UserOrGroupId = :u1.Id];
            System.assertEquals(gm2.size(), 0);
        }
    }
}