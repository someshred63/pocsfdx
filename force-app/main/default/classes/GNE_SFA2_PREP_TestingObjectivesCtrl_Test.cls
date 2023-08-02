@isTest 
public with sharing class GNE_SFA2_PREP_TestingObjectivesCtrl_Test {
	private static void init() {
		GNE_SFA2_PREP_Test_Helper.init();
	}
	
	private static void init(String userRole, Integer accountSize) {
		GNE_SFA2_PREP_Test_Helper.init(userRole, accountSize);
	}
	
	private TestMethod static void testInitController() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP'))[0];
		GNE_SFA2_PREP_Testing_Objectives_Ctrl.ControllerData ctrlData;
		
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			ctrlData = GNE_SFA2_PREP_Testing_Objectives_Ctrl.getInitData(accId);
		}
		
		System.assertEquals(3, ctrlData.tStrategies.size(), 'Wrong Number of available strategies');
		System.assertEquals(5, ctrlData.availableStatuses.size(), 'Wrong Number of available statuses');
		System.assertEquals(null, ctrlData.accStatus, 'Wrong Account PREP Status');
		System.assertEquals(true, ctrlData.canEdit, 'Wrong "Can Edit" flag');
		System.assertEquals(false, ctrlData.isHco, 'Wrong "Is HCO" flag');
		System.assertEquals(false, ctrlData.sendEmailNotificationMode, 'Wrong "Send Email Notification" flag');
	}
	
	private TestMethod static void testSaveStatus() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		GNE_SFA2_PREP_Testing_Objectives_Ctrl.ControllerData ctrlData;
		
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			ctrlData = GNE_SFA2_PREP_Testing_Objectives_Ctrl.getInitData(accId);
			ctrlData.tStrategies[0].mbos[0].status = GNE_SFA2_PREP_Util.PREP_STATUS_LIGHT_GREEN;
			ctrlData = GNE_SFA2_PREP_Testing_Objectives_Ctrl.updateStatus(accId, JSON.serialize(ctrlData));
		}
		
		System.assertEquals(3, [SELECT count() FROM SFA2_PREP_Account_Testing_Strategy_gne__c], 'Wrong Number of created Account Strategies');
		System.assertEquals(7, [SELECT count() FROM SFA2_PREP_Account_MBO_gne__c], 'Wrong Number of created Account MBOs');
		System.assertEquals(GNE_SFA2_PREP_Util.PREP_STATUS_LIGHT_GREEN, [SELECT Status_gne__c FROM SFA2_PREP_Account_MBO_gne__c WHERE MBO_gne__r.Name = :ctrlData.tStrategies[0].mbos[0].name].Status_gne__c, 'Wrong MBO Status');
		System.assertEquals(GNE_SFA2_PREP_Util.PREP_STATUS_YELLOW, [SELECT Status_gne__c FROM SFA2_PREP_Account_Testing_Strategy_gne__c WHERE Testing_Strategy_gne__r.Name = :ctrlData.tStrategies[0].name].Status_gne__c, 'Wrong Strategy Status');
		System.assertEquals(GNE_SFA2_PREP_Util.PREP_STATUS_YELLOW, [SELECT PREP_Status_gne__c FROM Account WHERE Id = :accId].PREP_Status_gne__c, 'Wrong Account PREP Status (check #1)');
		System.assertEquals(GNE_SFA2_PREP_Util.PREP_STATUS_YELLOW, ctrlData.accStatus, 'Wrong Account PREP Status (check #2)');
		System.assertEquals(true, ctrlData.canEdit, 'Wrong "Can Edit" flag');
		System.assertEquals(true, ctrlData.isHco, 'Wrong "Is HCO" flag');
		System.assertEquals(false, ctrlData.sendEmailNotificationMode, 'Wrong "Send Email Notification" flag');
	}
	
	private TestMethod static void testSwitchAccountToFullGreenStatus() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		GNE_SFA2_PREP_Testing_Objectives_Ctrl.ControllerData ctrlData;
		
		User currentUser = GNE_SFA2_PREP_Test_Helper.getCurrentUser();
		currentUser.ManagerId = GNE_SFA2_PREP_Test_Helper.userHelper.getUser('Manager').Id;
		GNE_SFA2_Admin_Mode__c adminModeSetting = GNE_SFA2_Admin_Mode__c.getInstance();
		adminModeSetting.GNE_SFA2_Is_Admin_Mode__c = true;
		upsert adminModeSetting;
		update currentUser;
		adminModeSetting.GNE_SFA2_Is_Admin_Mode__c = false;
		update adminModeSetting;
		
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			ctrlData = GNE_SFA2_PREP_Testing_Objectives_Ctrl.getInitData(accId);
			ctrlData.tStrategies[0].mbos[0].status = GNE_SFA2_PREP_Util.PREP_STATUS_LIGHT_GREEN;
			ctrlData = GNE_SFA2_PREP_Testing_Objectives_Ctrl.updateStatus(accId, JSON.serialize(ctrlData));
			
			for(GNE_SFA2_PREP_Testing_Objectives_Ctrl.TestingStrategyWrapper tStrat : ctrlData.tStrategies) {
				for(GNE_SFA2_PREP_Testing_Objectives_Ctrl.TestingMboWrapper mbo : tStrat.mbos) {
					mbo.status = GNE_SFA2_PREP_Util.PREP_STATUS_LIGHT_GREEN;
				}
			}
			
			ctrlData = GNE_SFA2_PREP_Testing_Objectives_Ctrl.updateStatus(accId, JSON.serialize(ctrlData));
		}
		
		System.assertEquals(3, [SELECT count() FROM SFA2_PREP_Account_Testing_Strategy_gne__c WHERE Status_gne__c = :GNE_SFA2_PREP_Util.PREP_STATUS_GREEN], 'Wrong Number of Account Green Strategies');
		System.assertEquals(7, [SELECT count() FROM SFA2_PREP_Account_MBO_gne__c WHERE Status_gne__c = :GNE_SFA2_PREP_Util.PREP_STATUS_LIGHT_GREEN], 'Wrong Number of Account Green MBOs');
		System.assertEquals(GNE_SFA2_PREP_Util.PREP_STATUS_GREEN, [SELECT PREP_Status_gne__c FROM Account WHERE Id = :accId].PREP_Status_gne__c, 'Wrong Account PREP Status (check #1)');
		System.assertEquals(GNE_SFA2_PREP_Util.PREP_STATUS_GREEN, ctrlData.accStatus, 'Wrong Account PREP Status (check #2)');
		System.assertEquals(true, ctrlData.canEdit, 'Wrong "Can Edit" flag');
		System.assertEquals(true, ctrlData.isHco, 'Wrong "Is HCO" flag');
		System.assertEquals(true, ctrlData.sendEmailNotificationMode, 'Wrong "Send Email Notification" flag');
	}
	
	private TestMethod static void testGetEmailContacts() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP'))[0];
		List<String> emailContacts;
		
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			emailContacts = GNE_SFA2_PREP_Testing_Objectives_Ctrl.getAvailableEmailContacts(accId);
		}
		
		System.assertNotEquals(null, emailContacts, 'Email Contacts List should not be null');
		System.assertNotEquals(0, emailContacts.size(), 'Email Contacts List should not be empty');
		System.assert(Pattern.matches('^[^<]+<[^@]+@[^@]+>', emailContacts[0]), 'Email Contact is not in valid format: [Contact Name] <[Contact Email]>');
	}
	
	private TestMethod static void testSendEmail() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP'))[0];
		GNE_SFA2_PREP_Testing_Objectives_Ctrl.ControllerData ctrlData;
		
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			ctrlData = GNE_SFA2_PREP_Testing_Objectives_Ctrl.getInitData(accId);
			ctrlData.emailData = new GNE_SFA2_PREP_Testing_Objectives_Ctrl.EmailData(new String[]{'test.email@test.domain.com'}, new String[]{}, 'TEST SUBJECT', 'TEST BODY');
			Test.startTest();
			ctrlData = GNE_SFA2_PREP_Testing_Objectives_Ctrl.sendEmail(accId, JSON.serialize(ctrlData));
			Test.stopTest();
		}
		
		System.assertEquals(0, ctrlData.errorMessages.size(), 'Error Messages should be empty');
		System.assertEquals(1, ctrlData.infoMessages.size(), 'There should be one Info Message');
		System.assertEquals(System.Label.GNE_SFA2_PREP_MANAGER_NOTIFICATION_SEND, ctrlData.infoMessages[0], 'Wrong Info Message');
	}
	
	private TestMethod static void testErrorHandling() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCP'))[0];
		GNE_SFA2_PREP_Testing_Objectives_Ctrl.ControllerData ctrlData;
		
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			ctrlData = GNE_SFA2_PREP_Testing_Objectives_Ctrl.getInitData(accId);
			ctrlData = GNE_SFA2_PREP_Testing_Objectives_Ctrl.updateStatus(accId, 'WRONG JSON STRING');
		}
		
		System.assertNotEquals(null, ctrlData.retURL);
	}
	
	private TestMethod static void testDeleteMbos() {
		init();
		Id accId = new List<Id>(GNE_SFA2_PREP_Test_Helper.accountHelper.accountsByTypeCache.get('US_HCO'))[0];
		GNE_SFA2_PREP_Testing_Objectives_Ctrl.ControllerData ctrlData;
		
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			ctrlData = GNE_SFA2_PREP_Testing_Objectives_Ctrl.getInitData(accId);
			ctrlData.tStrategies[0].mbos[0].status = GNE_SFA2_PREP_Util.PREP_STATUS_LIGHT_GREEN;
			ctrlData = GNE_SFA2_PREP_Testing_Objectives_Ctrl.updateStatus(accId, JSON.serialize(ctrlData));
			delete [SELECT Id FROM SFA2_PREP_Account_MBO_gne__c];
			delete [SELECT Id FROM SFA2_PREP_Account_Testing_Strategy_gne__c];
		}
		
		System.assertEquals(0,[SELECT count() FROM SFA2_PREP_Account_MBO_gne__c], 'All Account MBOs should be deleted');
		System.assertEquals(0,[SELECT count() FROM SFA2_PREP_Account_Testing_Strategy_gne__c], 'All Account Strategies should be deleted');
		
		delete [SELECT Id FROM SFA2_PREP_MBO_gne__c];
		delete [SELECT Id FROM SFA2_PREP_Testing_Strategy_gne__c];
		
		System.assertEquals(0,[SELECT count() FROM SFA2_PREP_MBO_gne__c], 'All MBOs should be deleted');
		System.assertEquals(0,[SELECT count() FROM SFA2_PREP_Testing_Strategy_gne__c], 'All Strategies should be deleted');
	}
	
	private TestMethod static void testPrepControllerRedirect() {
		init();
		PageReference pageRef;
		 
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			pageRef = GNE_SFA2_PREP_Base_Ctrl.cancel();
		}
		
		System.assertNotEquals(null, pageRef);
		
		System.runAs(GNE_SFA2_PREP_Test_Helper.getCurrentUser()) {
			pageRef = GNE_SFA2_PREP_Base_Ctrl.setErrorPageReference(new GNE_SFA2_PREP_Base_Ctrl.InvalidInputValueException(new List<String>()));
		}
		
		System.assertNotEquals(null, pageRef);
	}
}