@isTest
private class GNE_CRM_340B_Case_Controller_Ext_Test {
	
    private static User createUser(String name, Id profileId, Boolean toInsert) {
        User user = new User(
			Alias = 'standt',
			Email = name + 'user@veevasystems.com',
			EmailEncodingKey = 'UTF-8',
			LastName = 'Testing',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			ProfileId = profileId,
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = name + 'user@veevasystems.com'
        );
        if (toInsert) insert user;
        return user;
    }
        
    @isTest
    static void testSetFutureSavings() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User uManager = createUser('manager', profileId, true);
        User uRun = createUser('340user', profileId, false);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Initiative';
        case340B.Case_Status__c = 'Assigned';
        case340B.Future_Savings_Amount1__c = 1;
        case340B.Future_Savings_Amount2__c = 2;
        case340B.Future_Savings_Amount3__c = 3;
        case340B.Future_Savings_Amount4__c = 4;
        insert case340B;
        
        System.runAs(uRun) {
            Test.startTest();
            	PageReference new_edit_clone_page = Page.GNE_CRM_340B_Case_New_Edit_Clone;
        	new_edit_clone_page.getParameters().put('id', case340B.id);
        	test.setCurrentPage(new_edit_clone_page);
            	ApexPages.StandardController sc = new ApexPages.StandardController(case340B);
		GNE_CRM_340B_Case_Controller_Extension  ctrlExt = new GNE_CRM_340B_Case_Controller_Extension(sc);
            	ctrlExt.saveAndNew();
        	Test.stopTest();
        }
        
    }
}