@isTest
private class CFAR_Budget_Contract_TrackingTriggerTest {
    @testSetup
    static void setup() {
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        trial.CTMS_gne__c = '09876';
        trial.Other_Trial_gne_Id__c = '09983';
        trial.IIS_Portal_RO_Number_gne__c = 'RO-IIS-2017-12345';
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

        CFAR_Budget_Contract_gne__c bc = CFAR_DataFactory.createBudgetContract(tm);
        insert bc;

        CFAR_Budget_Contract_Type_gne__c contractType = new CFAR_Budget_Contract_Type_gne__c(Active_gne__c = true, Name = 'Planned');
        insert contractType;

        CFAR_Budget_Contract_Tracking_gne__c bct = new CFAR_Budget_Contract_Tracking_gne__c();
        bct.Type_ref_gne__c = contractType.Id;
        bct.Amount_gne__c = 11;
        bct.Budget_Contract_ref_gne__c = bc.Id;
        insert bct;
        System.assert(true);
    }

    static testMethod void testInsertBudgetContractTracking() {
        //GIVEN
        CFAR_Budget_Contract_Type_gne__c plannedContractType = [SELECT Id FROM CFAR_Budget_Contract_Type_gne__c WHERE Name = 'Planned'];
        CFAR_Budget_Contract_gne__c bc = [SELECT Id FROM  CFAR_Budget_Contract_gne__c LIMIT 1];

        //WHEN
        CFAR_Budget_Contract_Tracking_gne__c bct = new CFAR_Budget_Contract_Tracking_gne__c();
        bct.Type_ref_gne__c = plannedContractType.Id;
        bct.Amount_gne__c = 11;
        bct.Budget_Contract_ref_gne__c = bc.Id;
        insert bct;

        //THEN
        List<CFAR_Budget_Contract_Tracking_gne__c> bResult = [
            SELECT Id, Name, Amendment_Number_gne__c, Amount_gne__c,
            Comments_gne__c, Contract_Expiry_Date_gne__c, Contract_ID_gne__c, CreatedDate,
            frm_sfdc_Completed_gne__c, frm_Type_gne__c, Fully_Executed_Date_gne__c, LastModifiedDate, Budget_Contract_ref_gne__c,
            txt_Type_gne__c, Type_ref_gne__c, Type_ref_gne__r.Name, Variance_gne__c
            FROM CFAR_Budget_Contract_Tracking_gne__c
            WHERE Budget_Contract_ref_gne__c = :bc.Id
        ];

        System.assertNotEquals(null, bResult);
    }

    static testMethod void testUpdateBudgetContractTracking() {
        CFAR_Budget_Contract_Tracking_gne__c bct = [SELECT Type_ref_gne__c, Fully_Executed_Date_gne__c, Budget_Contract_ref_gne__c FROM CFAR_Budget_Contract_Tracking_gne__c LIMIT 1];

        CFAR_Budget_Contract_Type_gne__c contractType2 = new CFAR_Budget_Contract_Type_gne__c(Active_gne__c = true, Name='Original Contract');
        insert contractType2;
        bct.Type_ref_gne__c = contractType2.Id;

        Test.startTest();
        bct.Contract_Requested_Date__c = Date.Today() + 20;
        bct.Fully_Executed_Date_gne__c = System.today();
        bct.Contract_Expiry_Date_gne__c = System.today() + 30; 
        bct.Amount_gne__c = 20;
        update bct;

        CFAR_Budget_Contract_gne__c contract = [SELECT Contract_End_Date_gne__c, Original_Contract_Execution_Date_gne__c, Last_Amendment_Amount_gne__c FROM CFAR_Budget_Contract_gne__c WHERE Id = : bct.Budget_Contract_ref_gne__c ];
        System.assertEquals(bct.Fully_Executed_Date_gne__c, contract.Original_Contract_Execution_Date_gne__c, 
            'Should update contract\'s Original_Contract_Execution_Date_gne__c based on original contract trackings Fully_Executed_Date_gne__c');
        System.assertEquals(bct.Amount_gne__c, contract.Last_Amendment_Amount_gne__c,
            'Should update contract\'s Last_Amendment_Amount_gne__c based on original contract trackings Amount_gne__c');
        System.assertEquals(bct.Contract_Expiry_Date_gne__c, contract.Contract_End_Date_gne__c,
            'Should update contract\'s Contract_End_Date_gne__c based on original contract trackings Contract_Expiry_Date_gne__c');
        Test.stopTest();
    }

