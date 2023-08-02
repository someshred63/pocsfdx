@IsTest
private class gFRS_FundingProcessTest {

    private static id ID_FR_EXHIBIT_RECTYPE = [select id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='Field_Initiated_Exhibits'].id;
    private static id ID_PHILANTHROPIC_RECTYPE = [select id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='Philanthropic'].id;
    private static id ID_IMED_RECTYPE = [select id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='IMED'].id;

    class TestSetting {
        public Account objAccount;
        public Contact objContact;
        public User objUser;
        public GFRS_Organization__c objOrg;
        public GFRS_Location__c objLoc;
        public GFRS_Funding_Request__c objRequest;
        public GFRS_Payment_History__c paymentHistory;
        public id frId;

        public TestSetting() {
            this.objAccount = gFRS_UnitTestHelper.CreateAccount('accTest');
            this.objUser = gFRS_UnitTestHelper.CreateInternalGFRSUser();
            System.runAs(this.objUser) {
                this.objOrg = gFRS_UnitTestHelper.CreateOrganization('01-9191329', this.objAccount.id);
                this.objLoc = gFRS_UnitTestHelper.CreateLocation('accTestLocation', this.objOrg.id);
                this.frId = gFRS_UnitTestHelperCorporateMembership.CreateCorpMemberRequestInStatusNew(objOrg.id, objLoc.id, this.objUser);
                this.objRequest = [SELECT Id, Sub_Status__c, Legal_Review__c FROM GFRS_Funding_Request__c WHERE Id = :this.frId];
            }
        }
    }

    @isTest
    private static void releasePaymentHistoryApprovesFRExhibitTest() {
        TestSetting testSettings = new TestSetting();
        testSettings.objRequest.recordTypeId = ID_FR_EXHIBIT_RECTYPE;
        update testSettings.objRequest;

        gFRS_Payment_History__c paymentHistory = createPaymentHistory(testSettings.objRequest);
        paymentHistory.ESB_Error__c = 'Hello ' + gFRS_Util.IS_SUCCESSFULLY_RELEASED;
        update paymentHistory;

        GFRS_Funding_Request__c retrievedRequest = [SELECT Id, Sub_Status__c, External_Sub_Status__c
                                                    FROM GFRS_Funding_Request__c LIMIT 1];
        System.assertEquals(gFRS_Util.REQUEST_SUB_STATUS_PAYMENT, retrievedRequest.Sub_Status__c);
        System.assertEquals(gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED, retrievedRequest.External_Sub_Status__c);
    }

    @isTest
    private static void releasePaymentHistoryApprovesFRLoaSignedTest() {
        TestSetting testSettings = new TestSetting();
        testSettings.objRequest.LOA_Signed__c = 'No';
        update testSettings.objRequest;

        gFRS_Payment_History__c paymentHistory = createPaymentHistory(testSettings.objRequest);
        paymentHistory.ESB_Error__c = 'Hello ' + gFRS_Util.IS_SUCCESSFULLY_RELEASED;
        update paymentHistory;

        GFRS_Funding_Request__c retrievedRequest = [SELECT Id, Sub_Status__c, External_Sub_Status__c
                                                    FROM GFRS_Funding_Request__c LIMIT 1];
        System.assertEquals(gFRS_Util.REQUEST_SUB_STATUS_WAITING_LOA, retrievedRequest.Sub_Status__c);
    }

    @isTest
    private static void releasePaymentHistoryApprovesFRCHChartTest() {
        TestSetting testSettings = new TestSetting();
        testSettings.objRequest.LOA_Signed__c = 'Yes';
        testSettings.objRequest.Foundation_Eligible__c = 'NO';
        testSettings.objRequest.recordTypeId = ID_PHILANTHROPIC_RECTYPE;
        update testSettings.objRequest;

        gFRS_Payment_History__c paymentHistory = createPaymentHistory(testSettings.objRequest);
        paymentHistory.ESB_Error__c = 'Hello ' + gFRS_Util.IS_SUCCESSFULLY_RELEASED;
        update paymentHistory;

        GFRS_Funding_Request__c retrievedRequest = [SELECT Id, Sub_Status__c, External_Sub_Status__c
        FROM GFRS_Funding_Request__c LIMIT 1];
        System.assertEquals(gFRS_Util.REQUEST_SUB_STATUS_APPROVED, retrievedRequest.Sub_Status__c);
        System.assertEquals(gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED, retrievedRequest.External_Sub_Status__c);
    }

