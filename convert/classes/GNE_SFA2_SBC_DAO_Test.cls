/************************************************************
*  @author: Grzegorz Skaruz
*  Date: 2016-11-03
*  This is a test for GNE_SFA2_SBC_DAO class
*
*  Modification History
*  Date        Name        Description
*  2016-11-05 Laniecki     fixed issue with MIXED_DML_OPERATION
*************************************************************/
@isTest

private class GNE_SFA2_SBC_DAO_Test {
    @future
    static void futureDML(){
    	Id terrModelId = [SELECT Id FROM Territory2Model LIMIT 1].Id;
    	Id terrTypeId = [SELECT Id FROM Territory2Type LIMIT 1].Id;
        Territory2 sampleTerritory = new Territory2(Name = 'Test 1', DeveloperName = 'Test_1', Territory2ModelId = terrModelId, Territory2TypeId = terrTypeId, external_id_gne__c = 'GNE-US;SFA-FPM;FRANCHISE PROGRAM MANAGER;ACTEMRA;FPM;Test 1', Parent_External_Id_gne__c ='GNE-US;SFA-FPM;FRANCHISE PROGRAM MANAGER;ACTEMRA;FPM');
		insert sampleTerritory;

		insert new List<Territory2> {
			new Territory2(Name = 'Test 2', DeveloperName = 'Test_2', Territory2ModelId = terrModelId, Territory2TypeId = terrTypeId, external_id_gne__c = 'GNE-US;SFA;FPM;FRANCHISE PROGRAM MANAGER;ACTEMRA;FPM;Test 1;Test 2', ParentTerritory2Id = sampleTerritory.Id,Parent_External_Id_gne__c ='GNE-US;SFA-FPM;FRANCHISE PROGRAM MANAGER;ACTEMRA;FPM;Test 1')
		};        
    }

    @testSetup
    static void init() {
		insert new List<SFASearchStrings_gne__c> {
			new SFASearchStrings_gne__c(Name = 'Test 1', AccountType_gne__c	 = 'HCP'),
			new SFASearchStrings_gne__c(Name = 'Test 2', AccountType_gne__c	 = 'HCO'),
			new SFASearchStrings_gne__c(Name = 'Test 3', AccountType_gne__c	 = 'HCP'),
			new SFASearchStrings_gne__c(Name = 'Test 4', AccountType_gne__c	 = 'HCO'),
			new SFASearchStrings_gne__c(Name = 'Test 5', AccountType_gne__c	 = 'HCP'),
			new SFASearchStrings_gne__c(Name = 'Test 6', AccountType_gne__c	 = 'HCO'),
			new SFASearchStrings_gne__c(Name = 'Test 7', AccountType_gne__c	 = 'HCP'),
			new SFASearchStrings_gne__c(Name = 'Test 8', AccountType_gne__c	 = 'HCO'),
			new SFASearchStrings_gne__c(Name = 'Test 9', AccountType_gne__c	 = 'HCP'),
			new SFASearchStrings_gne__c(Name = 'Test 10', AccountType_gne__c = 'HCO')
		};

		insert new List<Account> {
			new Account(Name = 'testAccount1', SAP_ID_gne__c = '1'),
			new Account(Name = 'testAccount2', SAP_ID_gne__c = '2'),
			new Account(Name = 'testAccount3', SAP_ID_gne__c = '3')
		};
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        User testuser = new User(
          	FirstName = 'John',
          	Alias = 'test',
          	Email = 'testuser@gene.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Brown',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'GNE_SFA2_SBC_DAO_Test@gene.com'
        );
        insert testuser;
		GNE_SFA2_Util.updateAdminSetings(true);
        futureDML();
    }

    static testMethod void testGetLastSearchHistoryRecord() {
		Test.startTest();
	    	List<SFASearchStrings_gne__c> hcpResults = GNE_SFA2_SBC_DAO.getLastSearchHistoryRecord(GNE_SFA2_SBC_Config.AccountModes.HCP.name(), UserInfo.getUserId());
		Test.stopTest();
    	System.AssertEquals(hcpResults.size(), 1);
    	System.AssertEquals(hcpResults.get(0).AccountType_gne__c, GNE_SFA2_SBC_Config.AccountModes.HCP.name());
    }

