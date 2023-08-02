@isTest
private class gFRS_ApprovalEmailReminderTest {
	
	class TestSettings{
		public EmailTemplate et;
		public GFRS_Funding_Request__c fundingRequest; 
		public String addresses = 'test@test.roche';
		
		GFRS_Organization__c organization;
        Contact contact;
        Account account;
        User user;
        public String PROF_GFRS_USER_NAME = 'GNE-GFRS-User';
        public id PROF_GFRS_USER;
        public  String DEFAULT_STATUS = 'Intake';
        public  String DEFAULT_SUB_STATUS = 'Not Submitted';
		 
		public TestSettings(){
			
			PROF_GFRS_USER = [ select Id, Name, Type from Profile where Name =:PROF_GFRS_USER_NAME limit 1 ].Id;
            account = createAccount('test');
            insert account;
            organization = createOrganization('223344556', account);
            insert organization;
            contact = createContact(account);
            insert contact;
            user = createUser3('Test', 'test', 'aaa@gene.com', PROF_GFRS_USER, '1234');
            insert user;
		}  
		
		public void createFundingRequestWithProgram(){
            this.fundingRequest = createFundingRequest('IMED' , DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', organization.Id, null);
            insert this.fundingRequest;
        }
        public  Account createAccount( String accountName ){
    		return( new Account( Name = accountName ) );
		} 
		public GFRS_Organization__c createOrganization(String taxId, Account account){
		    return( new GFRS_Organization__c(
		        Organization_Name__c = 'test org',
		        Tax_Id__c = taxId,
		        Account__c = account.id
		        
		    ) );
		} 
		public Contact createContact(Account account){
		    return( new Contact(
		            FirstName = 'Test',
		            LastName = 'Test',
		            Email = 'test@test.com',
		            Phone = '555-555-555',
		            AccountID = account.Id
		           ) );
		}
		public  User createUser3( String firstName, String lastName, String email, id profileId, String securityPin ){
		    return( new User(
		        FirstName = firstName,
		        LastName = lastName,
		        username = email,
		        CompanyName = 'Genentech',
		        Email = email,
		        ProfileId = profileId,
		        IsActive=true,
		        Security_PIN__c = securityPin,
		        TimeZoneSidKey = 'America/Los_Angeles',
		        LocaleSidKey = 'en_US',
		        LanguageLocaleKey = 'en_US',
		        EmailEncodingKey = 'UTF-8',
		        External_ID_gne__c = 'qwertyuio'
		   )  );
		}
		public GFRS_Funding_Request__c createFundingRequest(String recordType, String status, String subStatus, String externalSubStatus, String infoNeeded, Id organizationId, Id locationId){
		     RecordType rt = [ SELECT id from RecordType where DeveloperName = :recordType and SobjectType = 'GFRS_Funding_Request__c' ];
		    return( new GFRS_Funding_Request__c(
		        recordTypeId = rt.id,
		        Status__c = status,
		        Sub_Status__c = subStatus,
		        External_Sub_status__c = externalSubStatus,
		        Organization__c = organizationId,
		        Location__c = locationId,
		        Information_Needed__c = infoNeeded,
		        Attention_To__c = 'tuser',
		        Send_By_FedEx_cost_center_will_be_charg__c = 'No'
		    ) );
		}           
	}
	
	static testMethod void sendReminderUnitTest() {		
		gFRS_ApprovalEmailReminder reminderObject = new gFRS_ApprovalEmailReminder();
		reminderObject.execute(null);
    }
/*
    static testMethod void sendReminderUnitTest() {		

		TestSettings ts = new TestSettings();
		//System.RunAs(ts.user){
			ts.createFundingRequestWithProgram();
			ts.fundingRequest = [select Id, Name, Funding_Type__c, Event_Program_Title__c, Record_Type_Name__c, Program_Start_Date_Min__c, Requested_Amount__c from GFRS_Funding_Request__c].get(0);
			
			System.assertNotEquals(ts.fundingRequest, null);  	
			System.assertNotEquals(ts.addresses,null);
			
			Messaging.SingleEmailMessage message = gFRS_ApprovalEmailReminder.sendReminder(ts.fundingRequest, ts.addresses, new EmailTemplate(Body='test', DeveloperName='Test_name', FolderId='00DS0000001CspPMAS', TemplateType='text', Name='test name', IsActive = true, Subject='test'));
		     			
			System.assertNotEquals(message, null);
			System.assertNotEquals(message.getPlainTextBody(), null);	
			System.assertNotEquals(message.getPlainTextBody(), '');
			System.assertNotEquals(message.getSubject(), null);	
			System.assertNotEquals(message.getSubject(), '');	
			System.assertNotEquals(message.getToAddresses(), null);
			System.assertNotEquals(message.getToAddresses().size(), 0);
			System.assertEquals(message.getSaveAsActivity(), false);	
		//}
    }
    
    static testMethod void sendEmailUnitTest() {		

		TestSettings ts = new TestSettings();
			ts.createFundingRequestWithProgram();
			ts.fundingRequest = [select Id, Name, Funding_Type__c, Event_Program_Title__c, Record_Type_Name__c, Program_Start_Date_Min__c, Requested_Amount__c from GFRS_Funding_Request__c].get(0);
			
			System.assertNotEquals(ts.fundingRequest, null);  	
			System.assertNotEquals(ts.addresses,null);
			
			gFRS_ApprovalEmailReminder.sendEmail();

    }
    */
}