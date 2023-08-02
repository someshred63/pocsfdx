/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-22
*  Description: This is a test clsass for GNE_SFA2_Time_Off_Territory_Day_Trigger trigger
*    
*  Modification History
*  Date        Name        Description
*  2014-02-13  Piotr Przesmycki Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data          
*************************************************************/
@isTest
public with sharing class GNE_SFA2_ToT_Day_Trigger_Test {
	private static Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
	private static Integer BATCH_SIZE = 201;
	
	public static testMethod void testChildRecordUpdatesOnInsert() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Time_Off_Territory_gne__c tot = GNE_SFA2_Triggers_Test_Util.prepareTime_Off_Territory_gne();
				insert tot;
				
				List<Time_off_Territory_Day_gne__c> totDays = new List<Time_off_Territory_Day_gne__c>();
				for(Integer i = 0; i < BATCH_SIZE; i++) {
					totDays.add(GNE_SFA2_Triggers_Test_Util.prepareTime_off_Territory_Day_gne(tot.Id, System.today()));
				}
				
				Test.startTest();
				insert totDays;
				Test.stopTest();
				
				List<Event> events = [ SELECT Id, Subject, WhatId, ActivityDate FROM Event WHERE WhatId = :totDays  ];
				System.assertEquals(BATCH_SIZE, events.size());
				for(Event event : events) {
					System.assertEquals(System.today(), event.ActivityDate);
					System.assertEquals('Day out of territory', event.Subject);
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}

	public static testMethod void testFieldUpdatesMCCO() {
		User mccoUser = getTestUser('%MCCO%');
		if(mccoUser != null) {
			System.runAs(mccoUser) {
				Time_Off_Territory_gne__c tot = GNE_SFA2_Triggers_Test_Util.prepareTime_Off_Territory_gne();
				insert tot;
				String reason='test';
				String mainReason='main';
				List<Time_off_Territory_Day_gne__c> totDays = new List<Time_off_Territory_Day_gne__c>();
				Time_off_Territory_Day_gne__c testToTDay;
				for(Integer i = 0; i < BATCH_SIZE; i++) {
					testToTDay = GNE_SFA2_Triggers_Test_Util.prepareTime_off_Territory_Day_gne(tot.Id, System.today());
					testToTDay.Reason_gne__c=null;
					testToTDay.Reason_MCCO_gne__c=mainReason;
					testToTDay.Reason_PC_gne__c=reason;
					testToTDay.Reason_SFA_gne__c=reason; 
					testToTDay.Reason_MedAffair_gne__c=reason;
					totDays.add(testToTDay);
				}
				
				Test.startTest();
				insert totDays;
				Test.stopTest();
				
				totDays = [ SELECT Id, Reason_gne__c, Reason_MCCO_gne__c, Reason_PC_gne__c, Reason_SFA_gne__c, Reason_MedAffair_gne__c
							FROM Time_off_Territory_Day_gne__c WHERE Id IN :totDays];
				System.assertEquals(BATCH_SIZE, totDays.size());
				for(Time_off_Territory_Day_gne__c totDay : totDays) {
					System.assertEquals(totDay.Reason_gne__c,mainReason);
					System.assertEquals(totDay.Reason_MCCO_gne__c,mainReason);
					System.assertEquals(totDay.Reason_PC_gne__c,null);
					System.assertEquals(totDay.Reason_SFA_gne__c,null);
					System.assertEquals(totDay.Reason_MedAffair_gne__c,null);
				}
			}
		} else {
			System.assert(false, 'Could not find any MCCO users!');
		}
	}


	/*********************
	*	Test should check the code from GNE_SFA2_ToT_Day_Field_Updates class for Primary-Care user, but there is no Primary-Care profile, 
	*	nor user who would have Profile_name_gne__c field containing 'Primary-Care'
	*************/
	/*public static testMethod void testFieldUpdatesPrimaryCare() {
		User pcUser = getTestUser('%Primary-Care%');
		if(pcUser != null) {
			System.runAs(pcUser) {
				Time_Off_Territory_gne__c tot = new Time_Off_Territory_gne__c();
				insert tot;
				String reason='test';
				String mainReason='main';
				List<Time_off_Territory_Day_gne__c> totDays = new List<Time_off_Territory_Day_gne__c>();
				for(Integer i = 0; i < BATCH_SIZE; i++) {
					totDays.add(new Time_off_Territory_Day_gne__c(Reason_gne__c=null, Reason_MCCO_gne__c=reason, Reason_PC_gne__c=mainReason,
																  Reason_SFA_gne__c=reason, Reason_MedAffair_gne__c=reason, 
																  Time_Off_Territory_gne__c = tot.Id, Date_gne__c = System.today()
																  )
					);
				}
				
				Test.startTest();
				insert totDays;
				Test.stopTest();
				
				totDays = [ SELECT Id, Reason_gne__c, Reason_MCCO_gne__c, Reason_PC_gne__c, Reason_SFA_gne__c, 	Reason_MedAffair_gne__c
							FROM Time_off_Territory_Day_gne__c WHERE Id IN :totDays];
				System.assertEquals(BATCH_SIZE, totDays.size());
				for(Time_off_Territory_Day_gne__c totDay : totDays) {
					System.assertEquals(totDay.Reason_gne__c,mainReason);
					System.assertEquals(totDay.Reason_MCCO_gne__c,null);
					System.assertEquals(totDay.Reason_PC_gne__c,mainReason);
					System.assertEquals(totDay.Reason_SFA_gne__c,null);
					System.assertEquals(totDay.Reason_MedAffair_gne__c,null);
				}
			}
		} else {
			System.assert(false, 'Could not find any Primary-Care users!');
		}
	}*/

	public static testMethod void testFieldUpdatesMedAffair() {
		User maUser = GNE_FRM_TestUtilities.createUser('MedAffairMCL', ids2ProfilesMap.get('GNE-MedAffairs-MCL'), true);
		if(maUser != null) {
			System.runAs(maUser) {
				Time_Off_Territory_gne__c tot = GNE_SFA2_Triggers_Test_Util.prepareTime_Off_Territory_gne();
				insert tot;
				String reason='test';
				String mainReason='main';
				List<Time_off_Territory_Day_gne__c> totDays = new List<Time_off_Territory_Day_gne__c>();
				Time_off_Territory_Day_gne__c testToTDay;
				for(Integer i = 0; i < BATCH_SIZE; i++) {
					testToTDay = GNE_SFA2_Triggers_Test_Util.prepareTime_off_Territory_Day_gne(tot.Id, System.today());
					testToTDay.Reason_gne__c=null;
					testToTDay.Reason_MCCO_gne__c=reason;
					testToTDay.Reason_PC_gne__c=reason;
					testToTDay.Reason_SFA_gne__c=reason; 
					testToTDay.Reason_MedAffair_gne__c=mainReason;
					totDays.add(testToTDay);
				}
							
				Test.startTest();
				insert totDays;
				Test.stopTest();
				
				totDays = [ SELECT Id, Reason_gne__c, Reason_MCCO_gne__c, Reason_PC_gne__c, Reason_SFA_gne__c, Reason_MedAffair_gne__c
							FROM Time_off_Territory_Day_gne__c WHERE Id IN :totDays];
				System.assertEquals(BATCH_SIZE, totDays.size());
				for(Time_off_Territory_Day_gne__c totDay : totDays) {
					System.assertEquals(totDay.Reason_gne__c,mainReason);
					System.assertEquals(totDay.Reason_MCCO_gne__c,null);
					System.assertEquals(totDay.Reason_PC_gne__c,null);
					System.assertEquals(totDay.Reason_SFA_gne__c,null);
					System.assertEquals(totDay.Reason_MedAffair_gne__c,mainReason);
				}
			}
		} else {
			System.assert(false, 'Could not find any MedAffairs users!');
		}
	}

	public static testMethod void testFieldUpdatesSFA2() {
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Time_Off_Territory_gne__c tot = GNE_SFA2_Triggers_Test_Util.prepareTime_Off_Territory_gne();
				insert tot;
				String reason='test';
				String mainReason='main';
				List<Time_off_Territory_Day_gne__c> totDays = new List<Time_off_Territory_Day_gne__c>();
				Time_off_Territory_Day_gne__c testToTDay;
				for(Integer i = 0; i < BATCH_SIZE; i++) {
					testToTDay = GNE_SFA2_Triggers_Test_Util.prepareTime_off_Territory_Day_gne(tot.Id, System.today());
					testToTDay.Reason_gne__c=null;
					testToTDay.Reason_MCCO_gne__c=reason;
					testToTDay.Reason_PC_gne__c=reason;
					testToTDay.Reason_SFA_gne__c=mainReason; 
					testToTDay.Reason_MedAffair_gne__c=reason;
					totDays.add(testToTDay);
				}
				
				Test.startTest();
				insert totDays;
				Test.stopTest();
				
				totDays = [ SELECT Id, Reason_gne__c, Reason_MCCO_gne__c, Reason_PC_gne__c, Reason_SFA_gne__c, Reason_MedAffair_gne__c
							FROM Time_off_Territory_Day_gne__c WHERE Id IN :totDays];
				System.assertEquals(BATCH_SIZE, totDays.size());
				for(Time_off_Territory_Day_gne__c totDay : totDays) {
					System.assertEquals(totDay.Reason_gne__c,mainReason);
					System.assertEquals(totDay.Reason_MCCO_gne__c,null);
					System.assertEquals(totDay.Reason_PC_gne__c,null);
					System.assertEquals(totDay.Reason_SFA_gne__c,mainReason);
					System.assertEquals(totDay.Reason_MedAffair_gne__c,null);
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}

	public static testMethod void testEmailNotifications(){
		User maUser = GNE_FRM_TestUtilities.createUser('MedAffairMSL', ids2ProfilesMap.get('GNE-MedAffairs-MSL'), true);
		if(maUser != null) {
			System.runAs(maUser) {
				Time_Off_Territory_gne__c tot = GNE_SFA2_Triggers_Test_Util.prepareTime_Off_Territory_gne();
				insert tot;
				
				List<Time_off_Territory_Day_gne__c> totDays = new List<Time_off_Territory_Day_gne__c>();
				for(Integer i = 0; i < BATCH_SIZE; i++) {
					totDays.add(GNE_SFA2_Triggers_Test_Util.prepareTime_off_Territory_Day_gne(tot.Id, System.today()));
				}
				
				Test.startTest();
				insert totDays;
				Test.stopTest();
				
			}
		} else {
			System.assert(false, 'Could not find any MedAffairs users!');
		}
	}

	private static User getTestUser(String profileName){
		try{
			List<Profile> p = [SELECT Id FROM Profile WHERE Name LIKE :profileName];
			User u = [SELECT Id FROM User WHERE ProfileId IN :p AND IsActive=true AND IsPortalEnabled=false LIMIT 1];
			return u;
		}catch(Exception ex){
			system.debug(ex);
			return null;
		}
		return null;
	}

}