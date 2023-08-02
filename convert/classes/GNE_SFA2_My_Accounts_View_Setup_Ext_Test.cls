/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-09-23
*  Description: This is a test class for GNE_SFA2_My_Accounts_View_Setup_Ext
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
private class GNE_SFA2_My_Accounts_View_Setup_Ext_Test {
	
	public static testMethod void testConstructor() {
		User u = GNE_SFA2_Util.selectSFA2User();
		system.runAs(u){
			prepareSettings('SFA-US', 'Actemra', 'CS');

			PageReference myAccViewSetupPage = Page.GNE_SFA2_My_Accounts_View_Setup;
			Test.setCurrentPage(myAccViewSetupPage);
			GNE_SFA2_My_Accounts_View_Setup_Ext ext = new GNE_SFA2_My_Accounts_View_Setup_Ext(new ApexPages.StandardController(new SFA2_View_Config_gne__c()));

			system.assertEquals(5, ext.records.size());
			system.assertEquals(3, ext.picklistOperators.size());
			system.assertEquals(3, ext.multipicklistOperators.size());
			system.assertEquals(3, ext.booleanOperators.size());
			system.assertEquals(10, ext.stringOperators.size());
			system.assertEquals(7, ext.numberOperators.size());
			system.assertEquals(0, ext.selectedPersonRecordTypes.size());
			system.assertEquals(0, ext.selectedAccountRecordTypes.size());

			system.assertNotEquals(null, ext.personRecordTypesList);
			system.assertNotEquals(null, ext.accountRecordTypesList);

			system.assertEquals(10, ext.viewFieldsList.size());
			system.assertEquals(5, ext.filterFieldsList.size());
			system.assertEquals(5, ext.filterOperatorsList.size());
			system.assertEquals(5, ext.filterValuesList.size());

			system.assertEquals(10, ext.viewRecords.size());
			system.assertEquals('Account', ext.viewRecords[0]);
			system.assertEquals(10, ext.viewFields.size());
			system.assertEquals('Name', ext.viewFields[0]);
			system.assertEquals(10, ext.viewFieldType.size());
			system.assertEquals(5, ext.filterFieldType.size());
			system.assertEquals(5, ext.filterErrors.size());
			system.assertEquals(5, ext.filterErrorMessagesMap.size());
                        
			system.assertEquals(0, ext.recordSequence);
			system.assertEquals(0, ext.sortRow);

			//test for exisiting view
			SFA2_View_Config_gne__c sampleView = new SFA2_View_Config_gne__c();
			sampleView.Account_Record_Types_gne__c = 'Hospital_vod,Practice_vod';
			sampleView.Person_Record_Types_gne__c = 'Professional_vod,HealthCareProfessional';
			sampleView.View_Fields_gne__c = 'Account.Name;Address.Name;BrandAffiliation.CreatedBy.Name;TSF.Territory_vod__c';
			sampleView.Sorting_Field_gne__c = 'Address.Name';
			sampleView.Object_Type_gne__c = 'Account';
			sampleView.Page_Name_gne__c = 'GNE_SFA2_My_Accounts';
			sampleView.View_Name_gne__c = 'test';
			insert sampleView;
			ext = new GNE_SFA2_My_Accounts_View_Setup_Ext(new ApexPages.StandardController(sampleView));

			system.assertEquals(5, ext.records.size());
			system.assertEquals(3, ext.picklistOperators.size());
			system.assertEquals(3, ext.multipicklistOperators.size());
			system.assertEquals(3, ext.booleanOperators.size());
			system.assertEquals(10, ext.stringOperators.size());
			system.assertEquals(7, ext.numberOperators.size());
			system.assertEquals(2, ext.selectedPersonRecordTypes.size());
			system.assertEquals(2, ext.selectedAccountRecordTypes.size());

			system.assertNotEquals(null, ext.personRecordTypesList);
			system.assertNotEquals(null, ext.accountRecordTypesList);

			system.assertEquals(10, ext.viewFieldsList.size());
			system.assertEquals(5, ext.filterFieldsList.size());
			system.assertEquals(5, ext.filterOperatorsList.size());
			system.assertEquals(5, ext.filterValuesList.size());

			system.assertEquals(10, ext.viewRecords.size());
			system.assertEquals('Account', ext.viewRecords[0]);
			system.assertEquals(10, ext.viewFields.size());
			system.assertEquals('Name', ext.viewFields[0]);
			system.assertEquals(10, ext.viewFieldType.size());
			system.assertEquals(5, ext.filterFieldType.size());
			system.assertEquals(5, ext.filterErrors.size());
			system.assertEquals(5, ext.filterErrorMessagesMap.size());
                        
			system.assertEquals(3, ext.recordSequence);
			system.assertEquals(1, ext.sortRow);

		}
	}

