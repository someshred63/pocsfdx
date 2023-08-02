@isTest(seealldata = false)
public class Test_II {    
    @isTest static void generateTestEventLogFileData() {
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

    
    		PageReference pageRef = Page.EventLogFileAdministration;
	        Test.setCurrentPage(pageRef);
	
    	    ApexPages.StandardController stdController = new ApexPages.StandardController(s2i);
        	EventLogAdminController.runningStatuses();
	        EventLogAdminController.getIsSchedulerRunning();
            
    	    EventLogAdminController elac = new EventLogAdminController(stdController);
        	elac.getCurrentRecord();
	        elac.getCurrentRecord();
    	    elac.resetSchedule();
        	elac.save();
            
	        elac.getPageMode();
    	    elac.setPageMode('Edit');
        	elac.setPageMode('View');
	        elac.setPageModeToEdit();
    	    elac.setPageModeToView();
	
    	    elac.startPolling();
        	elac.stopPolling();
	        elac.getNextPollingTime();
    	    elac.setup();
    	}
    }
}