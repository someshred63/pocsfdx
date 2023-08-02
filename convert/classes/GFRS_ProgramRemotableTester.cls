@isTest
private class GFRS_ProgramRemotableTester {
	class TestSettings {
		Account acc;
		GFRS_Organization__c org;
		GFRS_Funding_Request__c fundingRequest; 
		GFRS_Location__c loc;
		GFRS_Program__c program;
		GFRS_Program_Audience_Group__c audience;
		
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
		}
	}
	
	static testMethod void testRemoteActions() {
		TestSettings ts = new TestSettings();
		ApexPages.StandardController controller;
		GFRS_ProgramRemotable cont = new GFRS_ProgramRemotable(controller);
		GFRS_ProgramRemotable.addAudience(ts.program.Id);
		GFRS_ProgramRemotable.removeAudience(ts.audience.Id);
	}
	
	static testMethod void testRemoteActions2() {	
		TestSettings ts = new TestSettings();
		System.assertEquals(GFRS_ProgramRemotable.updateAudienceField(ts.audience.Id, 'nonExistingField','1'),null);
		GFRS_ProgramRemotable.updateAudienceField(ts.audience.Id, 'Intended_Audience__c','1');
		GFRS_ProgramRemotable.fetchAttendees(ts.program.Id);
	}

}