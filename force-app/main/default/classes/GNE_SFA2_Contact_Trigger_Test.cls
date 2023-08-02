/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-03
*  Description: This is a test class for GNE_SFA2_Contact_Trigger trigger
*    
*  Modification History
*  Date        	Name        		Description
*  2014-02-20	Piotr Przesmycki	Using GNE_SFA2_Trigger_Test_Util to prepare data
*************************************************************/
@isTest
public without sharing class GNE_SFA2_Contact_Trigger_Test {
    
    private static Integer BATCH_SIZE = 200;
    private static Integer AFFILIATION_BATCH_SIZE = 30;
    
    private static Contact createTestContact(String firstName, String lastName) {
        Contact contact = new Contact(FirstName = firstName, LastName = lastName, MCL_Last_Interaction_Date_gne__c = System.today(),
                                        PFT_Last_Interaction_Date_gne__c = System.today(), Alternate_Fax_gne__c = '(888) 888-8888',
                                        Contact_Type_gne__c = 'Role', Role_gne__c = 'samplerole', Fax = '(888) 888-8888');
        insert contact;
        
        return contact;
    }
    
    private static List<Contact> createTestContacts(String firstName, String lastName) {
        List<Contact> contactsToAdd = new List<Contact>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            contactsToAdd.add(new Contact(FirstName = firstName + String.valueOf(i), LastName = lastName + String.valueOf(i), MCL_Last_Interaction_Date_gne__c = System.today(),
                                        PFT_Last_Interaction_Date_gne__c = System.today()));
        }
        insert contactsToAdd;
        
        return contactsToAdd;
    }
    
    private static List<Call2_vod__c> createTestInteractions(Contact testContact) {
        List<Call2_vod__c> testInteractions = new List<Call2_vod__c>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
        	Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
        	call.Contact_vod__c = testContact.Id;
            testInteractions.add(call);
        }
        
        insert testInteractions;
        return testInteractions;
    }
    
    private static List<Affiliation_vod__c> createTestAffiliations(List<Contact> fromContacts, Contact toContact) {
        List<Affiliation_vod__c> testAffiliations = new List<Affiliation_vod__c>();
        for(Integer i = 0; i < AFFILIATION_BATCH_SIZE; i++) {
            testAffiliations.add(GNE_SFA2_Triggers_Test_Util.prepareAffiliation_vod(null, fromContacts.get(i).Id, null, toContact.Id));
        }
        
        insert testAffiliations;
        return testAffiliations;
    }
    
    public static testMethod void testCreatingContactsMap() {
    	GNE_SFA2_Util.switchAdminMode(false);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Contact_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
		        List<Contact> testContacts = GNE_SFA2_Contact_Test_Helper.prepareTestContacts(null, new Map<String, Object>{'FirstName' => 'firstName', 'LastName' => 'lastName',
										'Alternate_Fax_gne__c' => '(888) 888-8888', 'Fax' => '(888) 888-8888', 'Contact_Type_gne__c' => 'Role', 'Role_gne__c' => 'samplerole',
										'MCL_Last_Interaction_Date_gne__c' => null, 'PFT_Last_Interaction_Date_gne__c' => null});
		        insert testContacts;
		        Test.startTest();
		        delete testContacts;
		        Test.stopTest();
		        
		        System.assertNotEquals(null, GNE_SFA2_Contact_Trigger_Helper.contactsMap);
		        System.assertNotEquals(0, GNE_SFA2_Contact_Trigger_Helper.contactsMap.size());
        	}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
    }
    
    public static testMethod void testContactValidationRules() {
    	GNE_SFA2_Util.switchAdminMode(false);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Contact_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
		        List<Contact> testContacts = GNE_SFA2_Contact_Test_Helper.prepareTestContacts(null, new Map<String, Object>{'FirstName' => 'firstName', 'LastName' => 'lastName',
										'Alternate_Fax_gne__c' => '(888) 888-8888', 'Fax' => '(888) 888-8888', 'Contact_Type_gne__c' => 'Role', 'Role_gne__c' => 'samplerole',
										'MCL_Last_Interaction_Date_gne__c' => null, 'PFT_Last_Interaction_Date_gne__c' => null});
				insert testContacts;
		        createTestInteractions(testContacts[0]);
		        
		        Test.startTest();
		        try {
		            delete testContacts;
		            System.assert(false, 'Contacts with interactions should not be added!');
		        } catch(DMLException ex) {
		            // do nothing - Contacts were not added as expected
		        }
		        Test.stopTest();
        	}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
    }
    
    public static testMethod void testContactValidationRulesOnInsertInvalidFax() {
    	GNE_SFA2_Util.switchAdminMode(false);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Contact_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
		        List<Contact> testContact = GNE_SFA2_Contact_Test_Helper.prepareTestContacts(null, new Map<String, Object>{'FirstName' => 'firstName', 'LastName' => 'lastName',
										'Alternate_Fax_gne__c' => '(888) 888-8888', 'Contact_Type_gne__c' => 'Role', 'Role_gne__c' => 'samplerole',
										'MCL_Last_Interaction_Date_gne__c' => null, 'PFT_Last_Interaction_Date_gne__c' => null});
		        
		        Test.startTest();
		        try {
		            insert testContact;
		            System.assert(false, 'Contacts without Fax number should not be added!');
		        } catch(DMLException ex) {
		            System.assert(ex.getMessage().contains(System.Label.Fax_Required), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		        }
		        Test.stopTest();
        	}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
    }
    
    public static testMethod void testContactValidationRulesOnInsertInvalidAlternateFax() {
    	GNE_SFA2_Util.switchAdminMode(false);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Contact_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
		        List<Contact> testContact = GNE_SFA2_Contact_Test_Helper.prepareTestContacts(null, new Map<String, Object>{'FirstName' => 'firstName', 'LastName' => 'lastName',
										'Fax' => '(888) 888-8888', 'Contact_Type_gne__c' => 'Role', 'Role_gne__c' => 'samplerole',
										'MCL_Last_Interaction_Date_gne__c' => null, 'PFT_Last_Interaction_Date_gne__c' => null});
		        
		        Test.startTest();
		        try {
		            insert testContact;
		            System.assert(false, 'Contacts without Fax number should not be added!');
		        } catch(DMLException ex) {
		            System.assert(ex.getMessage().contains(System.Label.Alternate_Fax_Required), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		        }
		        Test.stopTest();
        	}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
    }
    
    public static testMethod void testContactValidationRulesOnInsertDepartmentMissing() {
    	GNE_SFA2_Util.switchAdminMode(false);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Contact_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
		        List<Contact> testContact = GNE_SFA2_Contact_Test_Helper.prepareTestContacts(null, new Map<String, Object>{'FirstName' => 'firstName', 'LastName' => 'lastName',
										'Fax' => '(888) 888-8888', 'Alternate_Fax_gne__c' => '(888) 888-8888', 'Contact_Type_gne__c' => 'Department', 'Department_gne__c' => '',
										'MCL_Last_Interaction_Date_gne__c' => null, 'PFT_Last_Interaction_Date_gne__c' => null});
		        
		        Test.startTest();
		        try {
		            insert testContact;
		            System.assert(false, 'Contacts without Fax number should not be added!');
		        } catch(DMLException ex) {
		            System.assert(ex.getMessage().contains(System.Label.Department_Required), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		        }
		        Test.stopTest();
        	}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
    }
    
    public static testMethod void testContactValidationRulesOnInsertNameMissing() {
    	GNE_SFA2_Util.switchAdminMode(false);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Contact_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
		        List<Contact> testContact = GNE_SFA2_Contact_Test_Helper.prepareTestContacts(null, new Map<String, Object>{'FirstName' => 'firstName', 'LastName' => 'lastName',
										'Fax' => '(888) 888-8888', 'Alternate_Fax_gne__c' => '(888) 888-8888', 'Contact_Type_gne__c' => 'Program', 'Name_Other_gne__c' => '',
										'MCL_Last_Interaction_Date_gne__c' => null, 'PFT_Last_Interaction_Date_gne__c' => null});
		        
		        Test.startTest();
		        try {
		            insert testContact;
		            System.assert(false, 'Contacts without Fax number should not be added!');
		        } catch(DMLException ex) {
		            System.assert(ex.getMessage().contains(System.Label.Name_Other_Required), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		        }
		        Test.stopTest();
        	}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
    }
    
    public static testMethod void testContactValidationRulesOnInsertRoleMissing() {
    	GNE_SFA2_Util.switchAdminMode(false);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Contact_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
		        List<Contact> testContact = GNE_SFA2_Contact_Test_Helper.prepareTestContacts(null, new Map<String, Object>{'FirstName' => 'firstName', 'LastName' => 'lastName',
										'Fax' => '(888) 888-8888', 'Alternate_Fax_gne__c' => '(888) 888-8888', 'Contact_Type_gne__c' => 'Role', 'Role_gne__c' => '',
										'MCL_Last_Interaction_Date_gne__c' => null, 'PFT_Last_Interaction_Date_gne__c' => null});
		        
		        Test.startTest();
		        try {
		            insert testContact;
		            System.assert(false, 'Contacts without Fax number should not be added!');
		        } catch(DMLException ex) {
		            System.assert(ex.getMessage().contains(System.Label.Role_Required), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		        }
		        Test.stopTest();
        	}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
    }
    
    public static testMethod void testContactValidationRulesOnInsertTitleMissing() {
    	GNE_SFA2_Util.switchAdminMode(false);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Contact_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
		        List<Contact> testContact = GNE_SFA2_Contact_Test_Helper.prepareTestContacts(null, new Map<String, Object>{'FirstName' => 'firstName', 'LastName' => 'lastName',
										'Fax' => '(888) 888-8888', 'Alternate_Fax_gne__c' => '(888) 888-8888', 'Contact_Type_gne__c' => 'Individual', 'Title' => '',
										'MCL_Last_Interaction_Date_gne__c' => null, 'PFT_Last_Interaction_Date_gne__c' => null});
		        
		        Test.startTest();
		        try {
		            insert testContact;
		            System.assert(false, 'Contacts without Fax number should not be added!');
		        } catch(DMLException ex) {
		            System.assert(ex.getMessage().contains(System.Label.Title_Required), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		        }
		        Test.stopTest();
        	}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
    }
    
    public static testMethod void testContactFieldUpdatesLastInteractionDatesUpdate() {
    	GNE_SFA2_Util.switchAdminMode(false);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Contact_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
		        List<Contact> testContacts = GNE_SFA2_Contact_Test_Helper.prepareTestContacts(null, new Map<String, Object>{'FirstName' => 'firstName', 'LastName' => 'lastName',
										'Alternate_Fax_gne__c' => '(888) 888-8888', 'Fax' => '(888) 888-8888', 'Contact_Type_gne__c' => 'Role', 'Role_gne__c' => 'samplerole',
										'MCL_Last_Interaction_Date_gne__c' => System.today(), 'PFT_Last_Interaction_Date_gne__c' => System.today()});
		        insert testContacts;
		        for(Contact testContact : testContacts) {
		        	testContact.MCL_Last_Interaction_Date_gne__c = System.today().addDays(-2);
		        	testContact.PFT_Last_Interaction_Date_gne__c = System.today().addDays(-2);
		        }
		        
		        Test.startTest();
		        update testContacts;
		        Test.stopTest();
		        
		        List<Contact> updatedContacts = [ SELECT Id, MCL_Last_Interaction_Date_gne__c, PFT_Last_Interaction_Date_gne__c FROM Contact WHERE Id IN :testContacts];
		        
		        for(Contact updatedContact : updatedContacts) {
			        System.assertEquals(System.today(), updatedContact.MCL_Last_Interaction_Date_gne__c);
			        System.assertEquals(System.today(), updatedContact.PFT_Last_Interaction_Date_gne__c);
		        }
       		}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
    }
    
    public static testMethod void testContactChildRecordUpdates() {
    	GNE_SFA2_Util.switchAdminMode(false);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Contact_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
		        Contact testContact = createTestContact('firstName', 'lastName');
		        List<Contact> testContacts = GNE_SFA2_Contact_Test_Helper.prepareTestContacts(null, new Map<String, Object>{'FirstName' => 'firstName', 'LastName' => 'lastName',
										'Alternate_Fax_gne__c' => '(888) 888-8888', 'Fax' => '(888) 888-8888', 'Contact_Type_gne__c' => 'Role', 'Role_gne__c' => 'samplerole',
										'MCL_Last_Interaction_Date_gne__c' => null, 'PFT_Last_Interaction_Date_gne__c' => null});
				insert testContacts;
		        List<Affiliation_vod__c> testAffiliations = createTestAffiliations(testContacts, testContact);
		        
		        List<Affiliation_vod__c> addedAffiliations = [ SELECT Id FROM Affiliation_vod__c WHERE Id IN :testAffiliations ];
		        System.assertEquals(AFFILIATION_BATCH_SIZE, addedAffiliations.size());
		        
		        Test.startTest();
		        delete testContact;
		        Test.stopTest();
		        
		        List<Affiliation_vod__c> remainingAffiliations = [ SELECT Id FROM Affiliation_vod__c WHERE To_Contact_vod__c = :testContact.Id ];
		        System.assertEquals(0, remainingAffiliations.size());
        	}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
    }
}