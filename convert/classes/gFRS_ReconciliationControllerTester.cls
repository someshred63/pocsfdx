@isTest
private class gFRS_ReconciliationControllerTester {
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
	
	 
    
     static testMethod void testReconciliationControlleruploadFinalHandoutWebScreenshotandUploadOtherProgramMaterials() {
	 	 TestSettings ts = new TestSettings();
	 	 
	 	 ts.setupImed();
	 	 
	 	 gFRS_ReconciliationController cont = new gFRS_ReconciliationController(new ApexPages.StandardController(new GFRS_Funding_Request__c()));
	 	 cont = new gFRS_ReconciliationController(new ApexPages.StandardController(ts.request));
	 	 cont.savePage();
	 	 
	 	 Test.startTest();
	 	 ts.request.Refund_Request_Date__c = date.newInstance(2011, 12, 12);
	 	 ts.request.Approved_Amount__c = 200;
	 	 ts.request.Total_Amount_Used__c = 200;
	 	 Blob b=Blob.valueOf('test');
	 	 update ts.request;
	 	 //Upload with errror no names for attachments
	 	 
	 	 cont = new gFRS_ReconciliationController(new ApexPages.StandardController(ts.request));
	 	 cont.savePage();
	 	 cont.closePage();
	 	 Test.stopTest();
	 	 
     }
     
     static testMethod void testReconciliationControlleErrorEmptyAgenda() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed();
	 	 
	 	 ts.request.Refund_Request_Date__c = date.newInstance(2011, 12, 12);
	 	 ts.request.Approved_Amount__c = 200;
	 	 ts.request.Total_Amount_Used__c = 200;
	 	 
	 	 update ts.request;
	 	 Test.startTest();
	 	 gFRS_ReconciliationController cont = new gFRS_ReconciliationController(new ApexPages.StandardController(ts.request));
	 	 String [] ar=cont.topFieldSet;
	 	 cont.savePage();
	 	 cont.closePage();
	 	 cont.isSubmited=true;
	 	 cont.savePage();
	 	 Test.stopTest();
	 	 
     }
     static testMethod void testReconciliationControlleErrorEmptyAttachments() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed();
	 	 
	 	 ts.request.Refund_Request_Date__c = date.newInstance(2011, 12, 12);
	 	 ts.request.Approved_Amount__c = 200;
	 	 ts.request.Total_Amount_Used__c = 200;
	 	 
	 	 update ts.request;
	 	 Test.startTest();
	 	 gFRS_ReconciliationController cont = new gFRS_ReconciliationController(new ApexPages.StandardController(ts.request));
	 	 String [] ar=cont.topFieldSet;
	 	  Blob b=Blob.valueOf('test');
	 	 update ts.request;
	 	 cont.savePage();
	 	 cont.closePage();
	 	 cont.isSubmited=true;
	 	 cont.savePage();
	 	 Test.stopTest();
	 	 
     }
     static testMethod void testReconciliationControlleErrorEmptyProgramMaterials() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed();
	 	 
	 	 ts.request.Refund_Request_Date__c = date.newInstance(2011, 12, 12);
	 	 ts.request.Approved_Amount__c = 200;
	 	 ts.request.Total_Amount_Used__c = 200;
	 	 
	 	 update ts.request;
	 	 
	 	 gFRS_ReconciliationController cont = new gFRS_ReconciliationController(new ApexPages.StandardController(ts.request));
	 	 String [] ar=cont.topFieldSet;
	 	  Blob b=Blob.valueOf('test');
	 	 update ts.request;
	 	 Test.startTest();
	 	 cont.savePage();
	 	 cont.closePage();
	 	 cont.isSubmited=true;
	 	 cont.savePage();
	 	 Test.stopTest();
	 	 
     }
     
     static testMethod void testReconciliationControlleErrorEmptyFinalHandout() {
	 	 TestSettings ts = new TestSettings();
	 	 
	 	 ts.setupImed();
	 	 
	 	 ts.request.Refund_Request_Date__c = date.newInstance(2011, 12, 12);
	 	 ts.request.Approved_Amount__c = 200;
	 	 ts.request.Total_Amount_Used__c = 200;
	 	 
	 	 update ts.request;
	 	 
	 	 gFRS_ReconciliationController cont = new gFRS_ReconciliationController(new ApexPages.StandardController(ts.request));
	 	 String [] ar=cont.topFieldSet;
	 	 Blob b=Blob.valueOf('test');
	 	 update ts.request;
	 	 Test.startTest();
	 	 cont.savePage();
	 	 cont.closePage();
	 	 cont.isSubmited=true;
	 	 cont.savePage();
	 	 Test.stopTest();
	 	 
     }
     static testMethod void testReconciliationControlleErrortotalAmountUsedGTApprovedAmount() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed();
	 	 
	 	 ts.request.Refund_Request_Date__c = date.newInstance(2011, 12, 12);
	 	 ts.request.Approved_Amount__c = 200;
	 	 ts.request.Total_Amount_Used__c = 300;
	 	 
	 	 update ts.request;
	 	 Test.startTest();
	 	 gFRS_ReconciliationController cont = new gFRS_ReconciliationController(new ApexPages.StandardController(ts.request));
	 	 String [] ar=cont.topFieldSet;
	 	 cont.savePage();
	 	 cont.closePage();
	 	 Test.stopTest();
	 	 
     }
     static testMethod void testReconciliationControlleErrortotalAmountUsedLTZero() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed();
	 	 
	 	 ts.request.Refund_Request_Date__c = date.newInstance(2011, 12, 12);
	 	 ts.request.Approved_Amount__c = 200;
	 	 ts.request.Total_Amount_Used__c = -300;
         	 	 
         
	 	 update ts.request;
	 	 Test.startTest();
	 	 gFRS_ReconciliationController cont = new gFRS_ReconciliationController(new ApexPages.StandardController(ts.request));
	 	 cont.savePage();
	 	 cont.closePage();
         
	 	 Test.stopTest();
	 	 
     }
     static testMethod void testReconciliationControlleErrortotalAmountUsedLTZero1() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed();
	 	 
	 	 ts.request.Refund_Request_Date__c = date.newInstance(2011, 12, 12);
	 	 ts.request.Approved_Amount__c = 200;
	 	 ts.request.Total_Amount_Used__c = -300;
         	 	 
         
	 	 update ts.request;
	 	 Test.startTest();
	 	 gFRS_ReconciliationController cont = new gFRS_ReconciliationController(new ApexPages.StandardController(ts.request));
         
	 	 cont.savePage();
         cont.request.Funds_Used_To_Provide_Meals__c = 'Yes';
            
	 	 cont.closePage();
         
	 	 Test.stopTest();
	 	 
     }
}