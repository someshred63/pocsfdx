@isTest
private class EDM_AB_Events_List_View_Controller_Test{

	public static testMethod void finalizedExeSumsTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		insert testAABP;
		EDM_IABP_gne__c parentIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199
		);
		insert parentIABP;

		List<EDM_IABP_gne__c> IABPs = new List<EDM_IABP_gne__c>();
		IABPs.add(new EDM_IABP_gne__c(
			EDM_Parent_IABP_gne__c = parentIABP.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_ExeSum_Status_gne__c = 'Finalized',
			EDM_Type_of_Event_gne__c = 'testTypeOfEvent',
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_IABP_Version_gne__c = 10
		));
		IABPs.add(new EDM_IABP_gne__c(
			EDM_Parent_IABP_gne__c = parentIABP.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_ExeSum_Status_gne__c = 'Complete',
			EDM_Type_of_Event_gne__c = 'testTypeOfEvent',
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_IABP_Version_gne__c = 10
		));
		insert IABPs;		

		EDM_AB_Events_List_View_Controller ctrl = new EDM_AB_Events_List_View_Controller();

		System.assert(ctrl.additionalConditionForViews.trim().startsWith('EDM_Status_gne__c!=\'Canceled\' AND EDM_Historical_gne__c = false AND EDM_Executive_Summary_gne__c = false'));
	}

	public static testMethod void attendeesTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		insert testAABP;
		EDM_IABP_gne__c parentIABP1 = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = false,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199
		);
		insert parentIABP1;
		EDM_IABP_gne__c parentIABP2 = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = false,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199
		);
		insert parentIABP2;

		Account a = new Account(
			Name = 'TestAccount'
		);
		insert a;

		ApexPages.currentPage().getParameters().put('account',a.id);
		List<EDM_Attendee_gne__c> attds = new List<EDM_Attendee_gne__c>();
		attds.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = parentIABP1.Id,
			EDM_Account_gne__c = a.Id
		));
		attds.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = parentIABP2.Id,
			EDM_Account_gne__c = a.Id
		));
		insert attds;

		EDM_AB_Events_List_View_Controller ctrl = new EDM_AB_Events_List_View_Controller();

		System.assertEquals('EDM_Status_gne__c!=\'Canceled\' AND EDM_Historical_gne__c = false AND EDM_Executive_Summary_gne__c = false  AND Id NOT IN (\''+parentIABP1.Id+'\',\''+parentIABP2.Id+'\')',ctrl.additionalConditionForViews.trim());
	}

	public static testMethod void createEditTest(){

		EDM_AB_Events_List_View_Controller ctrl = new EDM_AB_Events_List_View_Controller();

		PageReference pr = ctrl.createEdit();
		
		System.assertEquals(null,pr);
	}

	public static testMethod void initRLTest(){

		Account a = new Account(
			Name = 'TestAccount'
		);
		insert a;
		ApexPages.currentPage().getParameters().put('account',a.id);

		EDM_AB_Events_List_View_Controller ctrl = new EDM_AB_Events_List_View_Controller();

		PageReference pr = ctrl.initRL();
		
		System.assertEquals(null,pr);
		System.assertEquals(null,ctrl.attributesWrapper);
	}

	public static testMethod void initRLTest2(){

		SFA2_Configuration_Object_gne__c co = new SFA2_Configuration_Object_gne__c(
			Object_Name_gne__c = 'Account',
			Configuration_Type_gne__c = 'Page',
			Is_Active_gne__c = true,
			Record_Type_gne__c = 'Company'
		);
		insert co;
		SFA2_Configuration_Object_Detail_gne__c cod = new SFA2_Configuration_Object_Detail_gne__c(
			Type_gne__c = 'Related List',
			Label_gne__c = 'Advisory Boards',
			Configuration_Object_ref_gne__c = co.Id,
			Is_Active_gne__c = true,
			Attributes_gne__c = 'TestAttributes'
		);
		insert cod;


		Account a = new Account(
			Name = 'TestAccount'
		);
		insert a;
		ApexPages.currentPage().getParameters().put('account',a.id);

		EDM_AB_Events_List_View_Controller ctrl = new EDM_AB_Events_List_View_Controller();

		PageReference pr = ctrl.initRL();

		System.assertEquals(null,pr);
		System.assertNotEquals(null,ctrl.attributesWrapper);
	}
}