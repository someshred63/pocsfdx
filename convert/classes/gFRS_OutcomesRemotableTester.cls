@isTest
private class gFRS_OutcomesRemotableTester {
	class TestSettings {
	 	public Account account;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;
        public GFRS_Funding_Request__c request;
        public GFRS_Program__c[] programs;
        public GFRS_Program_Audience_Group__c audience;
        
        public TestSettings(){
         	this.account = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
        	insert this.account;
        	
        	this.organization = gFRS_TestCreationUtils.createOrganization2( 'IBM', this.account.id );
        	insert this.organization;
        	
        	this.location = gFRS_TestCreationUtils.createLocation( 'SomeLocation', this.organization.id );
        	insert this.location;
        }
        
	     public void setupIMED(){
	       	this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
	    	insert this.request;
	    	this.request = [select Id, Name, Status__c, Status_Last_Modified_Date__c from GFRS_Funding_Request__c where Id= : this.request.Id];
	    	this.programs = [select ID, Name from GFRS_Program__c where Funding_Request__c = :this.request.Id];
	    	
	    	this.audience = gFRS_TestCreationUtils.createAudience(this.programs[0].Id);
	    	insert this.audience;
	    }
	}
	
	static testMethod void testOutcomesRemotable() {
		TestSettings ts = new TestSettings();
	 	ts.setupImed();
	 	ApexPages.StandardController controller;
		gFRS_OutcomesRemotable cont = new gFRS_OutcomesRemotable(controller);
		gFRS_OutcomesRemotable.fetchAttendees(String.valueOf(ts.programs[0].id));
		gFRS_OutcomesRemotable.updateAudienceField(String.valueOf(ts.audience.Id), 'Credit_Hours__c', '22');
		
	}
}