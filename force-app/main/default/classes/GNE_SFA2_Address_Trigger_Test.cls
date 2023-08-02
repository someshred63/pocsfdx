/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-08
*  Description: This is a test class for GNE_SFA2_Address_Trigger trigger
*  
*  Modification History
*  Date        Name        		Description
*  2014-01-24  Marta Malinowska	Add test methods for batch processing 
*  2014-02-19  Piotr Przesmycki Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data 
*  2014-12-03   Mateusz Michalczyk  Added after delete logic test for OTR_Deleted_Record_gne__c record creation.      
*************************************************************/
@isTest
public without sharing class GNE_SFA2_Address_Trigger_Test {
	
	/*public static testMethod void testAddressDeactivationValidationRulesInactiveReasonMissing() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c=true, App_Name_gne__c='SFA-US');
				Address_vod__c address = new Address_vod__c(Inactive_vod__c = true, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				
				Test.startTest();
				try {
					insert address;
					System.assert(false, 'Inactive address should not be added, because it has missing fields!');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Address_inactive_reason_cannot_be_null), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}*/

	@testSetup
	static void initData() {
		List<User> usersToInsertList = new List<User>{
				new User(
						ProfileId = [SELECT Id FROM Profile WHERE Name = :'GNE-FIELD' LIMIT 1].Id,
						TimeZoneSidKey = 'America/Los_Angeles',
						Email = 'us@gene.com',
						FirstName = 'usUser',
						External_ID_gne__c = 'ustest',
						Alias = 'ustest',
						Username = 'UsTest@gene.com',
						EmailEncodingKey = 'UTF-8',
						LanguageLocaleKey = 'en_US',
						LocaleSidKey = 'en_US',
						LastName = 'User',
						IsActive = true
				)
		};

		insert usersToInsertList;

	}
	
	public static testMethod void testAddressDeactivationValidationRulesInsertDeactivatedPrimaryAddress() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Address_vod__c address = new Address_vod__c(Inactive_vod__c = true, Primary_vod__c = true,
											Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				
				Test.startTest();
				try {
					insert address;
					System.assert(false, 'Primary address cannot be deactivated!');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Primary_address_cannot_be_marked_inactive), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	public static testMethod void testAddressDeactivationValidationRulesDeactivatePrimaryAddress() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;
				
				Address_vod__c address = new Address_vod__c(Inactive_vod__c = false, Primary_vod__c = true, Account_vod__c = account.Id,
															Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert address;
				
				Address_vod__c updatedAddress = [ SELECT Id, Inactive_vod__c, Primary_vod__c FROM Address_vod__c WHERE Id = :address.Id];
				
				Test.startTest();
				try {
					updatedAddress.Inactive_vod__c = true;
					update updatedAddress;
					System.assert(false, 'Primary address cannot be deactivated!');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Primary_address_cannot_be_marked_inactive), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	/*public static testMethod void testDeaAddressDeleteValidationRulesNotModifyAll() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {			
				Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
				insert account;
				
				Address_vod__c address = new Address_vod__c(Account_vod__c = account.Id, DEA_Address_vod__c = true, DEA_Status_vod__c = 'Valid_vod',
											DEA_Schedule_vod__c = 'testSchedule', DEA_vod__c = 'test', DEA_Expiration_Date_vod__c = System.today(),
											Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert address;
				
				Test.startTest();
				
				try {
					delete address;
					System.assert(false, 'Locked address cannot be deleted!');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.NO_DEL_DEA_ADDRESS), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}	
		} else {
			System.assert(false, 'Could not find any user SFA2 user without Modify All priviledge!');
		}	
	}
	
	public static testMethod void testLockedAddressDeleteValidationRulesNotModifyAll() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {				
				Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
				insert account;
					
				Address_vod__c address = new Address_vod__c(Lock_vod__c = true, Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert address;
					
				Test.startTest();
					
				try {
					delete address;
					System.assert(false, 'Locked address cannot be deleted!');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.ADDRESS_DEL_LOCK_MSG), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}	
		} else {
			System.assert(false, 'Could not find any SFA2 user without Modify All priviledge!');
		}	
	}
	
	public static testMethod void testControlingAddressNotNullAddressDeleteValidationRulesNotModifyAll() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
					
				GNE_SFA2_Address_Trigger_Helper.setChildAccount(false);
									
				Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
				insert account;
					
				Address_vod__c controllingAddress = new Address_vod__c(Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert controllingAddress;
					
				Address_vod__c address = new Address_vod__c(Account_vod__c = account.Id, Controlling_Address_vod__c = controllingAddress.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert address;
					
				Test.startTest();
					
				try {
					delete address;
					System.assert(false, 'Address with controlling address not null cannot be deleted!');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.ADDRESS_DEL_LOCK_MSG), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}	
		} else {
			System.assert(false, 'Could not find any SFA2 user without Modify All priviledge!');
		}	
	}
	
	public static testMethod void testDeaAddressDeleteValidationRulesModifyAll() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {				
				Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
				insert account;
					
				Address_vod__c address = new Address_vod__c(Account_vod__c = account.Id, DEA_Address_vod__c = true, DEA_Status_vod__c = 'Valid_vod',
												Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999', DEA_Schedule_vod__c = 'testSchedule', DEA_vod__c = 'test', DEA_Expiration_Date_vod__c = System.today() );
				insert address;
				
				Test.startTest();
					
				try {
					delete address;
				} catch (DMLException ex) {
					System.assert(false, 'Users with Modify All permission should be able to delete DEA address!');
				}
				Test.stopTest();
			}	
		} else {
			System.assert(false, 'Could not find any user with Modify All priviledge!');
		}	
	}
	
	public static testMethod void testLockedAddressDeleteValidationRulesModifyAll() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		Address_vod__c address;
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
				insert account;
					
				Address_vod__c controllingAddress = new Address_vod__c(Lock_vod__c = true, Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert controllingAddress;
				 	
				address = new Address_vod__c(Account_vod__c = account.Id, Controlling_Address_vod__c = controllingAddress.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert address;
					
				address = [ SELECT Id FROM Address_vod__c WHERE Id = :address.Id ];
			}
		}
			
		List<Profile> profilesWithModifyAll = [ SELECT Id FROM Profile WHERE PermissionsModifyAllData = true ];
		List<User> usersWithModifyAll = [ SELECT Id FROM User WHERE ProfileId in :profilesWithModifyAll AND isActive = true ];
		if(usersWithModifyAll != null && usersWithModifyAll.size() > 0) {
			System.runAs(usersWithModifyAll[0]) {				
					
				Test.startTest();
				try {
					delete address;
				} catch (DMLException ex) {
					System.assert(false, 'Users with Modify All permission should be able to delete locked address!');
				}
				Test.stopTest();
			}	
		} else {
			System.assert(false, 'Could not find any user with Modify All priviledge!');
		}	
	}
	
	
	
	/*public static testMethod void testControlingAddressNotNullAddressDeleteValidationRulesModifyAll() {
			GNE_SFA2_Util.switchAdminMode(false);
			Address_vod__c address; 
			List<Profile> profilesWithoutModifyAll = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-SFA%' AND PermissionsModifyAllData = false ];
			List<User> usersWithoutModifyAll = [ SELECT Id FROM User WHERE ProfileId in :profilesWithoutModifyAll AND isActive = true ];
			if(usersWithoutModifyAll != null && usersWithoutModifyAll.size() > 0) {
				System.runAs(usersWithoutModifyAll[0]) {
					Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
					insert account;
					
					Address_vod__c controllingAddress = new Address_vod__c(Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
					insert controllingAddress;
					
					address = new Address_vod__c(Account_vod__c = account.Id, Controlling_Address_vod__c = controllingAddress.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
					insert address;
					
					address = [ SELECT Id FROM Address_vod__c WHERE Id = :address.Id ];
				}
			}
			
			List<Profile> profilesWithModifyAll = [ SELECT Id FROM Profile WHERE PermissionsModifyAllData = true ];
			List<User> usersWithModifyAll = [ SELECT Id FROM User WHERE ProfileId in :profilesWithModifyAll AND isActive = true ];
			if(usersWithModifyAll != null && usersWithModifyAll.size() > 0) {
				System.runAs(usersWithModifyAll[0]) {
					
					VOD_ADDRESS_TRIG.setChildAccount(false);
					//GNE_SFA2_Address_Trigger_Helper.settChildAccount(false);
					
					Test.startTest();
					
					try {
						delete address;
					} catch (DMLException ex) {
						System.assert(false, 'Users with Modify All permission should be able to delete address with not null controlling address!');
					}
					Test.stopTest();
				}
			} else {
				System.assert(false, 'Could not find any user without Modify All priviledge!');
			}	
	}
	
	public static testMethod void testControlingAddressNotNullAddressUpdateValidationRules() {
			GNE_SFA2_Util.switchAdminMode(false);
			GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
			GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
			GNE_SFA2_Address_Test_Helper.insertCustomSettings();
			GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
			User sfa2User = GNE_SFA2_Util.selectSFA2User();
			if(sfa2User != null) {
				System.runAs(sfa2User) {
				
					Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
					insert account;
							
					Address_vod__c masterAddress = new Address_vod__c(Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
					insert masterAddress;
							
					List<Address_vod__c> testAddresses = GNE_SFA2_Address_Test_Helper.insertTestAddresses(null, new Map<String, Object>{'Account_vod__c' => account.Id, 'Controlling_Address_vod__c' => masterAddress.Id, 'Inactive_vod__c' => false, 'Primary_vod__c' => false,
																	'Lock_vod__c' => false,  'DEA_Address_vod__c' => false, 'No_Address_Copy_vod__c' => false, 'Controlled_Address_vod__c' => false,
																	'Entity_Reference_Id_vod__c' => null, 'Fax_vod__c' => '(999) 999-9999', 'Fax_2_vod__c' => '(999) 999-9999'});
							
					Test.startTest();
							
					for(Address_vod__c address : testAddresses) {
						address.Name = 'new name';					
					}
					try {
						update testAddresses;
						System.assert(false, 'Address with controlling address not null cannot be updated!');
					} catch (DMLException ex) {
						System.assert(ex.getMessage().contains(System.Label.ADDRESS_UPD_LOCK_MSG), ex.getMessage());
						System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', ex.getDmlStatusCode(0));
					}	
					Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	public static testMethod void testDeaAddressUpdateValidationRules() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Profile> profilesWithoutModifyAll = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-SFA%' AND PermissionsModifyAllData = false ];
		List<User> usersWithoutModifyAll = [ SELECT Id FROM User WHERE ProfileId in :profilesWithoutModifyAll AND isActive = true ];
			if(usersWithoutModifyAll != null && usersWithoutModifyAll.size() > 0) {
				System.runAs(usersWithoutModifyAll[0]) {
					Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
					insert account;
					
					List<Address_vod__c> testAddresses = GNE_SFA2_Address_Test_Helper.insertTestAddresses(null, new Map<String, Object>{'Account_vod__c' => account.Id, 'Inactive_vod__c' => false, 'Primary_vod__c' => false,
																		'Lock_vod__c' => false, 'Controlling_Address_vod__c' => null, 'DEA_Address_vod__c' => true, 'DEA_Status_vod__c' => 'Valid_vod', 'DEA_Schedule_vod__c' => 'testSchedule', 
																		'DEA_vod__c' => 'test', 'DEA_Expiration_Date_vod__c' => System.today(), 'No_Address_Copy_vod__c' => false, 'Controlled_Address_vod__c' => false, 'Entity_Reference_Id_vod__c' => null,
																		'Fax_vod__c' => '(999) 999-9999', 'Fax_2_vod__c' => '(999) 999-9999'});		
					
					for(Address_vod__c address : testAddresses) {
						address.Name = 'new name';					
					}
					try {
						Test.startTest();
						update testAddresses;
						Test.stopTest();
						System.assert(false, 'DEA address cannot be updated!');
					} catch (DMLException ex) {
						System.assert(ex.getMessage().contains(System.Label.NO_UPD_DEA_ADDRESS), ex.getMessage());
						System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', ex.getDmlStatusCode(0));
					}
				}
			}	
	}
	
	public static testMethod void testPrimaryAddressUpdateValidationRules() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Profile> profilesWithoutModifyAll = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-SFA%' AND PermissionsModifyAllData = false ];
		List<User> usersWithoutModifyAll = [ SELECT Id FROM User WHERE ProfileId in :profilesWithoutModifyAll AND isActive = true ];
			if(usersWithoutModifyAll != null && usersWithoutModifyAll.size() > 0) {
				System.runAs(usersWithoutModifyAll[0]) {
					Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
					insert account;
					
					Account account2 = new Account(FirstName = 'firstName2', LastName = 'lastName2');
					insert account2;
					
					List<Address_vod__c> testAddresses = GNE_SFA2_Address_Test_Helper.insertTestAddresses(null, new Map<String, Object>{'Account_vod__c' => account.Id, 'Inactive_vod__c' => false, 'Primary_vod__c' => true,
																		'Entity_Reference_Id_vod__c' => account2.Id, 'Lock_vod__c' => false, 'Controlling_Address_vod__c' => null, 'DEA_Address_vod__c' => false, 'No_Address_Copy_vod__c' => false, 'Controlled_Address_vod__c' => false,
																		'Fax_vod__c' => '(999) 999-9999', 'Fax_2_vod__c' => '(999) 999-9999' });		
					Test.startTest();
					for(Address_vod__c address : testAddresses) {
						address.Inactive_vod__c = true;					
					}
					try {
						update testAddresses;
						System.assert(false, 'Primary address cannot be deactivated!');
					} catch (DMLException ex) {
						System.assert(ex.getMessage().contains(System.Label.ADDRESS_PRIMARY_MSG), ex.getMessage());
						System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', ex.getDmlStatusCode(0));
					}
					Test.stopTest();
				}
			}			
	}
	
	public static testMethod void testLockedAddressUpdateValidationRulesNotModifyAll() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Profile> profilesWithoutModifyAll = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-SFA%' AND PermissionsModifyAllData = false ];
		List<User> usersWithoutModifyAll = [ SELECT Id FROM User WHERE ProfileId in :profilesWithoutModifyAll AND isActive = true ];
		if(usersWithoutModifyAll != null && usersWithoutModifyAll.size() > 0) {
			System.runAs(usersWithoutModifyAll[0]) {
				Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
				insert account;
					
				List<Address_vod__c> testAddresses = GNE_SFA2_Address_Test_Helper.insertTestAddresses(null, new Map<String, Object>{'Account_vod__c' => account.Id, 'Inactive_vod__c' => false, 'Primary_vod__c' => false,
															'Controlling_Address_vod__c' => null, 'Lock_vod__c' => true, 'DEA_Address_vod__c' => false, 'No_Address_Copy_vod__c' => false, 'Controlled_Address_vod__c' => false,
															'Entity_Reference_Id_vod__c' => null, 'Fax_vod__c' => '(999) 999-9999', 'Fax_2_vod__c' => '(999) 999-9999'});	
				
				for(Address_vod__c address : testAddresses) {
					address.Name = 'new name';
				}
					
				try {
					update testAddresses;
					System.assert(false, 'Locked address cannot be updated!');
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.ADDRESS_UPD_LOCK_MSG), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', ex.getDmlStatusCode(0));
				}
			}
		}
	}
	
	public static testMethod void testLockedAddressUpdateValidationRulesModifyAll() {
			GNE_SFA2_Util.switchAdminMode(false);
			List<Address_vod__c> testAddresses; 
			List<Profile> profilesWithoutModifyAll = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-SFA%' AND PermissionsModifyAllData = false ];
			List<User> usersWithoutModifyAll = [ SELECT Id FROM User WHERE ProfileId in :profilesWithoutModifyAll AND isActive = true ];
			if(usersWithoutModifyAll != null && usersWithoutModifyAll.size() > 0) {
				System.runAs(usersWithoutModifyAll[0]) {
					Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
					insert account;
					
					testAddresses = GNE_SFA2_Address_Test_Helper.insertTestAddresses(null, new Map<String, Object>{'Account_vod__c' => account.Id, 'Inactive_vod__c' => false, 'Primary_vod__c' => false, 'Controlled_Address_vod__c' => false,
															'Lock_vod__c' => false, 'Controlling_Address_vod__c' => null, 'Lock_vod_c' => true, 'DEA_Address_vod__c' => false, 'No_Address_Copy_vod__c' => false, 'Entity_Reference_Id_vod__c' => null,
															'Fax_vod__c' => '(999) 999-9999', 'Fax_2_vod__c' => '(999) 999-9999'});
				}
			}
			
			List<Profile> profilesWithModifyAll = [ SELECT Id FROM Profile WHERE PermissionsModifyAllData = true ];
			List<User> usersWithModifyAll = [ SELECT Id FROM User WHERE ProfileId in :profilesWithModifyAll AND isActive = true ];
			if(usersWithModifyAll != null && usersWithModifyAll.size() > 0) {
				System.runAs(usersWithModifyAll[0]) {
					
					Test.startTest();
					
					for(Address_vod__c address : testAddresses) {
						address.Name = 'new name';
					}
					try {
						update testAddresses;
					} catch (DMLException ex) {
						System.assert(false, 'Users with Modify All permission should be able to update locked address!');
					}
					Test.stopTest();
				}
			} else {
				System.assert(false, 'Could not find any user without Modify All priviledge!');
			}	
	}*/
	
	/*public static testMethod void testFaxValidationRules() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
				insert account;
				
				Address_vod__c testAddress1 = new Address_vod__c(Account_vod__c = account.Id, Fax_vod__c = null, Fax_2_vod__c = '(999) 999-9999');
				Address_vod__c testAddress2 = new Address_vod__c(Account_vod__c = account.Id, Fax_vod__c = 'invalid fax', Fax_2_vod__c = '(999) 999-9999');
				Address_vod__c testAddress3 = new Address_vod__c(Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				
				Address_vod__c testAddress4 = new Address_vod__c(Account_vod__c = account.Id, Fax_2_vod__c = null, Fax_vod__c = '(999) 999-9999');
				Address_vod__c testAddress5 = new Address_vod__c(Account_vod__c = account.Id, Fax_2_vod__c = 'invalid fax', Fax_vod__c = '(999) 999-9999');
				Address_vod__c testAddress6 = new Address_vod__c(Account_vod__c = account.Id, Fax_2_vod__c = '(999) 999-9999', Fax_vod__c = '(999) 999-9999');  
				*/
				/*try {
					insert testAddress1;
					System.assert(false, 'Address with invalid fax number should not be inserted!');
				} catch (Exception ex) {
					System.assert(ex.getMessage().contains('Please enter a valid fax number'), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}*/
	/*			try {
					insert testAddress1;
				} catch (Exception ex) {
					System.assert(false, 'Address without fax number should be inserted!');
				}

				try {
					insert testAddress2;
					System.assert(false, 'Address with invalid fax number should not be inserted!');
				} catch (Exception ex) {
					System.assert(ex.getMessage().contains('Please enter a valid fax number'), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				
				try {
					insert testAddress3;
				} catch (Exception ex) {
					System.assert(false, 'Address with valid fax number should be inserted!');
				}
				
				try {
					insert testAddress4;
				} catch (Exception ex) {
					System.assert(false, 'Address without fax2 number should be inserted!');
				}
				
				try {
					insert testAddress5;
					System.assert(false, 'Address with invalid fax 2 number should not be inserted!');
				} catch (Exception ex) {
					System.assert(ex.getMessage().contains('Please enter a valid fax number'), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				
				try {
					insert testAddress6;
				} catch (Exception ex) {
					System.assert(false, 'Address with valid fax 2 number should be inserted!');
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}*/
	
	/*public static testMethod void testCanadaPostalCodeAddressValidationRules() {
		GNE_SFA2_Util.switchAdminMode(false);
		Profile canadaProfile = [ SELECT Id FROM Profile WHERE Name LIKE '%CANADA%' LIMIT 1];
		List<User> canadaUsers = [ SELECT Id FROM User WHERE ProfileId = :canadaProfile.Id AND isActive = true ];  
		if(canadaUsers != null && canadaUsers.size() > 0) {
			System.runAs(canadaUsers[0]) {
				Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
				insert account;
				
				Address_vod__c testAddress1 = new Address_vod__c(Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999', Postal_Code_can_gne__c = 'invalid');
				Address_vod__c testAddress2 = new Address_vod__c(Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999', Postal_Code_can_gne__c = 'A0A 1B1');
				
				try {
					insert testAddress1;
					System.assert(false, 'Address with invalid Canada postal code should not be inserted!');
				} catch (Exception ex) {
					System.assert(ex.getMessage().contains('Postal Code must consist of 3 capital letters, 3 digits and one space character and match "XXX XXX" pattern (i.e. A0A 1B1)'), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				
				try {
					insert testAddress2;
				} catch (Exception ex) {
					System.assert(false, 'Address with valid Canada postal code should be inserted!');
				}
			}
		} else {
			System.assert(false, 'Could not find any Canada user!');
		}
	}*/
	
	public static testMethod void testCompanyMaintainedAddressChangeValidationRules() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		RecordType addressRecordType = [ SELECT Name FROM RecordType WHERE Name = 'Company Maintained' LIMIT 1 ];
		if(sfa2User != null) {
			System.runAs(sfa2User) {
					Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
					account.FirstName = 'firstName';
					insert account;
					
					Address_vod__c testAddress = new Address_vod__c(Name = 'testName', City_vod__c = 'testCity', State_vod__c = 'testState', Zip_vod__c = 'zip', RecordTypeId = addressRecordType.Id,
							Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999', Postal_Code_can_gne__c = 'invalid');
					
					Test.startTest();		
					insert testAddress;
					
					try {
						testAddress.Name = 'new name';
						testAddress.City_vod__c = 'new city';
						testAddress.State_vod__c = 'new state';
						testAddress.Zip_vod__c = 'new zip';
						update testAddress;
						System.assert(false, 'Address should not be changed!');
					} catch (Exception ex) {
						System.assert(ex.getMessage().contains('The street address can only be updated via a Data Change Request. Please field to its original value or select the Cancel Button.'), ex.getMessage());
						System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
					}
					Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 user!');
		}
	}
	
	public static testMethod void testCompanyMaintainedAddressChangeValidationRulesSysAdmin() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		RecordType addressRecordType = [ SELECT Name FROM RecordType WHERE Name = 'Company Maintained' LIMIT 1 ];

		// test with System administrator
		Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
		account.FirstName = 'firstName';
		insert account;
			
		Address_vod__c testAddress = new Address_vod__c(Name = 'testName', City_vod__c = 'testCity', State_vod__c = 'testState', Zip_vod__c = 'zip', RecordTypeId = addressRecordType.Id,
						Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999', Postal_Code_can_gne__c = 'invalid');
						
		insert testAddress;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User adminUser = new User(Alias = 'TesAdmin', Email='standardAdminuser@roche.com', 
            EmailEncodingKey='UTF-8', LastName='TestingAdmin', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestingAdmin@roche.com');
		Test.startTest();	
        System.runAs(adminUser){
            try {
                testAddress.Name = 'new name';
                testAddress.City_vod__c = 'new city';
                testAddress.State_vod__c = 'new state';
                testAddress.Zip_vod__c = 'new zip';
                update testAddress;
            } catch (Exception ex) {
                System.assert(false, 'System administrator should be able to change address!');
            }
        }
		
        Test.stopTest();
	}

	/*public static testMethod void testCanadaCompanyMaintainedAddressChangeValidationRules() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		RecordType companyMaintainedRecordType = [ SELECT Name FROM RecordType WHERE Name LIKE 'SFA Canada Company Maintained%' AND SobjectType = 'Address_vod__c' LIMIT 1 ];
		List<RecordType> canadaRecTypes = [ SELECT Id FROM RecordType WHERE Name LIKE 'SFA Canada%' AND SobjectType = 'Address_vod__c' ];
		// test with regular Canada user  
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
				insert account;
				
				Address_vod__c testAddress = new Address_vod__c(Name = 'testName', City_vod__c = 'testCity', State_vod__c = 'testState', Postal_Code_can_gne__c = 'A0A 1B1', RecordTypeId = companyMaintainedRecordType.Id,
						Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
						
				insert testAddress;
				
				Address_vod__c mrmLockTestAddress = new Address_vod__c(Name = 'testName', City_vod__c = 'testCity', State_vod__c = 'testState', Postal_Code_can_gne__c = 'A0A 1B1', RecordTypeId = canadaRecTypes[0].Id,
						Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999', MRM_Lock_add_can_gne__c = true);
						
				insert mrmLockTestAddress;
				
				Account pharmacist = new Account(FirstName = 'firstName', LastName = 'lastName', Account_Type_gne__c = 'Pharmacist');
				insert pharmacist;
				
				Account physician = new Account(FirstName = 'firstName', LastName = 'lastName', Account_Type_gne__c = 'Physician');
				insert physician;
				
				Address_vod__c pharmacistTestAddress = new Address_vod__c(Name = 'pharmacitsAddress', City_vod__c = 'testCity', State_vod__c = 'testState', Postal_Code_can_gne__c = 'A0A 1B1', RecordTypeId = canadaRecTypes[0].Id,
						Account_vod__c = pharmacist.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert pharmacistTestAddress;
				
				
				Address_vod__c physicianTestAddress = new Address_vod__c(Name = 'testName', City_vod__c = 'testCity', State_vod__c = 'testState', Postal_Code_can_gne__c = 'A0A 1B1', RecordTypeId = canadaRecTypes[0].Id,
						Account_vod__c = physician.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert physicianTestAddress;
				
				try {
					testAddress.Name = 'new name';
					testAddress.City_vod__c = 'new city';
					testAddress.State_vod__c = 'new state';
					update testAddress;
					System.assert(false, 'Address should not be changed!');
				} catch (Exception ex) {
					System.assert(ex.getMessage().contains('This address can be updated via a Data Change Request. Please return to its original value or select the Cancel button.'), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				
				try {
					mrmLockTestAddress.Name = 'new name';
					mrmLockTestAddress.City_vod__c = 'new city';
					mrmLockTestAddress.State_vod__c = 'new state';
					update mrmLockTestAddress;
					System.assert(false, 'Address should not be changed!');
				} catch (Exception ex) {
					System.assert(ex.getMessage().contains('This address can be updated via a Data Change Request. Please return to its original value or select the Cancel button.'), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				
				try {
					pharmacistTestAddress.Name = 'new name';
					pharmacistTestAddress.City_vod__c = 'new city';
					pharmacistTestAddress.State_vod__c = 'new state';
					update pharmacistTestAddress;
					System.assert(false, 'Address should not be changed!');
				} catch (Exception ex) {
					System.assert(ex.getMessage().contains('This address can be updated via a Data Change Request. Please return to its original value or select the Cancel button.'), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				
				try {
					physicianTestAddress.Name = 'new name';
					physicianTestAddress.City_vod__c = 'new city';
					physicianTestAddress.State_vod__c = 'new state';
					update physicianTestAddress;
					System.assert(false, 'Address should not be changed!');
				} catch (Exception ex) {
					System.assert(ex.getMessage().contains('This address can be updated via a Data Change Request. Please return to its original value or select the Cancel button.'), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 user!');
		}
		
		// test with System administrator
		Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
		insert account;
			
		Address_vod__c testAddress = new Address_vod__c(Name = 'testName', City_vod__c = 'testCity', State_vod__c = 'testState', Zip_vod__c = 'zip', RecordTypeId = companyMaintainedRecordType.Id,
						Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999', Postal_Code_can_gne__c = 'invalid');
						
		insert testAddress;
				
		try {
			testAddress.Name = 'new name';
			testAddress.City_vod__c = 'new city';
			testAddress.State_vod__c = 'new state';
			testAddress.Zip_vod__c = 'new zip';
			update testAddress;
		} catch (Exception ex) {
			System.assert(false, 'System administrator should be able to change address!');
		}
		
	}*/
	
	public static testMethod void testDeaValidationRules() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {

				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;
					
				Address_vod__c testAddress = new Address_vod__c(DEA_Address_vod__c = true, DEA_Schedule_vod__c = '', DEA_Status_vod__c = '', DEA_Expiration_Date_vod__c = null,
								Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				
				Address_vod__c puertoRicoAddress = new Address_vod__c(DEA_Address_vod__c = true, State_vod__c = 'PR', ASSMCA_vod__c = '', DEA_Schedule_vod__c = 'test', DEA_Status_vod__c = 'Valid_vod', DEA_Expiration_Date_vod__c = System.today(),
								Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
			
				try {				
					insert testAddress;
					System.assert(false, 'Address with empty DEA fields should not be added!');
				} catch (Exception ex) {
					System.assert(ex.getMessage().contains('The DEA Number, DEA Schedule, DEA Status, and DEA Expiration Date are required when creating a DEA Address.'), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				
				try {				
					insert puertoRicoAddress;
					System.assert(false, 'Puerto Rico address with empty ASSMCA_vod__c field should not be added!');
				} catch (Exception ex) {
					System.assert(ex.getMessage().contains('The ASSMCA Number is required when creating a DEA Address for Puerto Rico.'), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	/*public static testMethod void testAddressReactivationValidationRules() {
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		GNE_SFA2_Util.switchAdminMode(false);
		RecordType personAccount = [ SELECT Id FROM RecordType WHERE Name = 'Professional_vod' AND SObjectType = 'Account' LIMIT 1];
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		RecordType addressRecordType = [ SELECT Name FROM RecordType WHERE Name = 'Company Maintained' AND SObjectType = 'Address_vod__c' LIMIT 1 ];
		// test with regular user  
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c=true, App_Name_gne__c='SFA-US');
				Account hcpAccount = new Account(FirstName = 'firstName', LastName = 'lastName', RecordTypeId = personAccount.Id);
				insert hcpAccount;
				
				Account hcoAccount = new Account(FirstName = 'firstName', LastName = 'lastName');
				insert hcoAccount;
					
				Address_vod__c hcpTestAddress = new Address_vod__c(Inactive_vod__c  = true, Active_Flag_gne__c = false, MDM_Address_ID_gne__c = '1234', Inactivate_Reason_gne__c = 'reason',
												RecordTypeId = addressRecordType.Id, Account_vod__c = hcpAccount.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				
				insert hcpTestAddress;
				
				
				
				Address_vod__c hcoTestAddress = new Address_vod__c(Inactive_vod__c  = true, Active_Flag_gne__c = false, MDM_Address_ID_gne__c = '1234', Inactivate_Reason_gne__c = 'reason',
												RecordTypeId = addressRecordType.Id, Account_vod__c = hcoAccount.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				
				insert hcoTestAddress;

				try {
					hcpTestAddress.Inactive_vod__c = false;				
					update hcpTestAddress;
					System.assert(false, 'HCP Address should not be reactivated!');
				} catch (Exception ex) {
					System.assert(ex.getMessage().contains(System.Label.Address_Dactivated_Address_Reactivation_New_Address), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				
				try {				
					hcoTestAddress.Inactive_vod__c = false;				
					update hcoTestAddress;
					System.assert(false, 'HCO Address should not be reactivated!');
				} catch (Exception ex) {
					System.assert(ex.getMessage().contains(System.Label.Address_Dactivated_Address_Reactivation_DCR), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
		Account hcpAccount = new Account(FirstName = 'firstName', LastName = 'lastName', RecordType = personAccount);
		insert hcpAccount;
				
		Account hcoAccount = new Account(FirstName = 'firstName', LastName = 'lastName');
		insert hcoAccount;
					
		Address_vod__c hcpTestAddress = new Address_vod__c(Inactive_vod__c  = true, Active_Flag_gne__c = false, MDM_Address_ID_gne__c = '1234', Inactivate_Reason_gne__c = 'reason',
										Account_vod__c = hcpAccount.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				
		insert hcpTestAddress;
				
		Address_vod__c hcoTestAddress = new Address_vod__c(Inactive_vod__c  = true, Active_Flag_gne__c = false, MDM_Address_ID_gne__c = '1234', Inactivate_Reason_gne__c = 'reason',
										Account_vod__c = hcoAccount.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				
		insert hcoTestAddress;
		// check for system administrator also
		try {
			hcpTestAddress.Inactive_vod__c = false;				
			update hcpTestAddress;
		} catch (Exception ex) {
			System.assert(false, 'System administrator should be able to reactivete HCP Address!');
		}
				
		try {				
			hcoTestAddress.Inactive_vod__c = false;				
			update hcoTestAddress;
		} catch (Exception ex) {
			System.assert(false, 'System administrator should be able to reactivete HCO Address!');
		}
	}*/
	
	/*public static testMethod void testActemraNetworkAddressValidationRules() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		List<Profile> sfaProfiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-SFA-Actemra%'];
		List<User> sfaUsers = [ SELECT Id FROM User WHERE ProfileId in :sfaProfiles AND isActive = true ];
		// test with regular user
		if(sfaUsers != null && sfaUsers.size() > 0) {
			System.runAs(sfaUsers[0]) {
				
				Account testAccount = new Account(FirstName = 'firstName', LastName = 'lastName', Record_Type_Text_GNE__c = 'GNE-Network');
				insert testAccount;
				Address_vod__c testAddress = new Address_vod__c(Inactive_vod__c  = false,
												Account_vod__c = testAccount.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert testAddress;
				
				try {
					testAddress.Name = 'new name';				
					update testAddress;
					System.assert(false, 'SFA Actemra Network address should not be updated!');
				} catch (Exception ex) {
					System.assert(ex.getMessage().contains('The Address cannot be modified. Please Undo the edit of the Address or Cancel the edit of the Address.'), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA Actemra users!');
		}
		Account testAccount = new Account(FirstName = 'firstName', LastName = 'lastName', Record_Type_Text_GNE__c = 'GNE-Network');
		insert testAccount;
					
		Address_vod__c testAddress = new Address_vod__c(Inactive_vod__c  = false,
												Account_vod__c = testAccount.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
		insert testAddress;
				
		try {
			testAddress.Name = 'new name';				
			update testAddress;
		} catch (Exception ex) {
			System.assert(false, 'System administrator should be able to update SFA Actemra Network address!');
		}
	}*/
	
	/*public static testMethod void testAddressActivationFieldUpdates() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c=true, App_Name_gne__c='SFA-US');
				Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
				insert account;
				
				Address_vod__c address = new Address_vod__c(Inactive_vod__c = true, Inactivate_Reason_gne__c = 'test Reason', Account_vod__c = account.Id,
										Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert address;
				
				Test.startTest();
				address.Inactive_vod__c = false;
				update address;
				Test.stopTest();
				
				Address_vod__c updatedAddress = [ SELECT Id, Inactive_vod__c, Primary_vod__c, Inactivate_Reason_gne__c, Inactivate_User_gne__c FROM Address_vod__c WHERE Id = :address.Id];
				System.assertEquals(null, updatedAddress.Inactivate_Reason_gne__c);
				System.assertEquals(null, updatedAddress.Inactivate_User_gne__c);
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}*/
	
	public static testMethod void testAddressDeactivationFieldUpdates() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {

				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;

				Address_vod__c address = new Address_vod__c(Inactive_vod__c = false, Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				Address_vod__c tempAddress = new Address_vod__c(Inactive_vod__c = false, Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999', Primary_vod__c = true);
				insert tempAddress;
				insert address;
				
				Test.startTest();
				address.Inactive_vod__c = true;
				address.Inactivate_Reason_gne__c = 'test Reason';
				update address;
				Test.stopTest();
				
				Address_vod__c updatedAddress = [ SELECT Id, Inactive_vod__c, Primary_vod__c, Inactivate_Reason_gne__c, Inactivate_User_gne__c FROM Address_vod__c WHERE Id = :address.Id];
				System.assertNotEquals(null, updatedAddress.Inactivate_User_gne__c);
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	/*public static testMethod void testAddresInactiveCountFieldUpdates() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c=true, App_Name_gne__c='SFA-US');
				Account account = new Account(FirstName = 'firstName', LastName = 'lastName');
				insert account;
				
				Test.startTest();
				Address_vod__c address = new Address_vod__c(Inactive_vod__c = true, Inactivate_Reason_gne__c = 'test Reason', Account_vod__c = account.Id,
											Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert address;
				
				Address_vod__c updatedAddress = [ SELECT Id, Inactivate_Count_gne__c FROM Address_vod__c WHERE Id = :address.Id LIMIT 1];
				System.assertEquals(1, updatedAddress.Inactivate_Count_gne__c);
				
				updatedAddress.Inactive_vod__c = false;
				update updatedAddress;
				
				updatedAddress.Inactive_vod__c = true;
				updatedAddress.Inactivate_Reason_gne__c = 'test Reason';
				update updatedAddress;
				
				Test.stopTest();
				
				updatedAddress = [ SELECT Id, Inactivate_Count_gne__c FROM Address_vod__c WHERE Id = :address.Id LIMIT 1];
				System.assertEquals(2, updatedAddress.Inactivate_Count_gne__c);
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}*/
	
	public static testMethod void testAddresDeleteChildRecordUpdates() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
        GNE_SFA2_Address_Test_Helper.BATCH_SIZE = 1;
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {

				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;

				Address_vod__c masterAddress = new Address_vod__c(Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert masterAddress;
				
				GNE_SFA2_Address_Test_Helper.insertTestAddresses(null, new Map<String, Object>{'Account_vod__c' => account.Id, 'Controlling_Address_vod__c' => masterAddress.Id, 'Inactive_vod__c' => false, 'Primary_vod__c' => false,
																'Lock_vod__c' => false, 'DEA_Address_vod__c' => false, 'No_Address_Copy_vod__c' => false, 'Controlled_Address_vod__c' => true, 'Entity_Reference_Id_vod__c' => null,
																'Fax_vod__c' => '(999) 999-9999', 'Fax_2_vod__c' => '(999) 999-9999'});
				
				
				System.assertNotEquals(null, GNE_SFA2_Address_Trigger_Helper.getDelSet());
				System.assertEquals(0, GNE_SFA2_Address_Trigger_Helper.getDelSet().size());
				
				Test.startTest();
				delete masterAddress;
				Test.stopTest();
				
				System.assertNotEquals(null, GNE_SFA2_Address_Trigger_Helper.getDelSet());
				System.assertNotEquals(0, GNE_SFA2_Address_Trigger_Helper.getDelSet().size());
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	public static testMethod void testAddresInsertFieldUpdates() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {

				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;
				
				Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName2');
				account2.FirstName = 'firstName2';
				insert account2;
				
				Test.startTest();
				
				Address_vod__c testAddress = new Address_vod__c(Account_vod__c = account.Id, Inactive_vod__c = false, Primary_vod__c = false,
																Lock_vod__c = false, DEA_Address_vod__c = false, No_Address_Copy_vod__c = false, Controlled_Address_vod__c = true,
																Entity_Reference_Id_vod__c = account2.Id, External_ID_vod__c = null, Controlling_Address_vod__c = null,
																Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert testAddress;
				
				Test.stopTest();
				
				List<Address_vod__c> updatedTestAddresses = [ SELECT Id, No_Address_Copy_vod__c, Entity_Reference_Id_vod__c, Account_vod__c, Controlling_Address_vod__c, External_ID_vod__c FROM Address_vod__c WHERE Id = :testAddress.Id ];
				
				for(Address_vod__c addr : updatedTestAddresses) {
					System.assertNotEquals(true, GNE_SFA2_Address_Trigger_Helper.isCopySetFalse(addr.Id));
					System.assertEquals(false, addr.No_Address_Copy_vod__c);
					System.assertEquals(account2.Id, addr.Account_vod__c);
					System.assertEquals(null, addr.Entity_Reference_Id_vod__c);
					System.assertEquals(addr.Account_vod__c + '_' + addr.Controlling_Address_vod__c , addr.External_ID_vod__c);
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	public static testMethod void testAddresUpdateFieldUpdates() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {

				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;
				
				Account account2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName2');
				account2.FirstName = 'firstName2';
				insert account2;
				
				Address_vod__c testAddress = new Address_vod__c(Account_vod__c = account.Id, Inactive_vod__c = false, Primary_vod__c = false, Name = 'testName',
																Lock_vod__c = false, DEA_Address_vod__c = false, No_Address_Copy_vod__c = false, Controlled_Address_vod__c = false,
																Entity_Reference_Id_vod__c = account2.Id, External_ID_vod__c = null, Controlling_Address_vod__c = null, Longitude_vod__c = 0.00,
																Latitude_vod__c = 0.00, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				
				insert testAddress;
				GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
				testAddress = [ SELECT Id, No_Address_Copy_vod__c, Controlled_Address_vod__c, Name FROM Address_vod__c WHERE Id = :testAddress.Id];
				Test.startTest();

				testAddress.No_Address_Copy_vod__c = true;
				testAddress.Controlled_Address_vod__c = true;
				testAddress.Name = 'Updated name';
				update testAddress;	
				Test.stopTest();
				
				List<Address_vod__c> updatedTestAddresses = [ SELECT Id, No_Address_Copy_vod__c, Entity_Reference_Id_vod__c, Account_vod__c, External_ID_vod__c, Controlling_Address_vod__c,
															Longitude_vod__c, Latitude_vod__c FROM Address_vod__c WHERE Id = :testAddress.Id ];
				
				for(Address_vod__c addr : updatedTestAddresses) {
					System.assertEquals(true, GNE_SFA2_Address_Trigger_Helper.isCopySetFalse(addr.Id));
					System.assertEquals(false, addr.No_Address_Copy_vod__c);
					System.assertEquals(account2.Id, addr.Account_vod__c);
					System.assertEquals(addr.Account_vod__c + '_' + addr.Controlling_Address_vod__c , addr.External_ID_vod__c);
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	public static testMethod void testAddresUpdateFieldUpdatePrimaryAddressHandling() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {

				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;
				 
				Address_vod__c testAddress1 = new Address_vod__c(Account_vod__c = account.Id, Inactive_vod__c = false, Primary_vod__c = true, Name = 'testName',
																Lock_vod__c = false, DEA_Address_vod__c = false, No_Address_Copy_vod__c = false, Controlled_Address_vod__c = false,
																Entity_Reference_Id_vod__c = null, External_ID_vod__c = null, Controlling_Address_vod__c = null, Longitude_vod__c = 0.00,
																Latitude_vod__c = 0.00, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				
				insert testAddress1;
				GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
				Address_vod__c testAddress2 = new Address_vod__c(Account_vod__c = account.Id, Inactive_vod__c = false, Primary_vod__c = false, Name = 'testName',
																Lock_vod__c = false, DEA_Address_vod__c = false, No_Address_Copy_vod__c = false, Controlled_Address_vod__c = false,
																Entity_Reference_Id_vod__c = null, External_ID_vod__c = null, Controlling_Address_vod__c = null, Longitude_vod__c = 0.00,
																Latitude_vod__c = 0.00, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				
				insert testAddress2;
				GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
	
				Test.startTest();
				testAddress2.Primary_vod__c = true;
				update testAddress2;
				Test.stopTest();
				
				Address_vod__c updatedTestAddresses1 = [ SELECT Id, No_Address_Copy_vod__c, Entity_Reference_Id_vod__c, Account_vod__c, External_ID_vod__c, Controlling_Address_vod__c,
															Primary_vod__c FROM Address_vod__c WHERE Id = :testAddress1.Id LIMIT 1];
															
				Address_vod__c updatedTestAddresses2 = [ SELECT Id, No_Address_Copy_vod__c, Entity_Reference_Id_vod__c, Account_vod__c, External_ID_vod__c, Controlling_Address_vod__c,
															Primary_vod__c FROM Address_vod__c WHERE Id = :testAddress2.Id LIMIT 1];
	
				System.assertEquals(true, updatedTestAddresses2.Primary_vod__c);
				System.assertEquals(false, updatedTestAddresses1.Primary_vod__c);
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}

	public static testMethod void testUsAddresInsertValidLicenseInfoUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {

				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;
																
				Address_vod__c previousAddress = new Address_vod__c(Account_vod__c = account.Id, Controlling_Address_vod__c = null, Inactive_vod__c = false, Primary_vod__c = false,
																	Lock_vod__c = false, DEA_Address_vod__c = false, No_Address_Copy_vod__c = false, Controlled_Address_vod__c = false, Entity_Reference_Id_vod__c = null, State_vod__c = 'MN',
																	Country_vod__c = 'US', Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert previousAddress;	
				GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
				Address_vod__c testAddress = new Address_vod__c(Account_vod__c = account.Id, Inactive_vod__c = false, Primary_vod__c = false, Name = 'testName', State_vod__c = 'MN', Country_vod__c = 'US',
																	Lock_vod__c = false, DEA_Address_vod__c = false, No_Address_Copy_vod__c = false, Controlled_Address_vod__c = false,
																	Entity_Reference_Id_vod__c = null, External_ID_vod__c = null, Controlling_Address_vod__c = null, Longitude_vod__c = 0.00,
																	Latitude_vod__c = 0.00, License_vod__c = '1234', License_Status_vod__c = 'Valid_vod', License_Expiration_date_vod__c = System.today().addDays(10),
																	Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
																	
				
				Test.startTest();
				insert testAddress;
				Test.stopTest();
				
				for(Address_vod__c addr : [ SELECT Id, License_Expiration_date_vod__c, License_Status_vod__c, License_vod__c FROM Address_vod__c WHERE Id = :previousAddress.Id]) {
					System.assertEquals(testAddress.License_Expiration_date_vod__c, addr.License_Expiration_date_vod__c);
					System.assertEquals(testAddress.License_Status_vod__c, addr.License_Status_vod__c);
					System.assertEquals(testAddress.License_vod__c, addr.License_vod__c);
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	public static testMethod void testUsAddresInsertInvalidLicenseInfoUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {

				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;
				
				Address_vod__c previousAddress = new Address_vod__c(Account_vod__c = account.Id, Inactive_vod__c = false, Primary_vod__c = false, Name = 'testName', State_vod__c = 'CA', Country_vod__c = 'us',
																	Lock_vod__c = false, DEA_Address_vod__c = false, No_Address_Copy_vod__c = false, Controlled_Address_vod__c = false,
																	Entity_Reference_Id_vod__c = null, External_ID_vod__c = null, Controlling_Address_vod__c = null, Longitude_vod__c = 0.00,
																	Latitude_vod__c = 0.00, License_vod__c = '1234', License_Status_vod__c = 'Valid_vod', License_Expiration_date_vod__c = System.today().addDays(10),
																	Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
		
				insert previousAddress;
				GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
				
				Test.startTest();
				Address_vod__c testAddress = new Address_vod__c(Account_vod__c = account.Id, Controlling_Address_vod__c = null, Inactive_vod__c = false, Primary_vod__c = false, 
																Lock_vod__c = false, DEA_Address_vod__c = false, No_Address_Copy_vod__c = false, Controlled_Address_vod__c = false, Entity_Reference_Id_vod__c = null, State_vod__c = 'CA',
																Country_vod__c = 'us', License_vod__c = null, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert testAddress;													
				Test.stopTest();
				
				for(Address_vod__c addr : [ SELECT Id, License_Expiration_date_vod__c, License_Status_vod__c, License_vod__c FROM Address_vod__c WHERE Id = :testAddress.Id]) {
					System.assertEquals(previousAddress.License_Expiration_date_vod__c, addr.License_Expiration_date_vod__c);
					System.assertEquals(previousAddress.License_Status_vod__c, addr.License_Status_vod__c);
					System.assertEquals(previousAddress.License_vod__c, addr.License_vod__c);
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	public static testMethod void testUsAddresUpdateValidLicenseInfoUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
        GNE_SFA2_Address_Test_Helper.BATCH_SIZE = 1;
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;
				
				List<Address_vod__c> previousAddresses = GNE_SFA2_Address_Test_Helper.insertTestAddresses(null, new Map<String, Object>{'Account_vod__c' => account.Id, 'Controlling_Address_vod__c' => null, 'Inactive_vod__c' => false, 'Primary_vod__c' => false,
																	'Lock_vod__c' => false, 'DEA_Address_vod__c' => false, 'No_Address_Copy_vod__c' => false, 'Controlled_Address_vod__c' => false, 'Entity_Reference_Id_vod__c' => null, 'State_vod__c' => 'IL',
																	'Country_vod__c' => 'us', 'License_Expiration_date_vod__c' => System.today() + 15, 'License_status_vod__c' => 'Valid_vod', 'License_vod__c' => '1234',
																	'Fax_vod__c' => '(999) 999-9999', 'Fax_2_vod__c' => '(999) 999-9999'});
				
				GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
				Address_vod__c testAddress = new Address_vod__c(Account_vod__c = account.Id, Inactive_vod__c = false, Primary_vod__c = false, Name = 'testName', State_vod__c = 'CA', Country_vod__c = 'us',
																	Lock_vod__c = false, DEA_Address_vod__c = false, No_Address_Copy_vod__c = false, Controlled_Address_vod__c = false,
																	Entity_Reference_Id_vod__c = null, External_ID_vod__c = null, Controlling_Address_vod__c = null, Longitude_vod__c = 0.00,
																	Latitude_vod__c = 0.00, License_vod__c = '1234', License_Status_vod__c = 'Valid_vod', License_Expiration_date_vod__c = System.today().addDays(10),
																	Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				
				insert testAddress;
				GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
				Test.startTest();
				testAddress.State_vod__c = 'IL';
				update testAddress;
				Test.stopTest();
				
				testAddress = [SELECT Id, License_Status_vod__c, License_Expiration_date_vod__c, License_vod__c, License_Valid_to_Sample_vod__c FROM Address_vod__c WHERE Id = :testAddress.Id LIMIT 1];
				previousAddresses = [SELECT Id, License_Status_vod__c, License_Expiration_date_vod__c, License_vod__c, License_Valid_to_Sample_vod__c FROM Address_vod__c WHERE Id in :previousAddresses ];
				
				System.assertEquals(previousAddresses[0].License_Expiration_date_vod__c, testAddress.License_Expiration_date_vod__c);
				System.assertEquals(previousAddresses[0].License_Status_vod__c, testAddress.License_Status_vod__c);
				System.assertEquals(previousAddresses[0].License_vod__c, testAddress.License_vod__c);
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	public static testMethod void testCanadaAddresInsertInvalidLicenseInfoUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {

				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;
				
				Address_vod__c previousAddress = new Address_vod__c(Account_vod__c = account.Id, Inactive_vod__c = false, Primary_vod__c = false, Name = 'testName', Country_vod__c = 'CA',
																	Lock_vod__c = false, DEA_Address_vod__c = false, No_Address_Copy_vod__c = false, Controlled_Address_vod__c = false,
																	Entity_Reference_Id_vod__c = null, External_ID_vod__c = null, Controlling_Address_vod__c = null, Longitude_vod__c = 0.00,
																	Latitude_vod__c = 0.00, License_vod__c = '1234', License_Status_vod__c = 'Valid_vod', License_Expiration_date_vod__c = System.today().addDays(10),
																	Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
		
				insert previousAddress;
				GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
				
				Test.startTest();
				Address_vod__c testAddress = new Address_vod__c(Account_vod__c = account.Id, Controlling_Address_vod__c = null, Inactive_vod__c = false, Primary_vod__c = false, License_vod__c = null,
																	Lock_vod__c = false, DEA_Address_vod__c = false, No_Address_Copy_vod__c = false, Controlled_Address_vod__c = false, Entity_Reference_Id_vod__c = null, Country_vod__c = 'CA',
																	Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert testAddress;
				Test.stopTest();
				
				
				for(Address_vod__c addr : [ SELECT Id, License_Expiration_date_vod__c, License_Status_vod__c, License_vod__c FROM Address_vod__c WHERE Id = :testAddress.Id]) {
					System.assertEquals(previousAddress.License_Expiration_date_vod__c, addr.License_Expiration_date_vod__c);
					System.assertEquals(previousAddress.License_Status_vod__c, addr.License_Status_vod__c);
					System.assertEquals(previousAddress.License_vod__c, addr.License_vod__c);
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}	
	}
	
	public static testMethod void testCanadaAddresUpdateValidLicenseInfoUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
        GNE_SFA2_Address_Test_Helper.BATCH_SIZE = 1;
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;
				
				List<Address_vod__c> previousAddresses = GNE_SFA2_Address_Test_Helper.insertTestAddresses(null, new Map<String, Object>{'Account_vod__c' => account.Id, 'Controlling_Address_vod__c' => null, 'Inactive_vod__c' => false, 'Primary_vod__c' => false,
																	'Lock_vod__c' => false, 'DEA_Address_vod__c' => false, 'No_Address_Copy_vod__c' => false, 'Controlled_Address_vod__c' => false, 'Entity_Reference_Id_vod__c' => null,
																	'Country_vod__c' => 'CA', 'License_Expiration_date_vod__c' => System.today() + 15, 'License_status_vod__c' => 'Valid_vod', 'License_vod__c' => '1234', 'Fax_vod__c' => '(999) 999-9999', 'Fax_2_vod__c' => '(999) 999-9999'});
				GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
				Address_vod__c testAddress = new Address_vod__c(Account_vod__c = account.Id, Inactive_vod__c = false, Primary_vod__c = false, Name = 'testName', Country_vod__c = 'CA',
																	Lock_vod__c = false, DEA_Address_vod__c = false, No_Address_Copy_vod__c = false, Controlled_Address_vod__c = false,
																	Entity_Reference_Id_vod__c = null, External_ID_vod__c = null, Controlling_Address_vod__c = null, Longitude_vod__c = 0.00,
																	Latitude_vod__c = 0.00, License_vod__c = '1234', License_Status_vod__c = 'Valid_vod', License_Expiration_date_vod__c = System.today().addDays(10),
																	Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				
				insert testAddress;
				Test.startTest();
				testAddress.State_vod__c = 'IL';
				update testAddress;
				Test.stopTest();
				
				testAddress = [SELECT Id, License_Status_vod__c, License_Expiration_date_vod__c, License_vod__c, License_Valid_to_Sample_vod__c FROM Address_vod__c WHERE Id = :testAddress.Id LIMIT 1];
				previousAddresses = [SELECT Id, License_Status_vod__c, License_Expiration_date_vod__c, License_vod__c, License_Valid_to_Sample_vod__c FROM Address_vod__c WHERE Id in :previousAddresses ];
				
				System.assertEquals(previousAddresses[0].License_Expiration_date_vod__c, testAddress.License_Expiration_date_vod__c);
				System.assertEquals(previousAddresses[0].License_Status_vod__c, testAddress.License_Status_vod__c);
				System.assertEquals(previousAddresses[0].License_vod__c, testAddress.License_vod__c);
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}	
	}
	
	public static testMethod void testOneUsAddresUpdateValidLicenseInfoUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;
				
				Address_vod__c previousAddress = new Address_vod__c(Account_vod__c = account.Id, Inactive_vod__c = false, Primary_vod__c = false, Name = 'testName', State_vod__c = 'CA', Country_vod__c = 'us',
																	Lock_vod__c = false, DEA_Address_vod__c = false, No_Address_Copy_vod__c = false, Controlled_Address_vod__c = false,
																	Entity_Reference_Id_vod__c = null, External_ID_vod__c = null, Controlling_Address_vod__c = null, Longitude_vod__c = 0.00,
																	Latitude_vod__c = 0.00, License_vod__c = '1234', License_Status_vod__c = 'Valid_vod', License_Expiration_date_vod__c = System.today().addDays(10),
																	Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
		
				insert previousAddress;
				GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
				
				previousAddress = [SELECT Id, Primary_vod__c, State_vod__c FROM Address_vod__c WHERE Id = :previousAddress.Id];
				Test.startTest();
				previousAddress.State_vod__c = 'IL';
				update previousAddress;
				Test.stopTest();
				
				for(Address_vod__c addr : [ SELECT Id, License_Expiration_date_vod__c, License_Status_vod__c, License_vod__c FROM Address_vod__c WHERE Id = :previousAddress.Id]) {
					System.assertEquals(null, addr.License_Expiration_date_vod__c);
					System.assertEquals(null, addr.License_Status_vod__c);
					System.assertEquals(null, addr.License_vod__c);
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}	
	}
	
	public static testMethod void testBatchDeleteValidationRules() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;
				
				List<Address_vod__c> testAddresses = new List<Address_vod__c>();
				testAddresses.add(new Address_vod__c(Name = 'test address', Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999',
								DEA_Address_vod__c = true, DEA_Schedule_vod__c = 'test', DEA_Status_vod__c = 'Valid_vod', DEA_Expiration_Date_vod__c = System.today()));
				testAddresses.add(new Address_vod__c(Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999'));
				
				insert testAddresses;
				
				Database.DeleteResult[] srList = Database.delete(testAddresses, false);
				
				//testAddresses[0]: DEA Address should not be deleted!
				List<Database.Error> invalidFaxErrors = srList[0].getErrors();
				System.assertEquals(System.Label.DEA_Address_Delete_Lock_Label , invalidFaxErrors[0].getMessage());
				//testAddresses[1]: Address should be deleted!
				System.assertEquals(srList[1].isSuccess() , true);
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	public static testMethod void testBatchUpdateValidationRules() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		RecordType addressRecordType = [ SELECT Name FROM RecordType WHERE Name = 'Company Maintained' LIMIT 1 ];
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;

				TSF_vod__c tsf = GNE_SFA2_Triggers_Test_Util.prepareTSF_vod(account.Id);
				tsf.Address_vod__c = null;
				insert tsf;
				
				List<Address_vod__c> testAddresses = new List<Address_vod__c>();
				testAddresses.add(new Address_vod__c(Account_vod__c = account.Id, Primary_vod__c = true, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999'));
				testAddresses.add(new Address_vod__c(Account_vod__c = account.Id, Fax_2_vod__c = null, Fax_vod__c = '(999) 999-9999'));
				testAddresses.add(new Address_vod__c(Name = 'testName', City_vod__c = 'testCity', State_vod__c = 'testState', Zip_vod__c = 'zip', RecordTypeId = addressRecordType.Id,
													Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999', Postal_Code_can_gne__c = 'invalid'));
				insert testAddresses;
				
				testAddresses[0].Fax_vod__c = 'invalid fax';
				testAddresses[0].Fax_2_vod__c = 'invalid fax';
				testAddresses[1].Fax_2_vod__c = '(999) 999-9999';
				testAddresses[2].Name = 'new name';
				testAddresses[2].City_vod__c = 'new city';
				testAddresses[2].State_vod__c = 'new state';
				testAddresses[2].Zip_vod__c = 'new zip';
				
				Database.SaveResult[] srList = Database.update(testAddresses, false);
				
				//testAddresses[0]: Address with invalid fax and fax 2 number should not be updated!
				List<Database.Error> invalidFaxErrors = srList[0].getErrors();
				System.assertEquals(System.Label.Address_Invalid_Fax_Number , invalidFaxErrors[0].getMessage());
				System.assertEquals('Fax_vod__c' , invalidFaxErrors[0].getFields()[0]);
				System.assertEquals(System.Label.Address_Invalid_Fax_Number , invalidFaxErrors[1].getMessage());
				System.assertEquals('Fax_2_vod__c' , invalidFaxErrors[1].getFields()[0]);
				//testAddresses[1]: Address with valid fax2 number should be updated!
				System.assertEquals(srList[1].isSuccess() , true);
				//testAddresses[2]: Address should not be changed!
				List<Database.Error> addressChangedErrors = srList[2].getErrors();
				System.assertEquals(System.Label.Address_Street_Address_Cannot_Be_Updated , addressChangedErrors[0].getMessage());
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	public static testMethod void testBatchInsertValidationRules() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger__c', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;

				TSF_vod__c tsf = GNE_SFA2_Triggers_Test_Util.prepareTSF_vod(account.Id);
				tsf.Address_vod__c = null;
				insert tsf;

				Test.startTest();
				Address_vod__c primaryAddress = new Address_vod__c(Account_vod__c = account.Id, Primary_vod__c = true, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999');
				insert primaryAddress;
				
				List<Address_vod__c> testAddresses = new List<Address_vod__c>();	
				
				testAddresses.add(new Address_vod__c(Account_vod__c = account.Id, Primary_vod__c = true, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999'));
				testAddresses.add(new Address_vod__c(Account_vod__c = account.Id, Fax_vod__c = 'invalid fax', Fax_2_vod__c = '(999) 999-9999',
								DEA_Address_vod__c = true, DEA_Schedule_vod__c = '', DEA_Status_vod__c = '', DEA_Expiration_Date_vod__c = null));
				
				testAddresses.add(new Address_vod__c(Account_vod__c = account.Id, Fax_2_vod__c = null, Fax_vod__c = '(999) 999-9999'));
				testAddresses.add(new Address_vod__c(Account_vod__c = account.Id, Fax_2_vod__c = 'invalid fax', Fax_vod__c = 'invalid fax'));
				
				testAddresses.add(new Address_vod__c(DEA_Address_vod__c = true, State_vod__c = 'PR', ASSMCA_vod__c = '', DEA_Schedule_vod__c = 'test', DEA_Status_vod__c = 'Valid_vod', DEA_Expiration_Date_vod__c = System.today(),
								Account_vod__c = account.Id, Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999'));
				
				Database.SaveResult[] srList = Database.insert(testAddresses, false);
				
				//testAddresses[0]: Address with valid fax number should be inserted!
				System.assertEquals(srList[0].isSuccess() , true);
				
				//testAddresses[1]: Address with invalid fax number and missing DEA field should not be inserted!
				List<Database.Error> faxAndMissingDEAErrors = srList[1].getErrors();
				System.assertEquals(System.Label.Address_Invalid_Fax_Number , faxAndMissingDEAErrors[0].getMessage());
				System.assertEquals('Fax_vod__c' , faxAndMissingDEAErrors[0].getFields()[0]);
				System.assertEquals(System.Label.Address_Missing_DEA_Fields , faxAndMissingDEAErrors[1].getMessage());
				System.assertEquals('Accepting_New_Patients_gne__c' , faxAndMissingDEAErrors[1].getFields()[0]);
				
				//testAddresses[2]: Address without fax2 number should be inserted!'
				System.assertEquals(srList[2].isSuccess() , true);
				
				//testAddresses[3]: Address with invalid fax and fax 2 number should not be inserted!
				List<Database.Error> invalidFaxErrors = srList[3].getErrors();
				System.assertEquals(System.Label.Address_Invalid_Fax_Number , invalidFaxErrors[0].getMessage());
				System.assertEquals('Fax_vod__c' , invalidFaxErrors[0].getFields()[0]);
				System.assertEquals(System.Label.Address_Invalid_Fax_Number , invalidFaxErrors[1].getMessage());
				System.assertEquals('Fax_2_vod__c' , invalidFaxErrors[1].getFields()[0]);
				
				//testAddresses[4]: Address with missing ASSMCA number should not be inserted!
				List<Database.Error> missingASSMCAErrors = srList[4].getErrors();
				System.assertEquals(System.Label.Address_Missing_ASSMCA_Number , missingASSMCAErrors[0].getMessage());
				
				//Primary address is is now updated with false value
				Address_vod__c primaryAddressAfterUpdate = [SELECT Id, Name, Primary_vod__c FROM Address_vod__c WHERE Id = :primaryAddress.Id];
				System.assertEquals(primaryAddressAfterUpdate.Primary_vod__c , false);
				Account updatedAccount = [SELECT Id, Name, Main_Address_gne__c FROM Account WHERE Id = :account.Id];
				System.assertEquals(updatedAccount.Main_Address_gne__c , testAddresses[0].Id);
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	public static testMethod void testAddresBatchInsertPrimaryAddressHandling() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {

				List<Account> accounts = new List<Account>();
				accounts.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName1'));
				accounts.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName2'));
				insert accounts;
				
				List<Address_vod__c> testAddresses1 = new List<Address_vod__c>();
				testAddresses1.add(new Address_vod__c(Account_vod__c = accounts[0].Id, Inactive_vod__c = false, Primary_vod__c = true, Name = 'testName',
																Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999'));
				testAddresses1.add(new Address_vod__c(Account_vod__c = accounts[1].Id, Inactive_vod__c = false, Primary_vod__c = true, Name = 'testName',
																Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999'));
				insert testAddresses1;
				List<Id> testAddresses1Ids = new List<Id>();
				for(Address_vod__c testAddress : testAddresses1){
					testAddresses1Ids.add(testAddress.Id);
				}
				
				Test.startTest();
				GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
				List<Address_vod__c> testAddresses2 = new List<Address_vod__c>();
				testAddresses2.add(new Address_vod__c(Account_vod__c = accounts[0].Id, Inactive_vod__c = false, Primary_vod__c = true, Name = 'testName',
																Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999'));
				testAddresses2.add(new Address_vod__c(Account_vod__c = accounts[0].Id, Inactive_vod__c = false, Primary_vod__c = true, Name = 'testName',
																Fax_vod__c = 'invalid fax', Fax_2_vod__c = '(999) 999-9999'));
				testAddresses2.add(new Address_vod__c(Account_vod__c = accounts[1].Id, Inactive_vod__c = false, Primary_vod__c = true, Name = 'testName',
																Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999'));
				
				Database.SaveResult[] srList1 = Database.insert(testAddresses2, false);
				
				//Primary address is is now updated with false value
				List<Address_vod__c> updatedTestAddresses1 = [SELECT Id, Primary_vod__c FROM Address_vod__c WHERE Id IN :testAddresses1Ids];
				for(Address_vod__c updatedTestAddress : updatedTestAddresses1){
					System.assertEquals(updatedTestAddress.Primary_vod__c , false);
				}
				//Main addresses for accounts are updated
				Account updatedAccount1 = [SELECT Id, Name, Main_Address_gne__c FROM Account WHERE Id = :accounts[0].Id LIMIT 1];
				System.assertEquals(updatedAccount1.Main_Address_gne__c , testAddresses2[0].Id);
				Account updatedAccount2 = [SELECT Id, Name, Main_Address_gne__c FROM Account WHERE Id = :accounts[1].Id LIMIT 1];
				System.assertEquals(updatedAccount2.Main_Address_gne__c , testAddresses2[2].Id);
				Test.stopTest();
				
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	public static testMethod void testAddresBatchUpdatePrimaryAddressHandling() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				
				List<Account> accounts = new List<Account>();
				accounts.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName1'));
				accounts.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName2'));
				insert accounts;
				
				List<Address_vod__c> testAddresses1 = new List<Address_vod__c>();
				testAddresses1.add(new Address_vod__c(Account_vod__c = accounts[0].Id, Inactive_vod__c = false, Primary_vod__c = true, Name = 'testName',
																Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999'));
				testAddresses1.add(new Address_vod__c(Account_vod__c = accounts[1].Id, Inactive_vod__c = false, Primary_vod__c = true, Name = 'testName',
																Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999'));
				insert testAddresses1;
				List<Id> testAddresses1Ids = new List<Id>();
				for(Address_vod__c testAddress : testAddresses1){
					testAddresses1Ids.add(testAddress.Id);
				}
				
				GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
				List<Address_vod__c> testAddresses2 = new List<Address_vod__c>();
				testAddresses2.add(new Address_vod__c(Account_vod__c = accounts[0].Id, Inactive_vod__c = false, Primary_vod__c = false, Name = 'testName',
																Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999'));
				testAddresses2.add(new Address_vod__c(Account_vod__c = accounts[1].Id, Inactive_vod__c = false, Primary_vod__c = false, Name = 'testName',
																Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999'));
				insert testAddresses2;
				
				Test.startTest();
				GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
	
				for(Address_vod__c updatedTestAddress : testAddresses2){
					updatedTestAddress.Primary_vod__c = true;
				}
				
				Database.SaveResult[] srList = Database.update(testAddresses2, false);
				
				System.assertEquals(srList[0].isSuccess() , true);
				//Primary address is is now updated with false value
				List<Address_vod__c> updatedTestAddresses1 = [SELECT Id, Primary_vod__c FROM Address_vod__c WHERE Id IN :testAddresses1Ids];
				for(Address_vod__c updatedTestAddress : updatedTestAddresses1){
					System.assertEquals(updatedTestAddress.Primary_vod__c , false);
				}
				//Main addresses for accounts are updated
				Account updatedAccount1 = [SELECT Id, Name, Main_Address_gne__c FROM Account WHERE Id = :accounts[0].Id LIMIT 1];
				System.assertEquals(updatedAccount1.Main_Address_gne__c , testAddresses2[0].Id);
				Account updatedAccount2 = [SELECT Id, Name, Main_Address_gne__c FROM Account WHERE Id = :accounts[1].Id LIMIT 1];
				System.assertEquals(updatedAccount2.Main_Address_gne__c , testAddresses2[1].Id);
				Test.stopTest();
				
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
	}
	
	public static testMethod void testUsAddresBatchInsertLicenseInfoUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = selectSFA2User();
		if(sfa2User != null) {
			System.runAs(sfa2User) {
				
				Account account = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
				account.FirstName = 'firstName';
				insert account;
				
				List<Address_vod__c> previousAddresses = new List<Address_vod__c>();										
				previousAddresses.add(new Address_vod__c(Account_vod__c = account.Id, Inactive_vod__c = false, Primary_vod__c = false, Name = 'test',
														State_vod__c = 'MN', Country_vod__c = 'US', Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999'));
				previousAddresses.add(new Address_vod__c(Account_vod__c = account.Id, Inactive_vod__c = false, Primary_vod__c = false, Name = 'testName', 
														State_vod__c = 'CA', Country_vod__c = 'US', Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999',
														License_vod__c = '1234', License_Status_vod__c = 'Valid_vod', License_Expiration_date_vod__c = System.today().addDays(10)));
				insert previousAddresses;
				
				GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
				Test.startTest();
				List<Address_vod__c> testAddresses = new List<Address_vod__c>();
				testAddresses.add(new Address_vod__c(Account_vod__c = account.Id, Inactive_vod__c = false, Primary_vod__c = false, Name = 'testName', 
														State_vod__c = 'MN', Country_vod__c = 'US', Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999',
														License_vod__c = '1234', License_Status_vod__c = 'Valid_vod', License_Expiration_date_vod__c = System.today().addDays(10)));
				testAddresses.add(new Address_vod__c(Account_vod__c = account.Id, Inactive_vod__c = false, Primary_vod__c = false,
														State_vod__c = 'CA', Country_vod__c = 'US', Fax_vod__c = '(999) 999-9999', Fax_2_vod__c = '(999) 999-9999',
														License_vod__c = null));
				testAddresses.add(new Address_vod__c(Account_vod__c = account.Id, Inactive_vod__c = false, Primary_vod__c = false,
														State_vod__c = 'CA', Country_vod__c = 'US', Fax_vod__c = 'invalid fax',
														License_vod__c = null));
														
				Database.SaveResult[] srList = Database.insert(testAddresses, false);
				
				System.assertEquals(srList[0].isSuccess() , true);
				Address_vod__c updatedMnStateAddress = [SELECT Id, License_Expiration_date_vod__c, License_Status_vod__c, License_vod__c FROM Address_vod__c WHERE Id = :previousAddresses[0].Id];
				System.assertEquals(testAddresses[0].License_Expiration_date_vod__c, updatedMnStateAddress.License_Expiration_date_vod__c);
				System.assertEquals(testAddresses[0].License_Status_vod__c, updatedMnStateAddress.License_Status_vod__c);
				System.assertEquals(testAddresses[0].License_vod__c, updatedMnStateAddress.License_vod__c);
				
				System.assertEquals(srList[1].isSuccess() , true);
				Address_vod__c updatedCaStateAddress = [SELECT Id, License_Expiration_date_vod__c, License_Status_vod__c, License_vod__c FROM Address_vod__c WHERE Id = :testAddresses[1].Id];
				System.assertEquals(updatedCaStateAddress.License_Expiration_date_vod__c, previousAddresses[1].License_Expiration_date_vod__c);
				System.assertEquals(updatedCaStateAddress.License_Status_vod__c, previousAddresses[1].License_Status_vod__c);
				System.assertEquals(updatedCaStateAddress.License_vod__c, previousAddresses[1].License_vod__c);
				
				System.assertEquals(srList[2].isSuccess() , false);
				List<Database.Error> errors = srList[2].getErrors();
				System.assertEquals(System.Label.Address_Invalid_Fax_Number , errors[0].getMessage());
				
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
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

    public static testMethod void testAddingOTRDeletedRecordsForAddress(){
    	GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
		GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Address_Test_Helper.insertCustomSettings();
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
    	
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
				insert acc;
				List<Address_vod__c> addresses = new List<Address_vod__c>();
				for(Integer i =0; i<200 ; i++){
					addresses.add(new Address_vod__c(Account_vod__c = acc.id, Name= 'some random address '));
				}
				insert addresses;
				Test.startTest();
					delete addresses;
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 users!');
		}
		String nameOfDeletedObject = GNE_SFA2_Deleted_Records_Util.getOtrObjectNameForObjectType(Address_vod__c.getSObjectType());
		List<OTR_Deleted_Record_gne__c> deletedRecords  =  [SELECT id, name,Object_name__c,Deleted_Record_Id__c,Parent_Account_Id_gne__c FROM OTR_Deleted_Record_gne__c WHERE Object_name__c LIKE :nameOfDeletedObject];
		System.assertEquals(200, deletedRecords.size());
	
	}
}