    static testMethod void testGetRecordTypeId() {
    	System.AssertEquals(GNE_SFA2_SBC_DAO.getRecordTypeId('Account', 'Agency_gne'), [ SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Agency_gne' ].Id);
    	System.AssertEquals(GNE_SFA2_SBC_DAO.getRecordTypeId('Account', 'Agency_gne_invalid'), null);
    }

    static testMethod void testGetRecordTypeIdMap() {
		Test.startTest();
	    	Map<String,Id> result = GNE_SFA2_SBC_DAO.getRecordTypeIdMap('Account', new set<String>{'Agency_gne'});
    	Test.stopTest();
		RecordType expectedResult = [ SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Agency_gne' ];
    	System.AssertEquals(result.size(), 1);
    	System.AssertEquals(result.get('Agency_gne'.toUpperCase()), expectedResult.Id);
    }

    static testMethod void testGetRecordTypeIdMapInvalid() {
		Test.startTest();
	    	Map<String,Id> result = GNE_SFA2_SBC_DAO.getRecordTypeIdMap('Account', new set<String>{'Agency_gne_invalid'});
		Test.stopTest();
		List<RecordType> expectedResult = [ SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Agency_gne_invalid' ];
    	System.AssertEquals(result.size(), 0);
    }

    static testMethod void testGetRecordTypesById() {
		List<RecordType> recordTypes = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Account'
                AND (DeveloperName = 'Agency_gne' OR DeveloperName = 'Archived_Account_gne')
        ];
		Set<Id> rIds = (new Map<Id,SObject>(recordTypes)).keySet();
		Test.startTest();
	    	List<RecordType> result = GNE_SFA2_SBC_DAO.getRecordTypesById(rIds);
		Test.stopTest();
    	System.AssertEquals(result.size(), 2);
    }

    static testMethod void testGetUserTerritories() {
		List<UserTerritory2Association> userTerritories = [ SELECT UserId, Territory2Id FROM UserTerritory2Association LIMIT 10000 ];
		set<Id> userIds = new set<Id>();
		for (UserTerritory2Association t : userTerritories) {
			userIds.add(t.UserId);
		}
		Test.startTest();
	    	List<Territory2> result = GNE_SFA2_SBC_DAO.getUserTerritories(userIds);
		Test.stopTest();
    	System.AssertNotEquals(result.size(), 0);
    }

    static testMethod void testGetTerritoriesByParentIds() {
		List<Territory2> sampleTerritory = [
            SELECT Id, Name, ParentTerritory2Id
            FROM Territory2
            WHERE ParentTerritory2Id != null
            LIMIT 1
        ];
		set<Id> parentIds = new set<Id>();
		parentIds.add(sampleTerritory.get(0).ParentTerritory2Id);
		List<Territory2> territories = [
            SELECT ParentTerritory2Id
			FROM Territory2
			WHERE ParentTerritory2Id IN :parentIds
        ];
		Test.startTest();
	    	List<Territory2> result = GNE_SFA2_SBC_DAO.getTerritoriesByParentIds(parentIds);
		Test.stopTest();
    	System.AssertNotEquals(result.size(), 0);
    }

    static testMethod void testSampleTerritoryGroup() {
    	List<Group> result = GNE_SFA2_SBC_DAO.getTerritoryGroups(new set<Id>{});
    }

    static testMethod void testGetAccountBySapId() {
    	List<Account> result = GNE_SFA2_SBC_DAO.getAccountBySapId('2');
    	System.AssertEquals(result.size(), 1);
    	System.AssertEquals(result.get(0).Name, 'testAccount2');
    }

    static testMethod void testGetAccountByMdmId() {
    	List<Account> result = GNE_SFA2_SBC_DAO.getAccountByMdmId('', new set<String>{}, new set<String>{}, new set<Id>{}, new set<String>{});
    }

    static testMethod void testGetUserByExternalId() {
        User userx = [select External_ID_gne__c from user where Username = 'GNE_SFA2_SBC_DAO_Test@gene.com'];
        system.debug('++++ '+userx.External_ID_gne__c);
		Test.startTest();
	    	List<User> result = GNE_SFA2_SBC_DAO.getUserByExternalId('GNE_SFA2_SBC_DAO_Test');
		Test.stopTest();
    	System.AssertEquals(1, result.size());
    	System.AssertEquals([SELECT Id FROM USER WHERE Email='testuser@gene.com' AND Username = 'GNE_SFA2_SBC_DAO_Test@gene.com' LIMIT 1].Id, result.get(0).Id);
    }

    static testMethod void testGetAccountsByAddressIds() {
		List<Account> accounts = [ SELECT Id FROM Account ];
		List<Address_vod__c> addressVods = new List<Address_vod__c>();
		for (Account a : accounts) {
			Address_vod__c singleAddressVod = new Address_vod__c(
                Inactive_vod__c = false,
				MDM_Address_ID_gne__c = '1',
				Account_vod__c = a.Id
			);
			addressVods.add(singleAddressVod);
		}
		insert addressVods;
		List<Address_vod__c> resultAccVods = [ SELECT Id FROM Address_vod__c ];
		Set<Id> ids = (new Map<Id,SObject>(resultAccVods)).keySet();
		Test.startTest();
	    	List<Account> result = GNE_SFA2_SBC_DAO.getAccountsByAddressIds(ids);
		Test.stopTest();
    	System.AssertEquals(result.size(), 3);
    }

    static testMethod void testGetAccountsByIds() {
		List<Account> accounts = [ SELECT Id, Name FROM Account WHERE Name = 'testAccount1' OR Name = 'testAccount3' ];
		Set<Id> ids = (new Map<Id,SObject>(accounts)).keySet();
		Test.startTest();
	    	List<Account> result = GNE_SFA2_SBC_DAO.getAccountsByIds(ids);
		Test.stopTest();
    	System.AssertEquals(result.size(), 2);
    }
}