	public static testMethod void testFiltering(){
		User u = GNE_SFA2_Util.selectSFA2User();
		system.runAs(u){
			prepareSettings('SFA-US', 'Actemra', 'CS');

			List<String> valueType = new List<String>{'STRING', 'PICKLIST', 'MULTIPICKLIST', 'DOUBLE', 'BOOLEAN'};
			List<String> value = new List<String>{'test', null, null,'5', 'true'};
			List<String> record = new List<String>{'BrandAffiliation', 'Account', 'Address', 'TSF', 'Account'};
			List<String> operator = new List<String>{'eq', 'ecl', 'inc', 'gte', 'eq'};
			List<List<String>> multiValue = new List<List<String>>{null, new List<String>{'Satellite'}, new List<String>{'Activase'}, null, null};
			List<String> field = new List<String>{'CreatedBy.Name', 'Practice_Type_gne__c', 'Genentech_Product_Experience_gne__c', 'Planned_Frequency_can_gne__c', 'X340B_Eligible_gne__c'};
			List<String> brand = new List<String>{'Actemra', null, null, null, null};
			String filter = createFilter(valueType, value, record, operator, multiValue, field, brand);

			SFA2_View_Config_gne__c sampleView = new SFA2_View_Config_gne__c();
			sampleView.Account_Record_Types_gne__c = 'Hospital_vod,Practice_vod';
			sampleView.Person_Record_Types_gne__c = 'Professional_vod,HealthCareProfessional';
			sampleView.View_Fields_gne__c = 'Account.Name;Address.Name;BrandAffiliation.CreatedBy.Name;TSF.Territory_vod__c';
			sampleView.Sorting_Field_gne__c = 'Address.Name';
			sampleView.Object_Type_gne__c = 'Account';
			sampleView.Page_Name_gne__c = 'GNE_SFA2_My_Accounts';
			sampleView.View_Name_gne__c = 'test';
			sampleView.Filter_Statement_gne__c = filter;
			insert sampleView;
			GNE_SFA2_My_Accounts_View_Setup_Ext ext = new GNE_SFA2_My_Accounts_View_Setup_Ext(new ApexPages.StandardController(sampleView));
			for(Integer i = 0; i < 5; i++){
				ext.filterSequence = i;
				ext.prepareFilterOperators();
				system.assertNotEquals(1, ext.filterOperatorsList[i].size());
			}

			system.assertEquals(null, ext.assignSortRow());
		}
	}