    @isTest
    private static void releasePaymentHistoryApprovesFRIMEDTest() {
        TestSetting testSettings = new TestSetting();
        testSettings.objRequest.LOA_Signed__c = 'Yes';
        testSettings.objRequest.recordTypeId = ID_IMED_RECTYPE;
        update testSettings.objRequest;
        gFRS_Payment_History__c paymentHistory = createPaymentHistory(testSettings.objRequest);
        paymentHistory.ESB_Error__c = 'Hello ' + gFRS_Util.IS_SUCCESSFULLY_RELEASED;
        Test.startTest();
        update paymentHistory;
        Test.stopTest();
    }

    @isTest
    private static void releasePaymentHistoryApprovesFREmptySignedTest() {
        TestSetting testSettings = new TestSetting();
        testSettings.objRequest.LOA_Signed__c = 'Yes';
        update testSettings.objRequest;

        gFRS_Payment_History__c paymentHistory = createPaymentHistory(testSettings.objRequest);
        paymentHistory.ESB_Error__c = 'Hello ' + gFRS_Util.IS_SUCCESSFULLY_RELEASED;
        Test.startTest();
        update paymentHistory;
        Test.stopTest();
        GFRS_Funding_Request__c retrievedRequest = [SELECT Id, Sub_Status__c, External_Sub_Status__c
        FROM GFRS_Funding_Request__c LIMIT 1];
        System.assertEquals(gFRS_Util.REQUEST_SUB_STATUS_PAYMENT, retrievedRequest.Sub_Status__c);
        System.assertEquals(gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED, retrievedRequest.External_Sub_Status__c);
    }

    @isTest
    private static void updateRefundedAmountAfterRefundHistoryDeletedRefundAndSuccessTest() {
        TestSetting testSettings = new TestSetting();
        update testSettings.objRequest;
        gFRS_Payment_History__c paymentHistory = createPaymentHistory(testSettings.objRequest);
        paymentHistory.Type_of_Check_Received__c = 'Genetech';
        paymentHistory.Check_Number__c = '12345';
        paymentHistory.Payment_Type__c = 'Refund';
        paymentHistory.Status__c = 'Success';
        update paymentHistory;
        Test.startTest();
        delete paymentHistory;
        Test.stopTest();
        GFRS_Funding_Request__c[] fundingRequests = [SELECT Id, Refunded_Amount__c from GFRS_Funding_Request__c];
        System.assertEquals(1, fundingRequests.size());
        System.assertEquals(0, fundingRequests.get(0).Refunded_Amount__c);
    }

    @isTest static void updateRefundedAmountAfterRefundHistorySuccessRefundAndSuccessTest() {
        TestSetting testSettings = new TestSetting();
        update testSettings.objRequest;

        gFRS_Payment_History__c paymentHistory = createPaymentHistory(testSettings.objRequest);
        paymentHistory.Type_of_Check_Received__c = 'Genetech';
        paymentHistory.Check_Number__c = '12345';
        paymentHistory.Payment_Type__c = 'Refund';
        paymentHistory.Status__c = 'Success';
        Test.startTest();
        update paymentHistory;
        Test.stopTest();
        GFRS_Funding_Request__c[] fundingRequests = [SELECT Id, Refunded_Amount__c from GFRS_Funding_Request__c];
        System.assertEquals(1, fundingRequests.size());
        System.assertEquals(100, fundingRequests.get(0).Refunded_Amount__c);
    }

    public static gFRS_Payment_History__c createPaymentHistory(GFRS_Funding_Request__c objRequest) {
        GFRS_WBS_Codes__c wbsCodes = gFRS_TestCreationUtils.createWBSCode('testIMED_A','Asthma', gFRS_Util.TYPE_IMED_NAME);
        insert wbsCodes;
        GFRS_Cost_Center_Code__c costCenterCode = gFRS_TestCreationUtils.createCostCenter('testIMED',gFRS_Util.TYPE_IMED_NAME);
        insert costCenterCode;

        gFRS_Payment_History__c paymentHistory = new gFRS_Payment_History__c();
        paymentHistory.Grant__c = objRequest.Id;
        paymentHistory.WBS_Code__c = wbsCodes.Id;
        paymentHistory.Cost_Center__c = costCenterCode.Id;
        paymentHistory.Amount__c = 100;
        insert paymentHistory;
        return paymentHistory;
    }
}