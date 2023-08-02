@isTest(SeeAllData=false)
private class CFAR_FieldHistoryXLS_Controller_Test {

    @testSetup
    static void setup() {
        CFAR_TestUtils.createTestAdminUser();
        System.assert(true);
    }

    static testMethod void testMethod1() {
        List<sObject> testRecords = new List<sObject>();
        Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
        Map<String, object> fieldsConfig = new Map<String, object>();
        for (Integer th = 0; th <= 5; th++) {
            fieldsConfig.put('Name', 'TH' + String.valueOf(th));
            fieldsConfig.put('Active_gne__c', true);
            objectConfig.put(new CFAR_Theme_gne__c(), fieldsConfig);
            sObject cfarTheme = CFAR_TestUtils.createRecord(objectConfig);
            testRecords.add(cfarTheme);
        }
        insert testRecords;
        testRecords = new List<sObject>();
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        List<CFAR_Theme_gne__c> cfarThemes = [Select Id, Name from CFAR_Theme_gne__c];
        Integer prodCounter = 0;
        for (CFAR_Theme_gne__c theme : cfarThemes) {
            fieldsConfig.put('Name', 'Product' + String.valueOf(prodCounter));
            fieldsConfig.put('Description_gne__c', 'ABCD' + String.valueOf(prodCounter));
            fieldsConfig.put('Generic_Name_gne__c', 'GenName' + String.valueOf(prodCounter));
            fieldsConfig.put('Other_GNE_Agent_Active_gne__c', true);
            fieldsConfig.put('Active_gne__c', true);
            fieldsConfig.put('Theme_ref_gne__c', theme.Id);
            objectConfig.put(new CFAR_Product_gne__c(), fieldsConfig);
            sObject cfarProduct = CFAR_TestUtils.createRecord(objectConfig);
            testRecords.add(cfarProduct);
            prodCounter++;
        }
        insert testRecords;
        testRecords = new List<sObject>();
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        for (Integer t = 0; t <= 5; t++) {
            fieldsConfig.put('Name', 'Trial' + String.valueOf(t));
            fieldsConfig.put('Cost_Center_gne__c', 'abc');
            fieldsConfig.put('Cost_Element_gne__c', 'abc');
            fieldsConfig.put('Planned_Enrollment_gne__c', 10);
            fieldsConfig.put('Received_Date_gne__c', Date.today());
            objectConfig.put(new CFAR_Trial_gne__c(), fieldsConfig);
            sObject cfarTrial = CFAR_TestUtils.createRecord(objectConfig);
            testRecords.add(cfarTrial);

        }
        Test.startTest();
        User testAdm = [SELECT Id FROM User WHERE alias = 'testAdm'];
        System.runAs(testAdm) {
            CFAR_Administrator_Controller adminController = new CFAR_Administrator_Controller();
            CFAR_Administrator_Controller.HistoryWrapper history = new CFAR_Administrator_Controller.HistoryWrapper();
            history.objectName = 'Team Member';
            system.assertEquals(adminController.getRenderAdminSection(), true);
            adminController.historyInitNewTrial();
            adminController.sortFieldHistory();
            CFAR_FieldHistoryXLS_Controller fh = new CFAR_FieldHistoryXLS_Controller();
        }
        Test.stopTest();
    }

