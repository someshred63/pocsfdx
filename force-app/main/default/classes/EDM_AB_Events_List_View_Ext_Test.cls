@isTest
private class EDM_AB_Events_List_View_Ext_Test{

	public static testMethod void goBackTest(){

		Account a = new Account(
			Name = 'TestAccount'
		);
		insert a;

		EDM_AB_Events_List_View_Controller ctrl = new EDM_AB_Events_List_View_Controller();
		ApexPages.currentPage().getParameters().put('account',a.Id);

		ApexPages.currentPage().getParameters().put('retURL','www.google.com');
		EDM_AB_Events_List_View_Ext ext = new EDM_AB_Events_List_View_Ext(ctrl);

		PageReference pr = ext.goBack();
		System.assertEquals('www.google.com',pr.getUrl());
	}

	public static testMethod void goBackTest2(){

		Account a = new Account(
			Name = 'TestAccount'
		);
		insert a;

		EDM_AB_Events_List_View_Controller ctrl = new EDM_AB_Events_List_View_Controller();
		ApexPages.currentPage().getParameters().put('account',a.Id);
		EDM_AB_Events_List_View_Ext ext = new EDM_AB_Events_List_View_Ext(ctrl);

		PageReference pr = ext.goBack();
		System.assertEquals('/apex/gne_sfa2_account_layout?id=' + a.Id,pr.getUrl());
	}

	public static testMethod void saveAdvisorsExeSumTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		insert testAABP;
		EDM_IABP_gne__c parentIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = false,
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
			EDM_IABP_Version_gne__c = 10,
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		));
		IABPs.add(new EDM_IABP_gne__c(
			EDM_Parent_IABP_gne__c = parentIABP.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_ExeSum_Status_gne__c = 'Complete',
			EDM_Type_of_Event_gne__c = 'testTypeOfEvent',
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_IABP_Version_gne__c = 10,
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		));
		insert IABPs;	

		EDM_IABP_gne__c exesumIABP = new EDM_IABP_gne__c(
			EDM_Parent_IABP_gne__c = IABPs[0].Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_ExeSum_Status_gne__c = 'Complete',
			EDM_Type_of_Event_gne__c = 'testTypeOfEvent',
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_IABP_Version_gne__c = 10,
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		insert exesumIABP;

		Account a = new Account(
			Name = 'TestAccount'
		);
		insert a;

		EDM_AB_Events_List_View_Controller ctrl = new EDM_AB_Events_List_View_Controller();
		EDM_AB_Events_List_View_Ext ext = new EDM_AB_Events_List_View_Ext(ctrl);

		ext.selected = '';
		Integer i = IABPs.size();
		for(EDM_IABP_gne__c iabp : IABPs){
			ext.selected += iabp.Id;
			if(i>1){
				ext.selected += ';';
				i--;
			}
		}
		ext.saveAdvisors();

		System.assertEquals(1,[Select Id From EDM_Attendee_gne__c Where EDM_Parent_IABP_gne__c = :IABPs[0].Id].size());
		System.assertEquals(1,[Select Id From EDM_Attendee_gne__c Where EDM_Parent_IABP_gne__c = :IABPs[1].Id].size());
		System.assertEquals(1,[Select Id From EDM_Attendee_gne__c Where EDM_Parent_IABP_gne__c = :exesumIABP.Id].size());
	}

	public static testMethod void saveAdvisorsTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		insert testAABP;
		EDM_IABP_gne__c parentIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = false,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199
		);
		insert parentIABP;

		List<EDM_IABP_gne__c> IABPs = new List<EDM_IABP_gne__c>();
		IABPs.add(new EDM_IABP_gne__c(
			EDM_Parent_IABP_gne__c = parentIABP.Id,
			EDM_Executive_Summary_gne__c = false,
			EDM_ExeSum_Status_gne__c = 'Finalized',
			EDM_Type_of_Event_gne__c = 'testTypeOfEvent',
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_IABP_Version_gne__c = 10
		));
		IABPs.add(new EDM_IABP_gne__c(
			EDM_Parent_IABP_gne__c = parentIABP.Id,
			EDM_Executive_Summary_gne__c = false,
			EDM_ExeSum_Status_gne__c = 'Complete',
			EDM_Type_of_Event_gne__c = 'testTypeOfEvent',
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_IABP_Version_gne__c = 10
		));
		insert IABPs;

		EDM_IABP_gne__c exesumIABP = new EDM_IABP_gne__c(
			EDM_Parent_IABP_gne__c = IABPs[0].Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_ExeSum_Status_gne__c = 'Complete',
			EDM_Type_of_Event_gne__c = 'testTypeOfEvent',
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_IABP_Version_gne__c = 10
		);
		insert exesumIABP;

		Account a = new Account(
			Name = 'TestAccount'
		);
		insert a;

		EDM_AB_Events_List_View_Controller ctrl = new EDM_AB_Events_List_View_Controller();
		EDM_AB_Events_List_View_Ext ext = new EDM_AB_Events_List_View_Ext(ctrl);

		ext.selected = '';
		Integer i = IABPs.size();
		for(EDM_IABP_gne__c iabp : IABPs){
			ext.selected += iabp.Id;
			if(i>1){
				ext.selected += ';';
				i--;
			}
		}
		ext.saveAdvisors();

		System.assertEquals(1,[Select Id From EDM_Attendee_gne__c Where EDM_Parent_IABP_gne__c = :IABPs[0].Id].size());
		System.assertEquals(1,[Select Id From EDM_Attendee_gne__c Where EDM_Parent_IABP_gne__c = :IABPs[1].Id].size());
		System.assertEquals(1,[Select Id From EDM_Attendee_gne__c Where EDM_Parent_IABP_gne__c = :exesumIABP.Id].size());
	}

	public static testMethod void maxAdvisorsReachedTest(){

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		insert testAABP;
		EDM_IABP_gne__c parentIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = false,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199
		);
		insert parentIABP;

		List<EDM_IABP_gne__c> IABPs = new List<EDM_IABP_gne__c>();
		IABPs.add(new EDM_IABP_gne__c(
			EDM_Parent_IABP_gne__c = parentIABP.Id,
			EDM_Executive_Summary_gne__c = false,
			EDM_ExeSum_Status_gne__c = 'Finalized',
			EDM_Type_of_Event_gne__c = 'testTypeOfEvent',
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_IABP_Version_gne__c = 10
		));
		insert IABPs;

		Account a = new Account(
			Name = 'TestAccount'
		);
		insert a;

		List<EDM_Attendee_gne__c> attds = new List<EDM_Attendee_gne__c>();
		for(Integer i = 0; i < 100; i++){
			attds.add(new EDM_Attendee_gne__c(
				EDM_Account_gne__c = a.Id,
				EDM_Parent_IABP_gne__c = IABPs[0].Id,
				EDM_Type_gne__c = 'HCP/Business Professional'
			));
		}
		insert attds;

		EDM_AB_Events_List_View_Controller ctrl = new EDM_AB_Events_List_View_Controller();
		EDM_AB_Events_List_View_Ext ext = new EDM_AB_Events_List_View_Ext(ctrl);

		ext.selected = '';
		Integer i = IABPs.size();
		for(EDM_IABP_gne__c iabp : IABPs){
			ext.selected += iabp.Id;
			if(i>1){
				ext.selected += ';';
				i--;
			}
		}
		ext.saveAdvisors();

		System.assert(ext.hasEventReachedMaxAdvisors(attds,IABPs[0].Id));
	}

	public static testMethod void shouldNotDisplayFinalizedExeSumsTest(){
		User absUser = EDM_ABM_Test_Utils.getABSes()[0];
		System.runAs(absUser) {
			EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today(),
				EDM_ABS_Manager_gne__c = UserInfo.getUserId()
			);
			insert testAABP;
			EDM_IABP_gne__c parentIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = testAABP.Id,
				EDM_Executive_Summary_gne__c = false,
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
				EDM_IABP_Version_gne__c = 10,
				EDM_ABS_Manager_gne__c = UserInfo.getUserId()
			));
			insert IABPs;

			Account a = new Account(
				Name = 'TestAccount'
			);
			insert a;

			List<EDM_Attendee_gne__c> attds = new List<EDM_Attendee_gne__c>();
			
			attds.add(new EDM_Attendee_gne__c(
				EDM_Account_gne__c = a.Id,
				EDM_Parent_IABP_gne__c = IABPs[0].Id,
				EDM_Type_gne__c = 'HCP/Business Professional'
			));
			
			insert attds;

			EDM_AB_Events_List_View_Controller ctrl = new EDM_AB_Events_List_View_Controller();
			EDM_AB_Events_List_View_Ext ext = new EDM_AB_Events_List_View_Ext(ctrl);

			ext.selected = '';
			Integer i = IABPs.size();
			for(EDM_IABP_gne__c iabp : IABPs){
				ext.selected += iabp.Id;
				if(i>1){
					ext.selected += ';';
					i--;
				}
			}
			ext.saveAdvisors();
			System.assertEquals(true, ctrl.getExcludedIabpIdsForRecentlyChosen(a.Id).contains(IABPs[0].Id));
		}
	}
}