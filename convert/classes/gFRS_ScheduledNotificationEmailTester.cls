@isTest
private class gFRS_ScheduledNotificationEmailTester {
	class TestSettings {
		public Account account;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;
        public GFRS_Funding_Request__c request;
        
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
        	
        }
	}
	static testMethod void testScheduledNotificationEmail() {
		TestSettings ts = new TestSettings();
	 	ts.setupImed();
	 	
	 	ts.request.Status_Last_Modified_Date__c = date.newInstance(1960, 2, 17); 
	 	update ts.request;
		gFRS_ScheduledNotificationEmail obj = new gFRS_ScheduledNotificationEmail();
		obj.sendEmail();
		
		obj.execute(null);
	}

}