/**
* @author ADMD Team
* @date 02/01/2014
* @description gFRS_AttachEmailServiceTester class - Testing Inbund Email Setvice in gfrs application o
*
*/

@isTest

private class gFRS_AttachEmailServiceTester {

	/**
	* @author ADMD Team
	* @date 02/01/2014
	* @description TestSettings class - helper class used to create innitial Fundign Request
	*
	*/
	class TestSettings {
	 	public Account account;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;
        public GFRS_Funding_Request__c request;
        public GFRS_Program__c programs;
        
        public TestSettings(){
         	this.account = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
        	insert this.account;
        	
        	this.organization = gFRS_TestCreationUtils.createOrganization2( '20110101', this.account.id );
        	insert this.organization;
        	
        	this.location = gFRS_TestCreationUtils.createLocation( 'SomeLocation', this.organization.id );
        	insert this.location;
        }
        
        public void setupIMED(String infoNeeded){
           	this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, infoNeeded, this.organization.id, this.location.id );
        	insert this.request;
        	this.request = [select Id, Name, Status__c, Status_Last_Modified_Date__c from GFRS_Funding_Request__c where Id= : this.request.Id];
        	
        }
         
        
	 }
	 
	 /**
	* @author ADMD Team
	* @date 02/01/2014
	* @description testIfEmailWasAttachedUnderFundingRequest class - checking if email would be attached under funding request
	*
	*/
	 @isTest(SeeAllData=true)
	 static  void testIfEmailWasAttachedUnderFundingRequest() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed('Program');
	 	 Messaging.Inboundemail email = new Messaging.Inboundemail();
	 	 Messaging.InboundEnvelope envelop=new Messaging.InboundEnvelope();
	 	 email.subject=ts.request.Name+' Test email service';
	 	 email.plainTextBody='Hello from gfrs test \n\n'+'[ref:'+ts.request.id+']';
	 	 email.fromAddress='hello@gmail.com';
	 	 email.toAddresses=new String[]{'hello1@gmail.com'};
	 	 email.ccAddresses=new String[]{'hello2@gmail.com'};
	 	 test.startTest();
	 	 gFRS_AttachEmailForFundingRequestService service=new gFRS_AttachEmailForFundingRequestService();
	 	 service.handleInboundEmail(email, envelop);
	 	 ts.request = [select (select Name from Attachments) ,Id, Name from GFRS_Funding_Request__c where Id= : ts.request.Id];
	 	 system.assertEquals(ts.request.Attachments.size()>0,true,'request should be attached under email');
	 	 
	 	 test.stopTest();
	 	 
	 	 
	 	 
	 }
	 
	 
}