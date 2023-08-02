@isTest
public class SPCM_TestUtils
{
    
    public User userAnalyst { get; set; }
    public User userManager { get; set; }
    public All_User_Hierarchy_gne__c analystAUH { get; set; }
    public All_User_Hierarchy_gne__c managerAUH { get; set; }
    public User busRoleUser { get; set; }
    public User busRoleUser2 { get; set; }
    public GNE_Business_Role__c busRole { get; set; }
    public SPCM_Customer_Name__c customerName { get; set; }
    public SPCM_Customer_Type__c customerType { get; set; }
    public SPCM_Account_Manager__c accountManager { get; set; }
    public SPCM_Contract_Manager__c contractManager { get; set; }
    public SPCM_Agreement_Type__c agreementType { get; set; }
    public SPCM_Market_Type__c marketType { get; set; }
    public User_Business_Role_gne__c userBusRole { get; set; }
    public SPCM_Region__c region { get; set; }
    public SPCM_State__c state { get; set; }
    public SPCM_Legal_Approver__c legalApprover { get; set; }
    public SPCM_Level_1_Approver__c level1Approver { get; set; }
    
    // constructor
    public SPCM_TestUtils()
    {
    
        // disable future call functionality
        GNE_AllUserHistoryUtils.DisableFutureCalls = true;
        GNE_UserDelegationUtils.DisableFutureCalls = true;
    
        // create test user to avoid mix dml issue
        List<Profile> p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = new User(alias = 'u1test', email='u1test@gene.com',
            emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1[0].Id,
            timezonesidkey='America/Los_Angeles', username='u1test@gene.com');
        insert (user1);
        
        // run as test user
        System.runAs(user1)
        {
         
            // create test users
            userManager = new User(alias = 'u2test', email='u2test@gene.com',
                emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1[0].Id,
                timezonesidkey='America/Los_Angeles', username='u2test@gene.com',
                External_Id_gne__c = 'u2test');
            insert (userManager);
            System.assertNotEquals(userManager.Id, null);
            userAnalyst = new User(alias = 'u3test', email='u3test@gene.com',
                emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1[0].Id,
                timezonesidkey='America/Los_Angeles', username='u3test@gene.com', 
                External_Id_gne__c = 'u3test', ManagerId = userManager.Id);
            insert (userAnalyst);
            System.assertNotEquals(userAnalyst.Id, null);
            busRoleUser = new User(alias = 'u4test', email='u4test@gene.com',
                emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1[0].Id,
                timezonesidkey='America/Los_Angeles', username='u4test@gene.com', 
                ManagerId = userManager.Id);
            insert (busRoleUser);
            System.assertNotEquals(busRoleUser.Id, null);
            busRoleUser2 = new User(alias = 'u5test', email='u5test@gene.com',
                emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1[0].Id,
                timezonesidkey='America/Los_Angeles', username='u5test@gene.com', 
                ManagerId = userManager.Id);
            insert (busRoleUser2);
            System.assertNotEquals(busRoleUser2.Id, null);
         
            // create test user hierarchies
            managerAUH = new All_User_Hierarchy_gne__c(
                 Name = 'u2test@gene.com', FirstName_gne__c = 'Test', LastName_gne__c = 'Test',
                 Active_gne__c = true, Email_Id__c = 'u2test@gene.com', 
                 User_External_Id_gne__c = 'u2test');
            insert (managerAUH);
            System.assertNotEquals(managerAUH.Id, null);
            analystAUH = new All_User_Hierarchy_gne__c(
                 Name = 'u3test@gene.com', FirstName_gne__c = 'Test', LastName_gne__c = 'Test',
                 Active_gne__c = true, Email_Id__c = 'u3test@gene.com', 
                 User_External_Id_gne__c = 'u3test', All_User_Hierarchy_Level1_gne__c = managerAUH.Id);
            insert (analystAUH);
            System.assertNotEquals(analystAUH.Id, null);
         
            // create test permission set
            UserLicense ul = [SELECT Id FROM UserLicense WHERE Name = 'Salesforce'];
            PermissionSet permSet = new PermissionSet(Name = 'SPCM_TEST_PS1', Label = 'SPCM_TEST_PS1', UserLicenseId = ul.Id);
            insert(permSet);
            System.assertNotEquals(permSet.Id, null);
            
            // create test group
            Group pubGroup = new Group(Name = 'SPCM_TEST_G1', DeveloperName = 'SPCM_TEST_G1');
            insert(pubGroup);
            System.assertNotEquals(pubGroup.Id, null);

            // create test business role
            busRole = new GNE_Business_Role__c(Name = 'TEST_BUSINESS_ROLE');
            insert(busRole);
            System.assertNotEquals(busRole.Id, null);
            
            // create test business role permission set
            GNE_Business_Role_Permission_Set__c busRolePermSet = new GNE_Business_Role_Permission_Set__c(
                Business_Role__c = busRole.Id, Permission_Set__c = 'SPCM_TEST_PS1', Permission_Set_Id__c = permSet.Id);
            insert (busRolePermSet);
            System.assertNotEquals(busRolePermSet.Id, null);
            
            // create test business role public group
            GNE_Business_Role_Public_Group__c busRolePubGroup = new GNE_Business_Role_Public_Group__c(
                Business_Role__c = busRole.Id, Public_Group__c = 'SPCM_TEST_G1', Public_Group_Id__c = pubGroup.Id);
            insert (busRolePubGroup);
            System.assertNotEquals(busRolePubGroup.Id, null);
            
            // create test user business role
            userBusRole = new User_Business_Role_gne__c(
                Name = 'TEST_BUSINESS_ROLE', Business_Role_gne__c = 'TEST_BUSINESS_ROLE',
                Role_Assigned_Date_gne__c = Datetime.now(), User_gne__c = busRoleUser.Id, 
                User_RM_Role_Key_gne__c = 'u1test@TEST_BUSINESS_ROLE');
            insert (userBusRole);
            System.assertNotEquals(userBusRole.Id, null);
            
            // create test region
            region = new SPCM_Region__c(Name = 'TEST_REGION');
            insert (region);
            System.assertNotEquals(region.Id, null);
            
            // create test state
            state = new SPCM_State__c(Name = 'TEST_STATE', State_Abbreviation__c = 'TST_ST', Region__c = region.Id);
            insert (state);
            System.assertNotEquals(state.Id, null);
  
            // create lookup data
            CreateLookupData();
         }
    }
    
