@isTest
private class CFAR_TeamMemberTrigger_Test {
	@testSetup
	private static void setup() {
		CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();
		CFAR_TestUtils.createRolesToUsersMapping();
		CFAR_TestUtils.createDollarAndDrug('Drug Only');
		CFAR_TestUtils.createDollarAndDrug('$ Only');
		CFAR_TestUtils.createDollarAndDrug('$ and Drug');
		CFAR_Contact_gne__c contact = CFAR_DataFactory.createContact('contact test one', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
		contact.Last_Name_gne__c = 'testlastname1234xx';
		insert contact;
		CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
		insert parentOrg;
		CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'testName123xx');
		insert institution;
		CFAR_Contact_Address_gne__c contactAddress  = CFAR_DataFactory.createContactAddress(institution);
		insert contactAddress;
		CFAR_Contact_Address_JO_gne__c caJO = CFAR_DataFactory.createContactAddressJO(contact, contactAddress);
		insert caJO;
		CFAR_Team_Member_gne__c tm = CFAR_DataFactory.createTeamMember(trial, 'testTM123xxx', caJO, CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
		insert tm;
	}
	static testMethod void shouldUpdateGneSupportOnTrial() {
		//GIVEN
		CFAR_Trial_gne__c trial = [SELECT Investigator_ref_gne__c, Dollar_and_Drug_ref_gne__c FROM CFAR_Trial_gne__c LIMIT 1];
		System.assertEquals(null, trial.Dollar_and_Drug_ref_gne__c, 'If created bypassing Trial Controller, Dollar and Drug should be empty.');

		//WHEN
		CFAR_Team_Member_gne__c pi = [SELECT Dollar_and_Drug_ref_gne__c FROM CFAR_Team_Member_gne__c WHERE Function_Role_gne__c = :CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR];
		CFAR_Dollar_and_Drug_gne__c dollarOnly = [SELECT Id FROM CFAR_Dollar_and_Drug_gne__c WHERE Name = '$ Only'];
		pi.Dollar_and_Drug_ref_gne__c = dollarOnly.Id;
		update pi;

		//THEN
		trial = [SELECT Dollar_and_Drug_ref_gne__c FROM CFAR_Trial_gne__c LIMIT 1];
		System.assertEquals(dollarOnly.Id, trial.Dollar_and_Drug_ref_gne__c, 'If Primary Investigators Gne Support is changed, this change should be populated on related Trial.');
	}

	static testMethod void shouldUpdateInvestigatorOnTrial() {
		//GIVEN
		CFAR_Trial_gne__c trial = [SELECT Investigator_ref_gne__c, Dollar_and_Drug_ref_gne__c FROM CFAR_Trial_gne__c LIMIT 1];
		CFAR_Team_Member_gne__c pi = [SELECT Dollar_and_Drug_ref_gne__c FROM CFAR_Team_Member_gne__c WHERE Function_Role_gne__c = :CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR];
		pi.Inactive_On_gne__c =  Date.today().addDays(-1);
		update pi;

		//WHEN
		CFAR_Contact_gne__c contact = CFAR_DataFactory.createContact('contact test one2', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
		contact.Last_Name_gne__c = 'testContact2';
		insert contact;
		CFAR_Contact_Address_gne__c contactAddress  = CFAR_DataFactory.createContactAddress([SELECT Id FROM CFAR_Institution_gne__c]);
		insert contactAddress;
		CFAR_Contact_Address_JO_gne__c caJO = CFAR_DataFactory.createContactAddressJO(contact, contactAddress);
		insert caJO;
		CFAR_Team_Member_gne__c newPi = CFAR_DataFactory.createTeamMember(trial, 'testMember2', caJO, CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
		newPi.Active_On_gne__c = Date.Today();
		newPi.Inactive_On_gne__c = null;
		newPi.Dollar_and_Drug_ref_gne__c =  [SELECT Id FROM CFAR_Dollar_and_Drug_gne__c WHERE Name = '$ and Drug'].Id;
		insert newPi;

		//THEN
		trial = [SELECT Investigator_ref_gne__c, Dollar_and_Drug_ref_gne__c FROM CFAR_Trial_gne__c LIMIT 1];
		newPi = [SELECT Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c, Dollar_and_Drug_ref_gne__c FROM CFAR_Team_Member_gne__c WHERE Id = :newPi.Id];
		System.assertEquals(newPi.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c, trial.Investigator_ref_gne__c, 
			'If new Primary Investigators is added to Trial, Investigator_ref_gne__c field of trial should be populated by gSTARS Contact related to this team member.');
		System.assertEquals(newPi.Dollar_and_Drug_ref_gne__c, trial.Dollar_and_Drug_ref_gne__c, 
			'If new Primary Investigators is added to Trial, its Gne Support field value should be populated on related Trial.');
	}

	static testMethod void shouldNotUpdateInvestigatorOnTrial() {
		//GIVEN
		CFAR_Trial_gne__c trial = [SELECT Investigator_ref_gne__c, Dollar_and_Drug_ref_gne__c FROM CFAR_Trial_gne__c LIMIT 1];
		CFAR_Team_Member_gne__c pi = [SELECT Dollar_and_Drug_ref_gne__c FROM CFAR_Team_Member_gne__c WHERE Function_Role_gne__c = :CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR];
		pi.Inactive_On_gne__c =  Date.today().addDays(-1);
		update pi;

		//WHEN
		CFAR_Contact_gne__c contact = CFAR_DataFactory.createContact('contact test one2', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
		contact.Last_Name_gne__c = 'testContact2';
		insert contact;
		CFAR_Contact_Address_gne__c contactAddress  = CFAR_DataFactory.createContactAddress([SELECT Id FROM CFAR_Institution_gne__c]);
		insert contactAddress;
		CFAR_Contact_Address_JO_gne__c caJO = CFAR_DataFactory.createContactAddressJO(contact, contactAddress);
		insert caJO;
		CFAR_Team_Member_gne__c newSubInv = CFAR_DataFactory.createTeamMember(trial, 'testMember2', caJO, CFAR_TeamMemberHelper.ROLE_SUB_INVESTIGATOR);
		newSubInv.Active_On_gne__c = Date.Today();
		newSubInv.Inactive_On_gne__c = null;
		newSubInv.Dollar_and_Drug_ref_gne__c = [SELECT Id FROM CFAR_Dollar_and_Drug_gne__c WHERE Name = '$ and Drug'].Id;
		insert newSubInv;

		//THEN
		trial = [SELECT Investigator_ref_gne__c, Dollar_and_Drug_ref_gne__c FROM CFAR_Trial_gne__c LIMIT 1];
		newSubInv = [SELECT Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c, Dollar_and_Drug_ref_gne__c FROM CFAR_Team_Member_gne__c WHERE Id = :newSubInv.Id];
		System.assertNotEquals(newSubInv.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c, trial.Investigator_ref_gne__c, 
			'If team member of Role other than PI is added to trial, trigger should not populate Investigator_ref_gne__c with gstars contact related to this team member.');
		System.assertNotEquals(newSubInv.Dollar_and_Drug_ref_gne__c, trial.Dollar_and_Drug_ref_gne__c, 
			'If team member of Role other than PI is added to trial, trigger should not populate its Dollar_and_Drug_ref_gne__c with gstars contact related to this team member.');
	}
}