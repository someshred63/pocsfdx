@isTest(SeeAllData=true)
private class gFRS_ProgramControllerTester {
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
        	
        	gFRS_UnitTestHelper.setGfrsCustomSettings(true);
        }
        
        public void setupIMED(String infoNeeded){
           	this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, infoNeeded, this.organization.id, this.location.id );
        	insert this.request;
        	this.request = [select Id, Name, Status__c, Status_Last_Modified_Date__c from GFRS_Funding_Request__c where Id= : this.request.Id];
        	
        }
        
        public void setupCorporate(String infoNeeded){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_CORPORATE_MEMBERSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, infoNeeded, this.organization.id, this.location.id );
        	insert this.request;
        	this.request = [select Id, Name, Status__c, Status_Last_Modified_Date__c from GFRS_Funding_Request__c where Id= : this.request.Id];
        }
        public void setupNotImedProgram(GFRS_Program__c []  progList){
        	for(GFRS_Program__c progItem:progList){
        		progItem.Start_Date__c=Date.today().addDays(74);
        		progItem.End_Date__c=Date.today().addDays(79);
        		progItem.Is_CMEO__c=true;
        	}
        	update progList;
        }
        public void setupNotImedProgramWithEmptyType(GFRS_Program__c []  progList){
        	for(GFRS_Program__c progItem:progList){
        		progItem.Start_Date__c=Date.today().addDays(74);
        		progItem.End_Date__c=Date.today().addDays(79);
        		progItem.Is_CMEO__c=true;
        		progItem.Type__c=null;
        	}
        	update progList;
        }
        
        public void setupHCCharProgram(GFRS_Program__c []  progList,string progType){
        	for(GFRS_Program__c progItem:progList){
        		progItem.Type__c=progType;
        		progItem.Expected_Number_of_Attendees__c=1;
        		progItem.Expected_of_attendees_that_are_HCPs__c=1;
        		progItem.Venue_Name__c='Test Name';
        		progItem.Venue_City__c='Warsaw';
        		progItem.Venue_State__c='AK';
        		progItem.Venue_Zip_Code__c='12-18';
        		progItem.Venue_Country__c='Poland';
        		progItem.Benefits_Exchanged_for_Funding__c='Entry into the event';
        		progItem.Exhibits_or_Displays_Allowed__c='Yes';
        		progItem.Other_Commercial_Supporters__c='No';
        		progItem.If_Known_List_Other_Supporters__c='some description';
        		progItem.Start_Date__c=Date.today().addDays(74);
        		progItem.End_Date__c=Date.today().addDays(79);
        		progItem.Program_Title__c='Some title';
        		
        		Attachment tmp = new Attachment();
        		tmp.body=Blob.valueOf('test');
        		tmp.name='Test.txt';
        		tmp.parentId=progItem.id;
        		insert tmp;
        		progItem.Promotional_Event_Advertising__c=tmp.id;
        		progItem.Meeting_Agenda__c=tmp.id;
        		progItem.Additional_Document_Uploads__c=tmp.id;
        		progItem.Additional_Document_Uploads_2__c=tmp.id;
        		progItem.Additional_Document_Uploads_3__c=tmp.id;
        		progItem.Additional_Document_Uploads_4__c=tmp.id;
        		progItem.Additional_Document_Uploads_5__c=tmp.id;
        		
        		
        		//progItem.Is_CMEO__c=true;
        	}
        	update progList;
        }
        public void setupExhibits(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_EXHIBITS_OTHER_PROMOS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
        	this.request.Funding_Sub_Type__c = 'Exhibit Booth';
            insert this.request;
        	this.request = [select Id, Name, Status__c, Status_Last_Modified_Date__c from GFRS_Funding_Request__c where Id= : this.request.Id];
        }
        public void setupFellowships(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_FELLOWSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
        	insert this.request;
        	this.request = [select Id, Name, Status__c, Status_Last_Modified_Date__c from GFRS_Funding_Request__c where Id= : this.request.Id];
        }
        
        public void setupField(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_FIELD_INITIATED_EXHIBITS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
        	insert this.request;
        	this.request = [select Id, Name, Status__c, Status_Last_Modified_Date__c from GFRS_Funding_Request__c where Id= : this.request.Id];
        }
        
        public void setupHCChar(String infoNeeded){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_HC_CHAR, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, infoNeeded, this.organization.id, this.location.id );
        	insert this.request;
        	this.request = [select Id, Name, Status__c, Status_Last_Modified_Date__c from GFRS_Funding_Request__c where Id= : this.request.Id];
        }
        
        public void setupHCCharCustom(String infoNeeded,String EventProgramType){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_HC_CHAR, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, infoNeeded, this.organization.id, this.location.id );
            this.request.Event_Project_type__c=EventProgramType;
        	insert this.request;
        	this.request = [select Id,RecordTypeId,Sub_Status__c,Event_Project_sub_type__c,External_Sub_status__c,Organization__c,Attention_To__c,Information_Needed__c,Send_By_FedEx_cost_center_will_be_charg__c,Status__c,Location__c,Record_Type_Name__c,Event_Project_type__c from GFRS_Funding_Request__c where Id= : this.request.Id];
        }
        
        public void setupPhilanthropic(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_PHILANTHROPIC, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
        	insert this.request;
        	this.request = [select Id, Name, Status__c, Status_Last_Modified_Date__c from GFRS_Funding_Request__c where Id= : this.request.Id];
        }
        
        public void setupScientific(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_SCIENTIFIC_PROJECTS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
        	insert this.request;
        	this.request = [select Id, Name, Status__c, Status_Last_Modified_Date__c from GFRS_Funding_Request__c where Id= : this.request.Id];
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
        public void setupImedwithOutStartDate (GFRS_Program__c []  progList){
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
        		//progItem.Start_Date__c=Date.today().addDays(74);
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
        public void setupImedwithOutEndDate (GFRS_Program__c []  progList){
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
        		//progItem.End_Date__c=Date.today().addDays(79);
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
        public void setupImedwithOutAudienceGroupFields(GFRS_Program__c []  progList){
        	//Map<id,List<GFRS_Program_Audience_Group__c>> mapGroups=new Map<Id,List<GFRS_Program_Audience_Group__c>>([select program__c,Intended_Audience__c, Specialty__c, Category_of_Credit__c, Credit_Hours__c,Number_of_Participants__c,Expected_Learners__c,Expected_Learners_Credit__c  from GFRS_Program_Audience_Group__c where Program__c in : progList]);
        	List<GFRS_Program_Audience_Group__c> groupsToAdd=new List<GFRS_Program_Audience_Group__c>();
        	Schema.DescribeFieldResult audienceField = GFRS_Program_Audience_Group__c.Intended_Audience__c.getDescribe();
        	Schema.DescribeFieldResult categoryField = GFRS_Program_Audience_Group__c.Category_of_Credit__c.getDescribe();
        	Schema.DescribeFieldResult specialtyField = GFRS_Program_Audience_Group__c.Specialty__c.getDescribe();
        	Schema.DescribeFieldResult programSubTypeField=GFRS_Program__c.Program_Subtype__c.getDescribe();
        	Schema.DescribeFieldResult venueStateField=GFRS_Program__c.Venue_State__c.getDescribe();
        	Schema.DescribeFieldResult venueCountryeField=GFRS_Program__c.Venue_Country__c.getDescribe();
        	for(GFRS_Program__c progItem:progList){
        		GFRS_Program_Audience_Group__c itemGroup=new GFRS_Program_Audience_Group__c(Program__c=progItem.id);
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
         public void setupImedwithOutAudienceGroup(GFRS_Program__c []  progList){
        	//Map<id,List<GFRS_Program_Audience_Group__c>> mapGroups=new Map<Id,List<GFRS_Program_Audience_Group__c>>([select program__c,Intended_Audience__c, Specialty__c, Category_of_Credit__c, Credit_Hours__c,Number_of_Participants__c,Expected_Learners__c,Expected_Learners_Credit__c  from GFRS_Program_Audience_Group__c where Program__c in : progList]);
        	List<GFRS_Program_Audience_Group__c> groupsToAdd=new List<GFRS_Program_Audience_Group__c>();
        	Schema.DescribeFieldResult audienceField = GFRS_Program_Audience_Group__c.Intended_Audience__c.getDescribe();
        	Schema.DescribeFieldResult categoryField = GFRS_Program_Audience_Group__c.Category_of_Credit__c.getDescribe();
        	Schema.DescribeFieldResult specialtyField = GFRS_Program_Audience_Group__c.Specialty__c.getDescribe();
        	Schema.DescribeFieldResult programSubTypeField=GFRS_Program__c.Program_Subtype__c.getDescribe();
        	Schema.DescribeFieldResult venueStateField=GFRS_Program__c.Venue_State__c.getDescribe();
        	Schema.DescribeFieldResult venueCountryeField=GFRS_Program__c.Venue_Country__c.getDescribe();
        	for(GFRS_Program__c progItem:progList){
        		//GFRS_Program_Audience_Group__c itemGroup=new GFRS_Program_Audience_Group__c(Program__c=progItem.id);
        		//groupsToAdd.add(itemGroup);
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
        	//gFRS_Util_NoShare.saveLockedProgramAudience( groupsToAdd);
        }
        
	 }
	 
	 static testMethod void testProgramControllerConstructorForNewIMEDTestSaveProgramFailure() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed('Program');
	 	 
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 test.startTest();
	 	 System.assertEquals(ts.request.Id,cont.request.Id);
	 	 System.assertNotEquals(null, cont.request.Record_Type_name__c);
	 	 System.assertEquals(gFRS_TestCreationUtils.RT_FR_IMED_NAME, cont.recordTypeName);
	 	 System.assertEquals(true, cont.isEditable);
	 	 System.assertEquals(1, cont.programs.size());
	 	 System.assertNotEquals(null, cont.categoryOfCreditOptions);
	 	 System.assertNotEquals(null, cont.intendedAudienceOptions);
	 	 System.assertNotEquals(null, cont.specialtyOptions);
	 	 System.assertEquals(true, cont.areMultipleAllowed);
	 	 //System.assertNotEquals(null, cont.testAttachment);
	 	 System.assertEquals(true, cont.showPleaseNoteMessage);
	 	 ts.setupValidImedPrograms(cont.programs);
	 	 cont.saveProgram();
	 	 system.assertEquals(true, cont.hasMessages);
	 	 test.stopTest();
	 	 
	 }
	 static testMethod void testProgramControllerConstructorForNewIMEDTestSaveProgramSuccess() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed('Program');
	 	 
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 test.startTest();
	 	 System.assertEquals(ts.request.Id,cont.request.Id);
	 	 System.assertNotEquals(null, cont.request.Record_Type_name__c);
	 	 System.assertEquals(gFRS_TestCreationUtils.RT_FR_IMED_NAME, cont.recordTypeName);
	 	 System.assertEquals(true, cont.isEditable);
	 	 System.assertEquals(1, cont.programs.size());
	 	 System.assertNotEquals(null, cont.categoryOfCreditOptions);
	 	 System.assertNotEquals(null, cont.intendedAudienceOptions);
	 	 System.assertNotEquals(null, cont.specialtyOptions);
	 	 System.assertEquals(true, cont.areMultipleAllowed);
	 	 //System.assertNotEquals(null, cont.testAttachment);
	 	 System.assertEquals(true, cont.showPleaseNoteMessage);
	 	 ts.setupValidImedPrograms(cont.programs);
	 	 cont.selectedProgramId=string.valueOf(cont.programs[0].id);
	 	 cont.saveProgram();
	 	 system.assertEquals(false, cont.hasMessages);
	 	 cont.addProgram();
	 	 test.stopTest();
	 	 
	 }
	 
	  static testMethod void testProgramControllerConstructorForNewIMEDTestSaveProgramSuccessWeb() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed('Program');
	 	 
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 test.startTest();
	 	 System.assertEquals(ts.request.Id,cont.request.Id);
	 	 System.assertNotEquals(null, cont.request.Record_Type_name__c);
	 	 System.assertEquals(gFRS_TestCreationUtils.RT_FR_IMED_NAME, cont.recordTypeName);
	 	 System.assertEquals(true, cont.isEditable);
	 	 System.assertEquals(1, cont.programs.size());
	 	 System.assertNotEquals(null, cont.categoryOfCreditOptions);
	 	 System.assertNotEquals(null, cont.intendedAudienceOptions);
	 	 System.assertNotEquals(null, cont.specialtyOptions);
	 	 System.assertEquals(true, cont.areMultipleAllowed);
	 	 //System.assertNotEquals(null, cont.testAttachment);
	 	 System.assertEquals(true, cont.showPleaseNoteMessage);
	 	 cont.programs[0].TYPE__c=gFRS_ProgramController.TYPE_WEB;
	 	 cont.programs[0].Web_URL__c='www.sampleUrl.com';
	 	 ts.setupValidImedPrograms(cont.programs);
	 	 cont.selectedProgramId=string.valueOf(cont.programs[0].id);
	 	 cont.saveProgram();
	 	 system.assertEquals(false, cont.hasMessages);
	 	 test.stopTest();
	 	 
	 }
	 
	 static testMethod void testProgramControllerConstructorForNewIMEDTestSaveProgramSuccessLiveGroundRounds() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed('Program');
	 	 
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 test.startTest();
	 	 System.assertEquals(ts.request.Id,cont.request.Id);
	 	 System.assertNotEquals(null, cont.request.Record_Type_name__c);
	 	 System.assertEquals(gFRS_TestCreationUtils.RT_FR_IMED_NAME, cont.recordTypeName);
	 	 System.assertEquals(true, cont.isEditable);
	 	 System.assertEquals(1, cont.programs.size());
	 	 System.assertNotEquals(null, cont.categoryOfCreditOptions);
	 	 System.assertNotEquals(null, cont.intendedAudienceOptions);
	 	 System.assertNotEquals(null, cont.specialtyOptions);
	 	 System.assertEquals(true, cont.areMultipleAllowed);
	 	 //System.assertNotEquals(null, cont.testAttachment);
	 	 System.assertEquals(true, cont.showPleaseNoteMessage);
	 	 cont.programs[0].TYPE__c=gFRS_ProgramController.TYPE_LIVE;
	 	 cont.programs[0].Program_Subtype__c=gFRS_ProgramController.SUB_TYPE_GRAND_ROUNDS;
	 	 ts.setupValidImedPrograms(cont.programs);
	 	 cont.selectedProgramId=string.valueOf(cont.programs[0].id);
	 	 cont.saveProgram();
	 	 system.assertEquals(false, cont.hasMessages);
	 	 test.stopTest();
	 	 
	 }
	 
	 static testMethod void testProgramControllerConstructorForNewIMEDTestSaveProgramSuccessLiveMeetingSeries() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed('Program');
	 	 
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 test.startTest();
	 	 System.assertEquals(ts.request.Id,cont.request.Id);
	 	 System.assertNotEquals(null, cont.request.Record_Type_name__c);
	 	 System.assertEquals(gFRS_TestCreationUtils.RT_FR_IMED_NAME, cont.recordTypeName);
	 	 System.assertEquals(true, cont.isEditable);
	 	 System.assertEquals(1, cont.programs.size());
	 	 System.assertNotEquals(null, cont.categoryOfCreditOptions);
	 	 System.assertNotEquals(null, cont.intendedAudienceOptions);
	 	 System.assertNotEquals(null, cont.specialtyOptions);
	 	 System.assertEquals(true, cont.areMultipleAllowed);
	 	 //System.assertNotEquals(null, cont.testAttachment);
	 	 System.assertEquals(true, cont.showPleaseNoteMessage);
	 	 cont.programs[0].TYPE__c=gFRS_ProgramController.TYPE_LIVE;
	 	 cont.programs[0].Program_Subtype__c=gFRS_ProgramController.SUB_TYPE_MEETING_SERIES;
	 	 ts.setupValidImedPrograms(cont.programs);
	 	 cont.selectedProgramId=string.valueOf(cont.programs[0].id);
	 	 cont.saveProgram();
	 	 system.assertEquals(false, cont.hasMessages);
	 	 test.stopTest();
	 	 
	 }
	 
	 static testMethod void testProgramControllerConstructorForNewIMEDTestSaveProgramFailLiveMeetingSeriesForUS() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed('Program');
	 	 
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 test.startTest();
	 	 System.assertEquals(ts.request.Id,cont.request.Id);
	 	 System.assertNotEquals(null, cont.request.Record_Type_name__c);
	 	 System.assertEquals(gFRS_TestCreationUtils.RT_FR_IMED_NAME, cont.recordTypeName);
	 	 System.assertEquals(true, cont.isEditable);
	 	 System.assertEquals(1, cont.programs.size());
	 	 System.assertNotEquals(null, cont.categoryOfCreditOptions);
	 	 System.assertNotEquals(null, cont.intendedAudienceOptions);
	 	 System.assertNotEquals(null, cont.specialtyOptions);
	 	 System.assertEquals(true, cont.areMultipleAllowed);
	 	 //System.assertNotEquals(null, cont.testAttachment);
	 	 System.assertEquals(true, cont.showPleaseNoteMessage);
	 	 cont.programs[0].TYPE__c=gFRS_ProgramController.TYPE_LIVE;
	 	 cont.programs[0].Program_Subtype__c=gFRS_ProgramController.SUB_TYPE_MEETING_SERIES;
	 	 ts.setupValidImedPrograms(cont.programs);
	 	 cont.programs[0].Venue_Country__c='United States';
	 	 cont.programs[0].Venue_State__c=null;
	 	 update cont.programs[0];
	 	 cont.selectedProgramId=string.valueOf(cont.programs[0].id);
	 	 cont.saveProgram();
	 	 system.assertEquals(true, cont.hasMessages,System.Label.gFRS_ERROR_SpecifyVenueState);
	 	 test.stopTest();
	 	 
	 }
	 
	 static testMethod void testProgramControllerConstructorForNewIMEDTestSaveProgramFailLiveMeetingSeriesForNonUS() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed('Program');
	 	 
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 test.startTest();
	 	 System.assertEquals(ts.request.Id,cont.request.Id);
	 	 System.assertNotEquals(null, cont.request.Record_Type_name__c);
	 	 System.assertEquals(gFRS_TestCreationUtils.RT_FR_IMED_NAME, cont.recordTypeName);
	 	 System.assertEquals(true, cont.isEditable);
	 	 System.assertEquals(1, cont.programs.size());
	 	 System.assertNotEquals(null, cont.categoryOfCreditOptions);
	 	 System.assertNotEquals(null, cont.intendedAudienceOptions);
	 	 System.assertNotEquals(null, cont.specialtyOptions);
	 	 System.assertEquals(true, cont.areMultipleAllowed);
	 	 //System.assertNotEquals(null, cont.testAttachment);
	 	 System.assertEquals(true, cont.showPleaseNoteMessage);
	 	 cont.programs[0].TYPE__c=gFRS_ProgramController.TYPE_LIVE;
	 	 cont.programs[0].Program_Subtype__c=gFRS_ProgramController.SUB_TYPE_MEETING_SERIES;
	 	 ts.setupValidImedPrograms(cont.programs);
	 	 cont.programs[0].Venue_Country__c='Afganistan';
	 	 cont.programs[0].Venue_Province_Region__c=null;
	 	 update cont.programs[0];
	 	 cont.selectedProgramId=string.valueOf(cont.programs[0].id);
	 	 cont.saveProgram();
	 	 system.assertEquals(true, cont.hasMessages,System.Label.gFRS_ERROR_SpecifyProvinceRegion);
	 	 test.stopTest();
	 	 
	 }
	 
	 static testMethod void testProgramControllerConstructorForNewIMEDFails() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed('Program');
	 	 ts.request=new GFRS_Funding_Request__c();
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.assertEquals(true, cont.hasMessages);
	 	 test.stopTest();
	 	 
	 }
	 static testMethod void testProgramControllerConstructorForNewIMEDEmptyStartDate() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed('Program');
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 ts.setupImedwithOutStartDate(cont.programs);
	 	  System.assertEquals(false,cont.validateSave(cont.programs),'Checking if validation on start Date work correctly');
	 	 //ApexPages.PageReference resultPage = cont.saveProgram();
	 	 //System.assertEquals(null, resultPage, 'Checking if validation on start Date work correctly');
	 	 test.stopTest();
	 }
	 static testMethod void testProgramControllerConstructorForNewIMEDEmptyEndDate() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed('Program');
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 ts.setupImedwithOutEndDate(cont.programs);
	 	 //ApexPages.PageReference resultPage = cont.saveProgram();
	 	 System.assertEquals(false,cont.validateSave(cont.programs),'Checking if validation on end Date work correctly');
	 	 test.stopTest();
	 }
	 static testMethod void testProgramControllerConstructorForNewIMEDEmptyAudienceGroupFields() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed('Program');
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 ts.setupImedwithOutAudienceGroupFields(cont.programs);
	 	// ApexPages.PageReference resultPage = cont.saveProgram();
	 	 System.assertEquals(false,cont.validateSave(cont.programs),'Checking if validation on AudienceGroup Date work correctly');
	 	 test.stopTest();
	 }

	  static testMethod void testProgramControllerConstructorForNewIMEDEmptyAudienceGroup() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed('Program');
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 ts.setupImedwithOutAudienceGroup(cont.programs);
	 	// ApexPages.PageReference resultPage = cont.saveProgram();
	 	 System.assertEquals(false,cont.validateSave(cont.programs),'Checking if validation on AudienceGroup Date work correctly');
	 	 test.stopTest();
	 }
	 static testMethod void testProgramControllerConstructorForNewCorporateValidationCheck() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupCorporate('Program');
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 ts.setupNotImedProgram(cont.programs);
	 	 
	 	 System.assertEquals(false,cont.validateSave(cont.programs),'Checking if validation  work correctly');
	 	 System.assertEquals(cont.programDetailsTitle==gFRS_ProgramController.CORP_MEM_PROGRAM_TITLE,true,'Check if return correct program title');
	 	 test.stopTest();
	 }
	 static testMethod void testProgramControllerConstructorForNewExhibitsValidationCheck() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupExhibits();
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 ts.setupNotImedProgram(cont.programs);
	 	 
	 	 System.assertEquals(false,cont.validateSave(cont.programs), 'Checking if validation  work correctly');
	 	 test.stopTest();
	 }
	 static testMethod void testProgramControllerConstructorForNewFellowshipsValidationCheck() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupFellowships();
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 ts.setupNotImedProgram(cont.programs);
	 	 
	 	System.assertEquals(true,cont.validateSave(cont.programs),'Checking if validation  work correctly');
	 	 test.stopTest();
	 }
	 static testMethod void testProgramControllerConstructorForNewFieldValidationCheck() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupField();
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 ts.setupNotImedProgram(cont.programs);
	 	 
	 	 System.assertEquals(false,cont.validateSave(cont.programs),'Checking if validation  work correctly');
	 	 System.assertEquals(cont.programDetailsTitle==gFRS_ProgramController.FIELD_EXHIB_PROGRAM_TITLE,true,'Check if return correct program title');
	 	 test.stopTest();
	 }
	 
	 static testMethod void testProgramControllerConstructorForNewPhilanthropicValidationCheck() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupPhilanthropic();
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 ts.setupNotImedProgram(cont.programs);
	 	 
	 	 System.assertEquals(true,cont.validateSave(cont.programs),'Checking if validation  work correctly');
	 	 test.stopTest();
	 }
	 
	 
	 static testMethod void testProgramControllerConstructorForHCCHar() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupHCCharCustom('Program','Patient and General Disease Education');
	 	 
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 System.assertEquals(ts.request.Id,cont.request.Id);
	 	 System.assertNotEquals(null, cont.request.Record_Type_name__c);
	 	 System.assertEquals(gFRS_Util.TYPE_HC_CHAR_NAME, cont.recordTypeName);
	 	 System.assertEquals(true, cont.isEditable);
	 	 System.assertEquals(1, cont.programs.size());
	 	 System.assertNotEquals(null, cont.categoryOfCreditOptions);
	 	 System.assertNotEquals(null, cont.intendedAudienceOptions);
	 	 System.assertNotEquals(null, cont.specialtyOptions);
	 	 System.assertEquals(true, cont.areMultipleAllowed);
	 	 //System.assertNotEquals(null, cont.testAttachment);
	 	 System.assertEquals(true, cont.showPleaseNoteMessage);
	 	
	 }
	 
	 static testMethod void testProgramControllerConstructorForCorporate() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupCorporate('');
	 	 
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 System.assertEquals(ts.request.Id,cont.request.Id);
	 	 System.assertNotEquals(null, cont.request.Record_Type_name__c);
	 	 System.assertEquals(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME, cont.recordTypeName);
	 	 System.assertEquals(false, cont.isEditable);
	 	 System.assertEquals(1, cont.programs.size());
	 	 System.assertNotEquals(null, cont.categoryOfCreditOptions);
	 	 System.assertNotEquals(null, cont.intendedAudienceOptions);
	 	 System.assertNotEquals(null, cont.specialtyOptions);
	 	 System.assertEquals(false, cont.areMultipleAllowed);
	 	 //System.assertNotEquals(null, cont.testAttachment);
	 	 System.assertEquals(false, cont.showPleaseNoteMessage);
	 	
	 }
	 
	 /*static testMethod void testBackNext() {
	 	TestSettings ts = new TestSettings();
	 	ts.setupImed('Program');
	 	gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	ApexPages.PageReference resultPage =  cont.next();
	 	System.assertEquals(resultPage.getUrl(),  new ApexPages.PageReference(gFRS_Util.initializeLink( gFRS_ProgramController.PATH_COMPLETE, ts.request, '' )).getUrl());
	 	resultPage =  cont.back();
	 	System.assertEquals(resultPage.getUrl(),  new ApexPages.PageReference(gFRS_Util.initializeLink( gFRS_ProgramController.PATH_BACK, ts.request, '' )).getUrl());
	 }
	 */
	 
	 static testMethod void testProgramControllerConstructorForNewHC() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupHCCharCustom('Program','Patient and General Disease Education');
	 	 system.debug('check program');
	 	 system.debug(ts.request);
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.debug(cont.programs.size());
	 	 //ts.setupNotImedProgram(cont.programs);
	 	 
	 	 //System.assertEquals(false,cont.validateSave(cont.programs),'Checking if validation  work correctly');
	 	 test.stopTest();
	 }
	
	 
	 /**
    * @author ADMD Team
    * @date 15/04/2013
    * @description testProgramControllerNewHCPatientEducation method - test if Event / program type is set on Patient and General Disease Education ,
    * field Program type under external program page have proper values
    *   
    */
    
	 static testMethod void testProgramControllerNewHCPatientEducation() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupHCCharCustom('Program','Patient and General Disease Education');
	 	 system.debug('check program');
	 	 system.debug(ts.request);
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.debug(cont.programs.size());
	 	 List<SelectOption> availableOptions=cont.getAvalableProgramTypes();
	 	 System.assertEquals(3,availableOptions.size(),'Following Program type should be available under program page Live Activity, Ongoing, Online Resources');
	 	 String allAvailableProgramType='';
	 	 for(SelectOption item:availableOptions){
	 	 	allAvailableProgramType +=item.getValue()+',';
	 	 }
	 	 System.assertEquals(true,allAvailableProgramType.contains('Live Activity'),'Following Program  should have Live Activity type available');
	 	 System.assertEquals(true,allAvailableProgramType.contains('Ongoing'),'Following Program  should have Ongoing type available');
	 	 System.assertEquals(true,allAvailableProgramType.contains('Online Resources'),'Following Program  should have Online Resources type available');
	 	 System.assertEquals(true,cont.areMultipleAllowed,'Add program button should be visible on external program page');
	 	 test.stopTest();
	 }
	 
	 /**
    * @author ADMD Team
    * @date 15/04/2013
    * @description testProgramControllerNewHCPatientServices method - test if Event / program type is set on Patient Serices ,
    * field Program type under external program page have proper values
    *   
    */
    
	 static testMethod void testProgramControllerNewHCPatientServices() {
	 	 TestSettings ts = new TestSettings();
         ts.setupHCCharCustom('Program','Patient Support');
         ts.request.Event_Project_sub_type__c = 'Patient Services (e.g., nutrition support, transportation)';
         update ts.request;
	 	 system.debug('check program');
	 	 system.debug(ts.request);
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.debug(cont.programs.size());
	 	 List<SelectOption> availableOptions=cont.getAvalableProgramTypes();
	 	 System.assertEquals(3,availableOptions.size(),'Following Program type should be available under program page Live Activity, Ongoing, Online Resources');
	 	 String allAvailableProgramType='';
	 	 for(SelectOption item:availableOptions){
	 	 	allAvailableProgramType +=item.getValue()+',';
	 	 }
	 	 System.assertEquals(true,allAvailableProgramType.contains('Live Activity'),'Following Program  should have Live Activity type available');
	 	 System.assertEquals(true,allAvailableProgramType.contains('Ongoing'),'Following Program  should have Ongoing type available');
	 	 System.assertEquals(true,allAvailableProgramType.contains('Online Resources'),'Following Program  should have Online Resources type available');
	 	 System.assertEquals(true,cont.areMultipleAllowed,'Add program button should be visible on external program page');
	 	 test.stopTest();
	 }
	 
	 /**
    * @author ADMD Team
    * @date 15/04/2013
    * @description testProgramControllerNewHCFinancialAssistance method - test if Event / program type is set on Financial assistance ,
    * field Program type under external program page have proper values
    *   
    */
	 
	 static testMethod void testProgramControllerNewHCFinancialAssistance() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupHCCharCustom('Program','Patient Support');
	 	 ts.request.Event_Project_sub_type__c = 'Financial Assistance';
         update ts.request;
	 	 system.debug('check program');
	 	 system.debug(ts.request);
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.debug(cont.programs.size());
         
	 	 List<SelectOption> availableOptions=cont.getAvalableProgramTypes();
	 	 System.assertEquals(1,availableOptions.size(),'Following Program type should be available under program page Ongoing');
	 	 String allAvailableProgramType='';
	 	 for(SelectOption item:availableOptions){
	 	 	allAvailableProgramType +=item.getValue()+',';
	 	 }
	 	 System.assertEquals(false,allAvailableProgramType.contains('Live Activity'),'Following Program  should not have Live Activity type available');
	 	 System.assertEquals(true,allAvailableProgramType.contains('Ongoing'),'Following Program  should  have Ongoing type available');
	 	 System.assertEquals(false,allAvailableProgramType.contains('Online Resources'),'Following Program  should not have Online Resources type available');
	 	 System.assertEquals(false,cont.areMultipleAllowed,'Add program button should be invisible on external program page');
	 	 test.stopTest();
	 }
	 
	 /**
    * @author ADMD Team
    * @date 15/04/2013
    * @description testProgramControllerNewHCGeneralOrganizationalSupport method - test if Event / program type is set on General organizational support ,
    * field Program type under external program page have proper values
    *   
    */
	 
	 static testMethod void testProgramControllerNewHCGeneralOrganizationalSupport() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupHCCharCustom('Program','General organizational support');
	 	 system.debug('check program');
	 	 system.debug(ts.request);
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.debug(cont.programs.size());
	 	 List<SelectOption> availableOptions=cont.getAvalableProgramTypes();
	 	 System.assertEquals(1,availableOptions.size(),'Following Program type should be available under program page Ongoing');
	 	 String allAvailableProgramType='';
	 	 for(SelectOption item:availableOptions){
	 	 	allAvailableProgramType +=item.getValue()+',';
	 	 }
	 	 System.assertEquals(false,allAvailableProgramType.contains('Live Activity'),'Following Program  should not have Live Activity type available');
	 	 System.assertEquals(true,allAvailableProgramType.contains('Ongoing'),'Following Program  should  have Ongoing type available');
	 	 System.assertEquals(false,allAvailableProgramType.contains('Online Resources'),'Following Program  should not have Online Resources type available');
	 	 System.assertEquals(false,cont.areMultipleAllowed,'Add program button should be invisible on external program page');
	 	 test.stopTest();
	 }
	 
	 /**
    * @author ADMD Team
    * @date 15/04/2013
    * @description testProgramControllerNewHCFundraiser method - test if Event / program type is set on Fundraiser ,
    * field Program type under external program page have proper values
    *   
    */
	 
	 static testMethod void testProgramControllerNewHCFundraiser() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupHCCharCustom('Program','Fundraiser');
	 	 system.debug('check program');
	 	 system.debug(ts.request);
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.debug(cont.programs.size());
	 	 List<SelectOption> availableOptions=cont.getAvalableProgramTypes();
	 	 System.assertEquals(1,availableOptions.size(),'Following Program type should be available under program page Live Activity');
	 	 String allAvailableProgramType='';
	 	 for(SelectOption item:availableOptions){
	 	 	allAvailableProgramType +=item.getValue()+',';
	 	 }
	 	 System.assertEquals(true,allAvailableProgramType.contains('Live Activity'),'Following Program  should  have Live Activity type available');
	 	 System.assertEquals(false,allAvailableProgramType.contains('Ongoing'),'Following Program  should not have Ongoing type available');
	 	 System.assertEquals(false,allAvailableProgramType.contains('Online Resources'),'Following Program  should not have Online Resources type available');
	 	 System.assertEquals(true,cont.areMultipleAllowed,'Add program button should be visible on external program page');
	 	 test.stopTest();
	 }
	 
	 
	 /**
    * @author ADMD Team
    * @date 15/04/2013
    * @description testProgramControllerNewHCHealthScreenings method - test if Event / program type is set on Health Screenings ,
    * field Program type under external program page have proper values
    *   
    */
	 
	 static testMethod void testProgramControllerNewHCHealthScreenings() {
	 	 TestSettings ts = new TestSettings();
         ts.setupHCCharCustom('Program','Patient Support');
         ts.request.Event_Project_sub_type__c = 'Health Screenings';
         update ts.request;
	 	 system.debug('check program');
	 	 system.debug(ts.request);
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.debug(cont.programs.size());
	 	 List<SelectOption> availableOptions=cont.getAvalableProgramTypes();
	 	 System.assertEquals(1,availableOptions.size(),'Following Program type should be available under program page Live Activity');
	 	 String allAvailableProgramType='';
	 	 for(SelectOption item:availableOptions){
	 	 	allAvailableProgramType +=item.getValue()+',';
	 	 }
	 	 System.assertEquals(true,allAvailableProgramType.contains('Live Activity'),'Following Program  should  have Live Activity type available');
	 	 System.assertEquals(false,allAvailableProgramType.contains('Ongoing'),'Following Program  should not have Ongoing type available');
	 	 System.assertEquals(false,allAvailableProgramType.contains('Online Resources'),'Following Program  should not have Online Resources type available');
	 	 System.assertEquals(true,cont.areMultipleAllowed,'Add program button should be visible on external program page');
	 	 test.stopTest();
	 }
	 
	 
	 /**
    * @author ADMD Team
    * @date 15/04/2013
    * @description testProgramControllerNewHCInternationalScientificMedicalMeeting method - test if Event / program type is set on International scientific/medical meeting ,
    * field Program type under external program page have proper values
    *   
    */
	 
	 static testMethod void testProgramControllerNewHCInternationalScientificMedicalMeeting() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupHCCharCustom('Program','International scientific/medical meeting');
	 	 system.debug('check program');
	 	 system.debug(ts.request);
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.debug(cont.programs.size());
	 	 List<SelectOption> availableOptions=cont.getAvalableProgramTypes();
	 	 System.assertEquals(1,availableOptions.size(),'Following Program type should be available under program page Live Activity');
	 	 String allAvailableProgramType='';
	 	 for(SelectOption item:availableOptions){
	 	 	allAvailableProgramType +=item.getValue()+',';
	 	 }
	 	 System.assertEquals(true,allAvailableProgramType.contains('Live Activity'),'Following Program  should  have Live Activity type available');
	 	 System.assertEquals(false,allAvailableProgramType.contains('Ongoing'),'Following Program  should not have Ongoing type available');
	 	 System.assertEquals(false,allAvailableProgramType.contains('Online Resources'),'Following Program  should not have Online Resources type available');
	 	 System.assertEquals(false,cont.areMultipleAllowed,'Add program button should be invisible on external program page');
	 	 test.stopTest();
	 }
	 
	 
	 /**
    * @author ADMD Team
    * @date 15/04/2013
    * @description testProgramControllerNewHCNationalScientificMedicalMeeting method - test if Event / program type is set on National scientific/medical meeting ,
    * field Program type under external program page have proper values
    *   
    */
	 
	 static testMethod void testProgramControllerNewHCNationalScientificMedicalMeeting() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupHCCharCustom('Program','National scientific/medical meeting');
	 	 system.debug('check program');
	 	 system.debug(ts.request);
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.debug(cont.programs.size());
	 	 List<SelectOption> availableOptions=cont.getAvalableProgramTypes();
	 	 System.assertEquals(1,availableOptions.size(),'Following Program type should be available under program page Live Activity');
	 	 String allAvailableProgramType='';
	 	 for(SelectOption item:availableOptions){
	 	 	allAvailableProgramType +=item.getValue()+',';
	 	 }
	 	 System.assertEquals(true,allAvailableProgramType.contains('Live Activity'),'Following Program  should  have Live Activity type available');
	 	 System.assertEquals(false,allAvailableProgramType.contains('Ongoing'),'Following Program  should not have Ongoing type available');
	 	 System.assertEquals(false,allAvailableProgramType.contains('Online Resources'),'Following Program  should not have Online Resources type available');
	 	 System.assertEquals(false,cont.areMultipleAllowed,'Add program button should be invisible on external program page');
	 	 test.stopTest();
	 }
	 
	 
	  /**
    * @author ADMD Team
    * @date 15/04/2013
    * @description testProgramControllerNewHCRegionalScientificMedicalMeeting method - test if Event / program type is set on Regional scientific/medical meeting ,
    * field Program type under external program page have proper values
    *   
    */
	 
	 static testMethod void testProgramControllerNewHCRegionalScientificMedicalMeeting() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupHCCharCustom('Program','Regional scientific/medical meeting');
	 	 system.debug('check program');
	 	 system.debug(ts.request);
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.debug(cont.programs.size());
	 	 List<SelectOption> availableOptions=cont.getAvalableProgramTypes();
	 	 System.assertEquals(1,availableOptions.size(),'Following Program type should be available under program page Live Activity');
	 	 String allAvailableProgramType='';
	 	 for(SelectOption item:availableOptions){
	 	 	allAvailableProgramType +=item.getValue()+',';
	 	 }
	 	 System.assertEquals(true,allAvailableProgramType.contains('Live Activity'),'Following Program  should  have Live Activity type available');
	 	 System.assertEquals(false,allAvailableProgramType.contains('Ongoing'),'Following Program  should not have Ongoing type available');
	 	 System.assertEquals(false,allAvailableProgramType.contains('Online Resources'),'Following Program  should not have Online Resources type available');
	 	 System.assertEquals(false,cont.areMultipleAllowed,'Add program button should be invisible on external program page');
	 	 test.stopTest();
	 }
	 
	 
	 /**
    * @author ADMD Team
    * @date 15/04/2013
    * @description testProgramControllerNewHCRegionalScientificMedicalMeeting method - test if Event / program type is set on Local scientific/medical meeting ,
    * field Program type under external program page have proper values
    *   
    */
	 
	 static testMethod void testProgramControllerNewHCLocalScientificMedicalMeeting() {
	 	
		
	 	
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupHCCharCustom('Program','Local scientific/medical meeting');
	 	 system.debug('check program');
	 	 system.debug(ts.request);
	 	 test.startTest();
	 	 System.assert( [ SELECT Id from GFRS_Program__c  where Funding_Request__c = :ts.request.Id].size()>0, 'tttteee: ' + ts.request);
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.debug(cont.programs.size());
	 	 List<SelectOption> availableOptions=cont.getAvalableProgramTypes();
	 	 System.assertEquals(1,availableOptions.size(),'Following Program type should be available under program page Live Activity');
	 	 String allAvailableProgramType='';
	 	 for(SelectOption item:availableOptions){
	 	 	allAvailableProgramType +=item.getValue()+',';
	 	 }
	 	 System.assertEquals(true,allAvailableProgramType.contains('Live Activity'),'Following Program  should  have Live Activity type available');
	 	 System.assertEquals(false,allAvailableProgramType.contains('Ongoing'),'Following Program  should not have Ongoing type available');
	 	 System.assertEquals(false,allAvailableProgramType.contains('Online Resources'),'Following Program  should not have Online Resources type available');
	 	 System.assertEquals(false,cont.areMultipleAllowed,'Add program button should be invisible on external program page');
	 	 test.stopTest();
	 }
	  
	 
	 static testMethod void testHCCharAddProgramValidationCheckErrors() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupHCCharCustom('Program','Patient and General Disease Education');
	 	 system.debug('check program');
	 	 system.debug(ts.request);
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.debug(cont.programs.size());
	 	 ts.setupNotImedProgram(cont.programs);
	 	 
	 	 ts.setupHCCharProgram(cont.programs,'Live Activity');
	 	 ApexPages.PageReference output=cont.addProgram();
	 	 
	 	 System.assertEquals(null,output,'Checking if validation  work correctly');
	 	 test.stopTest();
	 }
	 
    
	 
	 static testMethod void testHCCharAddProgramValidationCheckErrorsForOnlineResources() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupHCCharCustom('Program','Patient and General Disease Education');
	 	 system.debug('check program');
	 	 system.debug(ts.request);
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.debug(cont.programs.size());
	 	 //ts.setupNotImedProgram(cont.programs);
	 	 
	 	 ts.setupHCCharProgram(cont.programs,'Online Resources');
	 	 cont.resetUnusedFieldForHCChar(cont.programs[0]);
	 	 ApexPages.PageReference output=cont.addProgram();
	 	 
	 	 System.assertEquals(null,output,'Checking if validation  work correctly');
	 	 test.stopTest();
        
	 }
	 
	 static testMethod void testHCCharAddProgramValidationCheckErrorsForOngoing() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupHCCharCustom('Program','Patient and General Disease Education');
	 	 system.debug('check program');
	 	 system.debug(ts.request);
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.debug(cont.programs.size());
	 	 ts.setupNotImedProgram(cont.programs);
	 	 
	 	 ts.setupHCCharProgram(cont.programs,'Ongoing');
	 	 /*cont.uploadMeetingAgenda();
	 	 cont.uploadPromoEvent();
	 	 cont.uploadAdditionalDocument1();
	 	 cont.uploadAdditionalDocument2();
	 	 cont.uploadAdditionalDocument3();
	 	 cont.uploadAdditionalDocument4();
	 	 cont.uploadAdditionalDocument5();
	 	 //check upsert files without creating new one
	 	 cont.uploadMeetingAgenda();
	 	 cont.uploadPromoEvent();
	 	 cont.uploadAdditionalDocument1();
	 	 cont.uploadAdditionalDocument2();
	 	 cont.uploadAdditionalDocument3();
	 	 cont.uploadAdditionalDocument4();
	 	 cont.uploadAdditionalDocument5();*/
	 	  cont.saveProgram();
	 	  
	 	
	 	 ApexPages.PageReference output=cont.addProgram();
	 	 System.debug('check validations Errors for Ongoing programs');
	 	 for(ApexPages.Message m : Apexpages.getMessages()){
	 	 	System.debug(m.getDetail());
	 	 }
	 	
	 	 //cont.goToNextHCCharProgram();
	 	 cont.removeProgram();
	 	 
	 	 
	 	 //cont.changeProgramType();
	 	 System.assertEquals(null,output,'Checking if validation  work correctly');
	 	 test.stopTest();
        
	 }
	 
	 static testMethod void testProgramControllerConstructorForNewIMEDTestSaveProgramSuccess_1() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupImed('Program');
	 	 
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 test.startTest();
	 	 System.assertEquals(ts.request.Id,cont.request.Id);
	 	 System.assertNotEquals(null, cont.request.Record_Type_name__c);
	 	 System.assertEquals(gFRS_TestCreationUtils.RT_FR_IMED_NAME, cont.recordTypeName);
	 	 System.assertEquals(true, cont.isEditable);
	 	 System.assertEquals(1, cont.programs.size());
	 	 System.assertNotEquals(null, cont.categoryOfCreditOptions);
	 	 System.assertNotEquals(null, cont.intendedAudienceOptions);
	 	 System.assertNotEquals(null, cont.specialtyOptions);
	 	 System.assertEquals(true, cont.areMultipleAllowed);
	 	 //System.assertNotEquals(null, cont.testAttachment);
	 	 System.assertEquals(true, cont.showPleaseNoteMessage);
	 	 ts.setupValidImedPrograms(cont.programs);
	 	 cont.selectedProgramId=string.valueOf(cont.programs[0].id);
	 	 cont.saveProgram();
	 	 
	 	 system.assertEquals(false, cont.hasMessages);
	 	 
	 	 cont.addProgram();
	 	 cont.goToNextIMEDProgram();
	 	 cont.removeProgram();
	 	 
	 	 system.assertEquals(false, cont.isCMEOShown);
	 	 test.stopTest();
	 	 
	 }



	 
	 
	 
	 
	 
	 
	 static testMethod void testHCCharUploadDocumentsForOngoing() {
	 	 TestSettings ts = new TestSettings();
	 	 ts.setupHCCharCustom('Program','Patient and General Disease Education');
	 	 system.debug('check program');
	 	 system.debug(ts.request);
	 	 test.startTest();
	 	 gFRS_ProgramController cont = new gFRS_ProgramController(new ApexPages.StandardController(ts.request));
	 	 system.debug(cont.programs.size());
	 	 ts.setupNotImedProgram(cont.programs);
	 	 
	 	 ts.setupHCCharProgram(cont.programs,'Ongoing');
	 	 /*cont.uploadMeetingAgenda();
	 	 cont.uploadPromoEvent();
	 	 cont.uploadAdditionalDocument1();
	 	 cont.uploadAdditionalDocument2();
	 	 cont.uploadAdditionalDocument3();
	 	 cont.uploadAdditionalDocument4();
	 	 cont.uploadAdditionalDocument5();
	 	 //check upsert files without creating new one
	 	 cont.attachmentMeetingAgenda = new Attachment();
	 	 cont.attachmentPromoEvent = new Attachment();
	 	 cont.attachmentAdditionalDocumentUpload1= new Attachment();
	 	 cont.attachmentAdditionalDocumentUpload2= new Attachment();
	 	 cont.attachmentAdditionalDocumentUpload3= new Attachment();
	 	 cont.attachmentAdditionalDocumentUpload4= new Attachment();
	 	 cont.attachmentAdditionalDocumentUpload5= new Attachment();
	 	 cont.uploadMeetingAgenda();
	 	 cont.uploadPromoEvent();
	 	 cont.uploadAdditionalDocument1();
	 	 cont.uploadAdditionalDocument2();
	 	 cont.uploadAdditionalDocument3();
	 	 cont.uploadAdditionalDocument4();
	 	 cont.uploadAdditionalDocument5();*/
	 	  cont.saveProgram();
	 	  
	 	
	 	 ApexPages.PageReference output=cont.addProgram();
	 	 System.debug('check validations Errors for Ongoing programs');
	 	 for(ApexPages.Message m : Apexpages.getMessages()){
	 	 	System.debug(m.getDetail());
	 	 }
	 	
	 	 //cont.goToNextHCCharProgram();
	 	 cont.removeProgram();
	 	 
	 	 
	 	 //cont.changeProgramType();
	 	 System.assertEquals(null,output,'Checking if validation  work correctly');
	 	 test.stopTest();
        
	 }
	 
	
}