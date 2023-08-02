@IsTest
private class gFRS_ResetCurrentYearBudgetsTester {
	
	public static final Decimal EPSILON = 0.00000000000001;
	
	class TestSettings {
        
        //-- instance variables
        public Account account;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;
        public GFRS_Funding_Request__c request;
        public TestSettings(){
        	//gFRS_TestCreationUtils.initialize();
        	this.account = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
        	insert this.account;
        	
        	this.organization = gFRS_TestCreationUtils.createOrganization2( '20110101', this.account.id );
        	insert this.organization;
        	
        	this.location = gFRS_TestCreationUtils.createLocation( 'SomeLocation', this.organization.id );
        	insert this.location;
        
        }
        
        public void setupIMED(){
           	this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
        	insert this.request;
        	this.request = [select Id, Name, Status__c, Status_Last_Modified_Date__c from GFRS_Funding_Request__c where Id= : this.request.Id];
        }
        
        public void refreshOrganization(){
        	this.organization = [ select id, Name, Account__c, Total_Approved_Current_Year__c
        		from gFRS_Organization__c
        		where id = :this.organization.id ];
        }
	}
	
	static testMethod void testResetCurrentYearsBudgets() {
		TestSettings ts = new TestSettings();
        ts.setupIMED();
        
        Test.StartTest();
		GFRS_ScheduleResetCurrentYearBudgets testObj = new GFRS_ScheduleResetCurrentYearBudgets();
        String schTime = '0 0 23 * * ?';
        String jobId = system.schedule('Test scheduler', schTime, testObj);
		GFRS_ResetCurrentYearBudgets driver = new GFRS_ResetCurrentYearBudgets( ts.organization.id );
		Database.executeBatch( driver );
		Test.StopTest();
		
		//-- for now only test that the schedule has started, we test the batch separately
		System.assertNotEquals( null, jobId, 'As we scheduled the job, there must be a job id to prove it was successfully set' );
	}
	
	static testMethod void testBatchWithoutApprovedAmounts(){
		TestSettings ts = new TestSettings();
		ts.setupIMED();
		
		GFRS_ResetCurrentYearBudgets driver = new GFRS_ResetCurrentYearBudgets( ts.organization.id );
		
		//System.debug( 'organizationId:' + ts.organization.id );
		
		Test.StartTest();
		Id batchProcessId = Database.executeBatch( driver, 10 );
		Test.StopTest();
		
		ts.refreshOrganization();
		
		//-- float comparisons must not use equality
		System.assert( ts.organization.Total_Approved_Current_Year__c < EPSILON, 'As there are no approved amounts, the total approved must be infinitely close to zero:' + ts.organization.Total_Approved_Current_Year__c );
	}
	
	static testMethod void testBatchWithApprovedAmounts(){
		Decimal approvedAmount = 100.00;
		
		TestSettings ts = new TestSettings();
		ts.setupIMED();
		ts.request.Approved_Amount__c = approvedAmount;
		update ts.request;
		
		//System.debug( 'approvedAmount:' + [ select id, Approved_Amount__c from gFRS_Funding_Request__C where id = :ts.request.id ] );
		//System.debug( 'organizationId:' + ts.organization.id );
		
		GFRS_ResetCurrentYearBudgets driver = new GFRS_ResetCurrentYearBudgets( ts.organization.id );
		
		Test.StartTest();
		Id batchProcessId = Database.executeBatch( driver);
		Test.StopTest();
		
		ts.refreshOrganization();
		
		//-- float comparisons must not use equality
		Boolean floatEqual =  ts.organization.Total_Approved_Current_Year__c == 0;
		
		System.assert( floatEqual, 'The total approved in current Year should be equal 0: ' + ts.organization.Total_Approved_Current_Year__c );
	}
}