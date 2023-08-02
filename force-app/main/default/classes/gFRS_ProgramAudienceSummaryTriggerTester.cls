public with sharing class gFRS_ProgramAudienceSummaryTriggerTester {
	
	class TestSettings {
		Account acc;
		GFRS_Organization__c org;
		GFRS_Funding_Request__c fundingRequest; 
		GFRS_Location__c loc;
		GFRS_Program__c program;
		GFRS_Program_Audience_Group__c audience;
		GFRS_Program_Audience_Group__c audience2;
		
		public String DEFAULT_STATUS = 'Intake';
        public String DEFAULT_SUB_STATUS = 'Not Submitted';
        
		public TestSettings(){
			acc = gFRS_TestCreationUtils.createAccount('gFRS_FundingRequestReadControllerTesterAcc');
	     	insert acc;
		 	org = gFRS_TestCreationUtils.createOrganization('TestOrg1', acc);
		 	insert org;
		 	loc = gFRS_TestCreationUtils.createLocation('gFRS_FundingRequestReadControllerTesterLoc',org.id);
      		insert loc;
		 	fundingRequest = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_IMED , DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', org.Id, loc.Id);
		 	insert fundingRequest;
		 	program = gFRS_TestCreationUtils.createProgram_min('type1', fundingRequest);
			insert program;
			audience = gFRS_TestCreationUtils.createProgramAudience_min(program);
			insert audience;
			audience2 = gFRS_TestCreationUtils.createProgramAudience_min(program);
			insert audience2;
		}
	}
	
	static testMethod void testRemoteActions() {
		TestSettings ts = new TestSettings();
		ts.audience.Actual_Learners__c = 22;
		ts.audience.Expected_Learners__c = 55;
		Test.startTest();
		update ts.audience;
		ts.audience2.Actual_Learners__c = 2;
		ts.audience2.Expected_Learners__c = 5;
		update ts.audience2;
		
		system.assertEquals(24,[select Expected_Attendees__c from GFRS_Funding_Request__c where id = :ts.fundingRequest.Id limit 1].Expected_Attendees__c);
		system.assertEquals(60,[select Total_of_Expected_Learners__c from GFRS_Funding_Request__c where id = :ts.fundingRequest.Id limit 1].Total_of_Expected_Learners__c);
		Test.stopTest();
		
	}
}