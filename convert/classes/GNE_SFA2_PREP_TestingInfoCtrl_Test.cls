@isTest
public with sharing class GNE_SFA2_PREP_TestingInfoCtrl_Test {
	private static void init() {
		GNE_SFA2_PREP_Test_Helper.init();
		GNE_SFA2_PREP_Test_Helper.insertTestingInfoCOs();
	}
	
	private static void init(String userRole, Integer accountSize) {
		GNE_SFA2_PREP_Test_Helper.init(userRole, accountSize);
		GNE_SFA2_PREP_Test_Helper.insertTestingInfoCOs();
	}
	
	private static List<SFA2_PREP_Account_Testing_Info_gne__c> insertAccountTestingInfo(Id accId) {
		List<SFA2_PREP_Account_Testing_Info_gne__c> tInfos = new List<SFA2_PREP_Account_Testing_Info_gne__c>();
		
		tInfos.add(new SFA2_PREP_Account_Testing_Info_gne__c(Account_gne__c = accId, Test_Type_gne__c = 'Breast Cancer HER2 Testing', 
				Test_Component_gne__c = 'PC Only', Test_Hierarchy_gne__c = 'Primary', Test_Method_gne__c = 'IHC', 
				Testing_Volume_Month_gne__c = 100));
		tInfos.add(new SFA2_PREP_Account_Testing_Info_gne__c(Account_gne__c = accId, Test_Type_gne__c = 'mGeJ/mGastric Testing', Testing_Volume_Month_gne__c = 100));
		
		insert tInfos;
		return tInfos;
	}
	
	private TestMethod static void testInitAccountDetailPageControllerNoInfos() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		GNE_SFA2_PREP_Testing_Information_Ctrl.ControllerData ctrlData;
		
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			ctrlData = GNE_SFA2_PREP_Testing_Information_Ctrl.getInitData(accId);
		}
		
		System.assertNotEquals(0, ctrlData.columnApiNames.size(), 'Wrong Number of Column Headers');
		System.assertEquals(ctrlData.columnApiNames.size(), ctrlData.columnHeaders.size(), 'Number of columns different than number of culumn headers');
		System.assertEquals(accId, ctrlData.accId, 'Wrong Account Id');
		System.assertEquals(0, ctrlData.tInfos.size(), 'List of Testing Information should be empty');
	}
	
	private TestMethod static void testInitAccountDetailPageController() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		GNE_SFA2_PREP_Testing_Information_Ctrl.ControllerData ctrlData;
		
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			insertAccountTestingInfo(accId);
			ctrlData = GNE_SFA2_PREP_Testing_Information_Ctrl.getInitData(accId);
		}
		
		System.assertNotEquals(0, ctrlData.columnApiNames.size(), 'Wrong Number of Column Headers');
		System.assertEquals(ctrlData.columnApiNames.size(), ctrlData.columnHeaders.size(), 'Number of columns different than number of culumn headers');
		System.assertEquals(accId, ctrlData.accId, 'Wrong Account Id');
		System.assertEquals(2, ctrlData.tInfos.size(), 'Wrong Number of Testing Information');
	}
	
	private TestMethod static void testInitTestingInfoCtrlNewMode() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		GNE_SFA2_PREP_TestingInfo_Ctrl ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PREP_TestingInfo_Edit_Create;
			pageRef.getParameters().put('accId', accId);
        	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new SFA2_PREP_Account_Testing_Info_gne__c());
        	ctrl = new GNE_SFA2_PREP_TestingInfo_Ctrl(stdCtrl);
        	pRef = ctrl.init();
		}
		System.assertEquals(null, pRef, 'PegeReference not null: ' + (pRef!=null ? pRef.getURL() : ''));
		System.assertEquals(null, ctrl.recId, 'Rec Id should be null');
		System.assertEquals(accId, ctrl.accId, 'Account Id should not be null');
		System.assertNotEquals(null, ctrl.record, 'Record should not be null');
		System.assertEquals(1, ctrl.recordPerTestType.size(), 'Wrong number of records per Test Type');
		System.assertEquals(String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.sObjectType), ctrl.objectType, 'Wrong object Type');
		System.assertNotEquals(null, ctrl.customLookupEngine, 'Custom Lookup Engine is not set');
		System.assertNotEquals(0, ctrl.sectionsList.size(), 'Sections List is empty');
		System.assertNotEquals(0, ctrl.sectionsMap.size(), 'Section Map is empty');
		System.assertNotEquals(null, ctrl.testTypeApiNamesInJSON, 'JSON Test Types is not set');
	}
	
	private TestMethod static void testInitTestingInfoCtrlEditMode() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		GNE_SFA2_PREP_TestingInfo_Ctrl ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			List<SFA2_PREP_Account_Testing_Info_gne__c> tInfos = insertAccountTestingInfo(accId);
			PageReference pageRef = Page.GNE_SFA2_PREP_TestingInfo_Edit_Create;
			pageRef.getParameters().put('accId', accId);
        	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(tInfos[0]);
        	ctrl = new GNE_SFA2_PREP_TestingInfo_Ctrl(stdCtrl);
        	pRef = ctrl.init();
		}
		System.assertEquals(null, pRef, 'PegeReference not null: ' + (pRef!=null ? pRef.getURL() : ''));
		System.assertNotEquals(null, ctrl.recId, 'Rec Id should be set');
		System.assertEquals(accId, ctrl.accId, 'Account Id should not be null');
		System.assertNotEquals(null, ctrl.record, 'Record should not be null');
		System.assertEquals(1, ctrl.recordPerTestType.size(), 'Wrong number of records per Test Type');
		System.assertEquals(String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.sObjectType), ctrl.objectType, 'Wrong object Type');
		System.assertNotEquals(null, ctrl.customLookupEngine, 'Custom Lookup Engine is not set');
		System.assertNotEquals(0, ctrl.sectionsList.size(), 'Sections List is empty');
		System.assertNotEquals(0, ctrl.sectionsMap.size(), 'Section Map is empty');
		System.assertNotEquals(null, ctrl.testTypeApiNamesInJSON, 'JSON Test Types is not set');
	}
	
	private TestMethod static void testSaveInfoCtrlNewMode() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		GNE_SFA2_PREP_TestingInfo_Ctrl ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PREP_TestingInfo_Edit_Create;
			pageRef.getParameters().put('accId', accId);
        	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new SFA2_PREP_Account_Testing_Info_gne__c());
        	ctrl = new GNE_SFA2_PREP_TestingInfo_Ctrl(stdCtrl);
        	ctrl.init();
        	ctrl.record.Test_Type_gne__c = 'Breast Cancer HER2 Testing';
        	String testTypeApiName = GNE_SFA2_PREP_Config.getTestTypeApiName(ctrl.record.Test_Type_gne__c);
        	SFA2_PREP_Account_Testing_Info_gne__c rec = ctrl.recordPerTestType.get(testTypeApiName);
        	rec.Test_Component_gne__c = 'PC Only';
        	rec.Test_Hierarchy_gne__c = 'Primary';
        	rec.Test_Method_gne__c = 'IHC';
        	rec.Testing_Volume_Month_gne__c = 100;
        	pRef = ctrl.save();
		}
		System.assertNotEquals(null, pRef, 'PegeReference not set');
		System.assert(pRef.getUrl().contains(Page.GNE_SFA2_Account_Layout.getUrl()), 'PageReference not set to Account Layout');
		System.assertEquals(null, ctrl.recId, 'Rec Id should be null');
		System.assertEquals(accId, ctrl.accId, 'Account Id should not be null');
		System.assertNotEquals(null, ctrl.record, 'Record should not be null');
		System.assertEquals(1, ctrl.recordPerTestType.size(), 'Wrong number of records per Test Type');
		System.assertEquals(String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.sObjectType), ctrl.objectType, 'Wrong object Type');
		System.assertNotEquals(null, ctrl.customLookupEngine, 'Custom Lookup Engine is not set');
		System.assertNotEquals(0, ctrl.sectionsList.size(), 'Sections List is empty');
		System.assertNotEquals(0, ctrl.sectionsMap.size(), 'Section Map is empty');
		System.assertNotEquals(null, ctrl.testTypeApiNamesInJSON, 'JSON Test Types is not set');
		
		System.assertEquals(1, [SELECT count() FROM SFA2_PREP_Account_Testing_Info_gne__c], 'One Testing Info should be in Database');
	}
	
	private TestMethod static void testSaveInfoCtrlEditMode() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		GNE_SFA2_PREP_TestingInfo_Ctrl ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			List<SFA2_PREP_Account_Testing_Info_gne__c> tInfos = insertAccountTestingInfo(accId);
			PageReference pageRef = Page.GNE_SFA2_PREP_TestingInfo_Edit_Create;
			pageRef.getParameters().put('accId', accId);
        	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(tInfos[0]);
        	ctrl = new GNE_SFA2_PREP_TestingInfo_Ctrl(stdCtrl);
        	ctrl.init();
        	String testTypeApiName = GNE_SFA2_PREP_Config.getTestTypeApiName('Breast Cancer HER2 Testing');
        	SFA2_PREP_Account_Testing_Info_gne__c rec = ctrl.recordPerTestType.get(testTypeApiName);
        	rec.Testing_Volume_Month_gne__c = 101;
        	pRef = ctrl.save();
		}
		System.assertNotEquals(null, pRef, 'PegeReference not set');
		System.assert(pRef.getUrl().contains(Page.GNE_SFA2_Account_Layout.getUrl()), 'PageReference not set to Account Layout');
		System.assertNotEquals(null, ctrl.recId, 'Rec Id should be set');
		System.assertEquals(accId, ctrl.accId, 'Account Id should not be null');
		System.assertNotEquals(null, ctrl.record, 'Record should not be null');
		System.assertEquals(1, ctrl.recordPerTestType.size(), 'Wrong number of records per Test Type');
		System.assertEquals(String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.sObjectType), ctrl.objectType, 'Wrong object Type');
		System.assertNotEquals(null, ctrl.customLookupEngine, 'Custom Lookup Engine is not set');
		System.assertNotEquals(0, ctrl.sectionsList.size(), 'Sections List is empty');
		System.assertNotEquals(0, ctrl.sectionsMap.size(), 'Section Map is empty');
		System.assertNotEquals(null, ctrl.testTypeApiNamesInJSON, 'JSON Test Types is not set');
		
		System.assertEquals(2, [SELECT count() FROM SFA2_PREP_Account_Testing_Info_gne__c], 'Two Testing Infos should be in Database');
	}
	
	private TestMethod static void testSaveInfoHandlingException() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		GNE_SFA2_PREP_TestingInfo_Ctrl ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PREP_TestingInfo_Edit_Create;
			pageRef.getParameters().put('accId', accId);
        	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new SFA2_PREP_Account_Testing_Info_gne__c());
        	ctrl = new GNE_SFA2_PREP_TestingInfo_Ctrl(stdCtrl);
        	ctrl.init();
        	ctrl.record.Test_Type_gne__c = 'Breast Cancer HER2 Testing';
        	String testTypeApiName = GNE_SFA2_PREP_Config.getTestTypeApiName(ctrl.record.Test_Type_gne__c);
        	SFA2_PREP_Account_Testing_Info_gne__c rec = ctrl.recordPerTestType.get(testTypeApiName);
        	rec.Test_Component_gne__c = 'PC Only';
        	rec.Test_Hierarchy_gne__c = 'Primary';
        	rec.Test_Method_gne__c = 'IHC';
        	rec.Testing_Volume_Month_gne__c = 100;
        	rec.Percent_of_TC_gne__c = -1;
        	pRef = ctrl.save();
		}
		
		System.assertEquals(0, [SELECT count() FROM SFA2_PREP_Account_Testing_Info_gne__c], 'No Testing Info should be in Database');
		System.assertEquals(1, ApexPages.getMessages().size(), 'No Errors logged');
		System.assert(ApexPages.getMessages()[0].getSummary().contains(System.Label.GNE_SFA2_PREP_NUMBER_OUT_OF_RANGE.substringBefore('.')), '"Number out of range" error not logged');
	}
	
	private TestMethod static void testSaveInfoRequiredFieldMissing() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		GNE_SFA2_PREP_TestingInfo_Ctrl ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_PREP_TestingInfo_Edit_Create;
			pageRef.getParameters().put('accId', accId);
        	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new SFA2_PREP_Account_Testing_Info_gne__c());
        	ctrl = new GNE_SFA2_PREP_TestingInfo_Ctrl(stdCtrl);
        	ctrl.init();
        	ctrl.record.Test_Type_gne__c = 'Breast Cancer HER2 Testing';
        	String testTypeApiName = GNE_SFA2_PREP_Config.getTestTypeApiName(ctrl.record.Test_Type_gne__c);
        	SFA2_PREP_Account_Testing_Info_gne__c rec = ctrl.recordPerTestType.get(testTypeApiName);
        	rec.Test_Component_gne__c = 'PC Only';
        	rec.Test_Hierarchy_gne__c = 'Primary';
        	rec.Test_Method_gne__c = null;
        	rec.Testing_Volume_Month_gne__c = 100;
        	rec.Percent_of_TC_gne__c = -1;
        	pRef = ctrl.save();
		}
		
		System.assertEquals(0, [SELECT count() FROM SFA2_PREP_Account_Testing_Info_gne__c], 'No Testing Info should be in Database');
		System.assertEquals(1, ApexPages.getMessages().size(), 'No Errors logged');
		//System.assert(ApexPages.getMessages()[0].getSummary().contains(System.Label.GNE_SFA2_PREP_REQUIRED_FIELD.substringAfter(':')), '"Required field" error not logged');
	}
	
	private TestMethod static void testDeleteInfoCtrlEditMode() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		GNE_SFA2_PREP_TestingInfo_Ctrl ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			List<SFA2_PREP_Account_Testing_Info_gne__c> tInfos = insertAccountTestingInfo(accId);
			PageReference pageRef = Page.GNE_SFA2_PREP_TestingInfo_Layout;
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(tInfos[0]);
        	ctrl = new GNE_SFA2_PREP_TestingInfo_Ctrl(stdCtrl);
        	ctrl.init();
        	String testTypeApiName = GNE_SFA2_PREP_Config.getTestTypeApiName('Breast Cancer HER2 Testing');
        	SFA2_PREP_Account_Testing_Info_gne__c rec = ctrl.recordPerTestType.get(testTypeApiName);
        	rec.Testing_Volume_Month_gne__c = 101;
        	pRef = ctrl.deleteClick();
		}
		System.assertNotEquals(null, pRef, 'PegeReference not set');
		System.assert(pRef.getUrl().contains(Page.GNE_SFA2_Account_Layout.getUrl()), 'PageReference not set to Account Layout');
		System.assertEquals(1, [SELECT count() FROM SFA2_PREP_Account_Testing_Info_gne__c], 'One Testing Infos should be in Database');
	}
	
	private TestMethod static void testGetButtonsDynamicComponent() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		GNE_SFA2_PREP_TestingInfo_Ctrl ctrl;
		Component.Apex.PageBlockButtons buttons;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			List<SFA2_PREP_Account_Testing_Info_gne__c> tInfos = insertAccountTestingInfo(accId);
			PageReference pageRef = Page.GNE_SFA2_PREP_TestingInfo_Layout;
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(tInfos[0]);
        	ctrl = new GNE_SFA2_PREP_TestingInfo_Ctrl(stdCtrl);
        	ctrl.init();
        	buttons = ctrl.getCustomButtons();
		}
		System.assertNotEquals(null, buttons, 'PageBlockButtons not set');
	}
}