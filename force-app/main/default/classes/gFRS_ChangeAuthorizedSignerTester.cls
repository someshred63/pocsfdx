@isTest(SeeAllData=true)

public with sharing class gFRS_ChangeAuthorizedSignerTester {
	public static final String USER_EMAIL = 'test@domain.com';
	public static final String OTHER_EMAIL = 'bad@horrible.com';
	
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
        public GFRS_RequestBudget__c budget;
    	public GFRS_Program__c program;
    	public GFRS_Content__c[] content;
    	public GFRS_Content_Translation__c[] contentTranslations;
    	public Contact myContact;
    	public User myUser;
    	
    	public gFRS_ConfirmController controller;
    	
    	public TestSettings(){
    	}
    	
    	public void setupUser(){
    		//-- initialization done for ALL SETUPs done here
    		//gFRS_TestCreationUtils.initialize();
        	this.userAccount = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
        	insert this.userAccount;
        	
        	this.myContact = gFRS_TestCreationUtils.createContact( this.userAccount );
	    	insert this.myContact;
	    	
	    	Profile extProfile = [select Id, Name from Profile where Name = 'GNE-GFRS-Admin' limit 1];
	    	
	    	this.myUser = gFRS_TestCreationUtils.createUser3('Test', 'test', 'aaa@gene.com', extProfile.Id, '1234');
	    	insert this.myUser;
    	}
    	
    	public void initialSetup(){
    		this.account = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
        	insert this.account;
    		
    		this.organization = gFRS_TestCreationUtils.createInternalOrganization( '20110101', this.account );
    		System.debug('PN: TEST: this.organization: ' + this.organization.RecordType);
        	insert this.organization;
        	
        	this.location = gFRS_TestCreationUtils.createLocation( 'SomeLocation', this.organization.id );
        	insert this.location;
        	
        	this.content = new GFRS_Content__c[]{
        		gFRS_TestCreationUtils.createContent( gFRS_ConfirmController.CONTENT_TYPE, null, gFRS_TestCreationUtils.LANG_EN ),
        		gFRS_TestCreationUtils.createContent( gFRS_ConfirmController.FINAL_DISCLAIMER_KEY, null, gFRS_TestCreationUtils.LANG_EN ),
        		gFRS_TestCreationUtils.createContent( gFRS_ConfirmController.NON_LEGAL_KEY, null, gFRS_TestCreationUtils.LANG_EN )
        	};
        	insert this.content;
        	
        	this.contentTranslations = new GFRS_Content_Translation__c[]{
        		gFRS_TestCreationUtils.createContentTranslation( this.content[0], 'someContent', null, gFRS_TestCreationUtils.LANG_EN ),
        		gFRS_TestCreationUtils.createContentTranslation( this.content[1], 'someContent', null, gFRS_TestCreationUtils.LANG_EN ),
        		gFRS_TestCreationUtils.createContentTranslation( this.content[2], 'someContent', null, gFRS_TestCreationUtils.LANG_EN )
        	};
        	insert this.contentTranslations;
    	}
    	
    	public void setupIMED(){
		   	this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
			this.prepareRequestForUpdate();
			insert this.request;
		}
		public void setupIMEDSubmitted(){
		   	this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
			this.prepareRequestForUpdate();
			this.request.Status__c = 'HC Compliance';
	    	this.request.Sub_Status__c = 'New';
			
			insert this.request;
		}
		public void setupCorporate(){
			this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_CORPORATE_MEMBERSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
			this.prepareRequestForUpdate();
			insert this.request;
		}
		
		public void setupExhibits(){
			this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_EXHIBITS_OTHER_PROMOS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
			this.request.Funding_Sub_Type__c = 'Exhibit Booth';
            this.prepareRequestForUpdate();
			insert this.request;
		}
		
		public void setupFellowships(){
			this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_FELLOWSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
			this.prepareRequestForUpdate();
			insert this.request;
		}
		
		 public void setupField(){
			this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_FIELD_INITIATED_EXHIBITS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
			this.prepareRequestForUpdate();
			insert this.request;
		}
		
		 public void setupHCChar(){
			this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_HC_CHAR, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
			this.prepareRequestForUpdate();
			insert this.request;
		}
		
		 public void setupPhilanthropic(){
			this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_PHILANTHROPIC, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
			this.prepareRequestForUpdate();
			insert this.request;
		}
		
		 public void setupScientific(){
			this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_SCIENTIFIC_PROJECTS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
			this.prepareRequestForUpdate();
			insert this.request;
		}
		
		/** cleanup the fundingRequest to the point that an update can occur **/
		public void prepareRequestForUpdate(){
			//this.request.Name = 'testRequest';
			
		}
    	
    	public void completeRequest(){
    		this.program = gFRS_TestCreationUtils.createProgram_min( 'Live', this.request );
    		insert this.program;
    		
    		this.budget = gFRS_TestCreationUtils.createRequestBudget_min( this.request );
    		insert this.budget;
    	}
    	
    	public void completeRequestWithAttende(){
    		this.program = gFRS_TestCreationUtils.createProgram_min( 'Live', this.request );
    		insert this.program;
    		setupValidImedPrograms(new GFRS_Program__c[] {this.program});
    		
    		this.budget = gFRS_TestCreationUtils.createRequestBudget_min( this.request );
    		insert this.budget;
    	}
    	
    	public void setupController(){
    		ApexPages.PageReference imedPage = new ApexPages.PageReference( '?id=' + this.request.id );
			Test.setCurrentPage( imedPage );
			
	   		this.controller = new gFRS_ConfirmController( new ApexPages.StandardController( this.request ) );
    	}
    	public void setupValidImedPrograms(GFRS_Program__c []  progList){
        	//Map<id,List<GFRS_Program_Audience_Group__c>> mapGroups=new Map<Id,List<GFRS_Program_Audience_Group__c>>([select program__c,Intended_Audience__c, Specialty__c, Category_of_Credit__c, Credit_Hours__c,Number_of_Participants__c,Expected_Learners__c,Expected_Learners_Credit__c  from GFRS_Program_Audience_Group__c where Program__c in : progList]);
        	List<GFRS_Program_Audience_Group__c> groupsToAdd=new List<GFRS_Program_Audience_Group__c>();
        	Schema.DescribeFieldResult audienceField = GFRS_Program_Audience_Group__c.Intended_Audience__c.getDescribe();
        	Schema.DescribeFieldResult categoryField = GFRS_Program_Audience_Group__c.Category_of_Credit__c.getDescribe();
        	Schema.DescribeFieldResult specialtyField = GFRS_Program_Audience_Group__c.Specialty__c.getDescribe();
        	Schema.DescribeFieldResult programSubTypeField=GFRS_Program__c.Program_Subtype__c.getDescribe();
        	Schema.DescribeFieldResult venueStateField=GFRS_Program__c.Venue_State__c.getDescribe();
        	Schema.DescribeFieldResult venueCountryeField=GFRS_Program__c.Venue_Country__c.getDescribe();
        	for(GFRS_Program__c progItem:progList){
        		GFRS_Program_Audience_Group__c itemGroup=new GFRS_Program_Audience_Group__c(Program__c=progItem.id,Intended_Audience__c=audienceField.getPicklistValues()[0].getValue(),Category_of_Credit__c=categoryField.getPicklistValues()[0].getValue(),Specialty__c=specialtyField.getPicklistValues()[0].getValue(),Credit_Hours__c=11,Number_of_Participants__c=11,Expected_Learners__c=11,Expected_Learners_Credit__c=11);
        		groupsToAdd.add(itemGroup);
        		progItem.Start_Date__c=Date.today().addDays(74);
        		progItem.End_Date__c=Date.today().addDays(79);
        		progItem.Program_Subtype__c=programSubTypeField.getPicklistValues()[1].getValue();
        		progItem.Speakers_Faculty__c=12;
        		progItem.Expected_of_Attendees_US_Based_HCPs__c=12;
        		progItem.Expected_Number_of_Attendees__c=12;
        		progItem.Venue_Type__c='12';
        		progItem.Venue_Name__c='dsvdsv';
        		progItem.Venue_City__c='dsvdsvdsv';
        		progItem.Venue_Country__c=venueCountryeField.getPicklistValues()[0].getValue();
        		progItem.Venue_State__c=venueStateField.getPicklistValues()[0].getValue();
        		progItem.Venue_Zip_Code__c='18-210';
        	}
        	update progList;
        	gFRS_Util_NoShare.saveLockedProgramAudience( groupsToAdd);
        }
    }
    
    static testMethod void changeAuthorizedSigner(){
    	TestSettings ts = new TestSettings();
    	ts.setupUser();
    	
    	
	    	ts.initialSetup();
	    	
	    	ts.setupIMEDSubmitted();
	    	ts.completeRequest();
	    	
	    	test.startTest();
	    	gFRS_ChangeAuthorizedSignerController testContoller=new gFRS_ChangeAuthorizedSignerController( new ApexPages.StandardController( ts.request ));
	    	User u =[select email from user limit 1];
	    	testContoller.request.Signing_Authority_Email__c = u.email;
	    	testContoller.request.Signing_Authority_First_Name__c = 'Test';
	    	testContoller.request.Signing_Authority_Last_Name__c = 'Test';
	    	
	    	
	    	testContoller.save();
	    	test.stopTest();
    	
    }
    
    static testMethod void changeAuthorizedSignerNotSubmitted(){
    	TestSettings ts = new TestSettings();
    	ts.setupUser();
    	
    	System.runAs( ts.myUser ){
	    	ts.initialSetup();
	    	
	    	ts.setupIMED();
	    	ts.completeRequest();
	    	
	    	
	    	test.startTest();
	    	gFRS_ChangeAuthorizedSignerController testContoller=new gFRS_ChangeAuthorizedSignerController( new ApexPages.StandardController( ts.request ));
	    	testContoller.request.Signing_Authority_Email__c = OTHER_EMAIL;
	    	testContoller.request.Signing_Authority_First_Name__c = 'Test';
	    	testContoller.request.Signing_Authority_Last_Name__c = 'Test';
	    	testContoller.request.Sub_Status__c = 'Not Submitted';
	    	testContoller.save();
	    	Boolean errorFlag=false;
	    	List<ApexPages.Message> msgList = ApexPages.getMessages();
    		for(ApexPages.Message msg:msgList){
	    		if(msg.getDetail().contains('Authorized Signer cannot be modified after the LOA is signed or before the request is submitted.')){
	    			errorFlag=true;
	    		}
    		}
    		System.assertEquals(true,errorFlag);
	    	test.stopTest();
    	}
    }
    
    
    
    static testMethod void changeAuthorizedSignerLOASigned(){
    	TestSettings ts = new TestSettings();
    	ts.setupUser();
    	
    	System.runAs( ts.myUser ){
	    	ts.initialSetup();
	    	
	    	ts.setupIMED();
	    	ts.completeRequest();
	    	Test.startTest();
	    	
	    	gFRS_ChangeAuthorizedSignerController testContoller=new gFRS_ChangeAuthorizedSignerController( new ApexPages.StandardController( ts.request ));
	    	testContoller.request.Signing_Authority_Email__c = OTHER_EMAIL;
	    	testContoller.request.Signing_Authority_First_Name__c = 'Test';
	    	testContoller.request.Signing_Authority_Last_Name__c = 'Test';
	    	testContoller.request.LOA_Signed__c = 'Yes';
	    	
	    	testContoller.save();
	    	Boolean errorFlag=false;
	    	List<ApexPages.Message> msgList = ApexPages.getMessages();
    		for(ApexPages.Message msg:msgList){
	    		if(msg.getDetail().contains('Authorized Signer cannot be modified after the LOA is signed or before the request is submitted.')){
	    			errorFlag=true;
	    		}
    		}
    		System.assertEquals(true,errorFlag);
	    	test.stopTest();
    	}
    }
    static testMethod void changeAuthorizedSignerEmptyMail(){
    	TestSettings ts = new TestSettings();
    	ts.setupUser();
    	
    	
	    	ts.initialSetup();
	    	
	    	ts.setupIMEDSubmitted();
	    	ts.completeRequest();
	    	
	    	test.startTest();
	    	gFRS_ChangeAuthorizedSignerController testContoller=new gFRS_ChangeAuthorizedSignerController( new ApexPages.StandardController( ts.request ));
	    	testContoller.request.Signing_Authority_Email__c = null;
	    	testContoller.request.Signing_Authority_First_Name__c = 'Test';
	    	testContoller.request.Signing_Authority_Last_Name__c = 'Test';
	    	
	    	
	    	testContoller.save();
	    	test.stopTest();
    	
    }
    static testMethod void changeAuthorizedSignerEmptyRequest(){
    	TestSettings ts = new TestSettings();
    	ts.setupUser();
    	
    	
	    	ts.initialSetup();
	    	
	    	ts.setupIMEDSubmitted();
	    	ts.completeRequest();
	    	
	    	test.startTest();
	    	gFRS_ChangeAuthorizedSignerController testContoller=new gFRS_ChangeAuthorizedSignerController( new ApexPages.StandardController( new GFRS_Funding_Request__c() ));
	    	
	    	test.stopTest();
    	
    }
    
}