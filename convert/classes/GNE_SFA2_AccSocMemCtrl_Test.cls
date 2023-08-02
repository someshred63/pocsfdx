@isTest
public with sharing class GNE_SFA2_AccSocMemCtrl_Test {
	private static void init() {
		GNE_SFA2_PREP_Test_Helper.init();
		GNE_SFA2_PREP_Test_Helper.insertAccSocMemCOs();
	}
	
	private static void init(String userRole, Integer accountSize) {
		GNE_SFA2_PREP_Test_Helper.init(userRole, accountSize);
		GNE_SFA2_PREP_Test_Helper.insertAccSocMemCOs();
	}
	
	private static List<SFA2_Account_Society_Membership_gne__c> insertAccSocMems(Id accId) {
		List<SFA2_Account_Society_Membership_gne__c> accSocMems = new List<SFA2_Account_Society_Membership_gne__c>();
		accSocMems.add(new SFA2_Account_Society_Membership_gne__c(Account_gne__c = accId, Membership_Name_gne__c = 'CAP', Year_gne__c = '2014'));
		accSocMems.add(new SFA2_Account_Society_Membership_gne__c(Account_gne__c = accId, Other_gne__c = 'NASA', Year_gne__c = '2015'));
		insert accSocMems;
		return accSocMems;
	}
	
	private TestMethod static void testInitControllerViewMode() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP'))[0];
		GNE_SFA2_AccSocMem_Layout_Ctrl ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			List<SFA2_Account_Society_Membership_gne__c> accSocMems = insertAccSocMems(accId);
			PageReference pageRef = Page.GNE_SFA2_AccSocMem_Layout;
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(accSocMems[0]);
        	ctrl = new GNE_SFA2_AccSocMem_Layout_Ctrl(stdCtrl);
        	pRef = ctrl.init();
		}
		
		System.assertEquals(null, pRef, 'PegeReference not null: ' + (pRef!=null ? pRef.getURL() : ''));
	}
	
	private TestMethod static void testInitControllerNewMode() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP'))[0];
		GNE_SFA2_AccSocMem_Edit_Create_Ctrl ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_AccSocMem_Edit_Create;
			pageRef.getParameters().put('accountId', accId);
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new SFA2_Account_Society_Membership_gne__c());
        	ctrl = new GNE_SFA2_AccSocMem_Edit_Create_Ctrl(stdCtrl);
        	pRef = ctrl.init();
		}
		
		System.assertEquals(null, pRef, 'PegeReference not null: ' + (pRef!=null ? pRef.getURL() : ''));
		System.assertNotEquals(null, ctrl.myObject, 'MyObject should be set');
		System.assertEquals(null, ctrl.myObject.Id, 'MyObject Id should be null');
		System.assertEquals(accId, ctrl.myObject.get('Account_gne__c'), 'MyObject Account Id should be set');
		System.assertEquals(System.today().year()-10, ctrl.startYear, 'Year\'s range should start from -10 years from now');
		System.assertEquals(System.today().year()+10, ctrl.endYear, 'Year\'s range should start from -10 years from now');
	}
	
	private TestMethod static void testInitControllerEditMode() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP'))[0];
		GNE_SFA2_AccSocMem_Edit_Create_Ctrl ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			List<SFA2_Account_Society_Membership_gne__c> accSocMems = insertAccSocMems(accId);
			PageReference pageRef = Page.GNE_SFA2_AccSocMem_Edit_Create;
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(accSocMems[0]);
        	ctrl = new GNE_SFA2_AccSocMem_Edit_Create_Ctrl(stdCtrl);
        	pRef = ctrl.init();
		}
		
		System.assertEquals(null, pRef, 'PegeReference not null: ' + (pRef!=null ? pRef.getURL() : ''));
		System.assertNotEquals(null, ctrl.myObject, 'MyObject should be set');
		System.assertNotEquals(null, ctrl.myObject.Id, 'MyObject Id should be set');
		System.assertEquals(accId, ctrl.myObject.get('Account_gne__c'), 'MyObject Account Id should be set');
		System.assertEquals(System.today().year()-10, ctrl.startYear, 'Year\'s range should start from -10 years from now');
		System.assertEquals(System.today().year()+10, ctrl.endYear, 'Year\'s range should start from -10 years from now');
	}
	
	private TestMethod static void testCreateSocialMembership() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP'))[0];
		GNE_SFA2_AccSocMem_Edit_Create_Ctrl ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			PageReference pageRef = Page.GNE_SFA2_AccSocMem_Edit_Create;
			pageRef.getParameters().put('accountId', accId);
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new SFA2_Account_Society_Membership_gne__c());
        	ctrl = new GNE_SFA2_AccSocMem_Edit_Create_Ctrl(stdCtrl);
        	pRef = ctrl.init();
        	ctrl.myObject.put('Membership_Name_gne__c','CAP');
        	ctrl.myObject.put('Year_gne__c','2014');
        	pRef = ctrl.save();
		}
		
		System.assertNotEquals(null, pRef, 'PegeReference not set');
		System.assert(pRef.getUrl().containsIgnoreCase(Page.GNE_SFA2_Account_Layout.getUrl()), 'PageReference not set to Account Layout. Current page is: ' + pRef.getUrl());
		System.assertEquals(1, [SELECT count() FROM SFA2_Account_Society_Membership_gne__c], 'Exactly one Social Membership should be in Database');
	}
	
	private TestMethod static void testEditSocialMembership() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP'))[0];
		GNE_SFA2_AccSocMem_Edit_Create_Ctrl ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			List<SFA2_Account_Society_Membership_gne__c> accSocMems = insertAccSocMems(accId);
			PageReference pageRef = Page.GNE_SFA2_AccSocMem_Edit_Create;
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(accSocMems[0]);
        	ctrl = new GNE_SFA2_AccSocMem_Edit_Create_Ctrl(stdCtrl);
        	pRef = ctrl.init();
        	ctrl.myObject.put('Year_gne__c','2016');
        	pRef = ctrl.save();
		}
		
		System.assertNotEquals(null, pRef, 'PegeReference not set');
		System.assert(pRef.getUrl().containsIgnoreCase(Page.GNE_SFA2_Account_Layout.getUrl()), 'PageReference not set to Account Layout. Current page is: ' + pRef.getUrl());
		System.assertEquals(2, [SELECT count() FROM SFA2_Account_Society_Membership_gne__c], 'Exactly two Social Membership should be in Database');
		System.assertEquals('2016', [SELECT Year_gne__c FROM SFA2_Account_Society_Membership_gne__c WHERE Id = :ctrl.myObject.Id].Year_gne__c, 'Year should be changed after save');
	}
	
	private TestMethod static void testDeleteSocialMembership() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP'))[0];
		GNE_SFA2_AccSocMem_Layout_Ctrl ctrl;
		PageReference pRef;
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			List<SFA2_Account_Society_Membership_gne__c> accSocMems = insertAccSocMems(accId);
			PageReference pageRef = Page.GNE_SFA2_AccSocMem_Layout;
			Test.setCurrentPage(pageRef);
        	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(accSocMems[0]);
        	ctrl = new GNE_SFA2_AccSocMem_Layout_Ctrl(stdCtrl);
        	pRef = ctrl.init();
        	pRef = ctrl.deleteClick();
		}
		
		System.assertNotEquals(null, pRef, 'PegeReference not set');
		System.assert(pRef.getUrl().containsIgnoreCase(Page.GNE_SFA2_Account_Layout.getUrl()), 'PageReference not set to Account Layout. Current page is: ' + pRef.getUrl());
		System.assertEquals(1, [SELECT count() FROM SFA2_Account_Society_Membership_gne__c], 'Exactly one Social Membership should be in Database');
	}
}