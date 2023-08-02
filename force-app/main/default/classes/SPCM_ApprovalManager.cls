public class SPCM_ApprovalManager
{
    public GNE_BusinessRoleConfig roleConfig { get; set; }
    public SPCM_ApprovalProcessConfig processConfig { get; set; }
    public SPCM_ApprovalManager()
    {
        roleConfig = new GNE_BusinessRoleConfig();
        processConfig = new SPCM_ApprovalProcessConfig();
    }
    public SPCM_ApprovalManager(GNE_BusinessRoleConfig extRoleConfig, SPCM_ApprovalProcessConfig apprProcessConfig)
    {
        roleConfig = extRoleConfig;
        processConfig = apprProcessConfig;
    }
    
    // method to get role approvers for process and level number
    public List<String> GetRoleApprovers(String objectType, Decimal levelNumber)
    {
    
        // declaration(s)
        List<String> approverIds = new List<String>();
        
        // if process level exists for object and level number
        if (processConfig.processLevels.containsKey(objectType) &&
            processConfig.processLevels.get(objectType).
            containsKey(levelNumber))
        {

            // loop through process levels
            for (SPCM_Approval_Process_Level__c level : processConfig.processLevels.get(objectType).
                get(levelNumber))
            {
            
                // if users exist for role id
                if (roleConfig.roleUsers.containsKey(level.Business_Role__r.Id))
                {
                
                    // add users to list
                    for (String userId : roleConfig.roleUsers.get(level.Business_Role__r.Id))
                    {
                        approverIds.add(userId);
                    }
                }
            }
        }
        
        // return approver ids
        return (approverIds);
    }
    
    // method to get single role name for process and level number
    public String GetSingleRoleName(String objectType, Decimal levelNumber)
    {
            
        // return single role name
        List<String> roleNames = GetRoleNames(objectType, levelNumber);
        return (roleNames.size() == 0 ? '' : roleNames[0]);
    }
    
    // method to get role names for process and level number
    public List<String> GetRoleNames(String objectType, Decimal levelNumber)
    {
    
        // declaration(s)
        List<String> roleNames = new List<String>();
        
        // loop through process levels
        for (SPCM_Approval_Process_Level__c processLevel : GetProcessLevels(objectType, levelNumber))
        {
            roleNames.add(processLevel.Business_Role__r.Name);
        }

        // return role names
        return (roleNames);
    }
    
    // method to get single level name for process and level number
    public String GetSingleLevelName(String objectType, Decimal levelNumber)
    {

        // return single level name
        List<String> levelNames = GetLevelNames(objectType, levelNumber);
        return (levelNames.size() == 0 ? '' : levelNames[0]);
    }
    
    // method to get process level by id
    public SPCM_Approval_Process_Level__c GetProcessLevelById(String processLevelId)
    {

        // declaration(s)
        SPCM_Approval_Process_Level__c level = null;
        
        // get process level
        if (processConfig.processLevelsById.containsKey(processLevelId))
        {
            level = processConfig.processLevelsById.get(processLevelId);
        }
        
        // return level
        return (level);
    }

    // method to get single level id for process and level number
    public String GetSingleProcessLevelId(String objectType, Decimal levelNumber)
    {

        // return single level id
        List<SPCM_Approval_Process_Level__c> levels = GetProcessLevels(objectType, levelNumber);
        return (levels.size() == 0 ? '' : levels[0].Id);
    }
    
    // method to get level names for process and level number
    public List<String> GetLevelNames(String objectType, Decimal levelNumber)
    {
    
        // declaration(s)
        List<String> levelNames = new List<String>();
        
        // loop through process levels
        for (SPCM_Approval_Process_Level__c processLevel : GetProcessLevels(objectType, levelNumber))
        {
            levelNames.add(processLevel.Name);
        }

        // return role names
        return (levelNames);
    }
    
    // method to get role approvers for process level
    public List<String> GetProcessLevelRoleApprovers(SPCM_Approval_Process_Level__c processLevel)
    {
    
        // declaration(s)
        List<String> approverIds = new List<String>();
        
        // if users exist for role id
        if (roleConfig.roleUsers.containsKey(processLevel.Business_Role__r.Id))
        {
        
            // add users to list
            for (String userId : roleConfig.roleUsers.get(processLevel.Business_Role__r.Id))
            {
                approverIds.add(userId);
            }
        }
        
        // return approvers
        return (approverIds);
    }
 
    // method to get process levels for a process and level number
    public List<SPCM_Approval_Process_Level__c> GetProcessLevels(String objectType, Decimal levelNumber)
    {
    
        // declaration(s)
        List<SPCM_Approval_Process_Level__c> processLevels = new List<SPCM_Approval_Process_Level__c>();
        
        // if process level exists for object and level number
        if (processConfig.processLevels.containsKey(objectType) &&
            processConfig.processLevels.get(objectType).
            containsKey(levelNumber))
        {

            // return process levels
            processLevels = processConfig.processLevels.get(objectType).get(levelNumber);
        }
        
        // return approver
        return (processLevels);
    }

    // method to get manager for user
    public String GetUserManagerId(String userId)
    {
    
        // declaration(s)
        String managerId = '';
        
        // query for user record
        List<User> u = [SELECT Id, External_Id_gne__c FROM User WHERE IsActive = true
            AND Id = :userId];
        if (u.size() == 1)
        {
        
            // retrieve user external id
            String userExternalId = u[0].External_Id_gne__c;
        
            // query for active user hierarchy, and corresponding active manager hierarchy, record
            List<All_User_Hierarchy_gne__c> userHierarchy = [SELECT Id, User_External_Id_gne__c, 
                All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c FROM All_User_Hierarchy_gne__c
                WHERE Active_gne__c = true AND All_User_Hierarchy_Level1_gne__r.Active_gne__c = true AND
                User_External_Id_gne__c = :userExternalId];
            if (userHierarchy.size() == 1)
            {
            
                // retrieve manager external id
                String managerExternalId = userHierarchy[0].All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c;
                if (managerExternalId != null && managerExternalId != '')
                {
            
                    // query for manager user record
                    List<User> manager = [SELECT Id, External_Id_gne__c FROM User WHERE IsActive = true
                        AND External_Id_gne__c = :managerExternalId];
                    if (manager.size() == 1)
                    {
                        managerId = manager[0].Id;
                    }
                }
            }
        }
        
        // return value
        return (managerId);
    }
    
    // test method for code coverage
    static testMethod void runTests()
    {
        
        // disable future call functionality
        GNE_AllUserHistoryUtils.DisableFutureCalls = true;
        GNE_UserDelegationUtils.DisableFutureCalls = true;
        
        // create test user to avoid mix dml issue
        Profile p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u1 = new User(alias = 'u1test', email='u1test@gene.com',
            emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id,
            timezonesidkey='America/Los_Angeles', username='u1test@gene.com',
            External_Id_gne__c = 'u1test');
        insert (u1);
        
        // run as test user
        System.runAs(u1)
        {
        
            // declaration(s)
            String objectType = 'TEST_AP_OT';
            Decimal levelNumber = 1;
            String levelName = 'TEST_AP_RULE';
        
            // create another test user for manager test
            User u2 = new User(alias = 'u2test', email='u2test@gene.com',
                emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1.Id, ManagerId = u1.Id,
                timezonesidkey='America/Los_Angeles', username='u2test@gene.com',
                External_Id_gne__c = 'u2test');
            insert (u2);
        
            // create test user hierarchies
            All_User_Hierarchy_gne__c managerAUH = new All_User_Hierarchy_gne__c(
                 Name = 'u1test@gene.com', FirstName_gne__c = 'Test', LastName_gne__c = 'Test',
                 Active_gne__c = true, Email_Id__c = 'u1test@gene.com', 
                 User_External_Id_gne__c = 'u1test');
            insert (managerAUH);
            System.assertNotEquals(managerAUH.Id, null);
            All_User_Hierarchy_gne__c analystAUH = new All_User_Hierarchy_gne__c(
                 Name = 'u2test@gene.com', FirstName_gne__c = 'Test', LastName_gne__c = 'Test',
                 Active_gne__c = true, Email_Id__c = 'u2test@gene.com', 
                 User_External_Id_gne__c = 'u2test', All_User_Hierarchy_Level1_gne__c = managerAUH.Id);
            insert (analystAUH);
            System.assertNotEquals(analystAUH.Id, null);
        
            // create test business role
            GNE_Business_Role__c br1 = new GNE_Business_Role__c(Name = 'TEST_BUSINESS_ROLE');
            insert(br1);
            System.assertNotEquals(br1, null);
            
            // create test user business role
            User_Business_Role_gne__c ubr1 = new User_Business_Role_gne__c(
                Name = 'TEST_BUSINESS_ROLE', Business_Role_gne__c = 'TEST_BUSINESS_ROLE',
                Role_Assigned_Date_gne__c = Datetime.now(), User_gne__c = u1.Id, 
                User_RM_Role_Key_gne__c = 'u1test@TEST_BUSINESS_ROLE');
            insert (ubr1);
            System.assertNotEquals(ubr1, null);
        
            // create test approval process
            SPCM_Approval_Process__c ap1 = new SPCM_Approval_Process__c(Name = 'TEST_AP',
                Approval_Process_Type__c = objectType);
            insert(ap1);
            System.assertNotEquals(ap1, null);
            
            // create test approval process level
            SPCM_Approval_Process_Level__c apl1 = new SPCM_Approval_Process_Level__c(
                Name = levelName, Level_Number__c = levelNumber, Approval_Process__c = ap1.Id,
                Business_Role__c = br1.Id);
            insert (apl1);
            System.assertNotEquals(apl1, null);
            
            // create helper objects
            GNE_BusinessRoleConfig roleConfig = new GNE_BusinessRoleConfig();
            SPCM_ApprovalProcessConfig processConfig = new SPCM_ApprovalProcessConfig();
            
            // test both constructors
            SPCM_ApprovalManager appMgr1 = new SPCM_ApprovalManager();
            SPCM_ApprovalManager appMgr2 = new SPCM_ApprovalManager(roleConfig, processConfig);
            
            // test methods
            System.assertEquals(appMgr1.GetRoleApprovers(objectType, levelNumber).size(), 1);
            System.assertEquals(appMgr1.GetSingleRoleName(objectType, levelNumber), br1.Name);
            System.assertEquals(appMgr1.GetRoleNames(objectType, levelNumber).size(), 1);
            System.assertEquals(appMgr1.GetSingleLevelName(objectType, levelNumber), levelName);
            System.assertEquals(appMgr1.GetLevelNames(objectType, levelNumber).size(), 1);
            String processLevelId = appMgr1.GetSingleProcessLevelId(objectType, levelNumber);
            System.assertEquals(processLevelId, apl1.Id);
            List<SPCM_Approval_Process_Level__c> apls1 = appMgr1.GetProcessLevels(objectType, levelNumber);
            System.assertEquals(apls1.size(), 1);
            System.assertEquals(appMgr1.GetProcessLevelById(processLevelId).Id, apl1.Id);
            System.assertEquals(appMgr1.GetProcessLevelRoleApprovers(apls1[0]).size(), 1);
            System.assertEquals(appMgr1.GetUserManagerId(u2.Id).substring(0, 15), String.valueOf(u1.Id).substring(0, 15));
        }
    }
}