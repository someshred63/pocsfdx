@isTest
private class EDM_Classification_ViewFormItem_Ctr_Test{

    @isTest
    public static void testCoverageGenerator() {

        Account acc = createAccount();

        createRequest(acc, 'Clinical');
        createRequest(acc, 'Business');

        ApexPages.currentPage().getParameters().put('id', acc.Id);

        EDM_Classification_ViewFormItem_Ctrl ext = new EDM_Classification_ViewFormItem_Ctrl();


        System.assert(EDM_Classification_ViewFormItem_Ctrl.isBusinessClassifcationPending);
        System.assert(EDM_Classification_ViewFormItem_Ctrl.isClinicalClassifcationPending);

        System.assertEquals(Date.today(),EDM_Classification_ViewFormItem_Ctrl.clinicalClassDate);
        System.assertEquals(Date.today(),EDM_Classification_ViewFormItem_Ctrl.businessClassDate);

        PageReference pr = Page.EDM_Classification_Request_Edit_Create;
        pr.getParameters().put('accountId', acc.Id);
        pr.getParameters().put('retUrl', '/' + acc.Id);
        pr.getParameters().put('typeOfClassification', 'Business'); 

        System.assertEquals(pr.getUrl(),ext.newBusinessRequestUrl);
        
        pr = Page.EDM_Classification_Request_Edit_Create;
        pr.getParameters().put('accountId', acc.Id);
        pr.getParameters().put('retUrl', '/' + acc.Id);
        pr.getParameters().put('typeOfClassification', 'Clinical'); 

        System.assertEquals(pr.getUrl(),ext.newClinicalRequestUrl);

        System.assertEquals(null,ext.parentObj);
    }

    @isTest
    public static void shouldGetClassificationHistory() {
        //given
        Account acc = createAccount();
        EDM_Classification_Request_gne__c clReq = createRequest(acc, 'Clinical');
        EDM_Classification_Request_gne__c bsReq = createRequest(acc, 'Business');

        //when
        EDM_Classification_Request_Email_Notif.isTriggerDisabledForFakeRecords = true;
        clReq.EDM_Action_Taken_gne__c = 'Verified and Clear';
        clReq.EDM_Status_gne__c = 'Completed';
        update clReq;
        bsReq.EDM_Action_Taken_gne__c = 'Verified and Clear';
        bsReq.EDM_Status_gne__c = 'Completed';
        update bsReq;

        EDM_Classification_ViewFormItem_Ctrl.ClassifHistoryResult result = EDM_Classification_ViewFormItem_Ctrl.getClassificationHistory(acc.Id);

        //then
        System.assertEquals(2, result.historyItems.size());
    }

    private static Account createAccount() {
        Account acc = new Account(Name='testAccount');
        insert acc;
        return acc;
    }

    private static EDM_Classification_Request_gne__c createRequest(Account acc, String typeOfCl) {
        EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c(
            EDM_Account_gne__c = acc.Id,
            EDM_Type_of_Classification_gne__c = typeOfCl,
            EDM_Status_gne__c = 'Pending'
        );
        insert req;
        return req;
    }
}