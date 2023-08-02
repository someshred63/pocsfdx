@isTest
private class EDM_ABM_Dispatcher_Controller_Test{

	public static testMethod void redirectToABMAppTest(){

		EDM_ABM_Dispatcher_Controller ctrl = new EDM_ABM_Dispatcher_Controller();

		PageReference pr = ctrl.selectApplicationAndNavigate();
		System.assertEquals('/apex/GNE_SFA2_Application_Dispatcher?application=ABM',pr.getUrl());
	}

	public static testMethod void redirectToAppNullTest(){

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

		System.runAs(u){

			insert new GNE_SFA2_User_App_Context_gne__c(
				App_Name_gne__c = 'ABM',
				Role_gne__c = EDM_ABM_Utils.ABS				
			);

			EDM_ABM_Dispatcher_Controller ctrl = new EDM_ABM_Dispatcher_Controller();

			PageReference pr = ctrl.selectApplicationAndNavigate();
			System.assertEquals('/apex/GNE_SFA2_Application_Dispatcher',pr.getUrl());
		}
		
	}
}