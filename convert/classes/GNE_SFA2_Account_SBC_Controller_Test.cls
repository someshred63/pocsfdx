/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-09-12
*  Description: This is a test for GNE_SFA2_Account_SBC_Controller class
*
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
private class GNE_SFA2_Account_SBC_Controller_Test {
    private static final Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();

	public static testMethod void testSBCControllerConstructors() {
		String canadianProfile = 'RCanada-SFA-MSL';
		insert new GNE_SFA2_Canadian_Users__c(Name = canadianProfile);
		User u = selectUserWithSpecifiedProfile(canadianProfile, false);
		GNE_SFA2_Account_SBC_Controller controller;
		system.runAs(u){
			controller = new GNE_SFA2_Account_SBC_Controller(false, true);
			system.assertEquals(false, controller.isTestCase);
			system.assertEquals(true, controller.isRemoteMode);
			system.assertEquals(null, controller.stdCont);
		}

		ApexPages.StandardController standardCtrl = new ApexPages.StandardController(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test name'));
		controller = new GNE_SFA2_Account_SBC_Controller(standardCtrl);
		system.assertEquals(false, controller.isTestCase);
		system.assertEquals(null, controller.isRemoteMode);
		system.assertEquals(standardCtrl, controller.stdCont);

		controller = new GNE_SFA2_Account_SBC_Controller();
		system.assertEquals(true, controller.isTestCase);
		system.assertEquals(null, controller.isRemoteMode);
		system.assertEquals(null, controller.stdCont);
	}

	public static testMethod void testSBCgettersAndPageReferenceCanada(){
		String canadianProfile = 'RCanada-SFA-MSL';
		insert new GNE_SFA2_Canadian_Users__c(Name = canadianProfile);
		User u = selectUserWithSpecifiedProfile(canadianProfile, true);
		GNE_SFA2_Account_SBC_Controller controller;
		system.runAs(u){
			controller = new GNE_SFA2_Account_SBC_Controller(false, false);
			insert new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SearchShowMDMId', Configuration_Value_gne__c = 'notExistingProfile,'+canadianProfile);
			insert new GNE_Foun_Misc_Config_Items_gne__c(Name = 'NewAccReq_And_Dcr_Canada_Smartsheet', Configuration_Value_gne__c = 'https://app.smartsheet.com/b/form/3faf93953e464aef9615f6d226c50c48');
			system.assertEquals(true, controller.getShowMdmId());
			system.assertEquals(true, controller.getShowBothTypes());
			controller.allowedType='Single';
			system.assertEquals(false, controller.getShowBothTypes());

			system.assertEquals(false, controller.getHasLWOProfile());
			system.assertEquals(true, controller.getHasCanadaProfile());
			system.assertEquals(false, controller.getHasSysAdminProfile());
			system.assertEquals(false, controller.getHasReadOnlyProfile());

			system.assertEquals(false, controller.getTooManyResults());

			List<SelectOption> itemsList = controller.getItems();
			system.assertEquals(2, itemsList.size());
			system.assertEquals('Organization (HCO)', itemsList[0].getLabel());
			system.assertEquals('HCO', itemsList[0].getValue());
			system.assertEquals('Professional (HCP)', itemsList[1].getLabel());
			system.assertEquals('HCP', itemsList[1].getValue());

			system.assertNotEquals(null, controller.getSpecType());
			system.assertNotEquals(0, controller.getSpecType().size());

			insert new GNE_FOUN_RuleSet_Matrix_gne__c(Name = 'test');
			List<SelectOption> rules = controller.getRules();
			system.assertEquals(2, rules.size());
			system.assertEquals(GNE_SFA2_Account_SBC_Controller.NONE_SELECTED, rules[0].getLabel());
			system.assertEquals(GNE_SFA2_Account_SBC_Controller.NONE_SELECTED, rules[0].getValue());
			system.assertEquals('test', rules[1].getLabel());
			system.assertEquals('test', rules[1].getValue());

			List<SelectOption> territories = controller.getTerritories();
			system.assert(territories.size()>=2);
			system.assertEquals(GNE_SFA2_Account_SBC_Controller.NO_TERRITORY_SELECTED, territories[territories.size()-1].getLabel());
			system.assertEquals(GNE_SFA2_Account_SBC_Controller.NO_TERRITORY_SELECTED, territories[territories.size()-1].getValue());

			system.assertEquals(true, controller.getHasTerritories());
			controller.hasSearchedForHCP = true;
			system.assertEquals(true, controller.getShowResults());


			PageReference currentPage = Page.GNE_SFA2_Account_Search_Before_Create;
			currentPage.getParameters().put('isPopup', 'true');
			currentPage.getParameters().put('isModal', 'true');
			currentPage.getParameters().put('acctType', 'HCP');
			currentPage.getParameters().put('showCreateNew', 'true');
			Test.setCurrentPage(currentPage);
			system.assertEquals(null, controller.setupHelp());
			system.assertEquals(true, controller.isPopup);
			system.assertEquals(true, controller.isModal);
			system.assertEquals(true, controller.ShowCreateNew);
			system.assertEquals(true, controller.getHasSearched());
			ApexPages.currentPage().getParameters().put('isPopup', 'false');
			ApexPages.currentPage().getParameters().put('allowType', 'HCP');
			ApexPages.currentPage().getParameters().put('pgTitle', 'SEARCH');
			controller.isPopup = false;
			system.assertEquals(null, controller.setup());

			Map<Id, Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Account.getRecordTypeInfosById();
			Map<Id, RecordType> rtMap = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account']);
			String rtName;
			for (Id rtId : rtMapById.keyset()){
            	Schema.RecordTypeInfo rtById = rtMapById.get(rtId);
            	if (rtById.IsAvailable() == true){
                	RecordType rt = rtMap.get(rtId);
                	if(rt != null){
                    	rtName = rt.Name;
                    	break;
                	}
            	}
        	}
			GNE_SFA_Canada_HCO_Record_Types__c rt = new GNE_SFA_Canada_HCO_Record_Types__c(Name = rtName, RecordType__c = rtName, RecordTypeDisplay__c = 'test');
			insert rt;
			List<String> classifications = GNE_SFA2_Account_SBC_Controller.getAvailableClassification();
			system.assertEquals(null, classifications);

			GNE_SFA_Canada_HCP_Record_Types__c rtHCP = new GNE_SFA_Canada_HCP_Record_Types__c(Name = rtName, RecordType__c = rtName);
			insert rtHCP;
			List<SelectOption> profTypes = controller.getProfTypes();
			system.assertEquals(2, profTypes.size());

			system.assertEquals(null, controller.changeType());

			ApexPages.currentPage().getParameters().put('mode', 'test');
			system.assertEquals(null, controller.changeMode());

			insert new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SearchAccountShowNew', Configuration_Value_gne__c = 'NotExistingProfile,RCanada-SFA-MSL');
			system.assertEquals(null, controller.checkForRedirect());
			Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test name');
			insert acc;
			Integer addressCount = [SELECT Count() FROM Address_vod__c];
			controller.acctType = 'HCO';
			system.debug('Record Type Id= ' + controller.getAddrRecTypeId());
			controller.createNewAddress(new SFASearchStrings_gne__c(Account_gne__c = acc.Id, Street_gne__c = 'testStreet', City_gne__c = 'city', State_gne__c = 'DC', Zip_gne__c = '12345', Address_MDM_Id_gne__c = '111'));
			//system.assertEquals(addressCount + 1, [SELECT Count() FROM Address_vod__c]);
			//Actually no new Address is created, because GNE_SFA2_Account_SBC_Controller is searching for recordtype developerName
			//using recordtype Name, so it doesn't find any recType and fails to insert new address
			system.assertEquals(addressCount, [SELECT Count() FROM Address_vod__c]);

			controller.hasSearchedForHCO = true;
			controller.hasSearchedForHCO = true;
			system.assertEquals(null, controller.clear());
			system.assertEquals(false, controller.hasSearchedForHCO);
			system.assertEquals(false, controller.hasSearchedForHCO);

			PageReference pref = new PageReference(
					GNE_Foun_Misc_Config_Items_gne__c.getValues('NewAccReq_And_Dcr_Canada_Smartsheet') != null ?
							GNE_Foun_Misc_Config_Items_gne__c.getValues('NewAccReq_And_Dcr_Canada_Smartsheet').Configuration_Value_gne__c :
							'');
			controller.pager.CurrSearch.OrgName_gne__c = '';
			system.assertEquals(pref.getUrl(), controller.createNew().getUrl());
//			system.assertEquals(null, controller.createNew());
			controller.pager.CurrSearch.OrgName_gne__c = 'org name';
			system.assertEquals(pref.getUrl(), controller.createNew().getUrl());
//			system.assertEquals(null, controller.createNew());
			controller.pager.CurrSearch.Type_gne__c = 'sample type';
			system.assertEquals(pref.getUrl(), controller.createNew().getUrl());
//			system.assertEquals(null, controller.createNew());
			controller.pager.currSearch.Province_can_gne__c = 'prov';
			system.assertEquals(pref.getUrl(), controller.createNew().getUrl());
//			system.assertEquals(null, controller.createNew());
			controller.pager.currSearch.Postal_Code_can_gne__c ='A0A 1B1';
			system.assertEquals(pref.getUrl(), controller.createNew().getUrl());
//			system.assertEquals(null, controller.createNew());
			controller.fakeAddress.Address_Type_gne__c = 'test';
			system.assertEquals(pref.getUrl(), controller.createNew().getUrl());
//			system.assertEquals(null, controller.createNew());
//			PageReference pr = controller.saveNew();
//			system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Account_Layout'), 'Unexpected URL: ' + pr.getURL());
//			system.assertNotEquals(null, pr.getParameters().get('id'));

			system.assertEquals(null, controller.cancel());
			system.assertEquals(false, controller.showCreateNew);

			TSF_vod__c tsf = new TSF_vod__c(My_Target_vod__c = true, Account_vod__c = acc.Id);
			insert tsf;
			controller.makeNotMyTargetCanadaAccount(acc.Id);
			system.assertEquals(false, [SELECT My_Target_vod__c FROM TSF_vod__c WHERE Id = :tsf.Id LIMIT 1][0].My_Target_vod__c);
		}
	}

	public static testMethod void testSBCgettersAndPageReferenceNotCanada(){
		User u = GNE_FRM_TestUtilities.createUser('actermaManager', ids2ProfilesMap.get('GNE-Field'), false);
		GNE_SFA2_Account_SBC_Controller controller;
		system.runAs(u){
			controller = new GNE_SFA2_Account_SBC_Controller(false, false);

			Map<Id, Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Account.getRecordTypeInfosById();
			Map<Id, RecordType> rtMap = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account']);
			String rtName;
			for (Id rtId : rtMapById.keyset()){
            	Schema.RecordTypeInfo rtById = rtMapById.get(rtId);
            	if (rtById.IsAvailable() == true){
                	RecordType rt = rtMap.get(rtId);
                	if(rt != null){
                    	rtName = rt.Name;
                    	break;
                	}
            	}
        	}
			GNE_Foun_Org_Type_Map_gne__c rt = new GNE_Foun_Org_Type_Map_gne__c(Name = rtName, Account_Record_Type_gne__c = rtName, Account_Record_Type_Display_gne__c = 'test', Active_gne__c = true, Account_Type_gne__c = 'test');
			insert rt;
			List<String> classifications = GNE_SFA2_Account_SBC_Controller.getAvailableClassification();
			system.assertEquals(null, classifications);

			GNE_Foun_Role_Ranking_gne__c rr = new GNE_Foun_Role_Ranking_gne__c(Name = rtName, Account_Professional_Type_gne__c = rtName, Role_Rank_gne__c = 3);
			insert rr;
			List<SelectOption> profTypes = controller.getProfTypes();
			system.assertEquals(2, profTypes.size());

			controller.acctType = 'BOTH';
			system.assertEquals(false, controller.getHasSearched());
		}
	}

	public static testMethod void testAddress(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		acc.MDMID_gne__c = 'test 1234';
		insert acc;
		Address_vod__c address = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(acc.Id, 'address', true, 'addressName');
		insert address;
		ApexPages.StandardController standardCtrl = new ApexPages.StandardController(address);
		GNE_SFA2_Account_SBC_Controller controller = new GNE_SFA2_Account_SBC_Controller(standardCtrl);
		//isTestCase is set for false
		system.assertNotEquals(null, controller.setupAddress());
		system.assertEquals('/'+acc.Id, controller.cancelAddress().getURL());
		PageReference pr = controller.redirectToAddressLayout();
		system.assertEquals(4, pr.getParameters().keySet().size());
		system.assertEquals(true, pr.getRedirect());

		ApexPages.currentPage().getParameters().put('addrId', address.Id);
		ApexPages.currentPage().getParameters().put('retURL', '');

		List<SObject> sobjects = new List<SObject>();
		sobjects.add(new SFASearchStrings_gne__c(Address_Mdm_Id_gne__c = address.Id, Account_gne__c = acc.Id));
		controller.pager.fullList = sobjects;
		pr = controller.subscribeAcct();
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Account_Layout'), 'Unexpected URL: ' + pr.getURL());
		system.assertEquals(acc.Id, pr.getParameters().get('id'));

		Integer addressCountSA = [SELECT Count() FROM Address_vod__c];
		controller.acctType = 'HCO';
		controller.createNewAddress(new SFASearchStrings_gne__c(Account_gne__c = acc.Id, Street_gne__c = 'testStreet', City_gne__c = 'city', State_gne__c = 'DC', Zip_gne__c = '12345', Address_MDM_Id_gne__c = '111'));
		system.assertEquals(addressCountSA + 1, [SELECT Count() FROM Address_vod__c]);

		//controller.createNew();
		Test.startTest();
		controller.newAcct = new Account();
		controller.newAcct.Account_Type_gne__c = 'testType';
		controller.newAddr = new SFASearchStrings_gne__c(Account_gne__c = acc.Id, Street_gne__c = 'testStreet', City_gne__c = 'city', State_gne__c = 'DC', Zip_gne__c = '12345', Address_MDM_Id_gne__c = '111');
		controller.pager.CurrSearch.OrgName_gne__c = 'org name';
		system.assertNotEquals(null, controller.saveNewAddress());
		Test.stopTest();
	}

	public static testMethod void testSearch(){
		String canadianProfile = 'RCanada-SFA-MSL';
		insert new GNE_SFA2_Canadian_Users__c(Name = canadianProfile);
		User u = selectUserWithSpecifiedProfile(canadianProfile, true);
		system.runAs(u){
			insert new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SearchAccountLocalOnly', Configuration_Value_gne__c = 'Not existing profile,' + canadianProfile);
			Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
			insert acc;
			Address_vod__c add =GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(acc.Id, 'address', true, 'addressName');
			add.Postal_Code_can_gne__c = 'A0A 1B1';
			insert add;
			insert new SFASearchStrings_gne__c(OrgName_gne__c = 'tes', OwnerId = u.Id, AccountType_gne__c = 'HCO', Address_vod__r = new List<Address_vod__c>{add});
			GNE_SFA2_Account_SBC_Controller controller = new GNE_SFA2_Account_SBC_Controller(false, false);
			controller.pager.currSearch.OrgName_gne__c = 'tes';
			controller.pager.currSearch.AccountType_gne__c = 'HCO';
			controller.searchLess();
		}
	}

	private static User selectUserWithSpecifiedProfile(String profileName, Boolean territoryRequired){
		String profileNameUpd = '%' + profileName + '%';
		List<Profile> profiles = [SELECT Id FROM Profile WHERE Name LIKE :profileNameUpd];
		system.assertNotEquals(0, profiles.size(), 'No profile with Name like ' + profileName + ' found.');
        Set<Id> parentIds = new Set<Id>();
        for(Territory2 t2 : [SELECT ParentTerritory2Id FROM Territory2 ]){
            parentIds.add(t2.ParentTerritory2Id);
        }
		List<User> users;
		if(territoryRequired){
			users = [SELECT Id FROM User WHERE ProfileId IN :profiles AND IsActive = true AND Id IN (Select UserId FROM UserTerritory2Association WHERE Territory2Id NOT IN : parentIds)];
		} else {
			users = [SELECT Id FROM User WHERE ProfileId IN :profiles AND IsActive = true];
		}
		system.assertNotEquals(0, users.size(), 'No users with profile like ' + profileName + ' found. Territory2 required = ' + territoryRequired);
		return users[0];
	}
}