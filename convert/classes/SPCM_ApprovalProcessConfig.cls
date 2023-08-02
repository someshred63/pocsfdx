public class SPCM_ApprovalProcessConfig
{

    // various maps
    public Map<String, Map<Decimal, List<SPCM_Approval_Process_Level__c>>> processLevels { get; set; }
    public Map<String, SPCM_Approval_Process_Level__c> processLevelsById { get; set; }
    
    // constructor
    public SPCM_ApprovalProcessConfig()
    {
    
        // initialize maps
        processLevels = new Map<String, Map<Decimal, List<SPCM_Approval_Process_Level__c>>>();
        processLevelsById = new Map<String, SPCM_Approval_Process_Level__c>();
        
        // query for approval process data
        for (SPCM_Approval_Process__c process : [SELECT Id, Name, Approval_Process_Type__c,
            (SELECT Id, Name, Business_Role__r.Name, User__c, Level_Number__c, Account_Team__c, Contract_Type__c, Comments__c,
            Frequency__c, High_Amount__c, Low_Amount__c, Region__c,Medicaid_States__c, isactive__c FROM Levels__r where isactive__c = true) 
            FROM SPCM_Approval_Process__c])
        {
            
            // initialize map entry
            if (!processLevels.containsKey(process.Approval_Process_Type__c))
            {
                processLevels.put(process.Approval_Process_Type__c, new Map<Decimal, List<SPCM_Approval_Process_Level__c>>());
            }
            
            // loop through process levels
            for (SPCM_Approval_Process_Level__c level : process.Levels__r)
            {
                if (!processLevelsById.containsKey(level.Id))
                {
                    processLevelsById.put(level.Id, level);
                }
                if (!processLevels.get(process.Approval_Process_Type__c).containsKey(level.Level_Number__c))
                {
                    processLevels.get(process.Approval_Process_Type__c).put(level.Level_Number__c, new List<SPCM_Approval_Process_Level__c>());
                }
                processLevels.get(process.Approval_Process_Type__c).get(level.Level_Number__c).add(level);
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
        
            // create test approval process
            SPCM_Approval_Process__c ap1 = new SPCM_Approval_Process__c(Name = 'TEST_AP',
                Approval_Process_Type__c = 'TEST_AP');
            insert(ap1);
            System.assertNotEquals(ap1, null);
            
            // create test approval process level
            SPCM_Approval_Process_Level__c apl1 = new SPCM_Approval_Process_Level__c(
                Name = 'TEST_AP_RULE', Level_Number__c = 1, Approval_Process__c = ap1.Id);
            insert (apl1);
            System.assertNotEquals(apl1, null);

            // create object
            SPCM_ApprovalProcessConfig processConfig = new SPCM_ApprovalProcessConfig();
            
            // run assertions
            System.assertEquals(true, processConfig.processLevels.containsKey('TEST_AP'));
            System.assertEquals(1, processConfig.processLevels.get('TEST_AP').size());
        }
    }
}