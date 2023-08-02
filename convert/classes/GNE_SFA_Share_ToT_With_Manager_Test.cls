@isTest
public with sharing class GNE_SFA_Share_ToT_With_Manager_Test {
    private static final Id profileId = [SELECT Id FROM Profile WHERE Name = 'GNE-Field' LIMIT 1].Id;

	@testSetup
	static void initData() {
        User user1 =  new User(
            ProfileId = profileId,
            TimeZoneSidKey = 'America/Los_Angeles',
            Email = 'usFirst@gene.com',
            FirstName = 'usUser',
            External_ID_gne__c = 'ustestFirst',
            Alias = 'ustestFr',
            Username = 'UsTestFirst@gene.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            LastName = 'UserFirst',
            IsActive = true
        );
        User user2 = new User(
            ProfileId = profileId,
            TimeZoneSidKey = 'America/Los_Angeles',
            Email = 'usSecond@gene.com',
            FirstName = 'usUser',
            External_ID_gne__c = 'ustestSecond',
            Alias = 'ustestSc',
            Username = 'UsTestSecond@gene.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            LastName = 'UserSecond',
            IsActive = true
        );

        insert new List <User> {user2, user1};

		user2.ManagerId = user1.Id;
		update user2;
        
        Territory2 terr = [SELECT Id FROM Territory2 WHERE (NOT External_id_gne__c LIKE 'INACTIVE TERRITORIES%') AND Id NOT IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId =: user2.Id) LIMIT 1];
        insert new UserTerritory2Association(UserId = user2.Id, Territory2Id = terr.Id);
	}
	
	private static List<User> getSfaBrandsUsersWithManager() {
		return [SELECT Id, ManagerId FROM User WHERE ProfileId = :profileId AND ManagerId != null AND isActive = true LIMIT 1000];
	}
	
	private static List<User> getSfaBrandsUsersWithoutManager() {
		return [SELECT Id, ManagerId FROM User WHERE ProfileId = :profileId AND ManagerId = null AND isActive = true LIMIT 1000];
	}
	
	private static List<User> getNonSfaBrandsUsers() {
		List<Profile> nonSfaBrandsProfiles = [SELECT Id, Name FROM Profile WHERE (not Name like 'GNE-SFA%') ];
		List<User> nonSfaBrandsUsers = [SELECT Id, ManagerId FROM User WHERE ProfileId in :nonSfaBrandsProfiles AND isActive = true LIMIT 1000];
		
		return nonSfaBrandsUsers;
	}

	private static void addUsersToUserAppContext(List<User> usersList) {
		List<GNE_SFA2_User_App_Context_gne__c> userAppContextToInsertList = new List<GNE_SFA2_User_App_Context_gne__c>();
		for(User usr : usersList) {
			userAppContextToInsertList.add(
					new GNE_SFA2_User_App_Context_gne__c(
							Name = 'GNE SFA2 User Application Context (User)',
							SetupOwnerId = usr.Id,
							App_Name_gne__c = 'SFA-US',
							Role_gne__c = 'CS',
							Run_in_SFA2_UI_gne__c = false,
							SFA2_Mode_gne__c = true,
							Brand_gne__c = ''
					)
			);
		}
		Database.insert(userAppContextToInsertList);
	}
		
	//inserts Time off Territory records as a SFA Brands user with correct manager
	static TestMethod void insertAsSfaUserWithCorrectManager(){
		List<User> sfaBrandsUsers = [SELECT Id, ManagerId FROM User WHERE Username = 'UsTestSecond@gene.com'];
		List<Time_Off_Territory_gne__c> totsToInsert = new List<Time_off_Territory_gne__c>();
		addUsersToUserAppContext(new List<User> { sfaBrandsUsers[0] });


		System.runAs(sfaBrandsUsers[0]){
			for(integer i=0;i<200;i++){
				Time_Off_Territory_gne__c tot = new Time_Off_Territory_gne__c();
				totsToInsert.add(tot);
			}
			
			insert totsToInsert;
		}

		Set<String> scopeIds = new Set<String>();
        for(Time_Off_Territory_gne__c tot : totsToInsert) {
        	scopeIds.add(tot.Id);
        }

		//check if sharing records exist
		System.debug('scopeIds '+scopeIds);
		List<Time_Off_Territory_gne__Share> sharingRecords = [select Id from Time_Off_Territory_gne__Share where userOrGroupId = :sfaBrandsUsers[0].ManagerId and ParentId in :scopeIds ];
		system.assertEquals(200, sharingRecords.size());		
	}
	
	//inserts Time off Territory records as a SFA Brands user with no manager specified
	static TestMethod void insertAsSfaUsersWithoutCorrectManager(){
		List<User> sfaBrandsUsers = getSfaBrandsUsersWithoutManager();
		List<Time_Off_Territory_gne__c> totsToInsert = new List<Time_off_Territory_gne__c>();
		
		System.runAs(sfaBrandsUsers[0]){
			for(integer i=0;i<200;i++){
				Time_Off_Territory_gne__c tot = new Time_Off_Territory_gne__c();
				totsToInsert.add(tot);
			}
			
			insert totsToInsert;
		}
		
		Set<String> scopeIds = new Set<String>();
        for(Time_Off_Territory_gne__c tot : totsToInsert) {
        	scopeIds.add(tot.Id);
        }
        
		//check if sharing records exist
		List<Time_Off_Territory_gne__Share> sharingRecords = [select Id from Time_Off_Territory_gne__Share where userOrGroupId = :sfaBrandsUsers[0].ManagerId and ParentId in :scopeIds ];
		system.assertEquals(0, sharingRecords.size());
	}
	
	//inserts Time off Territory records as a user other than SFA Brands with correct manager
	static TestMethod void insertAsNonSfaUsers(){
		List<User> nonSfaBrandsUsers = getNonSfaBrandsUsers();
		List<Time_Off_Territory_gne__c> totsToInsert = new List<Time_off_Territory_gne__c>();
		
		System.runAs(nonSfaBrandsUsers[0]){
			for(integer i=0;i<200;i++){
				Time_Off_Territory_gne__c tot = new Time_Off_Territory_gne__c();
				totsToInsert.add(tot);
			}
			
			insert totsToInsert;
		}
		
		Set<String> scopeIds = new Set<String>();
        for(Time_Off_Territory_gne__c tot : totsToInsert) {
        	scopeIds.add(tot.Id);
        }
        
		//check if sharing records exist
		List<Time_Off_Territory_gne__Share> sharingRecords = [select Id from Time_Off_Territory_gne__Share where userOrGroupId = :nonSfaBrandsUsers[0].ManagerId and ParentId in :scopeIds ];
		system.assertEquals(0, sharingRecords.size());
	}

}