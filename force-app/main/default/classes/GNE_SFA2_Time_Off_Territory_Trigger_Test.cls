/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-04
*  Description: This is a test class for GNE_SFA2_Time_Off_Territory_Trigger trigger
*
*  Modification History
*  Date        Name        		Description
*  2013-01-15  Piotr Przesmycki Fixed unit test
*  2014-02-13  Piotr Przesmycki Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data
*************************************************************/
@isTest
private without sharing class GNE_SFA2_Time_Off_Territory_Trigger_Test {

	private static Integer BATCH_SIZE = 201;

	public static testMethod void testTimeOffTerritoryFieldUpdates(){
		User sfa2User = selectSFA2UserWithTerritory();
		System.runAs(sfa2User){
			GNE_SFA2_Util.switchAdminMode(false);
			//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
			List<UserTerritory2Association> userTerritories = [ SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :UserInfo.getUserId() ];

			List<Time_Off_Territory_gne__c> testTimeOffTerritories = new List<Time_Off_Territory_gne__c>();
			for(Integer i = 0; i < BATCH_SIZE; i++) {
				testTimeOffTerritories.add(GNE_SFA2_Triggers_Test_Util.prepareTime_Off_Territory_gne());
			}

			Test.startTest();
			insert testTimeOffTerritories;
			Test.stopTest();


			testTimeOffTerritories = [ SELECT Territory_gne__c FROM Time_Off_Territory_gne__c WHERE Id in :testTimeOffTerritories ];
			for(Time_Off_Territory_gne__c tot : testTimeOffTerritories) {
				System.assertNotEquals(null, tot.Territory_gne__c);
			}
		}
	}

	public static testMethod void testTimeOffTerritoryChildRecordUpdates(){
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		List<Profile> sfa2Profiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-Field' ];
        List<User> sfa2Users = [ SELECT Id, ManagerId FROM USER WHERE ProfileId in :sfa2Profiles AND isActive = true LIMIT 2 ];
        User sfa2User = sfa2Users[0];
		User sfa2Manager = sfa2Users[1];

		sfa2User.ManagerId = sfa2Manager.Id;
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			Test.startTest();
			update sfa2User;
		}

		List<Time_Off_Territory_gne__c> testTimeOffTerritories = new List<Time_Off_Territory_gne__c>();
		for(Integer i = 0; i < BATCH_SIZE; i++) {
			testTimeOffTerritories.add(GNE_SFA2_Triggers_Test_Util.prepareTime_Off_Territory_gne());
		}


		System.runAs(sfa2User) {
			insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c=true, App_Name_gne__c='SFA-US');
			insert testTimeOffTerritories;
			Test.stopTest();
		}


		List<Time_Off_Territory_gne__Share> shares = [ SELECT Id FROM Time_Off_Territory_gne__Share WHERE UserOrGroupId = :sfa2Manager.Id AND ParentID IN :testTimeOffTerritories ];
		System.assertNotEquals(null, shares);
		System.assertEquals(BATCH_SIZE, shares.size());
	}

	private static User selectSFA2UserWithTerritory(){
		List<Profile> sfa2Profiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-Field'];
		if(sfa2Profiles != null && sfa2Profiles.size() > 0) {
			List<User> sfa2Users = [ SELECT Id FROM USER WHERE ProfileId in :sfa2Profiles AND isActive = true AND Id IN (SELECT UserId FROM UserTerritory2Association)];
			if(sfa2Users != null && sfa2Users.size() > 0) {
				return sfa2Users[0];
			}
		}
		return null;
	}
}