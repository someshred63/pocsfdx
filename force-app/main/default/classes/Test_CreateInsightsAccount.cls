@isTest(seealldata = false)
public class Test_CreateInsightsAccount {
    @isTest static void generateTestEventLogFileData() {
        CreateInsightsAccount aFlowPlugin = new CreateInsightsAccount();
        Map<String,Object> inputParams = new Map<String,Object>();
		Map<String,Object> outputParams = new Map<String,Object>();
        inputParams.put('FirstName','Heiko');
		inputParams.put('LastName','Leibenath');
        inputParams.put('eMail','heiko@newrelic.com');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
		result = aFlowPlugin.invoke(request);
        
        User testUser = new User();
        testUser.LastName = 'testUser';
        testUser.TimeZoneSidKey = 'America/Los_Angeles'; 
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.Email = 'test@test.com';
        testUser.UserName = 'test@wxyzthisisatest.com';
        testUser.Alias = 'test';
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1][0].Id;
        insert testUser;

        system.runAs(testUser){

        	SFDC2Insights__c s2i = new SFDC2Insights__c(Advanced_Data__c = true,
            	                                        Name = 'thisisatest', 
                	                                    Custom_Event__c = 'thisisatest', 
                    	                                Max_Insights_Intake__c = 1000, 
                        	                            NR_Account_ID__c = 'thisistest');
        	insert s2i;
            
            CreateInsightsAccount my_CIA = New CreateInsightsAccount();
            
            my_CIA.create_account(testUser.Alias, testUser.LastName, testUser.Email);
            
        }            
    }
}

/*
static testMethod void basicTestwithAccount() {
 
MyFlowPlugin aFlowPlugin = new MyFlowPlugin();
Map<String,Object> inputParams = new Map<String,Object>();
Map<String,Object> outputParams = new Map<String,Object>();
inputParams.put('Param1','val1');
inputParams.put('Param2','val2');Process.PluginRequest request = new Process.PluginRequest(inputParams);
Process.PluginResult result;
result = aFlowPlugin.invoke(request);

System.AssertEquals(result.size(), 3);
} */