	public static testMethod void testGettersAndSetters(){
		User u = GNE_SFA2_Util.selectSFA2User();
		system.runAs(u){
			prepareSettings('SFA-US', 'Actemra', 'CS');

			GNE_SFA2_My_Accounts_View_Setup_Ext ext = new GNE_SFA2_My_Accounts_View_Setup_Ext(new ApexPages.StandardController(new SFA2_View_Config_gne__c()));
			
			String test = 'test';
			List<String> testList = new List<String>{'test','test2'};

			ext.setViewRecord0(null);
			system.assertEquals('', ext.getViewRecord0());
			ext.setViewRecord1(null);
			system.assertEquals('', ext.getViewRecord1());
			ext.setViewRecord2(null);
			system.assertEquals('', ext.getViewRecord2());
			ext.setViewRecord3(null);
			system.assertEquals('', ext.getViewRecord3());
			ext.setViewRecord4(null);
			system.assertEquals('', ext.getViewRecord4());			
			ext.setViewRecord5(null);
			system.assertEquals('', ext.getViewRecord5());
			ext.setViewRecord6(null);
			system.assertEquals('', ext.getViewRecord6());
			ext.setViewRecord7(null);
			system.assertEquals('', ext.getViewRecord7());
			ext.setViewRecord8(null);
			system.assertEquals('', ext.getViewRecord8());
			ext.setViewRecord9(null);
			system.assertEquals('', ext.getViewRecord9());

			ext.setViewField0(null);
			system.assertEquals('', ext.getViewField0());
			ext.setViewField1(null);
			system.assertEquals('', ext.getViewField1());
			ext.setViewField2(null);
			system.assertEquals('', ext.getViewField2());
			ext.setViewField3(null);
			system.assertEquals('', ext.getViewField3());
			ext.setViewField4(null);
			system.assertEquals('', ext.getViewField4());			
			ext.setViewField5(null);
			system.assertEquals('', ext.getViewField5());
			ext.setViewField6(null);
			system.assertEquals('', ext.getViewField6());
			ext.setViewField7(null);
			system.assertEquals('', ext.getViewField7());
			ext.setViewField8(null);
			system.assertEquals('', ext.getViewField8());
			ext.setViewField9(null);
			system.assertEquals('', ext.getViewField9());

			ext.setFilterRecord0(test);
			system.assertEquals(test, ext.getFilterRecord0());
			ext.setFilterRecord1(test);
			system.assertEquals(test, ext.getFilterRecord1());
			ext.setFilterRecord2(test);
			system.assertEquals(test, ext.getFilterRecord2());
			ext.setFilterRecord3(test);
			system.assertEquals(test, ext.getFilterRecord3());
			ext.setFilterRecord4(test);
			system.assertEquals(test, ext.getFilterRecord4());

			ext.setFilterField0(test);
			system.assertEquals(test, ext.getFilterField0());
			ext.setFilterField1(test);
			system.assertEquals(test, ext.getFilterField1());
			ext.setFilterField2(test);
			system.assertEquals(test, ext.getFilterField2());
			ext.setFilterField3(test);
			system.assertEquals(test, ext.getFilterField3());
			ext.setFilterField4(test);
			system.assertEquals(test, ext.getFilterField4());

			ext.setFilterOperator0(test);
			system.assertEquals(test, ext.getFilterOperator0());
			ext.setFilterOperator1(test);
			system.assertEquals(test, ext.getFilterOperator1());
			ext.setFilterOperator2(test);
			system.assertEquals(test, ext.getFilterOperator2());
			ext.setFilterOperator3(test);
			system.assertEquals(test, ext.getFilterOperator3());
			ext.setFilterOperator4(test);
			system.assertEquals(test, ext.getFilterOperator4());

			ext.setFilterValue0(test);
			system.assertEquals(test, ext.getFilterValue0());
			ext.setFilterValue1(test);
			system.assertEquals(test, ext.getFilterValue1());
			ext.setFilterValue2(test);
			system.assertEquals(test, ext.getFilterValue2());
			ext.setFilterValue3(test);
			system.assertEquals(test, ext.getFilterValue3());
			ext.setFilterValue4(test);
			system.assertEquals(test, ext.getFilterValue4());

			ext.setFilterMultiValues0(testList);
			system.assertEquals(testList, ext.getFilterMultiValues0());
			ext.setFilterMultiValues1(testList);
			system.assertEquals(testList, ext.getFilterMultiValues1());
			ext.setFilterMultiValues2(testList);
			system.assertEquals(testList, ext.getFilterMultiValues2());
			ext.setFilterMultiValues3(testList);
			system.assertEquals(testList, ext.getFilterMultiValues3());
			ext.setFilterMultiValues4(testList);
			system.assertEquals(testList, ext.getFilterMultiValues4());
		}
	}

