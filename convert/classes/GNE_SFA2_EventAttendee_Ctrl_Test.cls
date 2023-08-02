@isTest
public with sharing class GNE_SFA2_EventAttendee_Ctrl_Test {

	@isTest
	private static void testEdit() {
		User user = [SELECT Id FROM User WHERE Name = 'Gianfranco Giometti'];
		Account account;
		Medical_Event_vod__c medicalEvent;
		Event_Attendee_vod__c eventAttendee;
		PageReference pageReference;
		System.runAs(user) {
			account = createSampleAccount();
			medicalEvent = createMedivalEvent();
	    	eventAttendee = createEventAttende(account, medicalEvent);
		}
		ApexPages.StandardController standardController = new ApexPages.StandardController(eventAttendee);
		GNE_SFA2_EventAttendee_Ctrl customController = new GNE_SFA2_EventAttendee_Ctrl(standardController);
		Test.startTest();
		pageReference = customController.edit();
		Test.stopTest();
		
		System.assertEquals('/apex/GNE_SFA2_EventAttende_Edit_Create_Layout?id='+eventAttendee.Id, pageReference.getUrl());
	}

	private static Account createSampleAccount() {
		Account account = new Account(Name = 'Test Acocunt');
		insert account;
		return account;
	}

	private static Medical_Event_vod__c createMedivalEvent() {
		Medical_Event_vod__c medicalEvent = new Medical_Event_vod__c(End_Date_vod__c = Date.newInstance(2017, 4, 10), Start_Date_vod__c = Date.newInstance(2017, 3, 28));
		insert medicalEvent;
		return medicalEvent;
	}

	private static Event_Attendee_vod__c createEventAttende(Account account, Medical_Event_vod__c medicalEvent) {
		Event_Attendee_vod__c eventAttendee = new Event_Attendee_vod__c(Account_vod__c = account.Id,
			Account_vod__r = account, Medical_Event_vod__c = medicalEvent.Id, Medical_Event_vod__r = medicalEvent);
		insert eventAttendee;
		return eventAttendee;
	}
}