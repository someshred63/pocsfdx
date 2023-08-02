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
private class gFRS_CreateAnnualReportTasksBatchTest {

	class TestSettings {
		public Account account;
		public GFRS_Organization__c organization;
	    public GFRS_Location__c location;
	
		public TestSettings() {
	        this.account = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
	        insert this.account;
	        this.organization = gFRS_TestCreationUtils.createOrganization2( '20110101', this.account.id );
	        insert this.organization;
	        this.location = gFRS_TestCreationUtils.createLocation( 'SomeLocation', this.organization.id );
	        insert this.location;
	       	GFRS_Content__c con = gFRS_TestCreationUtils.createContent('Gcal_Header','','');
	       	insert con;
	       	GFRS_Content_Translation__c conTran = gFRS_TestCreationUtils.createContentTranslation(con,'test','','en_US');
	       	insert conTran;
	    }
	    
	    public GFRS_Funding_Request__c prepareAndInsertRequest() {
	    	GFRS_Funding_Request__c req = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_FELLOWSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, 'Approved', gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
	    	req.Foundation_Eligible__c = 'Yes';
	    	req.LOA_Signed__c = 'Yes';
	    	insert req;
	    	return req;
	    }
	    
	    public void prepareAndInsertRequestAndProgram(Integer minYears, Integer maxYears, Integer minDays, Integer maxDays) {
	    	GFRS_Funding_Request__c req = prepareAndInsertRequest();
        	GFRS_Program__c prog = gFRS_TestCreationUtils.createProgram_min(gFRS_Util.PROGRAM_TYPE_LIVE,req);
        	prog.Start_Date__c = Date.today().addYears(minYears).addDays(minDays);
        	prog.End_Date__c = Date.today().addYears(maxYears).addDays(maxDays);
        	insert prog;
	    }
	}
    
    
    static testMethod void programEndToday() {
        //test first condition -> one task
        TestSettings ts = new TestSettings();
       	ts.prepareAndInsertRequestAndProgram(-1,0,0,0);
        Type targettype = Type.forName('gFRS_CreateAnnualReportTasksBatch');

		Test.startTest();
        
        if (targettype != null) {
            Database.Batchable<sObject> obj = (Database.Batchable<sObject>) targettype.NewInstance();
            Database.executeBatch(obj);
        }
		Test.stopTest();
		System.assert([SELECT Id, gFRS_Funding_Request__c FROM gFRS_Tasks__c].size() == 1);
    }
    
    static testMethod void programStartToday() {
        //Today is NOT > FPSD -> no task generated
        TestSettings ts = new TestSettings();
       	ts.prepareAndInsertRequestAndProgram(0,3,0,0);
        Type targettype = Type.forName('gFRS_CreateAnnualReportTasksBatch');

		Test.startTest();
        
        if (targettype != null) {
            Database.Batchable<sObject> obj = (Database.Batchable<sObject>) targettype.NewInstance();
            Database.executeBatch(obj);
        }
		Test.stopTest();
		System.assert([SELECT Id, gFRS_Funding_Request__c FROM gFRS_Tasks__c].size() == 0);
    }
    
    static testMethod void programNotStarted() {
		//program not yet started -> no task
     	TestSettings ts = new TestSettings();
       	ts.prepareAndInsertRequestAndProgram(1,3,0,0);
        
        Type targettype = Type.forName('gFRS_CreateAnnualReportTasksBatch');

		Test.startTest();
		
        if (targettype != null) {
            Database.Batchable<sObject> obj = (Database.Batchable<sObject>) targettype.NewInstance();
            Database.executeBatch(obj);
        }
		Test.stopTest();
		System.assert([SELECT Id, gFRS_Funding_Request__c FROM gFRS_Tasks__c].size() == 0);
    }
    
    static testMethod void programEnded() {
        //past program -> no task
        TestSettings ts = new TestSettings();
       	ts.prepareAndInsertRequestAndProgram(-4,-2,0,0);
        Type targettype = Type.forName('gFRS_CreateAnnualReportTasksBatch');

		Test.startTest();
        
        if (targettype != null) {
            Database.Batchable<sObject> obj = (Database.Batchable<sObject>) targettype.NewInstance();
            Database.executeBatch(obj);
        }
		Test.stopTest();
		System.assert([SELECT Id, gFRS_Funding_Request__c FROM gFRS_Tasks__c].size() == 0);
    }
    
    static testMethod void programRunningAniversary() {        
        //during program, correct day -> one task
		TestSettings ts = new TestSettings();
        ts.prepareAndInsertRequestAndProgram(-1,2,0,0);
        Type targettype = Type.forName('gFRS_CreateAnnualReportTasksBatch');

		Test.startTest();
        
        if (targettype != null) {
            Database.Batchable<sObject> obj = (Database.Batchable<sObject>) targettype.NewInstance();
            Database.executeBatch(obj);
        }        
		Test.stopTest();		        		
		System.assert([SELECT Id, gFRS_Funding_Request__c FROM gFRS_Tasks__c].size() == 1);
    }
    
    static testMethod void programRunningNotAniversary() {        
     	//during program but not on this day -> no task
		TestSettings ts = new TestSettings();
        ts.prepareAndInsertRequestAndProgram(0,1,-50,-50);
        
        Type targettype = Type.forName('gFRS_CreateAnnualReportTasksBatch');

		Test.startTest();
        
        if (targettype != null) {
            Database.Batchable<sObject> obj = (Database.Batchable<sObject>) targettype.NewInstance();
            Database.executeBatch(obj);
        }
		Test.stopTest();        
		System.assert([SELECT Id, gFRS_Funding_Request__c FROM gFRS_Tasks__c].size() == 0);
    }

    static testMethod void ExecuteScheduleBatch_gFRS_AnnualEvalutationTaskCreator(){
        Test.startTest();
        gFRS_AnnualEvalutationTaskCreator abs= new gFRS_AnnualEvalutationTaskCreator();
        abs.execute(null);
        Test.stopTest();
    }

}