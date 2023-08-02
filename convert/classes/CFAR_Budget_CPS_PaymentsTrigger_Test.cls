@isTest
private class CFAR_Budget_CPS_PaymentsTrigger_Test {

    static testMethod void testBudgetCPSPaymentInsert() {
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
    	CFAR_Payment_Schedule_Status_gne__c paymentSchedule = CFAR_DataFactory.createPaymentScheduleStatus('testname123x');
    	insert paymentSchedule;
    	
		CFAR_Budget_CPS_Payments_gne__c bCPSPayment = CFAR_DataFactory.createBudgePayments(rateTable, bc, paymentSchedule);
		insert bCPSPayment;
		
        
        List<CFAR_Budget_CPS_Payments_gne__c> result = [
        	SELECT Id, frm_sfdc_Completed_gne__c, Invoice_Amount_gne__c, Paid_On_gne__c, Payment_Status_ref_gne__c, 
        			Payment_Status_ref_gne__r.Name, Frm_Trial_Id_gne__c, Invoice_Submitted_Date_gne__c, Planned_Amount_gne__c
        	FROM CFAR_Budget_CPS_Payments_gne__c
        	WHERE Id = :bCPSPayment.Id
        ];
		
		System.assertNotEquals(null, result);
    }
}