	public static testMethod void testPageReferences(){
		User u = GNE_SFA2_Util.selectSFA2User();
		system.runAs(u){
			prepareSettings('SFA-US', 'Actemra', 'CS');

			List<String> valueType = new List<String>{'STRING', 'PICKLIST'};
			List<String> value = new List<String>{'test', null};
			List<String> record = new List<String>{'BrandAffiliation', 'Account'};
			List<String> operator = new List<String>{'eq', 'ecl'};
			List<List<String>> multiValue = new List<List<String>>{null, new List<String>{'Satellite'}};
			List<String> field = new List<String>{'CreatedBy.Name', 'Practice_Type_gne__c'};
			List<String> brand = new List<String>{'Actemra', null};
			String filter = createFilter(valueType, value, record, operator, multiValue, field, brand);

			SFA2_View_Config_gne__c sampleView = new SFA2_View_Config_gne__c();
			sampleView.Account_Record_Types_gne__c = 'Hospital_vod,Practice_vod';
			sampleView.Person_Record_Types_gne__c = 'Professional_vod,HealthCareProfessional';
			sampleView.View_Fields_gne__c = 'Account.Name;Address.Name;BrandAffiliation.CreatedBy.Name;TSF.Territory_vod__c';
			sampleView.Sorting_Field_gne__c = 'Address.Name';
			sampleView.Object_Type_gne__c = 'Account';
			sampleView.Page_Name_gne__c = 'GNE_SFA2_My_Accounts';
			sampleView.View_Name_gne__c = 'test';
			sampleView.Filter_Statement_gne__c = filter;
			insert sampleView;
			GNE_SFA2_My_Accounts_View_Setup_Ext ext = new GNE_SFA2_My_Accounts_View_Setup_Ext(new ApexPages.StandardController(sampleView));
			
			system.assertEquals(null, ext.assignSortRow());
			system.assertEquals(null, ext.rerenderViewFields());

			system.assert(ext.cancel().getURL().contains(Page.GNE_SFA2_MyAccounts.getURL()));


			ext.rowToDelete = 0;
			ext.rowToMove = 1;
			ext.deleteRow();
			system.assertEquals('',ext.viewRecords[0]);
			system.assertNotEquals('',ext.viewRecords[1]);
			ext.moveHigher();
			system.assertNotEquals('',ext.viewRecords[0]);
			system.assertEquals('',ext.viewRecords[1]);

			Integer viewCountBefore = [SELECT Count() FROM SFA2_View_Config_gne__c];
			PageReference pr = ext.save();
			system.assert(pr.getUrl().contains(Page.GNE_SFA2_MyAccounts.getUrl()), 'Unexpected URL: ' + pr.getUrl());
			Integer viewCount = [SELECT Count() FROM SFA2_View_Config_gne__c];
			system.assertEquals(viewCount, viewCountBefore);

			pr = ext.deleteView();
			system.assert(pr.getUrl().contains(Page.GNE_SFA2_MyAccounts.getUrl()), 'Unexpected URL: ' + pr.getUrl());

			viewCount = [SELECT Count() FROM SFA2_View_Config_gne__c];
			system.assertEquals(viewCountBefore-1, viewCount);

		}
	}

	private static void prepareSettings(String appType, String brand, String role){
		insert new GNE_SFA2_User_App_Context_gne__c(App_Name_gne__c = appType, Brand_gne__c = brand, Role_gne__c = role);
		GNE_SFA2_My_Accounts_Setttings__c myAccountSettings = new GNE_SFA2_My_Accounts_Setttings__c(Account_View_Columns_gne__c = 'Name,CreatedById', 
																									Address_View_Columns_gne__c = 'Name,Address_1_gne__c',
																									Brand_Affiliation_View_Columns_gne__c = 'Name,Source_gne__c',
																									PageSize_gne__c = 5,
																									TSF_View_Columns_gne__c = 'Last_Activity_Date_vod__c,Territory_vod__c',
																									Application_Type__c = appType,
																									Brand_gne__c = brand,
																									Role_gne__c = role
																									);
		insert myAccountSettings;
	}

	private static String createFilter(List<String> valueType, List<String> value, List<String> record, List<String> operator, List<List<String>> multiValue, List<String> field, List<String> brand){
		String filter = '[';
		for(Integer i = 0; i < valueType.size(); i++){
			if(i != 0){
				filter+=',';
			}
			filter += createSingleFilter(valueType[i], value[i], record[i], operator[i], multiValue[i], field[i], brand[i]);
		}
		filter += ']';
		return filter;
	}

	private static String createSingleFilter(String valueType, String value, String record, String operator, List<String> multiValue, String field, String brand){
		String multiValueString = '';
		if(multiValue != null && multiValue.size()>0){
			for(String mValue :multiValue){
				if(multiValueString!=''){
					multiValueString+=',';
				}
				if(mValue != null){
					multiValueString+='"' + mValue + '"';
				} else {
					multiValueString+=mValue;
				}
			}
		}
		valueType = valueType == null ? valueType : '"' + valueType + '"';
		value = value == null ? value : '"' + value + '"';
		record = record == null ? record : '"' + record + '"';
		operator = operator == null ? operator : '"' + operator + '"';
		field = field == null ? field : '"' + field + '"';
		brand = brand == null ? brand : '"' + brand + '"';

		String filter = '{'
						+	'"valueType": ' + valueType + ','
						+	'"value": ' + value + ','
 						+	'"record": ' + record + ','
  						+	'"operator": ' + operator + ','
  						+	'"multiValue": [' + multiValueString + '],'
  						+	'"field": ' + field + ','
  						+	'"brand": ' + brand + ''
  						+ '}';
  		return filter;
	}
}