    // creates test approval process data
    public void CreateApprovalProcessData(String objectType)
    {
    	CreateApprovalProcessData(objectType, 'TEST_' + objectType);
    }
    
    public void CreateApprovalProcessData(String objectType, String approvalProcessName)
    {
    
        // query for existing approval process data
        List<SPCM_Approval_Process__c> existingProcesses = [SELECT Id, Name, Approval_Process_Type__c FROM
            SPCM_Approval_Process__c WHERE Approval_Process_Type__c = :objectType];
            
        // update existing processes to allow for test data
        for (SPCM_Approval_Process__c existingProcess : existingProcesses)
        {
            existingProcess.Name = existingProcess.Name + '_TEMP';
            existingProcess.Approval_Process_Type__c = existingProcess.Approval_Process_Type__c + '_TEMP';
        }
        if (existingProcesses.size() > 0)
        {
            update(existingProcesses);
        }
        
        // create approval process
        SPCM_Approval_Process__c approvalProcess = new SPCM_Approval_Process__c(Name = approvalProcessName,
            Approval_Process_Type__c = objectType);
        insert (approvalProcess);
        System.assert(approvalProcess.Id != null);
        
        // create approval process levels
        List<SPCM_Approval_Process_Level__c> processLevels = new List<SPCM_Approval_Process_Level__c>();
        
        // mcc approval sheet
        if (objectType == 'SPCM_MCC_Approval_Sheet__c')
        {
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 1, Name = 'MCC Manager Approval', 
                Business_Role__c = busRole.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 2, Name = 'MCC Executive Approval', 
                Business_Role__c = busRole.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 3, Name = 'Channel Strategy Mgmt Executive Approval',
                Business_Role__c = busRole.Id, Account_Team__c = 'Channel Strategy Management'));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 3, Name = 'Payer Account Mgmt Executive Approval', 
                Business_Role__c = busRole.Id, Account_Team__c = 'Payer Account Management'));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 3, Name = 'Customer Operations Executive Approval',
                Business_Role__c = busRole.Id, Account_Team__c = 'Customer Operations'));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 4, Name = 'SPCM Executive Approval', 
                Business_Role__c = busRole.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 5, Name = 'MCC Contract Manager Approval', 
                Business_Role__c = busRole.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 6, Name = 'Managed Care Legal Approval', 
                Business_Role__c = busRole.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 7, Name = 'MCCO Executive Approval', 
                Business_Role__c = busRole.Id, Low_Amount__c = 2500000));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 8, Name = 'Chief Executive Officer Approval', 
                Business_Role__c = busRole.Id, Low_Amount__c = 5000000));
        }

        // mcc tracking sheet
        if (objectType == 'SPCM_MCC_Tracking_Sheet__c')
        {
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 1, Name = 'MCC Manager Approval', 
                Business_Role__c = busRole.Id));
        }
            
        // mcc exception sheet
        if (objectType == 'SPCM_MCC_Exception_Sheet__c')
        {
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 1, Name = 'MCC Manager Approval', 
                Business_Role__c = busRole.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 2, Name = 'MCC Executive Approval', 
                Business_Role__c = busRole.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 3, Name = 'Channel Strategy Mgmt Executive Approval',
                Business_Role__c = busRole.Id, Account_Team__c = 'Channel Strategy Management'));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 4, Name = 'GP Executive Approval',
                Business_Role__c = busRole.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 4, Name = 'C-Ops Executive Approval', 
                Business_Role__c = busRole.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 5, Name = 'SPCM Executive Approval', 
                Business_Role__c = busRole.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 6, Name = 'Managed Care Legal Approval', 
                Business_Role__c = busRole.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 7, Name = 'MCCO Executive Approval', 
                Business_Role__c = busRole.Id, Low_Amount__c = 2500000));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 8, Name = 'Chief Executive Officer Approval', 
                Business_Role__c = busRole.Id, Low_Amount__c = 5000000));
        }
            
        // cars payment packet
        if (objectType == 'SPCM_CARS_Payment_Packet__c')
        {
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 1, Name = 'Selected Reviewer Approval', 
                Business_Role__c = busRole.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 2, Name = 'C-Ops Group Manager Approval', 
                Business_Role__c = busRole.Id, Low_Amount__c = 10000, Contract_Type__c = 'GPO; Government; ONA'));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 3, Name = 'C-Ops Group Channel Manager Approval', 
                Business_Role__c = busRole.Id, Low_Amount__c = 100000, Contract_Type__c = 'GPO; Government; ONA'));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 4, Name = 'C-Ops Executive Approval', 
                Business_Role__c = busRole.Id, Low_Amount__c = 250000));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 5, Name = 'SPCM Executive Approval', 
                Business_Role__c = busRole.Id, Low_Amount__c = 2000000));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 6, Name = 'MCCO Executive Approval', 
                Business_Role__c = busRole.Id, Low_Amount__c = 5000000));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 7, Name = 'Chief Executive Officer Approval', 
                Business_Role__c = busRole.Id, Low_Amount__c = 20000000));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 8, Name = 'C-Ops Group Manager Payment Release', 
                Business_Role__c = busRole.Id, Low_Amount__c = 250000, Contract_Type__c = 'GPO; Government; ONA'));
        }
            
        // cars contract summary form
        if (objectType == 'SPCM_CARS_Contract_Summary_Form__c')
        {
            /*
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 1, Name = 'C-Ops Manager Approval', 
                Business_Role__c = busRole.Id));
            */
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 1, Name = 'RCM Approval', 
                User__c = busRoleUser.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 2, Name = 'Group Manager Approval', 
                User__c = busRoleUser2.Id));
        }
            
        // cars icfr sign-off
        if (objectType == 'SPCM_CARS_ICFR_Sign_Off__c')
        {
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 1, Name = 'C-Ops Frequency Approval', 
                User__c = busRoleUser.Id, Frequency__c = 'Monthly'));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 2, Name = 'C-Ops Manager Approval', 
                User__c = busRoleUser.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 3, Name = 'C-Ops Contract Analyst Approval', 
                User__c = busRoleUser.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 4, Name = 'C-Ops Sr. Manager Approval', 
                User__c = busRoleUser.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 4, Name = 'C-Ops Sr. Manager Approval', 
                User__c = busRoleUser2.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 5, Name = 'C-Ops Director Approval', 
                User__c = busRoleUser.Id));
        }
            
        // gp payment packet
        if (objectType == 'SPCM_GP_Payment_Packet__c')
        {
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 1, 
                Name = 'GP Payment - Associate Group Manager', Business_Role__c = busRole.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 2, Name = 'GP Payment - Group Manager Approval',
                Business_Role__c = busRole.Id, Low_Amount__c = 1000000));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 3, Name = 'GP Associate Director Approval',
                Business_Role__c = busRole.Id, Low_Amount__c = 2000000));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 4, Name = 'GP Executive Approval',
                Business_Role__c = busRole.Id, Low_Amount__c = 5000000));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 5, Name = 'SPCM Executive Approval',
                Business_Role__c = busRole.Id, Low_Amount__c = 10000000));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                    Approval_Process__c = approvalProcess.Id, Level_Number__c = 6, Name = 'MCCO Executive Approval',
                    Business_Role__c = busRole.Id, Low_Amount__c = 50000000));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 7,
                Name = 'Chief Executive Officer Approval', Business_Role__c = busRole.Id));
        }
            
        // medicaid payment packet
        if (objectType == 'SPCM_Medicaid_Payment_Packet__c')
        {
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 1, Region__c = region.Id,
                Name = 'Medicaid Contract Analyst Region 1 Approval', Business_Role__c = busRole.Id));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 2, Name = 'Medicaid Principal Contract Analyst', 
                Business_Role__c = busRole.Id, High_Amount__c = 10001));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 2, Name = 'Medicaid Manager Approval', 
                Business_Role__c = busRole.Id,  Low_Amount__c = 10001));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 3, Name = 'Medicaid Executive Approval', 
                Business_Role__c = busRole.Id, Low_Amount__c = 250000));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 4, Name = 'SPCM Executive Approval', 
                Business_Role__c = busRole.Id, Low_Amount__c = 2000000));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 5, Name = 'MCCO Executive Approval', 
                Business_Role__c = busRole.Id, Low_Amount__c = 5000000));
            processLevels.add(new SPCM_Approval_Process_Level__c(
                Approval_Process__c = approvalProcess.Id, Level_Number__c = 6, Name = 'Chief Executive Officer Approval', 
                Business_Role__c = busRole.Id, Low_Amount__c = 20000000));
        }
            
        // insert process levels
        if (processLevels.size() > 0)
        {
            insert(processLevels);
        }
    }
    
    // method to mass remove all business roles/users for approval process levels for negative testing
    public void RemoveApprovalProcessRolesAndUsers(String objectType)
    {
        
        // loop through approval process levels
        List<SPCM_Approval_Process_Level__c> processLevels = [SELECT Id, Business_Role__c, User__c FROM
            SPCM_Approval_Process_Level__c WHERE Approval_Process__r.Approval_Process_Type__c = :objectType];
        for (SPCM_Approval_Process_Level__c processLevel : processLevels)
        {
            
            // remove role and user
            processLevel.Business_Role__c = null;
            processLevel.User__c = null;
        }
        
        // update records
        if (processLevels.size() > 0)
        {
            update (processLevels);
        }
    }
    
    // method to mass delete all approval process levels for negative testing
    public void DeleteApprovalProcessLevels(String objectType)
    {
        
        // retrieve approval process levels
        List<SPCM_Approval_Process_Level__c> processLevels = [SELECT Id FROM SPCM_Approval_Process_Level__c 
            WHERE Approval_Process__r.Approval_Process_Type__c = :objectType];
        
        // delete records
        if (processLevels.size() > 0)
        {
            delete (processLevels);
        }
    }
    
    // method to retrieve a count of distinct approval levels
    public Decimal GetApprovalLevelCount(String objectType)
    {

        // loop through approval process levels
        Set<Decimal> levelNumbers = new Set<Decimal>();
        for (SPCM_Approval_Process_Level__c processLevel : [SELECT Id, Level_Number__c FROM
            SPCM_Approval_Process_Level__c WHERE Approval_Process__r.Approval_Process_Type__c = :objectType])
        {
            if (!levelNumbers.contains(processLevel.Level_Number__c))
            {
                levelNumbers.add(processLevel.Level_Number__c);
            }
        }
        
        // return count
        return (levelNumbers.size());        
    }
    
    // creates test lookup data
    private void CreateLookupData()
    {
        List<SObject> lookupData = new List<SObject>();
        customerName = new SPCM_Customer_Name__c(Name = 'CUSTOMER_NAME_TEST');
        lookupData.add(customerName);
        customerType = new SPCM_Customer_Type__c(Name = 'CUSTOMER_TYPE_TEST');
        lookupData.add(customerType);
        accountManager = new SPCM_Account_Manager__c(Name = 'ACCOUNT_MANAGER_TEST');
        lookupData.add(accountManager);
        contractManager = new SPCM_Contract_Manager__c(Name = 'CONTRACT_MANAGER_TEST');
        lookupData.add(contractManager);
        agreementType = new SPCM_Agreement_Type__c(Name = 'AGREEMENT_TYPE_TEST');
        lookupData.add(agreementType);
        marketType = new SPCM_Market_Type__c(Name = 'MARKET_TYPE_TEST');
        lookupData.add(marketType);
        legalApprover = new SPCM_Legal_Approver__c(Name = 'LEGAL_TEST', User__c = busRoleUser.Id,
            Is_Active__c = true);
        lookupData.add(legalApprover);
        level1Approver = new SPCM_Level_1_Approver__c(Name = 'LEVEL_1_TEST', User__c = busRoleUser.Id,
            Is_Active__c = true);
        lookupData.add(level1Approver);
        insert(lookupData);
    }
    
    // retrieves record type id
    public Id GetSObjectRecordTypeId(String objectType, String recordTypeName)
    {
    
        // declaration(s)
        Id recordTypeId = null;
        
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = :objectType
            AND DeveloperName = :recordTypeName];
        if (recordTypes.size() == 1)
        {
            recordTypeId = recordTypes[0].Id;
        }
        
        // return result
        return (recordTypeId);
    }
}