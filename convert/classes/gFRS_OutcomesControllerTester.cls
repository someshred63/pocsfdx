@isTest
private class gFRS_OutcomesControllerTester {
	class TestSettings {
	 	public Account account;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;
        public GFRS_Funding_Request__c request;
        public GFRS_Program__c[] programs;

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
	    }
	}
	
	 
    
     static testMethod void testOutcomesController() {
	 	 
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed();
	 	 
	 	 gFRS_OutcomesController cont = new gFRS_OutcomesController(new ApexPages.StandardController(new GFRS_Funding_Request__c()));
	 	 cont = new gFRS_OutcomesController(new ApexPages.StandardController(ts.request));
	 	 
	 	 cont.selectedProgramId = Id.valueOf('01pS00000001qRG');
	 	 cont.saveProgram();
	 	  
	 	 cont.selectedProgramId = ts.programs[0].id;
	 	 cont.saveProgram();
	 	 cont.back();
	 	 
	 	
     }
    
    static testMethod void testUploads5() {
     	 TestSettings ts = new TestSettings();
	 	 ts.setupImed();
         
	 	 test.startTest();
	 	 gFRS_OutcomesController cont = new gFRS_OutcomesController(new ApexPages.StandardController(ts.request));
	 	 
	 	 cont.outcomesreportid.Name = 'test';
	 	 cont.outcomesreportid.Body = Blob.valueOf('test');
	 	 cont.competenciesid.Name = 'test';
	 	 cont.competenciesid.Body = Blob.valueOf('test');
	 	 
	 	 
	 	 //cont.uploadPatientCare();
	 	 cont.uploadOutcomesReport();
	 	 cont.uploadCompetenciesReport();
	 	 
	 	 test.stopTest();
	 	 
     }
    
    static testMethod void testUploads6() {
     	 TestSettings ts = new TestSettings();
	 	 ts.setupImed();
         
	 	 test.startTest();
	 	 gFRS_OutcomesController cont = new gFRS_OutcomesController(new ApexPages.StandardController(ts.request));
	 	 
	 	 cont.attachmentSummaryOfResearchResult.Name = 'test';
	 	 cont.attachmentSummaryOfResearchResult.Body = Blob.valueOf('test');
	 	 
	 	 cont.uploadSummaryOfResearchResult();
	 	 //cont.uploadCompetenciesReport();
	 	 
	 	 test.stopTest();
	 	 
     }
}