@isTest
private class EDM_AABP_Edit_Create_Ext_Test{

	public static testMethod void currentAABPTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		insert testAABP;
		EDM_AABP_gne__c testAABP_1 = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		insert testAABP_1;
		EDM_IABP_gne__c testIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP_1.Id,
			EDM_Executive_Summary_gne__c = false,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199
		);
		insert testIABP;

		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP_1);

		EDM_AABP_Edit_Create_Ext ext = new EDM_AABP_Edit_Create_Ext(sc);

		PageReference pr = ext.deleteAABP();

		List<EDM_AABP_gne__c> AABPs = [SELECT Id FROM EDM_AABP_gne__c];

		System.assertEquals(1,AABPs.size());
	}

	public static testMethod void planYearstest(){
		EDM_AABP_gne__c testAABP_1 = new EDM_AABP_gne__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP_1);

		EDM_AABP_Edit_Create_Ext ext = new EDM_AABP_Edit_Create_Ext(sc);

		List<SelectOption> so = ext.getPlanYears();
		System.assertEquals(4,so.size());
		Integer currentYear = System.Today().year();
		System.assertEquals(String.valueOf(currentYear), so[0].getValue());
		System.assertEquals(String.valueOf(currentYear + 1), so[1].getValue());
		System.assertEquals(String.valueOf(currentYear + 2), so[2].getValue());
		System.assertEquals(String.valueOf(currentYear + 3), so[3].getValue());
	}

	public static testMethod void abAndVendorLeadsTest(){
		
		EDM_AABP_gne__c testAABP_1 = new EDM_AABP_gne__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP_1);

		EDM_AABP_Edit_Create_Ext ext = new EDM_AABP_Edit_Create_Ext(sc);
		List<User> users_before = ext.getABLeads();

		List<PermissionSet> ps = [Select id,UserLicenseId From PermissionSet Where Name in (:EDM_ABM_Utils.ABLEAD,:EDM_ABM_Utils.VDST_ABM)];
		Profile p_AB_Admin = [Select Id From Profile Where Name = 'GNE-TLS-SpeakerBureauLead'];
		User u2 = new User(
			FirstName = 'VDST_ABM',
			ProfileId = p_AB_Admin.Id,
			Username = 'b@roche.com',
			LastName = 'Test', 
			Email = 'b@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles', 
			LocaleSidKey = 'en_US', 
			EmailEncodingKey = 'ISO-8859-1', 
			LanguageLocaleKey = 'en_US'
		);
		insert u2;

		List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
		psa.add(new PermissionSetAssignment(AssigneeId = u2.Id, PermissionSetId = ps[0].Id));
		insert psa;

		List<User> us = ext.getABLeads();
		System.assertEquals(users_before.size()+1,us.size());

		List<User> us_vendor = ext.getVendorLeads();
		System.assertEquals(users_before.size()+1,us_vendor.size());
	}

	public static testMethod void abManagersTest(){
		
		EDM_AABP_gne__c testAABP_1 = new EDM_AABP_gne__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP_1);

		EDM_AABP_Edit_Create_Ext ext = new EDM_AABP_Edit_Create_Ext(sc);
		List<User> users_before = ext.getABSManagers();

		List<PermissionSet> ps = [Select id,UserLicenseId From PermissionSet Where Name in (:EDM_ABM_Utils.ABS)];
		Profile p_AB_Man = [Select Id From Profile Where Name = 'GNE-TLS-Manager'];
		User u2 = new User(
			FirstName = 'Manager',
			ProfileId = p_AB_Man.Id,
			Username = 'b@roche.com',
			LastName = 'Test', 
			Email = 'b@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles', 
			LocaleSidKey = 'en_US', 
			EmailEncodingKey = 'ISO-8859-1', 
			LanguageLocaleKey = 'en_US'
		);
		insert u2;

		List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
		psa.add(new PermissionSetAssignment(AssigneeId = u2.Id, PermissionSetId = ps[0].Id));
		insert psa;

		List<User> us = ext.getABSManagers();
		System.assertEquals(users_before.size()+1,us.size());
	}

	public static testMethod void otherSumEmptytest(){
		
		EDM_AABP_gne__c testAABP_1 = new EDM_AABP_gne__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP_1);

		EDM_AABP_Edit_Create_Ext ext = new EDM_AABP_Edit_Create_Ext(sc);

		Integer sum = ext.getOtherSum();
		System.assertEquals(0,sum);
	}

	public static testMethod void otherSumtest(){
		
		EDM_AABP_gne__c testAABP_1 = new EDM_AABP_gne__c(
			EDM_Other_gne__c = 10
		);
		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP_1);

		EDM_AABP_Edit_Create_Ext ext = new EDM_AABP_Edit_Create_Ext(sc);

		Integer sum = ext.getOtherSum();
		System.assertEquals(10,sum);
	}

	public static testMethod void goBackNoRetUrltest(){
		
		EDM_AABP_gne__c testAABP_1 = new EDM_AABP_gne__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP_1);

		EDM_AABP_Edit_Create_Ext ext = new EDM_AABP_Edit_Create_Ext(sc);

		PageReference pr = ext.goBack();
		System.assertEquals('/apex/EDM_AABP_List_View',pr.getUrl());
	}

	public static testMethod void goBacktest(){
		
		EDM_AABP_gne__c testAABP_1 = new EDM_AABP_gne__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP_1);

		ApexPages.currentPage().getParameters().put('retURL','www.google.com');
		EDM_AABP_Edit_Create_Ext ext = new EDM_AABP_Edit_Create_Ext(sc);

		PageReference pr = ext.goBack();
		System.assertEquals('www.google.com',pr.getUrl());
	}

	public static testMethod void saveAndGoBacktest(){
		
		EDM_AABP_gne__c testAABP_1 = new EDM_AABP_gne__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP_1);

		ApexPages.currentPage().getParameters().put('retURL','www.google.com');
		
		EDM_AABP_Edit_Create_Ext ext = new EDM_AABP_Edit_Create_Ext(sc);

		PageReference pr = ext.saveAndGoBack();
		System.assertEquals(null,pr);
		List<ApexPages.Message> msgs = ApexPages.getMessages();
		System.assert(msgs[0].getDetail().contains('Could not save AAPB!'));
	}

	public static testMethod void saveAndGoBacktest2(){
		
		EDM_AABP_gne__c testAABP_1 = new EDM_AABP_gne__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP_1);

		ApexPages.currentPage().getParameters().put('retURL','www.google.com');
		
		EDM_AABP_Edit_Create_Ext ext = new EDM_AABP_Edit_Create_Ext(sc);
		ext.currentAABP.EDM_Plan_Year_gne__c = '2016';
		ext.PlanReceivedDate = '';
		ext.PlanApprovedDate = '';
		ext.currentAABP.EDM_Group_gne__c = 'Commercial';
		ext.currentAABP.EDM_Unit_gne__c = 'GIO';
		ext.currentAABP.EDM_Team_gne__c = 'Actemra';

		PageReference pr = ext.saveAndGoBack();
		System.assertEquals('www.google.com',pr.getUrl());
		System.assertEquals(1,[Select id From EDM_AABP_gne__c].size());
	}

	public static testMethod void saveAndGoBacktest3(){
		
		EDM_AABP_gne__c testAABP_1 = new EDM_AABP_gne__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP_1);
		
		EDM_AABP_Edit_Create_Ext ext = new EDM_AABP_Edit_Create_Ext(sc);
		ext.currentAABP.EDM_Plan_Year_gne__c = '2016';
		ext.PlanReceivedDate = '';
		ext.PlanApprovedDate = '';
		ext.currentAABP.EDM_Group_gne__c = 'Commercial';
		ext.currentAABP.EDM_Unit_gne__c = 'GIO';
		ext.currentAABP.EDM_Team_gne__c = 'Actemra';

		PageReference pr = ext.saveAndGoBack();
		System.assertEquals('/apex/EDM_AABP_List_View',pr.getUrl());
		System.assertEquals(1,[Select id From EDM_AABP_gne__c].size());
	}

	public static testMethod void saveWithEventsTest(){
		
		EDM_AABP_gne__c testAABP_1 = new EDM_AABP_gne__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP_1);
		
		EDM_AABP_Edit_Create_Ext ext = new EDM_AABP_Edit_Create_Ext(sc);

		ext.PlanReceivedDate = '';
		ext.PlanApprovedDate = '';

		System.assertEquals(0,ext.Events.size());
		ext.newEvt.EDM_Type_of_Event_gne__c = 'CAB';
		ext.addEventEDM();
		System.assertEquals(1,ext.Events.size());

		PageReference pr = ext.saveAABP();
		System.assertEquals(null,pr);
		System.assertEquals(1,[Select id From EDM_AABP_gne__c].size());
	}

	public static testMethod void addAndRemoveEventsTest(){
		
		EDM_AABP_gne__c testAABP_1 = new EDM_AABP_gne__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP_1);
		
		EDM_AABP_Edit_Create_Ext ext = new EDM_AABP_Edit_Create_Ext(sc);

		ext.isEdit = true;

		System.assertEquals(0,ext.Events.size());
		for(Integer i = 0;i < 5;i++){			
			if(i == 0) ext.newEvt.EDM_Type_of_Event_gne__c = 'CAB';
			if(i == 1) ext.newEvt.EDM_Type_of_Event_gne__c = 'RAB';
			if(i == 2) ext.newEvt.EDM_Type_of_Event_gne__c = 'NAB';
			if(i == 3) ext.newEvt.EDM_Type_of_Event_gne__c = 'Combo';
			if(i == 4) ext.newEvt.EDM_Type_of_Event_gne__c = 'Other';
			ext.addEventEDM();
		}
		
		System.assertEquals(5,ext.Events.size());
		
		
		for(Integer i = 0;i < 5;i++){
			ext.RowToDel = 1;			
			ext.removeEvent();
		}
		System.assertEquals(0,ext.Events.size());
	}

	public static testMethod void deleteAABPTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		insert testAABP;

		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);

		EDM_AABP_Edit_Create_Ext ext = new EDM_AABP_Edit_Create_Ext(sc);

		PageReference pr = ext.deleteAABP();

		List<EDM_AABP_gne__c> AABPs = [SELECT Id FROM EDM_AABP_gne__c];

		System.assertEquals(0,AABPs.size());
	}

	public static testMethod void finalizeAABPTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		insert testAABP;
		
		ApexPages.StandardController sc = new ApexPages.StandardController(testAABP);

		EDM_AABP_Edit_Create_Ext ext = new EDM_AABP_Edit_Create_Ext(sc);

		PageReference pr = ext.finalizeAABP(); 

		List<EDM_AABP_gne__c> AABPs = [SELECT Id,EDM_Finalized_gne__c FROM EDM_AABP_gne__c];

		System.assertEquals(1,AABPs.size());
		System.assertEquals(true,AABPs[0].EDM_Finalized_gne__c);
	}
}