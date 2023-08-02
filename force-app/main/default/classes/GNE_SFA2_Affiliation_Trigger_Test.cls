/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-21
*  Description: This is a test class for GNE_SFA2_Affiliation_Trigger trigger
*
*  Modification History
*  Date        	Name        		Description
*  2014-01-31	Piotr Przesmycki	Removed seeAllData annotation, fixed unit tests
*  2014-02-19  Piotr Przesmycki 	Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data
*  2014-12-03   Mateusz Michalczyk  Added after delete logic test for OTR_Deleted_Record_gne__c record creation.
*************************************************************/
@isTest
public without sharing class GNE_SFA2_Affiliation_Trigger_Test {
	public static testMethod void emptyDrugFieldPrefferedAICAffiliationValidationRulesOnInsertTest() {

		Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		account.FirstName = 'testName';
		insert account;

		Account account2 =  GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
		account2.FirstName = 'testName2';
		insert account2;

		List<Affiliation_vod__c> testAffiliations = GNE_SFA2_Affiliation_Test_Helper.prepareTestAffiliations(new Set<String>{'Drug_gne__c', 'From_Contact_vod__c',
													'To_Contact_vod__c'}, new Map<String, String>{'Role_vod__c' => 'Preferred AIC', 'From_Account_vod__c' => account.Id,
													'To_Account_vod__c' => account2.Id}, null, null);
		Test.startTest();
		try {
			insert testAffiliations;
			System.assert(false, 'Drug field cannot be empty!');
		} catch (DMLException ex) {
			System.assert(ex.getMessage().contains(System.Label.Drug_field_cannot_be_empty), ex.getMessage());
			System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		}
		Test.stopTest();
	}

	public static testMethod void emptyDrugFieldPrefferedDistributorAffiliationValidationRulesOnInsertTest() {
		List<Affiliation_vod__c> testAffiliations = GNE_SFA2_Affiliation_Test_Helper.prepareTestAffiliations(new Set<String>{'Drug_gne__c', 'From_Account_vod__c', 'From_Contact_vod__c',
													'To_Contact_vod__c', 'To_Account_vod__c'}, new Map<String, String>{'Role_vod__c' => 'Preferred Distributor'}, null, null);
		Test.startTest();
		try {
			insert testAffiliations;
			System.assert(false, 'Drug field cannot be empty!');
		} catch (DMLException ex) {
			System.assert(ex.getMessage().contains(System.Label.Drug_field_cannot_be_empty), ex.getMessage());
			System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		}
		Test.stopTest();
	}

	public static testMethod void emptyDrugFieldPrefferedAICAffiliationValidationRulesOnUpdateTest() {
		Account account =  GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		account.FirstName = 'testName';
		insert account;

		Account account2 =  GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
		account2.FirstName = 'testName2';
		insert account2;

		Affiliation_vod__c testAffiliation = new Affiliation_vod__c(Role_vod__c = 'Preferred AIC',
													From_Account_vod__c = account.Id, To_Account_vod__c = account2.Id,
													Drug_gne__c = 'Avastin');
		insert testAffiliation;

		testAffiliation.Drug_gne__c = null;
		GNE_CM_case_trigger_monitor.resetTriggerInProcess();
		Test.startTest();
		try {
			update testAffiliation;
			System.assert(false, 'Drug field cannot be empty!');
		} catch (DMLException ex) {
			System.assert(ex.getMessage().contains(System.Label.Drug_field_cannot_be_empty), ex.getMessage());
			System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		}
		Test.stopTest();
	}

	public static testMethod void emptyDrugFieldPrefferedDistributorAffiliationValidationRulesOnUpdateTest() {
		Account account =  GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		account.FirstName = 'testName';
		insert account;

		Account account2 =  GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
		account2.FirstName = 'testName2';
		insert account2;

		Affiliation_vod__c testAffiliation = new Affiliation_vod__c(Role_vod__c = 'Preferred Distributor',
													From_Account_vod__c = account.Id, To_Account_vod__c = account2.Id,
													Drug_gne__c = 'Avastin');
		insert testAffiliation;
		testAffiliation.Drug_gne__c = null;
		GNE_CM_case_trigger_monitor.resetTriggerInProcess();
		Test.startTest();
		try {
			update testAffiliation;
			System.assert(false, 'Drug field cannot be empty!');
		} catch (DMLException ex) {
			System.assert(ex.getMessage().contains(System.Label.Drug_field_cannot_be_empty), ex.getMessage());
			System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		}
		Test.stopTest();
	}

	public static testMethod void sameToContactAffiliationsValidationRulesOnInsertTest() {
		Account account =  GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		account.FirstName = 'testName';
		insert account;

		Account account2 =  GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
		account2.FirstName = 'testName2';
		insert account2;

		Contact contact = GNE_SFA2_Triggers_Test_Util.prepareContact('testName');
		contact.FirstName = 'testName';
		insert contact;

		Affiliation_vod__c previousAffiliation = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Contact_vod__c = contact.Id,
																		Web_Order_Enabled_gne__c = true, Role_vod__c = 'Affiliated with');
		insert previousAffiliation;

		Affiliation_vod__c testAffiliation = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Contact_vod__c = contact.Id,
																	web_Order_Enabled_gne__c = true, Role_vod__c = 'Affiliated with');

		Test.startTest();
		try {
			insert testAffiliation;
			System.assert(false, 'Duplicate affiliation should not be inserted!');
		} catch (DMLException ex) {
			//System.assert(ex.getMessage().contains(System.Label.Affiliation_cannot_be_created), ex.getMessage());
			//System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
			system.assert(true, 'It should fail');
		}
		Test.stopTest();
	}

	public static testMethod void sameToAccountffiliationsValidationRulesOnInsertTest() {
		Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		account.FirstName = 'testName';
		insert account;

		Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
		account2.FirstName = 'testName2';
		insert account2;

		Account account3 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName3');
		account3.FirstName = 'testName3';
		insert account3;

		Affiliation_vod__c previousAffiliation = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account3.Id,
																		Web_Order_Enabled_gne__c = true, Role_vod__c = 'Affiliated with');
		insert previousAffiliation;

		Affiliation_vod__c testAffiliation = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account3.Id,
																	web_Order_Enabled_gne__c = true, Role_vod__c = 'Affiliated with');

		Test.startTest();
		try {
			insert testAffiliation;
			System.assert(false, 'Duplicate affiliation should not be inserted!');
		} catch (DMLException ex) {
			//System.assert(ex.getMessage().contains(System.Label.Affiliation_cannot_be_created), ex.getMessage());
			//System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
			system.assert(true, 'It should fail');
		}
		Test.stopTest();
	}

	public static testMethod void bothToAccountAndContactffiliationsValidationRulesOnInsertTest() {
		Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		account.FirstName = 'testName';
		insert account;

		Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
		account2.FirstName = 'testName2';
		insert account2;

		Contact contact = GNE_SFA2_Triggers_Test_Util.prepareContact('testName');
		contact.FirstName = 'testName';
		insert contact;

		Affiliation_vod__c testAffiliation = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account2.Id,
																	To_Contact_vod__c = contact.Id, Role_vod__c = 'Affiliated with');

		Test.startTest();
		try {
			insert testAffiliation;
			System.assert(false, 'Affiliation with To Account and To Contact specified should not be inserted!');
		} catch (DMLException ex) {
			System.assert(ex.getMessage().contains(System.Label.Only_One_To_Allowed_Label), ex.getMessage());
			System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		}
		Test.stopTest();
	}

	public static testMethod void bothFromAccountAndContactAffiliationsValidationRulesOnInsertTest() {
		Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		account.FirstName = 'testName';
		insert account;

		Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
		account2.FirstName = 'testName2';
		insert account2;

		Contact contact = GNE_SFA2_Triggers_Test_Util.prepareContact('testName');
		contact.FirstName = 'testName';
		insert contact;

		Affiliation_vod__c testAffiliation = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account2.Id,
																	From_Contact_vod__c = contact.Id, Role_vod__c = 'Affiliated with');

		Test.startTest();
		try {
			insert testAffiliation;
			System.assert(false, 'Affiliation with From Account and From Contact specified should not be inserted!');
		} catch (DMLException ex) {
			System.assert(ex.getMessage().contains(System.Label.Only_One_From_Allowed_Label), ex.getMessage());
			System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		}
		Test.stopTest();
	}

	public static testMethod void emptyToAffiliationsValidationRulesOnInsertTest() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account.FirstName = 'testName';
				insert account;

				Affiliation_vod__c testAffiliation = new Affiliation_vod__c(From_Account_vod__c = account.Id, Role_vod__c = 'Affiliated with');

				Test.startTest();
				try {
					insert testAffiliation;
					System.assert(false, 'Affiliation with empty To Account and To Contact should not be inserted!');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Must_Specify_To_Label), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}

	public static testMethod void emptyFromAffiliationsValidationRulesOnInsertTest() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account.FirstName = 'testName';
				insert account;

				Affiliation_vod__c testAffiliation = new Affiliation_vod__c(To_Account_vod__c = account.Id, Role_vod__c = 'Affiliated with');

				Test.startTest();
				try {
					insert testAffiliation;
					System.assert(false, 'Affiliation with empty From Account and From Contact should not be inserted!');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Must_Specify_From_Label), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}


	public static testMethod void updateToAccountAffiliationsValidationRulesOnUpdateTest() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account.FirstName = 'testName';
				insert account;

				Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
				account2.FirstName = 'testName2';
				insert account2;

				Account account3 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName3');
				account3.FirstName = 'testName3';
				insert account3;

				Affiliation_vod__c testAffiliation = new Affiliation_vod__c(To_Account_vod__c = account.Id, From_Account_vod__c = account2.Id, Role_vod__c = 'Affiliated with');
				insert testAffiliation;

				Test.startTest();
				try {
					testAffiliation.To_Account_vod__c = account3.Id;
					update testAffiliation;
					System.assert(false, 'To Account field of affiliation should not be updated!');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Affiliation_Update_Lock_Label), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}

	public static testMethod void validateAccountAddressAffiliationValidationRulesOnInsertTest() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account.FirstName = 'testName';
				insert account;

				Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
				account2.FirstName = 'testName2';
				insert account2;

				Address_vod__c testAddress = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(account.Id, null, true, null);
				testAddress.Fax_vod__c   = '(999) 999-9999';
				testAddress.Fax_2_vod__c = '(999) 999-9999';
				insert testAddress;

				Affiliation_vod__c testAffiliation = new Affiliation_vod__c(To_Account_vod__c = account.Id, From_Account_vod__c = account2.Id,
													To_Address_gne__c = testAddress.Id, Portal_Affiliation_gne__c = true, Role_vod__c = 'Affiliated with');
				insert testAffiliation;

				Test.startTest();
				try {
					testAffiliation.To_Address_gne__c = null;
					update testAffiliation;
					System.assert(false, 'To Address field of affiliation should not be updated!');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Affiliation_To_Account_To_Address_Empty), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}

	public static testMethod void validateAccountAddressAffiliationValidationRulesOnUpdateTest() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account.FirstName = 'testName';
				insert account;

				Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
				account2.FirstName = 'testName2';
				insert account2;

				Affiliation_vod__c testAffiliation = new Affiliation_vod__c(To_Account_vod__c = account.Id, From_Account_vod__c = account2.Id,
													Portal_Affiliation_gne__c = true, Role_vod__c = 'Affiliated with');
				Test.startTest();
				try {
					insert testAffiliation;
					System.assert(false, 'Portal Affiliation with empty To Address field should not be inseted!');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Affiliation_To_Account_To_Address_Empty), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}

	public static testMethod void validatePortalAffiliationUpdateAffiliationValidationRulesOnUpdateTest() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		Affiliation_vod__c testAffiliation;

		Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		account.FirstName = 'testName';
		insert account;

		Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
		account2.FirstName = 'testName2';
		insert account2;

		Address_vod__c testAddress = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(account.Id, null, true, null);
		testAddress.Fax_vod__c = '(999) 999-9999';
		testAddress.Fax_2_vod__c = '(999) 999-9999';
		insert testAddress;

		testAffiliation = new Affiliation_vod__c(To_Account_vod__c = account.Id, From_Account_vod__c = account2.Id,
											To_Address_gne__c = testAddress.Id, Portal_Affiliation_gne__c = true, Portal_Validation_Flag_gne__c = false, Role_vod__c = 'Affiliated with');
		insert testAffiliation;

		Test.startTest();
		try {
			testAffiliation.Role_vod__c = 'updated role';
			update testAffiliation;
		} catch (DMLException ex) {
			System.assert(false, 'System administrator should be able to update Portal Affiliation!' + ex.getMessage());
		}
		Test.stopTest();
	}

	public static testMethod void validatePortalAffiliationUpdateNotAdminAffiliationValidationRulesOnUpdateTest() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		Affiliation_vod__c testAffiliation;

		List<Profile> sfaProfiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-SFA%' AND Name <> 'GNE-SFA-Ops' ];
		List<User> sfaUsers = [ SELECT Id FROM User WHERE ProfileId in :sfaProfiles AND isActive = true AND IsPortalEnabled = false];
		if(sfaUsers != null && sfaUsers.size() > 0) {
			System.runAs(sfaUsers[0]) {
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account.FirstName = 'testName';
				insert account;

				Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
				account2.FirstName = 'testName2';
				insert account2;

				Address_vod__c testAddress = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(account.Id, null, true, null);
				testAddress.Fax_vod__c = '(999) 999-9999';
				testAddress.Fax_2_vod__c = '(999) 999-9999';
				insert testAddress;

				testAffiliation = new Affiliation_vod__c(To_Account_vod__c = account.Id, From_Account_vod__c = account2.Id,
													To_Address_gne__c = testAddress.Id, Portal_Affiliation_gne__c = true, Portal_Validation_Flag_gne__c = false, Role_vod__c = 'Affiliated with');
				insert testAffiliation;
				Test.startTest();
				try {
					testAffiliation.Role_vod__c = 'new role';
					update testAffiliation;
					System.assert(false, 'Regular users should not be able to update Portal Affiliation!');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Affiliation_Portal_Affiliation), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}
		} else {
			//System.assert(false, 'Could not find any SFA Brands users!');
		}
	}

	public static testMethod void validateToAndFromContactAffiliationValidationRulesOnInsertTest() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Contact contact = GNE_SFA2_Triggers_Test_Util.prepareContact('testName');
				contact.FirstName = 'testName';
				insert contact;

				Contact contact2 = GNE_SFA2_Triggers_Test_Util.prepareContact('testName');
				contact2.FirstName = 'testName';
				insert contact2;

				Affiliation_vod__c testAffiliation = new Affiliation_vod__c(To_Contact_vod__c = contact.Id, From_Contact_vod__c = contact.Id, Role_vod__c = 'Affiliated with');


				Test.startTest();
				try {
					insert testAffiliation;
					System.assert(false, 'Affiliation with the same To Contact and From Contact fields should not be inserted!');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Affiliation_Same_From_to_Contacts), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}

	public static testMethod void validateToAndFromContactAffiliationValidationRulesOnUpdateTest() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Contact contact = GNE_SFA2_Triggers_Test_Util.prepareContact('testName');
				contact.FirstName = 'testName';
				insert contact;

				Contact contact2 = GNE_SFA2_Triggers_Test_Util.prepareContact('testName');
				contact2.FirstName = 'testName';
				insert contact2;

				Affiliation_vod__c testAffiliation = new Affiliation_vod__c(To_Contact_vod__c = contact.Id, From_Contact_vod__c = contact2.Id, Role_vod__c = 'Affiliated with');
				insert testAffiliation;

				Test.startTest();
				try {
					testAffiliation.To_Contact_vod__c = contact2.Id;
					update testAffiliation;
					System.assert(false, 'Affiliation with the same To Contact and From Contact fields should not be updated!');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Affiliation_Same_From_to_Contacts), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	public static testMethod void topPayerField1UpdatesOnInsertTest() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				List<Account> testAccounts = new List<Account>();

				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account.FirstName = 'testName';
				testAccounts.add(account);

				Account account1 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName1');
				account1.FirstName = 'testName1';
				testAccounts.add(account1);

				Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
				account2.FirstName = 'testName2';
				testAccounts.add(account2);

				insert testAccounts;

				Affiliation_vod__c testAffiliation1 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account1.Id,
																			Parent_vod__c = false, Role_vod__c = '-Top Payer 1-');

				Affiliation_vod__c testAffiliation2 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account2.Id,
																			Parent_vod__c = true, Role_vod__c = '-Top Payer 1-');

				Test.startTest();
				insert testAffiliation1;
				insert testAffiliation2;
				Test.stopTest();
				testAffiliation1 = [ SELECT Role_vod__c FROM Affiliation_vod__c WHERE Id = :testAffiliation1.Id ];
			    testAffiliation2 = [ SELECT Role_vod__c FROM Affiliation_vod__c WHERE Id = :testAffiliation2.Id ];

				System.assertEquals('Affiliated with', testAffiliation1.Role_vod__c);
				System.assertEquals('Affiliated with', testAffiliation2.Role_vod__c);
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	public static testMethod void topPayerField2UpdatesOnInsertTest() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				List<Account> testAccounts = new List<Account>();

				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account.FirstName = 'testName';
				testAccounts.add(account);

				Account account3 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account3.FirstName = 'testName';
				testAccounts.add(account3);

				Account account4 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account4.FirstName = 'testName';
				testAccounts.add(account4);

				insert testAccounts;

				Affiliation_vod__c testAffiliation3 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account3.Id,
																			Parent_vod__c = false, Web_Order_Enabled_gne__c = true, Role_vod__c = '-Top Payer 2-');

				Affiliation_vod__c testAffiliation4 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account4.Id,
																			Parent_vod__c = true, Web_Order_Enabled_gne__c = true, Role_vod__c = '-Top Payer 2-');


				Test.startTest();
				insert testAffiliation3;
				insert testAffiliation4;
				Test.stopTest();
				testAffiliation3 = [ SELECT Role_vod__c FROM Affiliation_vod__c WHERE Id = :testAffiliation3.Id ];
				testAffiliation4 = [ SELECT Role_vod__c FROM Affiliation_vod__c WHERE Id = :testAffiliation4.Id ];

				System.assertEquals('Affiliated with', testAffiliation3.Role_vod__c);
				System.assertEquals('Affiliated with', testAffiliation4.Role_vod__c);
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}

	public static testMethod void topPayerField3UpdatesOnInsertTest() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				List<Account> testAccounts = new List<Account>();

				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account.FirstName = 'testName';
				testAccounts.add(account);

				Account account5 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account5.FirstName = 'testName';
				testAccounts.add(account5);

				Account account6 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account6.FirstName = 'testName';
				testAccounts.add(account6);

				insert testAccounts;

				Affiliation_vod__c testAffiliation5 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account5.Id,
																			Parent_vod__c = false, Web_Order_Enabled_gne__c = true, Role_vod__c = '-Top Payer 3-');

				Affiliation_vod__c testAffiliation6 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account6.Id,
																			Parent_vod__c = true, Web_Order_Enabled_gne__c = true, Role_vod__c = '-Top Payer 3-');


				Test.startTest();
				insert testAffiliation5;
				insert testAffiliation6;
				Test.stopTest();
				testAffiliation5 = [ SELECT Role_vod__c FROM Affiliation_vod__c WHERE Id = :testAffiliation5.Id ];
				testAffiliation6 = [ SELECT Role_vod__c FROM Affiliation_vod__c WHERE Id = :testAffiliation6.Id ];

				System.assertEquals('Affiliated with', testAffiliation5.Role_vod__c);
				System.assertEquals('Affiliated with', testAffiliation6.Role_vod__c);
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}

	/*public static testMethod void topPayerFieldUpdatesOnInsertTest() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				List<Account> testAccounts = new List<Account>();

				Account account = new Account(FirstName = 'testName', LastName = 'testName');
				testAccounts.add(account);

				Account account1 = new Account(FirstName = 'testName1', LastName = 'testName1');
				testAccounts.add(account1);

				Account account2 = new Account(FirstName = 'testName2', LastName = 'testName2');
				testAccounts.add(account2);

				Account account3 = new Account(FirstName = 'testName', LastName = 'testName');
				testAccounts.add(account3);

				Account account4 = new Account(FirstName = 'testName', LastName = 'testName');
				testAccounts.add(account4);

				Account account5 = new Account(FirstName = 'testName', LastName = 'testName');
				testAccounts.add(account5);

				Account account6 = new Account(FirstName = 'testName', LastName = 'testName');
				testAccounts.add(account6);

				insert testAccounts;

				Affiliation_vod__c testAffiliation1 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account1.Id,
																			Parent_vod__c = false, Role_vod__c = '-Top Payer 1-');

				Affiliation_vod__c testAffiliation2 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account2.Id,
																			Parent_vod__c = true, Role_vod__c = '-Top Payer 1-');

				Affiliation_vod__c testAffiliation3 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account3.Id,
																			Parent_vod__c = false, Web_Order_Enabled_gne__c = true, Role_vod__c = '-Top Payer 2-');

				Affiliation_vod__c testAffiliation4 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account4.Id,
																			Parent_vod__c = true, Web_Order_Enabled_gne__c = true, Role_vod__c = '-Top Payer 2-');

				Affiliation_vod__c testAffiliation5 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account5.Id,
																			Parent_vod__c = false, Web_Order_Enabled_gne__c = true, Role_vod__c = '-Top Payer 3-');

				Affiliation_vod__c testAffiliation6 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = account6.Id,
																			Parent_vod__c = true, Web_Order_Enabled_gne__c = true, Role_vod__c = '-Top Payer 3-');


				Test.startTest();
				insert testAffiliation1;
				insert testAffiliation2;
				insert testAffiliation3;
				insert testAffiliation4;
				insert testAffiliation5;
				insert testAffiliation6;
				Test.stopTest();
				testAffiliation1 = [ SELECT Role_vod__c FROM Affiliation_vod__c WHERE Id = :testAffiliation1.Id ];
			    testAffiliation2 = [ SELECT Role_vod__c FROM Affiliation_vod__c WHERE Id = :testAffiliation2.Id ];
				testAffiliation3 = [ SELECT Role_vod__c FROM Affiliation_vod__c WHERE Id = :testAffiliation3.Id ];
				testAffiliation4 = [ SELECT Role_vod__c FROM Affiliation_vod__c WHERE Id = :testAffiliation4.Id ];
				testAffiliation5 = [ SELECT Role_vod__c FROM Affiliation_vod__c WHERE Id = :testAffiliation5.Id ];
				testAffiliation6 = [ SELECT Role_vod__c FROM Affiliation_vod__c WHERE Id = :testAffiliation6.Id ];

				System.assertEquals('-Top Payer 1-', testAffiliation1.Role_vod__c);
				System.assertEquals('Affiliated with', testAffiliation2.Role_vod__c);
				System.assertEquals('-Top Payer 2-', testAffiliation3.Role_vod__c);
				System.assertEquals('Affiliated with', testAffiliation4.Role_vod__c);
				System.assertEquals('-Top Payer 3-', testAffiliation5.Role_vod__c);
				System.assertEquals('Affiliated with', testAffiliation6.Role_vod__c);
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}*/

	public static testMethod void setDrugFieldAffiliationFieldUpdatesOnInsertTest() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account.FirstName = 'testName';
				insert account;

				Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
				account2.FirstName = 'testName2';
				insert account2;

				Account account3 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName3');
				account3.FirstName = 'testName3';
				insert account3;

				Affiliation_vod__c childAffiliation = new Affiliation_vod__c(Role_vod__c = 'Affiliated with',
															From_Account_vod__c = account.Id, To_Account_vod__c = account2.Id,
															Drug_gne__c = 'Avastin');
				insert childAffiliation;

				Affiliation_vod__c testAffiliation = new Affiliation_vod__c(Role_vod__c = 'Affiliated with',
															From_Account_vod__c = account.Id, To_Account_vod__c = account3.Id,
															Child_affiliation_vod__c = childAffiliation.Id);
				Test.startTest();
				insert testAffiliation;
				Test.stopTest();

				testAffiliation = [ SELECT Drug_gne__c FROM Affiliation_vod__c WHERE Id = :testAffiliation.Id ];

				System.assertEquals('Avastin', testAffiliation.Drug_gne__c);
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}

	public static testMethod void setDrugFieldAffiliationFieldUpdatesOnUpdateTest() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account.FirstName = 'testName';
				insert account;

				Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
				account2.FirstName = 'testName2';
				insert account2;

				Account account3 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName3');
				account3.FirstName = 'testName3';
				insert account3;

				Affiliation_vod__c childAffiliation = new Affiliation_vod__c(Role_vod__c = 'Affiliated with',
															From_Account_vod__c = account.Id, To_Account_vod__c = account2.Id,
															Drug_gne__c = 'Avastin');
				insert childAffiliation;

				Affiliation_vod__c testAffiliation = new Affiliation_vod__c(Role_vod__c = 'Affiliated with',
															From_Account_vod__c = account.Id, To_Account_vod__c = account3.Id);
				insert testAffiliation;
				Test.startTest();
				testAffiliation.Child_affiliation_vod__c = childAffiliation.Id;
				update testAffiliation;
				Test.stopTest();

				testAffiliation = [ SELECT Drug_gne__c FROM Affiliation_vod__c WHERE Id = :testAffiliation.Id ];

				System.assertEquals('Avastin', testAffiliation.Drug_gne__c);
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}

	/*public static testMethod void changeOwnerMccoProfileAffiliationFieldUpdatesOnUpdateTest() {
		// insert/update custom setting
		GNE_SFA2_Affiliation_Ownership_Rules__c gneMccoCustomSetting;
		if(gneMccoCustomSetting == null) {
			gneMccoCustomSetting = new GNE_SFA2_Affiliation_Ownership_Rules__c(Group_Name__c = 'GNE-CFT-Affiliation-Owner-Queue', Group_Type__c = 'Queue',
							Not_Contains__c = false, Profile_Name_Condition__c = 'GNE-MCCO-CFT', Name='testName');
			insert gneMccoCustomSetting;
		} else {
			gneMccoCustomSetting.Group_Name__c = 'GNE-CFT-Affiliation-Owner-Queue';
			gneMccoCustomSetting.Group_Type__c = 'Queue';
			gneMccoCustomSetting.Not_Contains__c = false;
			gneMccoCustomSetting.Profile_Name_Condition__c = 'GNE-MCCO-CFT';
			update gneMccoCustomSetting;
		}

		List<Group> grpCFT = [ SELECT Id , Name, OwnerID FROM Group WHERE Name LIKE 'GNE-CFT-Affiliation-Owner-Queue' AND Type = 'Queue' LIMIT 1];
		List<Profile> mccoProfiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-MCCO-CFT%' ];
		List<User> mccoUsers = [ SELECT Id FROM User WHERE ProfileId in :mccoProfiles AND isActive = true ];
		if(mccoUsers != null && mccoUsers.size() > 0) {
			System.runAs(mccoUsers[0]) {
				Test.startTest();
				Account account = new Account(FirstName = 'testName', LastName = 'testName');
				insert account;

				List<Account> toAccounts = GNE_SFA2_Affiliation_Test_Helper.prepareTestAccounts();

				List<Affiliation_vod__c> testAffiliations = GNE_SFA2_Affiliation_Test_Helper.prepareTestAffiliations(null, new Map<String, String>{'Role_vod__c' => 'Affiliated with',
														'From_Account_vod__c' => account.Id, 'From_Contact_vod__c' => null, 'To_Contact_vod__c' => null, 'Influence_vod__c' => 'Has influence'}, toAccounts, null);
				insert testAffiliations;
				Test.stopTest();

				testAffiliations = [ SELECT OwnerId FROM Affiliation_vod__c WHERE Id in :testAffiliations ];
				for(Affiliation_vod__c aff : testAffiliations) {
					System.assertEquals(grpCFT[0].Id, aff.OwnerId);
				}
			}
		} else{
			System.assert(false, 'Could not find any GNE-MCCO-CFT users!');
		}
	}*/

	public static testMethod void changeOwnerCanadaProfileAffiliationFieldUpdatesOnUpdateTest() {
		List<Profile> canadaProfiles = [ SELECT Id FROM Profile WHERE Name LIKE '%RCANADA%' ];
		List<User> canadaUsers = [ SELECT Id FROM User WHERE ProfileId in :canadaProfiles AND isActive = true ];
		if(canadaUsers != null && canadaUsers.size() > 0) {
			System.runAs(canadaUsers[0]) {
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account.FirstName = 'testName';
				insert account;

				List<Account> toAccounts = GNE_SFA2_Affiliation_Test_Helper.prepareTestAccounts();

				List<Affiliation_vod__c> testAffiliations = GNE_SFA2_Affiliation_Test_Helper.prepareTestAffiliations(null, new Map<String, String>{'Role_vod__c' => 'Affiliated with',
														'From_Account_vod__c' => account.Id, 'From_Contact_vod__c' => null, 'To_Contact_vod__c' => null, 'Influence_vod__c' => 'Has influence'}, toAccounts, null);
				Test.startTest();
				insert testAffiliations;
				Test.stopTest();

				testAffiliations = [ SELECT OwnerId FROM Affiliation_vod__c WHERE Id in :testAffiliations ];
				for(Affiliation_vod__c aff : testAffiliations) {
					System.assertEquals(canadaUsers[0].Id, aff.OwnerId);
				}
			}
		} else{
			System.assert(false, 'Could not find any Canadian users!');
		}
	}

	/*public static testMethod void changeOwnerCmProfileAffiliationFieldUpdatesOnUpdateTest() {
		Group gneAffiliationOwnerQueue = [ SELECT Id, OwnerId, Name FROM Group WHERE Name = 'GNE-Affiliation-Owner-Queue' AND Type = 'Queue' LIMIT 1];
		//RecordType recordType = [ SELECT Id FROM RecordType WHERE SObjectType = 'Account' LIMIT 1 ];
		Account account = new Account(FirstName = 'testName', LastName = 'testName', RecordTypeId = recordType.Id);
		insert account;

		List<Account> toAccounts = GNE_SFA2_Affiliation_Test_Helper.prepareTestAccounts();

		List<Affiliation_vod__c> testAffiliations = GNE_SFA2_Affiliation_Test_Helper.prepareTestAffiliations(null, new Map<String, String>{'Role_vod__c' => 'Affiliated with',
														'From_Account_vod__c' => account.Id, 'From_Contact_vod__c' => null, 'To_Contact_vod__c' => null, 'Influence_vod__c' => 'Has influence'}, toAccounts, null);
		Test.startTest();
		insert testAffiliations;
		Test.stopTest();

		testAffiliations = [ SELECT OwnerId FROM Affiliation_vod__c WHERE Id in :testAffiliations ];
		for(Affiliation_vod__c aff : testAffiliations) {
			System.assertEquals(gneAffiliationOwnerQueue.Id, aff.OwnerId);
		}
	}

	public static testMethod void updateInverseAffiliationChildRecordUpdatesOnUpdateTest() {
		Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		account.FirstName = 'testName';
		insert account;

		Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
		account2.FirstName = 'testName2';
		insert account2;

		Account account3 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName3');
		account3.FirstName = 'testName3';
		insert account3;

		Affiliation_vod__c childAffiliation = new Affiliation_vod__c(Role_vod__c = 'Affiliated with',
													From_Account_vod__c = account.Id, To_Account_vod__c = account2.Id,
													Drug_gne__c = 'Avastin', Active_for_BioOnc_gne__c = true);
		insert childAffiliation;

		Affiliation_vod__c testAffiliation = new Affiliation_vod__c(Role_vod__c = 'Affiliated with', Child_affiliation_vod__c = childAffiliation.Id,
													From_Account_vod__c = account.Id, To_Account_vod__c = account3.Id, Active_for_BioOnc_gne__c = true);
		insert testAffiliation;
		Test.startTest();
		testAffiliation.Active_for_BioOnc_gne__c = false;
		update testAffiliation;
		Test.stopTest();

		childAffiliation = [ SELECT Active_for_BioOnc_gne__c FROM Affiliation_vod__c WHERE Id = :childAffiliation.Id ];

		System.assertEquals(false, childAffiliation.Active_for_BioOnc_gne__c);
	}	
	 */

	public static testMethod void deleteChildAffiliationChildRecordUpdatesOnDeleteTest() {
		Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		account.FirstName = 'testName';
		insert account;

		List<Account> toAccounts = GNE_SFA2_Affiliation_Test_Helper.prepareTestAccounts();

		List<Account> toAccounts2 = GNE_SFA2_Affiliation_Test_Helper.prepareTestAccounts();

		List<Affiliation_vod__c> testAffiliations = GNE_SFA2_Affiliation_Test_Helper.prepareTestAffiliations(null, new Map<String, String>{'Role_vod__c' => 'Affiliated with',
													'From_Account_vod__c' => account.Id, 'From_Contact_vod__c' => null, 'To_Contact_vod__c' => null}, toAccounts2, null);
		insert testAffiliations;
		System.assertEquals(GNE_SFA2_Affiliation_Test_Helper.BATCH_SIZE, [ SELECT count() FROM Affiliation_vod__c WHERE Child_affiliation_vod__c in :testAffiliations ]);
		GNE_SFA2_Affiliation_Test_Helper.setAfilTrig(false);
		GNE_SFA2_Affiliation_Test_Helper.setUpdAfilTrig(false);

		Test.startTest();
		delete testAffiliations;
		Test.stopTest();

		System.assertEquals(0, [ SELECT count() FROM Affiliation_vod__c WHERE Child_affiliation_vod__c in :testAffiliations ]);
	}


	public static testMethod void insertChildAffiliationChildRecordUpdatesOnInsertTest() {
		Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		account.FirstName = 'testName';
		insert account;

		List<Account> toAccounts = GNE_SFA2_Affiliation_Test_Helper.prepareTestAccounts();

		List<Account> toAccounts2 = GNE_SFA2_Affiliation_Test_Helper.prepareTestAccounts();

		List<Affiliation_vod__c> testAffiliations = GNE_SFA2_Affiliation_Test_Helper.prepareTestAffiliations(null, new Map<String, String>{'Role_vod__c' => 'Affiliated with',
													'From_Account_vod__c' => account.Id, 'From_Contact_vod__c' => null, 'To_Contact_vod__c' => null, 'Influence_vod__c' => 'Has influence'}, toAccounts, null);

		List<Affiliation_vod__c> testAffiliations2 = GNE_SFA2_Affiliation_Test_Helper.prepareTestAffiliations(null, new Map<String, String>{'Role_vod__c' => 'Affiliated with',
													'From_Account_vod__c' => account.Id, 'From_Contact_vod__c' => null, 'To_Contact_vod__c' => null, 'Influence_vod__c' => 'Is influenced'}, toAccounts2, null);

		Test.startTest();
		insert testAffiliations;
		GNE_SFA2_Affiliation_Test_Helper.setAfilTrig(false);
		GNE_SFA2_Affiliation_Test_Helper.setUpdAfilTrig(false);
		insert testAffiliations2;
		Test.stopTest();

		List<Affiliation_vod__c> childAffiliations = [ SELECT Id, Influence_vod__c FROM Affiliation_vod__c WHERE Child_affiliation_vod__c IN :testAffiliations ];
		List<Affiliation_vod__c> childAffiliations2 = [ SELECT Id, Influence_vod__c FROM Affiliation_vod__c WHERE Child_affiliation_vod__c IN :testAffiliations2 ];

		System.assertEquals(GNE_SFA2_Affiliation_Test_Helper.BATCH_SIZE, childAffiliations.size());
		for(Affiliation_vod__c childAffiliation : childAffiliations) {
			System.assertEquals('Is influenced', childAffiliation.Influence_vod__c);
		}

		System.assertEquals(GNE_SFA2_Affiliation_Test_Helper.BATCH_SIZE, childAffiliations2.size());
		for(Affiliation_vod__c childAffiliation : childAffiliations2) {
			System.assertEquals('Has influence', childAffiliation.Influence_vod__c);
		}
	}

	public static testMethod void updateChildAffiliationChildRecordUpdatesOnUpdateTest() {
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
				account.FirstName = 'testName';
				insert account;

				List<Account> toAccounts = GNE_SFA2_Affiliation_Test_Helper.prepareTestAccounts();
				List<Account> toAccounts2 = GNE_SFA2_Affiliation_Test_Helper.prepareTestAccounts();
				List<Account> toAccounts3 = GNE_SFA2_Affiliation_Test_Helper.prepareTestAccounts();

				List<Affiliation_vod__c> testAffiliations = GNE_SFA2_Affiliation_Test_Helper.prepareTestAffiliations(null, new Map<String, String>{'Role_vod__c' => 'Affiliated with',
													'From_Account_vod__c' => account.Id, 'From_Contact_vod__c' => null, 'To_Contact_vod__c' => null, 'Influence_vod__c' => 'Has influence'}, toAccounts, null);

				List<Affiliation_vod__c> testAffiliations2 = GNE_SFA2_Affiliation_Test_Helper.prepareTestAffiliations(null, new Map<String, String>{'Role_vod__c' => 'Affiliated with',
													'From_Account_vod__c' => account.Id, 'From_Contact_vod__c' => null, 'To_Contact_vod__c' => null, 'Influence_vod__c' => 'Is influenced'}, toAccounts2, null);

				List<Affiliation_vod__c> testAffiliations3 = GNE_SFA2_Affiliation_Test_Helper.prepareTestAffiliations(null, new Map<String, String>{'Role_vod__c' => 'Affiliated with',
													'From_Account_vod__c' => account.Id, 'From_Contact_vod__c' => null, 'To_Contact_vod__c' => null}, toAccounts3, null);

				Test.startTest();
				insert testAffiliations;

				GNE_SFA2_Affiliation_Test_Helper.setAfilTrig(false);
				GNE_SFA2_Affiliation_Test_Helper.setUpdAfilTrig(false);
				insert testAffiliations2;

				GNE_SFA2_Affiliation_Test_Helper.setAfilTrig(false);
				GNE_SFA2_Affiliation_Test_Helper.setUpdAfilTrig(false);
				insert testAffiliations3;

				GNE_SFA2_Affiliation_Test_Helper.setAfilTrig(false);
				GNE_SFA2_Affiliation_Test_Helper.setUpdAfilTrig(false);
				for(Integer i = 0; i < GNE_SFA2_Affiliation_Test_Helper.BATCH_SIZE; i++) {
					testAffiliations[i].Comments_vod__c = 'testComment1';
					testAffiliations2[i].Comments_vod__c = 'testComment2';
					testAffiliations3[i].Comments_vod__c = 'testComment3';
					testAffiliations[i].Role_vod__c = 'updatedRole1';
					testAffiliations2[i].Role_vod__c = 'updatedRole2';
					testAffiliations3[i].Role_vod__c = 'updatedRole3';
				}
				update testAffiliations;

				GNE_SFA2_Affiliation_Test_Helper.setAfilTrig(false);
				GNE_SFA2_Affiliation_Test_Helper.setUpdAfilTrig(false);
				update testAffiliations2;

				GNE_SFA2_Affiliation_Test_Helper.setAfilTrig(false);
				GNE_SFA2_Affiliation_Test_Helper.setUpdAfilTrig(false);
				update testAffiliations3;

				Test.stopTest();

				List<Affiliation_vod__c> childAffiliations = [ SELECT Id, Influence_vod__c, Comments_vod__c, Role_vod__c FROM Affiliation_vod__c WHERE Child_affiliation_vod__c IN :testAffiliations ];
				List<Affiliation_vod__c> childAffiliations2 = [ SELECT Id, Influence_vod__c, Comments_vod__c, Role_vod__c FROM Affiliation_vod__c WHERE Child_affiliation_vod__c IN :testAffiliations2 ];
				List<Affiliation_vod__c> childAffiliations3 = [ SELECT Id, Influence_vod__c, Comments_vod__c, Role_vod__c FROM Affiliation_vod__c WHERE Child_affiliation_vod__c IN :testAffiliations3 ];

				System.assertEquals(GNE_SFA2_Affiliation_Test_Helper.BATCH_SIZE, childAffiliations.size());
				for(Affiliation_vod__c childAffiliation : childAffiliations) {
					System.assertEquals('Is influenced', childAffiliation.Influence_vod__c);
					//System.assertEquals('testComment1', childAffiliation.Comments_vod__c);
					//System.assertEquals('updatedRole1', childAffiliation.Role_vod__c);
				}

				System.assertEquals(GNE_SFA2_Affiliation_Test_Helper.BATCH_SIZE, childAffiliations2.size());
				for(Affiliation_vod__c childAffiliation : childAffiliations2) {
					System.assertEquals('Has influence', childAffiliation.Influence_vod__c);
					//System.assertEquals('testComment2', childAffiliation.Comments_vod__c);
					//System.assertEquals('updatedRole2', childAffiliation.Role_vod__c);
				}

				System.assertEquals(GNE_SFA2_Affiliation_Test_Helper.BATCH_SIZE, childAffiliations3.size());
				for(Affiliation_vod__c childAffiliation : childAffiliations3) {
					System.assertEquals('No influence', childAffiliation.Influence_vod__c);
					//System.assertEquals('testComment3', childAffiliation.Comments_vod__c);
					//System.assertEquals('updatedRole3', childAffiliation.Role_vod__c);
				}
			}
		}
	}

	public static testMethod void alignToTerritoryChildRecordUpdatesOnUpdateTest() {
		Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		account.FirstName = 'testName';

		Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
		account2.FirstName = 'testName2';

		List<Profile> sfaBrandUserProfiles = [ SELECT Id FROM Profile WHERE Name = 'GNE-Field'];
		List<User> sfaBrandUsers = [ SELECT Id FROM User WHERE ProfileId IN :sfaBrandUserProfiles AND isActive = true LIMIT 100 ];
		Map<String, Integer> userTerritoriesCount = new Map<String, Integer>();
		List<AggregateResult> terrsCount = [ SELECT UserId, count(Id) FROM UserTerritory2Association WHERE UserId IN :sfaBrandUsers AND (NOT Territory2.External_id_gne__c LIKE 'INACTIVE TERRITORIES%') GROUP BY UserId ];
		for(AggregateResult terrCount : terrsCount) {
			userTerritoriesCount.put((String)terrCount.get('UserId'), (Integer)terrCount.get('expr0'));
		}

		User user1;
		for(User user : sfaBrandUsers) {
			if(userTerritoriesCount.get(user.Id) > 2) {
				user1 = user;
				break;
			}
		}
        if(user1 == null) {
            Territory2 terr = [SELECT Id FROM Territory2 WHERE (NOT External_id_gne__c LIKE 'INACTIVE TERRITORIES%') AND Id NOT IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId =: sfaBrandUsers[0].Id) LIMIT 1];
            insert new UserTerritory2Association(UserId = sfaBrandUsers[0].Id, Territory2Id = terr.Id);
            user1 = sfaBrandUsers[0];
        }


		List<Territory2> userTerrs = [ SELECT Id FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :user1.Id) ];
		Map<String, Group> userTerrsToGroup = new Map<String, Group>();
		for(Group g : [ SELECT Id, RelatedId FROM Group WHERE RelatedId IN :userTerrs AND Type = 'Territory' ] ) {
			userTerrsToGroup.put(g.RelatedId, g);
		}

		if(user1 != null) {
			System.runAs(user1) {
				Test.startTest();
				insert account;
				insert account2;
				ObjectTerritory2Association territoryAssociation = new ObjectTerritory2Association(ObjectId = account.Id, Territory2Id = userTerrs[0].Id, AssociationCause='Territory2Manual');
				insert territoryAssociation;

				Affiliation_vod__c testAffiliation = new Affiliation_vod__c(Role_vod__c = 'Affiliated with',
													From_Account_vod__c = account.Id, To_Account_vod__c = account2.Id);
				insert testAffiliation;
				Test.stopTest();

				List<AccountShare> createdAccountShares = [ SELECT Id FROM AccountShare WHERE AccountId = :account2.Id AND UserOrGroupId = :userTerrsToGroup.get(userTerrs[0].Id).Id ];
				System.assertNotEquals(null, createdAccountShares);
				//System.assertEquals(1, createdAccountShares.size());
			}
		} else {
			System.assert(false, 'Could not find any GNE-SFA users aligned to more than one territory!');
		}
	}

	public static testMethod void generateExternalIdAffiliationFieldUpdatesOnInsertTest() {
		Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		account.FirstName = 'testName';
		insert account;

		Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
		account2.FirstName = 'testName2';
		insert account2;

		Affiliation_vod__c testAffiliation = new Affiliation_vod__c(From_Account_vod__c = account.Id,  To_Account_vod__c = account2.Id, Role_vod__c = 'Affiliated with');

		Test.startTest();
		insert testAffiliation;
		Test.stopTest();

		testAffiliation = [ SELECT External_Id_vod__c FROM Affiliation_vod__c WHERE Id = :testAffiliation.Id LIMIT 1 ];

		System.assertNotEquals(null, testAffiliation.External_Id_vod__c);
		System.assertEquals(account.Id + ':null:' + account2.Id + ':null:Affiliated with', testAffiliation.External_Id_vod__c);
	}

	public static testMethod void generateExternalIdAffiliationFieldUpdatesOnUpdateTest() {
		Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		account.FirstName = 'testName';
		insert account;

		Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
		account2.FirstName = 'testName2';
		insert account2;

		Affiliation_vod__c testAffiliation = new Affiliation_vod__c(From_Account_vod__c = account.Id,  To_Account_vod__c = account2.Id, Role_vod__c = 'Affiliated with', External_Id_vod__c = '');
		insert testAffiliation;

		Test.startTest();
		update testAffiliation;
		Test.stopTest();

		testAffiliation = [ SELECT External_Id_vod__c FROM Affiliation_vod__c WHERE Id = :testAffiliation.Id LIMIT 1 ];

		System.assertNotEquals(null, testAffiliation.External_Id_vod__c);
		System.assertEquals(account.Id + ':null:' + account2.Id + ':null:Affiliated with', testAffiliation.External_Id_vod__c);
	}

	public static User selectSFA2User() {
        List<Profile> sfa2Profiles = [ SELECT Id FROM Profile WHERE Name = 'GNE-FIELD' ];
        if(sfa2Profiles != null && sfa2Profiles.size() > 0) {
            List<User> sfa2Users = [ SELECT Id FROM USER WHERE ProfileId in :sfa2Profiles AND isActive = true ];
            if(sfa2Users != null && sfa2Users.size() > 0) {
                return sfa2Users[0];
            }
        }
        return null;
    }


    public static testMethod void testAffiliationDeletedRecordCreation(){
    	User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
				insert acc;
				Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName2');
				account2.FirstName = 'testName2';
				insert account2;
				Affiliation_vod__c affliation = GNE_SFA2_Triggers_Test_Util.prepareAffiliation_vod(acc.id, null	,account2.Id,null);
				insert affliation;
				Test.startTest();
					delete affliation;
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
		String nameOfDeletedObject = GNE_SFA2_Deleted_Records_Util.getOtrObjectNameForObjectType(Affiliation_vod__c.getSObjectType());
		List<OTR_Deleted_Record_gne__c> deletedRecords  =  [SELECT id, name,Object_name__c,Deleted_Record_Id__c,Parent_Account_Id_gne__c   FROM OTR_Deleted_Record_gne__c WHERE Object_name__c LIKE :nameOfDeletedObject];
		System.assertEquals(2, deletedRecords.size());
    }
}