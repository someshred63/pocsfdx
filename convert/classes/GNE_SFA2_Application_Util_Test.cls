@isTest
private class GNE_SFA2_Application_Util_Test { 

	@isTest
	public static void switchToApplicationTest() {
		//GNE_SFA2_Exception
		try {
			PageReference pg = GNE_SFA2_Application_Util.switchUserToApplication('MCCO', null);
			System.assert(false, 'GNE_SFA2_Exception exception should be thrown');
		} catch (Exception e) {
			System.assertEquals(e instanceof GNE_SFA2_Exception, true, 'GNE_SFA2_Exception exception expected'); 
		}

		User testActemraUser = createSFA2User();
		System.runAs(testActemraUser){
			Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
			insert acc;
			IC_Calc_Sales_Roster_gne__c icCalc =  new IC_Calc_Sales_Roster_gne__c(App_URL_gne__c = 'https://test.salesforce.com/',
						Is_SFA2_Available_gne__c = true,
						Type_gne__c = 'SFA-US');	
			insert icCalc;
			insert new SFA2_User_Sales_Roster_gne__c(Role_gne__c = 'CS', 
						Profile_Name_gne__c = 'GNE-Field', 
						Sales_Roster_gne__c = icCalc.Id,
						User_gne__c = testActemraUser.Id,
						Sales_Roster_gne__r = icCalc);

			PageReference pr = Page.GNE_SFA2_Account;
			pr.getParameters().put('id', acc.Id);
			Test.setCurrentPage(pr);
			PageReference pg = GNE_SFA2_Application_Util.switchUserToApplication('SFA-US', null);
		}
	}

	private static User createSFA2User() {
        List<Profile> sfa2Profiles = [ SELECT Id FROM Profile WHERE Name = 'GNE-Field' ];
        if(sfa2Profiles != null && sfa2Profiles.size() > 0) {
			return GNE_SFA2_Triggers_Test_Util.createUser('testuser', sfa2Profiles[0]);
        }
        return null;
    }

}