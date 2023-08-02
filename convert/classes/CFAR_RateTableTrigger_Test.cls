@isTest
private class CFAR_RateTableTrigger_Test {

    static testMethod void testRTInsert() {
    	CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
		trial.CTMS_gne__c = '09876';
		trial.Other_Trial_gne_Id__c = '09983';
		insert trial;
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
    	CFAR_Budget_Contract_gne__c bc = new CFAR_Budget_Contract_gne__c(Team_Member_ref_gne__c = tm.Id);
    	insert bc;
    	CFAR_Rate_Table_gne__c rateTable = CFAR_DataFactory.createRateTable(bc);
    	rateTable.Payment_Type_gne__c = 'Subject';
    	insert rateTable;
        
        List<CFAR_Rate_Table_gne__c> r = [
        	SELECT Payment_Type_gne__c, Id, Contract_Term_gne__c, Total_Paid_Amount_gne__c
        	FROM CFAR_Rate_Table_gne__c
        	WHERE Id = :rateTable.Id
        ];
        
        System.assertNotEquals(null, r);
        System.assertEquals(0, r[0].Total_Paid_Amount_gne__c);
        
    }
}