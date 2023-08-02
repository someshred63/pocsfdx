/************************************************************
*  @author: Grzegorz Skaruz
*  Date: 2016-11-13
*  This is a test for GNE_SFA2_Search_Controller class
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest

private class GNE_SFA2_Search_Controller_Test {
	
	private static String testString = 'testSearch';

    static testMethod void testCtrl() {
		ApexPages.currentPage().getParameters().put('searchString', testString);
		GNE_SFA2_Search_Controller app = new GNE_SFA2_Search_Controller();	
		
		system.AssertEquals(app.sObjectsMap.size(), 0);
		system.AssertEquals(app.sectionHeadersMap.size(), 0); 
		system.AssertEquals(app.getResultsFound(), false);
    }
    
    private static SFA2_Search_Settings_gne__c prepareSearchSettings(String fieldNames, String headerLabel, String objectName, String filterName){
        GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();

		SFA2_Search_Settings_gne__c searchSettings = new SFA2_Search_Settings_gne__c(
			Fields_gne__c = fieldNames,
			Header_Label_gne__c = headerLabel,
			Object_gne__c = objectName,
			Filter_gne__c = filterName,
			Product_gne__c = userApplicationContext.Brand_gne__c,
			Role_gne__c = userApplicationContext.Role_gne__c,
			Application_Name_gne__c = userApplicationContext.App_Name_gne__c
		);
		insert searchSettings;
		return searchSettings;
    }    
    
    private static List<SFA2_Search_Settings_gne__c> prepareSearchSettingsList(String fieldNames, String headerLabel, String objectName, String filterName){
		SFA2_Search_Settings_gne__c searchSettings = prepareSearchSettings(fieldNames, headerLabel, objectName, filterName);
		List<SFA2_Search_Settings_gne__c> searchSettingsList = new List<SFA2_Search_Settings_gne__c>();
		searchSettingsList.add(searchSettings);
		return searchSettingsList;
    }

    static testMethod void testGetSearchSettings() {
		SFA2_Search_Settings_gne__c searchSettings = prepareSearchSettings(
			'Id;Name;Category_gne__c;Position_gne__c;Title_gne__c',
			'Questions',
			'Question_gne__c',
			null
		);
		
		Test.startTest();	
			ApexPages.currentPage().getParameters().put('searchString', testString);
			GNE_SFA2_Search_Controller app = new GNE_SFA2_Search_Controller();
			List<SFA2_Search_Settings_gne__c> result = app.getSearchSettings(GNE_SFA2_Util.getUserApplicationContext());
		Test.stopTest();
		
		system.assertEquals(result.size(), 1);
		system.assertEquals(result.get(0).Object_gne__c, searchSettings.Object_gne__c);
		system.assertEquals(result.get(0).Fields_gne__c, searchSettings.Fields_gne__c);
		system.assertEquals(result.get(0).Header_Label_gne__c, searchSettings.Header_Label_gne__c);
		system.assertEquals(result.get(0).Field_Header_gne__c, searchSettings.Field_Header_gne__c);
    }

    static testMethod void testGetRecordsBySearchCriteria() {
		List<SFA2_Search_Settings_gne__c> searchSettingsList = prepareSearchSettingsList(
			'Id;Name;Category_gne__c;Position_gne__c;Title_gne__c',
			'Questions',
			'Question_gne__c',
			null
		);

		Questionnaire_gne__c questionnaire = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne( false );
		questionnaire.No_Edit_gne__c = true;
		insert questionnaire;
		Question_gne__c question = GNE_SFA2_Triggers_Test_Util.prepareQuestion_gne( questionnaire.Id );
		question.Title_gne__c = testString;
		insert question;
		Test.setFixedSearchResults(new List<String>{question.Id});
		
		Test.startTest();	
			ApexPages.currentPage().getParameters().put('searchString', testString);
			GNE_SFA2_Search_Controller app = new GNE_SFA2_Search_Controller();
			List<String> searchQueries = app.buildListOfSearchQueries(searchSettingsList);
			List<List<Question_gne__c>> result = app.getRecordsBySearchCriteria(searchQueries);
		Test.stopTest();	 

		system.assertEquals(result.size(), 1);
		system.assertEquals(result.get(0).get(0).get('Title_gne__c'), testString);
    }
    
    static testMethod void testBuildListOfSearchQueriesContact() {
		List<SFA2_Search_Settings_gne__c> searchSettingsList = prepareSearchSettingsList(
			'Id;Name;Title_gne__c;AccountId;DoNotCall;Phone;MobilePhone;Email;Status_gne__c',
			'Contacts',
			'Contact',
			'IsPersonAccount = false'
		);

		Account a = new Account(Name = 'TestAccount1');
		insert a;

		Contact c = new Contact(LastName = testString, AccountId = a.Id);
		insert c;

		Test.startTest();	
			ApexPages.currentPage().getParameters().put('searchString', testString);
			GNE_SFA2_Search_Controller app = new GNE_SFA2_Search_Controller();
			List<String> searchQueries = app.buildListOfSearchQueries(searchSettingsList);
		Test.stopTest();	
		
		system.assertEquals(searchQueries.size(), 1);
		system.assertEquals(searchQueries.get(0), 'FIND \'testSearch*\' IN ALL FIELDS RETURNING Contact(Id, Name, Title_gne__c, AccountId, DoNotCall, Phone, MobilePhone, Email, Status_gne__c WHERE IsPersonAccount = false LIMIT 25)');
    }
    
    static testMethod void testBuildListOfSearchQueriesAccount() {
		List<SFA2_Search_Settings_gne__c> searchSettingsList = prepareSearchSettingsList(
			'LastName;IsPersonAccount ',
			'Accounts',
			'Account',
			null
		);
		
		RecordType personAccount = [ SELECT Id FROM RecordType WHERE Name = 'Professional_vod' AND SObjectType = 'Account' LIMIT 1]; 		
		insert new Account(LastName = testString, RecordTypeId = personAccount.Id);

		Test.startTest();	
			ApexPages.currentPage().getParameters().put('searchString', testString);
			GNE_SFA2_Search_Controller app = new GNE_SFA2_Search_Controller();
        	List<SFA2_Search_Settings_gne__c> searchSettings2 = app.getSearchSettings(GNE_SFA2_Application_Cache.userApplicationContext);
			List<String> searchQueries = app.buildListOfSearchQueries(searchSettings2);
		Test.stopTest();
		
		system.assertEquals(searchQueries.size(), 1);
		system.assertEquals(searchQueries.get(0), 'FIND \'testSearch*\' IN ALL FIELDS RETURNING Account(LastName, IsPersonAccount, Id LIMIT 25)');
    }
    
    static testMethod void testGetSectionHeadersMap() {
		List<SFA2_Search_Settings_gne__c> searchSettingsList = prepareSearchSettingsList(
			'LastName;IsPersonAccount ',
			'Accounts',
			'Account',
			null
		);

		RecordType personAccount = [ SELECT Id FROM RecordType WHERE Name = 'Professional_vod' AND SObjectType = 'Account' LIMIT 1]; 		
		insert new Account(FirstName = testString, LastName = testString, RecordTypeId = personAccount.Id);		

		Test.startTest();	
			ApexPages.currentPage().getParameters().put('searchString', testString);
			GNE_SFA2_Search_Controller app = new GNE_SFA2_Search_Controller();
			Map<String, String> sectionHeadersMap = app.getSectionHeadersMap(searchSettingsList);
		Test.stopTest();
		
		system.assertEquals(sectionHeadersMap.size(), 1);
		system.assertEquals(sectionHeadersMap.get('Account'), 'Accounts');
    }
    
    static testMethod void testUpdateViewColumnLabels() {
		SFA2_Search_Settings_gne__c searchSettings = prepareSearchSettings(
			'LastName;IsPersonAccount ',
			'Accounts',
			'Account',
			null
		);
		searchSettings.Field_Header_gne__c = 'LastName = '+testString+'';
        GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
		
        Schema.DescribeSObjectResult sObjectDescribe = GNE_SFA2_Application_Cache.describeObject(searchSettings.Object_gne__c);
        Map<String, Schema.SObjectField> sObjectFieldMap = sObjectDescribe.fields.getMap();
        Schema.SObjectField sObjectField = sObjectFieldMap.get('LastName');
        		
		List<GNE_SFA2_Search_Controller.ViewColumnDescribe> viewColumns = new List<GNE_SFA2_Search_Controller.ViewColumnDescribe>();
        GNE_SFA2_Search_Controller.ViewColumnDescribe viewColumn = new GNE_SFA2_Search_Controller.ViewColumnDescribe(sObjectField.getDescribe());
        viewColumns.add(viewColumn);
            
		Test.startTest();	
			ApexPages.currentPage().getParameters().put('searchString', testString);
			GNE_SFA2_Search_Controller app = new GNE_SFA2_Search_Controller();
			app.updateViewColumnLabels(viewColumns, searchSettings);
		Test.stopTest();

		system.assertEquals(viewColumns.get(0).label, testString);
    }    
}