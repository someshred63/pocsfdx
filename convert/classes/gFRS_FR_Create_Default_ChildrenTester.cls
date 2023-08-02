@isTest
private class gFRS_FR_Create_Default_ChildrenTester {

	class TestSettings {
        Account acc;
		GFRS_Organization__c org;
		GFRS_Location__c loc;
		GFRS_Funding_Request__c fundingRequest;
		Contact c;
		Contact c2;
		User u1Context;
		User u2Assign;
		All_User_Hierarchy_gne__c majorOne;
		All_User_Hierarchy_gne__c relatedOne;
		
		public String DEFAULT_STATUS = 'Intake';
        public String DEFAULT_SUB_STATUS = 'Not Submitted';
		
		public TestSettings(){
     		acc = gFRS_TestCreationUtils.createAccount('gFRS_FundingRequestReadControllerTesterAcc');
	     	insert acc;
		 	org = gFRS_TestCreationUtils.createOrganization('TestOrg1', acc);
		 	insert org;
		 	loc = gFRS_TestCreationUtils.createLocation('gFRS_FundingRequestReadControllerTesterLoc',org.id);
      		insert loc;
      		c = gFRS_TestCreationUtils.createContact2('John','Smithsonian',acc.Id);
      		insert c;
      		c2 = gFRS_TestCreationUtils.createContact2('George','Blue',acc.Id);
      		insert c2;
		 	u1Context = gFRS_TestCreationUtils.createUser2(c,'nonExistingUserNameTemp1@gFRSFRCreateDefaultChildrenTester.com');
		 	u1Context.External_Id_gne__c = 'externalIdNonExisting1';
		 	insert u1Context; 
		 	u2Assign = gFRS_TestCreationUtils.createUser(c2,'nonExistingUserNameTemp2@gFRSFRCreateDefaultChildrenTester.com');
		 	u2Assign.External_Id_gne__c = 'externalIdNonExisting2';
		 	insert u2Assign;
		 	relatedOne = gFRS_TestCreationUtils.createUserHierarchy(u2Assign.External_Id_gne__c, 'George', 'Blue', null, null, null, null, null, null, null);
		 	insert relatedOne; 
		 	majorOne = gFRS_TestCreationUtils.createUserHierarchy(u1Context.External_Id_gne__c, 'John', 'Smithsonian', relatedOne.Id, null, null, null, null, null, null); 
		 	insert majorOne;
		}
		
		public void setupFR(){
			fundingRequest = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_IMED_NAME , gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', org.Id, loc.Id);
		 	insert fundingRequest;
		}
	}

    static testMethod void myUnitTest1() {
        TestSettings ts = new TestSettings();
        System.runAs(ts.u1Context){
        	ts.setupFR();	
        }
        GFRS_Program__c[] processedDate = [select Id from GFRS_Program__c where Funding_Request__c = :ts.fundingRequest.id];
        System.assertEquals(processedDate.size(),1);
    }	
}