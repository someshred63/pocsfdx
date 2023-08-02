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
private class gFRS_FR_StatusModifiedDateTester {
	
	public static final String STATE_NEW = 'New';
	public static final String STATE_OLD = 'Old';
	
	public static final Date DEFAULT_DATE = Date.newInstance( 2011,01,01 );

    /**
     *  Internal Testing class that takes care of setup and tear downs.
     **/
    class TestSettings {
    	
    	//-- instance variables
    	public Account account;
    	public Account userAccount;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;
        public GFRS_Funding_Request__c request;
        
        public GFRS_Funding_Request__c[] newRequests;
        public Map<id,GFRS_Funding_Request__c> oldRequests;
    	
    	public TestSettings(){
    		//-- initialization done for ALL SETUPs done here
    		this.account = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
        	insert this.account;
    		
    		this.organization = gFRS_TestCreationUtils.createOrganization2( '20110101', this.account.id );
        	insert this.organization;
        	
        	this.location = gFRS_TestCreationUtils.createLocation( 'SomeLocation', this.organization.id );
        	insert this.location;
    	}
    	
    	public void setupWithoutStatus(){
    		this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
			this.prepareRequestForUpdate();
			this.request.Status__c = null;
			insert this.request;
    	}
    	
    	public void setupWithStatus(){
    		this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
			this.prepareRequestForUpdate();
			this.request.Status__c = 'New';
			insert this.request;
    	}
    	
    	/** cleanup the fundingRequest to the point that an update can occur **/
		public void prepareRequestForUpdate(){
			//this.request.Name = 'testRequest';
			this.request.Status_Last_Modified_Date__c = Date.newInstance( 2011, 01, 01 );
		}
		
    	public void setupOldAndNew(){
    		this.setupWithStatus();
    		
    		GFRS_Funding_Request__c[] requests = [ select id, Status__c, Status_Last_Modified_Date__c from GFRS_Funding_Request__c where id = :this.request.id limit 1];
    		this.newRequests = requests;
    		
    		requests = [ select id, Status__c, Status_Last_Modified_Date__c from GFRS_Funding_Request__c where id = :this.request.id limit 1];
    		requests[0].Status__c = STATE_OLD;
    		this.oldRequests = new Map<id,GFRS_Funding_Request__c>( requests );
    	}
    	
    	public void refreshFundingRequest(){
    		
    		this.request = [ select id, Status__c, Status_Last_Modified_Date__c
    			from GFRS_Funding_Request__c
    			where id = :this.request.id limit 1 ];
    	}
    }
    
    static testMethod void testSettingsSetsUpWithoutErrors(){
    	try {
	    	TestSettings ts = new TestSettings();
	    	ts.setupWithStatus();
	    	ts.refreshFundingRequest();
    	} catch( Exception err ){
    		System.assert( false, 'TestSetting/Setup must not throw any exceptions' );
    	}
    }
    
    static testMethod void testWithoutStatusMustBeDefault(){
    	TestSettings ts = new TestSettings();
    	ts.setupWithoutStatus();
    	ts.refreshFundingRequest();
    	
    	System.assertEquals( null, ts.request.Status__c, 'status should already be null' );
    	System.assertEquals( DEFAULT_DATE, ts.request.Status_Last_Modified_Date__c, 'Status last modified date must be blank');
    }
    
    static testMethod void testUpdateWithTriggerMustUpdateDate(){
    	TestSettings ts = new TestSettings();
    	ts.setupWithoutStatus();
    	
    	ts.request.Status__c = STATE_NEW;
    	update ts.request;
    	
    	ts.refreshFundingRequest();
    	
    	System.assertEquals( STATE_NEW, ts.request.Status__c, 'status should already be null' );
    	System.assertNotEquals( DEFAULT_DATE, ts.request.Status_Last_Modified_Date__c, 'Since the status was updated, teh last modified must be updated too' );
    }
    
    static testmethod void testUpdateMustUpdateDate(){
    	TestSettings ts = new TestSettings();
    	ts.setupOldAndNew();
    	
    	GFRS_Funding_Request__c[] updatedRequests = gFRS_Util.updateStatusLastModifiedDate2( ts.newRequests, ts.oldRequests );
    	System.assertEquals( 1, updatedRequests.size(), 'because the status has changed in the old status, the record should have an updated status last modified date');
    }
}