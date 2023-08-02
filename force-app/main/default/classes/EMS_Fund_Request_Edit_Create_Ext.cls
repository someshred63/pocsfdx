public with sharing class EMS_Fund_Request_Edit_Create_Ext extends EMS_Dynamic_VF_Edit_Create {

    public String recordTypeName { get; set; }
    public Boolean isResubmit { get; set; }
    public String pageErrorMessage { get; set; }
    private Id fundRequestToResubmit;
    private EMS_Fund_Request_gne__c fundRequest;

    public EMS_Fund_Request_Edit_Create_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Fund_Request_Layout');
    }

    protected override void initController(ApexPages.StandardController controller) {
        if (ApexPages.currentPage().getParameters().containsKey('isResubmit')) {
            isResubmit = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isResubmit'));
            fundRequestToResubmit = ApexPages.currentPage().getParameters().get('resubmitId');

            String queryString = 'SELECT ';
            EMS_Fund_Request_gne__c newFundRequest = new EMS_Fund_Request_gne__c();
            Map<String, Schema.SObjectField> objectFields = fundRequestToResubmit.getSObjectType().getDescribe().fields.getMap();

            for (Schema.SObjectField field : objectFields.values()) {
                if (field.getDescribe().isCreateable()) {
                    queryString += field.getDescribe().getName().trim() + ', ';
                }
            }

            queryString = queryString.removeEnd(', ');
            queryString += ' FROM EMS_Fund_Request_gne__c WHERE Id = \'' + fundRequestToResubmit + '\'';

            newFundRequest = Database.query(queryString);
            newFundRequest.Id = null;
            newFundRequest.Status_gne__c = 'New';
            newFundRequest.Required_By_Date_gne__c = System.today();
            newFundRequest.Approver_gne__c = null;
            newFundRequest.Approval_Rejection_Date_gne__c = null;

            recordTypeName = [SELECT Name FROM RecordType WHERE Id = :newFundRequest.RecordTypeId LIMIT 1].Name;

            myObject = newFundRequest;

        } else if (controller.getRecord().Id == null) {
            EMS_Fund_Request_gne__c newFundRequest = new EMS_Fund_Request_gne__c();
            String preSetRecordTypeId = ApexPages.currentPage().getParameters().get('preSetRecordType');

            String productId = ApexPages.currentPage().getParameters().get('productId');
            String regionId = ApexPages.currentPage().getParameters().get('regionId');
            String territoryId = ApexPages.currentPage().getParameters().get('territoryId');

            if (preSetRecordTypeId != null) {
                newFundRequest.RecordTypeId = (Id) preSetRecordTypeId;
                recordTypeName = [SELECT Name FROM RecordType WHERE Id = :(Id) preSetRecordTypeId LIMIT 1].Name;
            }

            if (productId != null) {
                newFundRequest.Related_Product_Budget_gne__c = (Id) productId;
            }

            if (regionId != null) {
                newFundRequest.Related_Region_Budget_gne__c = (Id) regionId;
            }

            if (territoryId != null) {
                newFundRequest.Related_Territory_Budget_gne__c = (Id) territoryId;
            }

            if (newFundRequest.Status_gne__c == null || newFundRequest.Status_gne__c == '') {
                newFundRequest.Status_gne__c = 'New';
            }


            myObject = newFundRequest;
        } else {
            EMS_Fund_Request_gne__c fr = (EMS_Fund_Request_gne__c) controller.getRecord();
            recordTypeName = [SELECT Name FROM RecordType WHERE Id = :fr.RecordTypeId LIMIT 1].Name;
        }

        super.initController(controller);
        fundRequest = (EMS_Fund_Request_gne__c) myObject;
    }

    public PageReference resubmit() {
        System.Savepoint initialState = Database.setSavepoint();

        try {
            submitForApproval();
        } catch (Exception e) {
            if (e.getTypeName() == 'System.DmlException') {
                DmlException eDML = (DmlException) e;
                for (Integer i = 0; i < eDML.getNumDml(); i++) {
                    pageErrorMessage += (i == 0) ? eDML.getDmlMessage(i) : '; ' + eDML.getDmlMessage(i);
                }
            } else {
                pageErrorMessage = e.getMessage();
            }
            Database.rollback(initialState);
            return null;
        }

        PageReference newpage = new PageReference('/apex/EMS_Fund_Request_Layout?id=' + fundRequest.Id);
        newpage.setRedirect(true);
        return newpage;
    }

    public PageReference cancelResubmit() {
        PageReference newpage = new PageReference('/apex/EMS_Fund_Request_Layout?id=' + String.valueOf(fundRequestToResubmit));
        newpage.setRedirect(true);
        return newpage;
    }

    private void submitForApproval() {
        fundRequest = (EMS_Fund_Request_gne__c) myObject;
        fundRequest.Submitted_By_gne__c = UserInfo.getUserId();
        upsert fundRequest;

        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(fundRequest.id);
        Approval.ProcessResult result = Approval.process(request);
    }
}