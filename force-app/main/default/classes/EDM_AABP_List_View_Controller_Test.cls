@isTest
private class EDM_AABP_List_View_Controller_Test{

	public static testMethod void controllerTest(){
		EDM_AABP_List_View_Controller ctrl = new EDM_AABP_List_View_Controller();
		System.assertEquals(false,ctrl.isABPManager);
	}

	public static testMethod void controllerABPManagerTest(){
		
		List<PermissionSet> ps = [Select id,UserLicenseId From PermissionSet Where Name in (:EDM_ABM_Utils.ABS)];
		Profile p_AB_Man = [Select Id From Profile Where Name = 'GNE-TLS-Manager'];
		User u = new User(
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
		insert u;

		List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
		psa.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps[0].Id));
		insert psa;

		System.runAs(u){
			EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP;
			EDM_AABP_gne__c testAABP_2 = new EDM_AABP_gne__c(
				EDM_Plan_Year_gne__c = '2015',
				EDM_Plan_Received_gne__c = Date.today(),
				EDM_Final_Approval_Received_gne__c = Date.today()
			);
			insert testAABP_2;

			EDM_AABP_List_View_Controller ctrl = new EDM_AABP_List_View_Controller();
			System.assertEquals(true,ctrl.isABPManager);
		}
	}

	public static testMethod void createEditLinkTest(){
		EDM_AABP_List_View_Controller ctrl = new EDM_AABP_List_View_Controller();
		PageReference pr = ctrl.createEdit();
		System.assertEquals('/apex/EDM_AABP_Edit_Create',pr.getUrl());
	}

	public static testMethod void listViewLabelTest(){
		EDM_AABP_List_View_Controller ctrl = new EDM_AABP_List_View_Controller();
		String label = ctrl.getListViewLabel();
		System.assertEquals('',label);
	}

	public static testMethod void listViewLabelTest2(){
		List<PermissionSet> ps = [Select id,UserLicenseId From PermissionSet Where Name in (:EDM_ABM_Utils.ABS)];
		Profile p_AB_Man = [Select Id From Profile Where Name = 'GNE-TLS-Manager'];
		User u = new User(
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
		insert u;

		List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
		psa.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps[0].Id));
		insert psa;

		System.runAs(u){

			insert new GNE_SFA2_User_App_Context_gne__c(
				App_Name_gne__c = 'ABM',
				Role_gne__c = EDM_ABM_Utils.ABS				
			);

			SFA2_Configuration_Object_gne__c co = new SFA2_Configuration_Object_gne__c(
				Application_Type__c = 'ABM',
				Configuration_Type_gne__c = 'List Page',
				Is_Active_gne__c = true,
				Object_Name_gne__c = 'EDM_AABP_gne__c', 
				Order_gne__c = 0,
				Role_gne__c = EDM_ABM_Utils.ABS, 
				Section_Header_gne__c = 'TestListView'
			);
			insert co;
			
			SFA2_User_Group_Mapping_gne__c ugm = new SFA2_User_Group_Mapping_gne__c(
				Application_gne__c = 'ABM',
				Permission_Set_Name_gne__c = EDM_ABM_Utils.ABS,
				Role_gne__c = EDM_ABM_Utils.ABS
			);
			insert ugm;

			SFA2_View_Config_gne__c vc = new SFA2_View_Config_gne__c(
				Role_gne__c = EDM_ABM_Utils.ABS,
				View_Name_gne__c = 'TestView',
				Object_Type_gne__c = 'EDM_AABP_gne__c',
				Page_Name_gne__c = 'TestListView'
			);
			insert vc;			
			
			System.assertEquals(1,[select Role_gne__c from SFA2_User_Group_Mapping_gne__c 
				WHERE Application_gne__c = 'ABM' AND Permission_Set_Name_gne__c in (:EDM_ABM_Utils.ABS)].size());
			EDM_AABP_List_View_Controller ctrl = new EDM_AABP_List_View_Controller();
			GNE_SFA2_User_App_Context_gne__c userContext = GNE_SFA2_Util.getUserApplicationContext();
			System.assertEquals('ABM',userContext.App_Name_gne__c);
            System.assertEquals('EDM_ABS_Manager',userContext.Role_gne__c);
            //System.assertEquals('Brand_gne__c',userContext.Brand_gne__c);
			System.assertEquals('TestListView',ctrl.getListPageName(),[SELECT Name, 
																			  Attributes_gne__c, 
																			  Section_Header_gne__c, 
																			  Configuration_Type_gne__c, 
																			  Is_Active_gne__c, 
																			  Application_Type__c, 
																			  Role_gne__c, 
																			  Brand_gne__c, 
																			  Object_Name_gne__c 
																			  FROM SFA2_Configuration_Object_gne__c]);
			String label = ctrl.getListViewLabel();
			System.assertEquals('TestView',label);
		}
	}
}