    static testMethod void testBudgetContractExpiryDate(){
        //GIVEN
        CFAR_Budget_Contract_gne__c bc = [SELECT Id FROM  CFAR_Budget_Contract_gne__c LIMIT 1];
        CFAR_Budget_Contract_Type_gne__c contractType1 = new CFAR_Budget_Contract_Type_gne__c(Active_gne__c = true, Name='Contract Amendment Decrease');
        insert contractType1;

        CFAR_Budget_Contract_Type_gne__c contractType2 = new CFAR_Budget_Contract_Type_gne__c(Active_gne__c = true, Name='Original Contract');
        insert contractType2;

        //WHEN
        CFAR_Budget_Contract_Tracking_gne__c bct1 = new CFAR_Budget_Contract_Tracking_gne__c();
        bct1.Type_ref_gne__c = contractType2.Id;
        bct1.Amount_gne__c = 11;
        bct1.Budget_Contract_ref_gne__c = bc.Id;
        bct1.Contract_Expiry_Date_gne__c = Date.Today() - 40;
        bct1.Contract_Requested_Date__c = Date.Today() - 20;
        insert bct1;

        CFAR_Budget_Contract_Tracking_gne__c bct2 = new CFAR_Budget_Contract_Tracking_gne__c();
        bct2.Type_ref_gne__c = contractType1.Id;
        bct2.Amount_gne__c = 11;
        bct2.Budget_Contract_ref_gne__c = bc.Id;
        bct2.Contract_Expiry_Date_gne__c = Date.Today() - 20;
        bct2.Contract_Requested_Date__c = Date.Today() - 20;
        insert bct2;

        CFAR_Rate_Table_gne__c rateTable = CFAR_DataFactory.createRateTable(bc);
        rateTable.Payment_Type_gne__c = 'Subject';
        insert rateTable;

        CFAR_Payment_Schedule_Status_gne__c paymentSchedule = CFAR_DataFactory.createPaymentScheduleStatus('Planned');
        insert paymentSchedule;

        CFAR_Budget_CPS_Payments_gne__c bCPSPayment = CFAR_DataFactory.createBudgePayments(rateTable, bc, paymentSchedule);
        insert bCPSPayment;

        //THEN
        CFAR_Budget_Contract_gne__c bcToVerify = [SELECT Contract_End_Date_gne__c FROM CFAR_Budget_Contract_gne__c WHERE ID =:bc.Id LIMIT 1];
        System.assertEquals(bct1.Contract_Expiry_Date_gne__c, bcToVerify.Contract_End_Date_gne__c, 
                            'Contract_End_Date_gne__c should store date of the latest Contract_Expiry_Date_gne__c of related contract trackings of types '
                           + Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE + ' and ' + Label.CFAR_GSTARS_CONTRACT_TRACKING_ADJUSTMENT_TYPE);

        CFAR_Budget_Contract_Tracking_gne__c bct3 = new CFAR_Budget_Contract_Tracking_gne__c();
        bct3.Type_ref_gne__c = contractType2.Id;
        bct3.Amount_gne__c = 11;
        bct3.Budget_Contract_ref_gne__c = bc.Id;
        bct3.Contract_Expiry_Date_gne__c = Date.Today()-50;
        bct3.Contract_Requested_Date__c = Date.Today() - 20;
        insert bct3;


        bcToVerify = [SELECT Contract_End_Date_gne__c FROM CFAR_Budget_Contract_gne__c WHERE ID =:bc.Id LIMIT 1];
        System.assertEquals(bct1.Contract_Expiry_Date_gne__c, bcToVerify.Contract_End_Date_gne__c, 
                            'Contract_End_Date_gne__c should store date of the latest Contract_Expiry_Date_gne__c of related contract trackings of types '
                           + Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE + ' and ' + Label.CFAR_GSTARS_CONTRACT_TRACKING_ADJUSTMENT_TYPE);
    }
}