    @IsTest
    static void shouldInitFieldHistory() {
        // given
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
        CFAR_Contact_Address_gne__c contactAddress = CFAR_DataFactory.createContactAddress(institution);
        insert contactAddress;
        CFAR_Contact_Address_JO_gne__c caJO = CFAR_DataFactory.createContactAddressJO(contact, contactAddress);
        insert caJO;
        CFAR_Team_Member_gne__c tm = CFAR_DataFactory.createTeamMember(trial, 'testTM123xxx', caJO, CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
        insert tm;

        CFAR_Budget_Contract_gne__c bc = CFAR_DataFactory.createBudgetContract(tm);
        bc.PO_Number_gne__c = 'PO10033';
        bc.Total_payments_gne__c = 500;
        bc.Prior_Years_Paid_gne__c = 500;
        bc.Year_to_Date_Paid_gne__c = 0;
        insert bc;
        CFAR_Budget_Contract_Type_gne__c bctype = CFAR_DataFactory.createBudgetContractType();
        bctype.Name = 'Original Contract';
        insert bctype;

        CFAR_Budget_Contract_Tracking_gne__c bctracing = CFAR_DataFactory.createBudgetContractTracking(bc, bctype, 1000);
        bctracing.Fully_Executed_Date_gne__c = date.newinstance(System.now().year(), 5, 1);
        bctracing.Contract_Expiry_Date_gne__c = date.newinstance(System.now().year(), 5, 1).addMonths(10);
        bctracing.Contract_Requested_Date__c = date.newinstance(System.now().year(), 5, 1);
        bctracing.txt_Type_gne__c = 'Original Contract';
        insert bctracing;
        CFAR_Comment_gne__c comm = CFAR_DataFactory.createComment(trial, 'test comment');
        insert comm;

        CFAR_Rate_Table_gne__c rateTable = CFAR_DataFactory.createRateTable(bc);
        rateTable.Payment_Type_gne__c = 'Subject';
        insert rateTable;
        CFAR_Payment_Schedule_Status_gne__c paymentSchedule = CFAR_DataFactory.createPaymentScheduleStatus('Planned');
        insert paymentSchedule;
        CFAR_Budget_CPS_Payments_gne__c bCPSPayment = CFAR_DataFactory.createBudgePayments(rateTable, bc, paymentSchedule);
        insert bCPSPayment;
        System.assert([select frm_Trial_Id_gne__c from CFAR_Budget_CPS_Payments_gne__c].frm_Trial_Id_gne__c == trial.Id, bCPSPayment.frm_Trial_Id_gne__c + ' ' + trial.Id);

        insert new CFAR_Team_Member_gne__history(Field = 'Name', ParentId = tm.Id);
        insert new CFAR_Budget_Contract_Tracking_gne__history(Field = 'Name', ParentId = bctracing.Id);
        insert new CFAR_Budget_Contract_Tracking_gne__history(Field = 'Contract_Expiry_Date_gne__c', ParentId = bctracing.Id);
        insert new CFAR_Budget_Contract_Tracking_gne__history(Field = 'Type_ref_gne__c', ParentId = bctracing.Id);
        insert new CFAR_Comment_gne__history(Field = 'Name', ParentId = comm.Id);
        insert new CFAR_Comment_gne__history(Field = 'Activity_Date_gne__c', ParentId = comm.Id);
        insert new CFAR_Comment_gne__history(Field = 'Created_By_CFAR_Contact_ref_gne__c', ParentId = comm.Id); // not included in result because null value
        insert new CFAR_Budget_CPS_Payments_gne__history(Field = 'Name', ParentId = bCPSPayment.Id);
        insert new CFAR_Budget_CPS_Payments_gne__history(Field = 'Invoice_Date_gne__c', ParentId = bCPSPayment.Id);
        insert new CFAR_Budget_CPS_Payments_gne__history(Field = 'Payment_Status_ref_gne__c', ParentId = bCPSPayment.Id);

        User testAdm = [SELECT Id FROM User WHERE alias = 'testAdm'];
        System.runAs(testAdm) {
            Test.startTest();
            // when
            PageReference pageRef = Page.CFAR_FieldHistoryXLS;
            pageRef.getParameters().put('id', String.valueOf(trial.Id).substring(0, 15));
            Test.setCurrentPage(pageRef);
            CFAR_FieldHistoryXLS_Controller ctrl = new CFAR_FieldHistoryXLS_Controller();
            // then
            System.assert(ctrl.fieldHistory != null);
            System.assert(ctrl.displayedFieldHistory != null);
            System.assertEquals(9, ctrl.fieldHistory.size());
            System.assert(ctrl.displayedFieldHistory.size() < 1000);
            System.assertEquals(9, ctrl.displayedFieldHistory.size());
            Test.stopTest();
        }
    }

    @IsTest
    static void shouldDisplay1000Rec() {
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        trial.CTMS_gne__c = '09876';
        trial.Other_Trial_gne_Id__c = '09983';
        trial.IIS_Portal_RO_Number_gne__c = 'RO-IIS-2017-12345';
        insert trial;
        CFAR_Comment_gne__c comm = CFAR_DataFactory.createComment(trial, 'test comment');
        insert comm;

        List<CFAR_Comment_gne__history> history_1100_rec = new List<CFAR_Comment_gne__history>();
        for (Integer i = 0; i < 1100; i++) {
            history_1100_rec.add(new CFAR_Comment_gne__history(Field = 'Name', ParentId = comm.Id));
        }
        insert history_1100_rec;

        User testAdm = [SELECT Id FROM User WHERE alias = 'testAdm'];
        System.runAs(testAdm) {
            Test.startTest();
            // when
            PageReference pageRef = Page.CFAR_FieldHistoryXLS;
            pageRef.getParameters().put('id', String.valueOf(trial.Id).substring(0, 15));
            Test.setCurrentPage(pageRef);
            CFAR_FieldHistoryXLS_Controller ctrl = new CFAR_FieldHistoryXLS_Controller();
            // then
            System.assert(ctrl.fieldHistory != null);
            System.assert(ctrl.displayedFieldHistory != null);
            System.assertEquals(1100, ctrl.fieldHistory.size());
            System.assertEquals(1000, ctrl.displayedFieldHistory.size());
            Test.stopTest();
        }
    }

    @IsTest
    private static void shouldGetWorkbookProperties() {
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        insert trial;
        trial = [SELECT Id, Name FROM CFAR_Trial_gne__c WHERE Id = :trial.Id];
        PageReference pageRef = Page.CFAR_FieldHistoryXLS;
        pageRef.getParameters().put('id', trial.Id);
        Test.setCurrentPage(pageRef);
        // when
        String fName = new CFAR_FieldHistoryXLS_Controller().getWorkbookProperties();
        System.debug(fName);
        System.assert(String.isNotBlank(fName));
        System.assert(fName.contains(trial.Name));
    }

    @IsTest
    private static void shouldGetFileName() {
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(0);
        insert trial;
        trial = [SELECT Id, Name FROM CFAR_Trial_gne__c WHERE Id = :trial.Id];
        PageReference pageRef = Page.CFAR_FieldHistoryXLS;
        pageRef.getParameters().put('id', trial.Id);
        Test.setCurrentPage(pageRef);
        // when
        String fName = new CFAR_FieldHistoryXLS_Controller().getFileName();
        System.debug(fName);
        System.assert(String.isNotBlank(fName));
        System.assert(fName.contains(trial.Name));
    }


}