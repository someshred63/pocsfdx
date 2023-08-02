/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class gFRS_RefundControllerTester {
	class TestSettings {
		public Account account;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;
        public GFRS_Funding_Request__c request;
		public GFRS_Program__c program;
        
        public TestSettings(){
			this.account = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
			insert this.account;
			  
			this.organization = gFRS_TestCreationUtils.createOrganization2( 'IBM', this.account.id );
			insert this.organization;
			  
			this.location = gFRS_TestCreationUtils.createLocation( 'SomeLocation', this.organization.id );
			insert this.location;
			
			this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
	        insert this.request;
	        this.request = [select Id, Name, Status__c, Status_Last_Modified_Date__c from GFRS_Funding_Request__c where Id= : this.request.Id];
        }

		public void createProgram() {
			this.program = gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, this.request, 3, 'test1234');
			Date endDate = Date.today().addMonths(2);
			this.program.End_Date__c = endDate;
			insert this.program;
		}

		public Boolean checkApexMessages(String message) {
			for(ApexPages.Message msg : ApexPages.getMessages()){
				if (msg.getDetail().contains(message)) {
					return true;
				}
			}
			return false;
		}
  }

    static testMethod void testPrivateMethods() {
    	TestSettings ts = new TestSettings();
    	ts.request.Refund_Request_Date__c = Date.today();
    	gFRS_RefundController cont = new gFRS_RefundController(new ApexPages.StandardController(ts.request));
    	
    	System.assertNotEquals(ts.request, null);
    	
    	ts.request.Approved_Amount__c = 1.0;
    	
    	gFRS_RefundController cont2 = new gFRS_RefundController(new ApexPages.StandardController(ts.request));
    	
    	cont2.closePage();
    	
    	gFRS_RefundController cont3 = new gFRS_RefundController(new ApexPages.StandardController(new GFRS_Funding_Request__c()));
    }

	@IsTest
	static void testRefreshRequest() {
		TestSettings ts = new TestSettings();
		ts.request.Refund_Request_Date__c = Date.today();
		ts.request.Approved_Amount__c = null;
		update ts.request;

		gFRS_RefundController cont = new gFRS_RefundController(new ApexPages.StandardController(ts.request));
		System.assert(ts.checkApexMessages('Approved Amount not found'));
	}

	@IsTest
	static void testControllerPropertiesAndProgram() {
		TestSettings ts = new TestSettings();
		ts.createProgram();
		ts.request.Approved_Amount__c = 1000;
		update ts.request;

		gFRS_RefundController cont = new gFRS_RefundController(new ApexPages.StandardController(ts.request));
		System.assertEquals(5, cont.topFieldSet.size());
		System.assertEquals(ts.program.End_Date__c, cont.lastProgram.End_Date__c);

		ts.program.End_Date__c = null;
		update ts.program;
		gFRS_RefundController cont2 = new gFRS_RefundController(new ApexPages.StandardController(ts.request));
		System.assertEquals(null, cont2.lastProgram.End_Date__c);
	}
}