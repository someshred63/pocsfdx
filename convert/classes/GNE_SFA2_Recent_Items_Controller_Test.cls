@isTest
private class GNE_SFA2_Recent_Items_Controller_Test {
	
	public static testMethod void testGetAvailableObjects() {
		insert new GNE_SFA2_User_App_Context_gne__c(App_Name_gne__c = 'ABM', Role_gne__c = 'ABS-Manager', Brand_gne__c = null);

		SFA2_Search_Settings_gne__c searchSettings1 = new SFA2_Search_Settings_gne__c(Object_gne__c = 'Account',
			Role_gne__c = 'ABS-Manager', Order_gne__c = 1.0,
			Fields_gne__c = 'Long_Id_gne__c;Name;Name_and_Address_gne__c;RecordTypeId;MDMID_gne__c;EDM_Clinical_Classification_gne__c;EDM_Business_Classification_gne__c;AGS_EX_Exclusion_Status_gne__c',
			Header_Label_gne__c = 'AABPs', Application_Name_gne__c = 'ABM');
		SFA2_Search_Settings_gne__c searchSettings2 = new SFA2_Search_Settings_gne__c(Object_gne__c = 'EDM_AABP_gne__c',
			Role_gne__c = 'ABS-Manager', Order_gne__c = 2.0,
			Fields_gne__c = 'Id;Name',
			Header_Label_gne__c = 'AABPs', Application_Name_gne__c = 'ABM');
		SFA2_Search_Settings_gne__c searchSettings3 = new SFA2_Search_Settings_gne__c(Object_gne__c = 'EDM_IABP_gne__c',
			Role_gne__c = 'ABS-Manager', Order_gne__c = 1.0,
			Fields_gne__c = 'Id;Name',
			Header_Label_gne__c = 'AABPs', Application_Name_gne__c = 'TLCRM');
		SFA2_Search_Settings_gne__c searchSettings4 = new SFA2_Search_Settings_gne__c(Object_gne__c = 'User',
			Role_gne__c = 'AB-Lead', Order_gne__c = 3.0,
			Fields_gne__c = 'Id;Name',
			Header_Label_gne__c = 'AABPs', Application_Name_gne__c = 'ABM');

		List<SFA2_Search_Settings_gne__c> searchSettings = new List<SFA2_Search_Settings_gne__c>{
			searchSettings1, searchSettings2, searchSettings3, searchSettings4
		};

		insert searchSettings;

		GNE_SFA2_Recent_Items_Controller ric = new GNE_SFA2_Recent_Items_Controller();
		Set<String> result = ric.getAvailableObjects();

		System.assert(result.size() == 2);
		System.assert(result.contains('Account'));
		System.assert(result.contains('EDM_AABP_gne__c'));
		System.assert(!result.contains('EDM_IABP_gne__c'));
		System.assert(!result.contains('User'));
	}

	public static testMethod void testGetRequestHeader(){
		GNE_SFA2_Recent_Items_Controller ric = new GNE_SFA2_Recent_Items_Controller();
		String result = ric.getRequestHeader();

		String toCompare = 'OAuth ' + UserInfo.getSessionId();

		System.assertEquals(toCompare, result);
	}

	public static testMethod void testGetEndPointUrl(){
		GNE_SFA2_Recent_Items_Controller ric = new GNE_SFA2_Recent_Items_Controller();
		String result = ric.getEndPointUrl();

		String toCompare = 'https://' + System.URL.getSalesforceBaseURL().getHost() + '/services/data/v26.0/recent';

		System.assertEquals(toCompare, result);
	}

}