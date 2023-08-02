public with sharing class EMS_Transaction_Edit_Create_Ext {

    public EMS_Event__c event { get; set; }
    public EMS_Speaker_Role_gne__c paymentRequest { get; set; }
    public Map<Integer, TransactionWrapper> transactionsList { get; set; }
    public Integer currentIndex { get; set; }
    public String approverName { get; set; }
    public String requestorName { get; set; }
    public String recordTypeName { get; set; }
    public Boolean recordTypePreselected { get; set; }
    public String pageErrorMessage { get; set; }

    private String retUrl;
    private EMS_Transaction_gne__c currentTransaction;
    private List<EMS_Transaction_gne__c> transactionsToRemove;
    private ApexPages.StandardController controller;
    private Integer counter;

    public EMS_Transaction_Edit_Create_Ext(ApexPages.StandardController controller) {
        this.controller = controller;
        counter = 0;
        approverName = '';
        requestorName = '';

        String eventId = ApexPages.currentPage().getParameters().get('objectId');
        String accountId = ApexPages.currentPage().getParameters().get('accountId');
        String ihcpId = ApexPages.currentPage().getParameters().get('ihcpId');

        retURL = System.currentPageReference().getParameters().get('retURL');
        if (retURL != null) {
            retURL = EncodingUtil.urlDecode(retURL, 'UTF-8');
        }

        SObject currentRecord = controller.getRecord();
        Schema.DescribeSObjectResult objectDescribe = currentRecord.getSObjectType().getDescribe();
        String sObjectName = objectDescribe.getName();

        pageErrorMessage = null;
        try {
            if (sObjectName == 'EMS_Transaction_gne__c') {
                currentTransaction = (EMS_Transaction_gne__c) controller.getRecord();
                if (currentTransaction.Id == null) {
                    EMS_Transaction_gne__c newTransaction = new EMS_Transaction_gne__c();
                    EMS_Speaker_Role_gne__c newPaymentRequest = new EMS_Speaker_Role_gne__c();

                    if (eventId != null) {
                        newTransaction.EMS_Event_gne__c = (Id) eventId;
                        newPaymentRequest.EMS_Event_gne__c = (Id) eventId;
                        newPaymentRequest.Status_gne__c = 'Draft';
                        event = [SELECT Name, Event_Type_gne__c, Event_Sub_Type_gne__c, Start_Date_gne__c, End_Date_gne__c, Event_Owner_gne__c, Event_Owner_gne__r.Name, Event_Requestor_gne__c, Event_Requestor_gne__r.Name, Event_Name_gne__c, Is_GSD_Event_gne__c, Cost_Center_Type_gne__c FROM EMS_Event__c WHERE Id = :((Id) eventId)];
                    }

                    if (accountId != null) {
                        newPaymentRequest.HCP_gne__c = (Id) accountId;
                    } else if (ihcpId != null) {
                        newPaymentRequest.EMS_International_Speaker_gne__c = (Id) ihcpId;
                    }

                    paymentRequest = newPaymentRequest;
                    currentTransaction = newTransaction;
                } else {
                    paymentRequest = [
                            SELECT Id, EMS_Event_gne__c, EMS_International_Speaker_gne__c, HCP_gne__c, HCP_gne__r.Name, Payment_Type_gne__c, Payment_Date_gne__c,
                                    Status_gne__c, Comment_gne__c, Honorarium_gne__c, Speaker_Topic_gne__c, Recipient_Vendor_Name_gne__c,
                                    Vendor_ID_gne__c, Vendor_Address_gne__c, Approver_gne__c, Requestor_gne__c, RecordType.Name
                            FROM EMS_Speaker_Role_gne__c
                            WHERE Id = :currentTransaction.EMS_Speaker_Role_gne__c
                            LIMIT 1
                    ];
                    event = [SELECT Name, Event_Type_gne__c, Event_Sub_Type_gne__c, Start_Date_gne__c, End_Date_gne__c, Event_Owner_gne__c, Event_Owner_gne__r.Name, Event_Requestor_gne__c, Event_Requestor_gne__r.Name, Event_Name_gne__c, Is_GSD_Event_gne__c, Cost_Center_Type_gne__c FROM EMS_Event__c WHERE Id = :paymentRequest.EMS_Event_gne__c];
                }
            } else if (sObjectName == 'EMS_Speaker_Role_gne__c') {
                paymentRequest = (EMS_Speaker_Role_gne__c) controller.getRecord();
                if (paymentRequest.Id == null) {
                    EMS_Speaker_Role_gne__c newPaymentRequest = new EMS_Speaker_Role_gne__c();

                    if (eventId != null) {
                        newPaymentRequest.EMS_Event_gne__c = (Id) eventId;
                        newPaymentRequest.Status_gne__c = 'Draft';
                        event = [SELECT Name, Event_Type_gne__c, Event_Sub_Type_gne__c, Start_Date_gne__c, End_Date_gne__c, Event_Owner_gne__c, Event_Owner_gne__r.Name, Event_Requestor_gne__c, Event_Requestor_gne__r.Name, Event_Name_gne__c, Is_GSD_Event_gne__c, Cost_Center_Type_gne__c FROM EMS_Event__c WHERE Id = :((Id) eventId)];
                    }

                    if (accountId != null) {
                        newPaymentRequest.HCP_gne__c = (Id) accountId;
                    } else if (ihcpId != null) {
                        newPaymentRequest.EMS_International_Speaker_gne__c = (Id) ihcpId;
                    }
                    paymentRequest = newPaymentRequest;
                } else {
                    paymentRequest = [
                            SELECT EMS_Event_gne__c, EMS_International_Speaker_gne__c, HCP_gne__c, HCP_gne__r.Name,
                                    Payment_Type_gne__c, Payment_Date_gne__c, Status_gne__c, Comment_gne__c, Honorarium_gne__c, Speaker_Topic_gne__c,
                                    Recipient_Vendor_Name_gne__c, Vendor_ID_gne__c, Vendor_Address_gne__c, Approver_gne__c, Requestor_gne__c, RecordType.Name
                            FROM EMS_Speaker_Role_gne__c
                            WHERE Id = :paymentRequest.Id
                            LIMIT 1
                    ];

                    event = [SELECT Name, Event_Type_gne__c, Event_Sub_Type_gne__c, Start_Date_gne__c, End_Date_gne__c, Event_Owner_gne__c, Event_Owner_gne__r.Name, Event_Requestor_gne__c, Event_Requestor_gne__r.Name, Event_Name_gne__c, Is_GSD_Event_gne__c FROM EMS_Event__c WHERE Id = :paymentRequest.EMS_Event_gne__c LIMIT 1];
                }
            }

            paymentRequest.Approver_gne__c = event.Event_Owner_gne__c;
            approverName = event.Event_Owner_gne__r.Name;
            paymentRequest.Requestor_gne__c = event.Event_Requestor_gne__c;
            requestorName = event.Event_Requestor_gne__r.Name;

            if (event.Event_Type_gne__c == 'Learning Programs') {
                paymentRequest.put('Honorarium_gne__c', true);
            }
            fetchtransactionsList();

            DescribeSObjectResult paymentRequestDescribe = EMS_Speaker_Role_gne__c.getSObjectType().getDescribe();
            Map<String, Schema.RecordTypeInfo> recordTypesMap = paymentRequestDescribe.getRecordTypeInfosByName();

            // set default record type
            if (paymentRequest.Id == null) {
                if (ihcpId != null) {
                    recordTypeName = 'iHCP Payment Request';
                    paymentRequest.RecordTypeId = recordTypesMap.get(recordTypeName).getRecordTypeId();
                } else {
                    recordTypeName = 'HCP/HCO Payment Request';
                    paymentRequest.RecordTypeId = recordTypesMap.get(recordTypeName).getRecordTypeId();
                }
                if (ihcpId != null || accountId != null) {
                    recordTypePreselected = true;
                }
            } else {
                recordTypeName = paymentRequest.RecordType.Name;
            }
        } catch (Exception ex) {
            pageErrorMessage = ex.getMessage();
        }
    }

    public List<SelectOption> getRecordTypes() {
        List<SelectOption> result = new List<SelectOption>();
        for (RecordType recordType : [SELECT Name, DeveloperName FROM RecordType WHERE sObjectType = 'EMS_Speaker_Role_gne__c']) {
            result.add(new SelectOption(recordType.Name, recordType.Name));
        }
        return result;
    }

    public PageReference onRecordTypeChange() {
        DescribeSObjectResult paymentRequestDescribe = EMS_Speaker_Role_gne__c.getSObjectType().getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypesMap = paymentRequestDescribe.getRecordTypeInfosByName();
        paymentRequest.RecordTypeId = recordTypesMap.get(recordTypeName).getRecordTypeId();
        return null;
    }

    public Boolean getIsEditable() {
        if (paymentRequest.Status_gne__c == 'Draft') {
            return true;
        } else if (EMS_Util.isAdmin()) {
            return true;
        } else {
            return false;
        }
    }

    private Integer getNextId() {
        Integer index = counter;
        counter++;
        return index;
    }

    private void fetchTransactionsList() {
        transactionsToRemove = new List<EMS_Transaction_gne__c>();
        transactionsList = new Map<Integer, TransactionWrapper>();
        List<EMS_Transaction_gne__c> tList = [SELECT Status_gne__c, EMS_Speaker_Role_gne__c, EMS_Speaker_Role_gne__r.Honorarium_gne__c, Name, Cost_Center_gne__c, Payment_taxes_gne__c, Disturbance_Fee_gne__c, Fee_Amount_gne__c, Cost_Element_gne__c FROM EMS_Transaction_gne__c WHERE EMS_Speaker_Role_gne__c = :paymentRequest.id];
        for (EMS_Transaction_gne__c t : tList) {
            transactionsList.put(getNextId(), new TransactionWrapper(t, event));
        }
    }

    public PageReference createTransaction() {
        transactionsList.put(getNextId(), new TransactionWrapper(new EMS_Transaction_gne__c(EMS_Speaker_Role_gne__r = paymentRequest, EMS_Event_gne__c = (Id) paymentRequest.get('EMS_Event_gne__c'), Status_gne__c = 'Draft'), event));
        return null;
    }

    public PageReference removeTransaction() {
        if (transactionsList.get(currentIndex).trans.Id != null) {
            transactionsToRemove.add(transactionsList.get(currentIndex).trans);
        }
        transactionsList.remove(currentIndex);
        return null;
    }

    public PageReference save() {
        if (doSave(false)) {
            if (retURL != null) {
                return new PageReference(retURL);
            } else {
                return Page.EMS_Home;
            }
        } else {
            return null;
        }
    }

    public PageReference cancel() {
        if (retURL != null) {
            PageReference pr = new PageReference(retURL);
            pr.setRedirect(true);
            return pr;
        } else {
            PageReference pr = new PageReference('/' + event.Id);
            pr.setRedirect(true);
            return pr;
        }
    }

    public PageReference deletePayment() {
        pageErrorMessage = null;
        PageReference newPage = null;
        try {
            delete paymentRequest;
            if (retURL != null) {
                newPage = new PageReference(retURL);
            } else {
                newPage = Page.EMS_Home;
            }
        } catch (DMLException ex) {
            pageErrorMessage = ex.getMessage();
        }
        return newPage;
    }

    public Boolean doSave(Boolean submit) {
        Boolean isSuccess = true;

        List<EMS_Transaction_gne__c> transactionsToInsert = new List<EMS_Transaction_gne__c>();
        List<EMS_Transaction_gne__c> transactionsToUpdate = new List<EMS_Transaction_gne__c>();

        System.Savepoint sp = Database.setSavepoint();
        if (!transactionsList.isEmpty()) {
            pageErrorMessage = null;
            try {
                if (submit) {
                    paymentRequest.Status_gne__c = 'Submitted';
                }
                upsert paymentRequest;

                if (!transactionsList.isEmpty()) {
                    for (TransactionWrapper t : transactionsList.values()) {
                        if (t.trans.Id == null) {
                            t.trans.EMS_Speaker_Role_gne__c = paymentRequest.id;
                            if (submit) {
                                t.trans.Status_gne__c = 'Not Started';
                            }
                            transactionsToInsert.add(t.trans);
                        } else {
                            if (submit) {
                                t.trans.Status_gne__c = 'Not Started';
                            }
                            transactionsToUpdate.add(t.trans);
                        }
                    }

                    if (!transactionsToInsert.isEmpty()) {
                        insert transactionsToInsert;
                    }
                    if (!transactionsToUpdate.isEmpty()) {
                        update transactionsToUpdate;
                    }

                }

                if (!transactionsToRemove.isEmpty()) {
                    delete transactionsToRemove;
                }
                // Refresh info about Transaction and Payement request. Fixing missing fields values on after submit page.
                fetchTransactionsList();
                paymentRequest = [
                        SELECT Id, EMS_Event_gne__c, EMS_International_Speaker_gne__c, HCP_gne__c, HCP_gne__r.Name, Payment_Type_gne__c, Payment_Date_gne__c, Status_gne__c, Comment_gne__c, Honorarium_gne__c, Speaker_Topic_gne__c, Recipient_Vendor_Name_gne__c, Vendor_ID_gne__c, Vendor_Address_gne__c, Approver_gne__c,
                                Requestor_gne__c
                        FROM EMS_Speaker_Role_gne__c
                        WHERE Id = :paymentRequest.Id
                        LIMIT 1
                ];
            } catch (DMLException ex) {
                Database.rollback(sp);

                // reset payment request status
                paymentRequest.Status_gne__c = 'Draft';
                // Refresh info about Payement request. Fixing missing fields values on after submit page.
                List<EMS_Speaker_Role_gne__c> paymentRequests = [
                        SELECT Id, EMS_Event_gne__c, EMS_International_Speaker_gne__c, HCP_gne__c, HCP_gne__r.Name, Payment_Type_gne__c, Payment_Date_gne__c, Status_gne__c, Comment_gne__c, Honorarium_gne__c, Speaker_Topic_gne__c, Recipient_Vendor_Name_gne__c, Vendor_ID_gne__c, Vendor_Address_gne__c, Approver_gne__c,
                                Requestor_gne__c
                        FROM EMS_Speaker_Role_gne__c
                        WHERE Id = :paymentRequest.Id
                        LIMIT 1
                ];

                if (paymentRequests.size() > 0) {
                    paymentRequest = paymentRequests[0];
                } else {
                    paymentRequest.Id = null;
                }
                pageErrorMessage = ex.getMessage();
                isSuccess = false;
            }
        } else {
            //pageErrorMessage = 'You have to create at least one transaction.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have to create at least one transaction.'));
            isSuccess = false;
        }
        return isSuccess;
    }

    public PageReference submitForPaymentClick() {
        List<EMS_Transaction_gne__c> transactionsToUpsert = new List<EMS_Transaction_gne__c>();
        pageErrorMessage = null;
        if (!transactionsList.isEmpty()) {
            if (doSave(true)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your payment request was submitted successfully.'));
            } else {
                //pageErrorMessage = 'Error occured when submitting a payment.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occured when submitting a payment.'));
            }
        } else {
            //pageErrorMessage = 'You have to create at least one transaction to submit a payment.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have to create at least one transaction to submit a payment.'));
        }
        return null;
    }

    private static final Integer SELECT_LIMIT = 10000;
    private static Map<Id, EMS_GSD_Detail__c> gsd_map = new Map<Id, EMS_GSD_Detail__c>([SELECT GSD_Type_gne__c, EMS_Event__c FROM EMS_GSD_Detail__c LIMIT :SELECT_LIMIT]);
    private static Map<Id, EMS_Cost_Center_gne__c> costCentersMap = new Map<Id, EMS_Cost_Center_gne__c>([SELECT Name, Cost_Center_Type_gne__r.Name, Product_Indication_Department_gne__c FROM EMS_Cost_Center_gne__c LIMIT :SELECT_LIMIT]);
    private static Map<Id, EMS_Budget_Allocation_gne__c> budgetAllocation_map = new Map<Id, EMS_Budget_Allocation_gne__c>([SELECT Cost_Center_gne__c, EMS_Event_gne__c FROM EMS_Budget_Allocation_gne__c LIMIT :SELECT_LIMIT]);

    private static Map<String, EMS_GSD_Detail__c> eventId_itemGSD_map {
        get {
            Map<String, EMS_GSD_Detail__c> retMap = new Map<String, EMS_GSD_Detail__c>();
            for (EMS_GSD_Detail__c GSD_item : gsd_map.values()) {
                if (GSD_item.EMS_Event__c != null) {
                    retMap.put(GSD_item.EMS_Event__c, GSD_item);
                }
            }
            return retMap;
        }
    }

    private static Map<String, List<EMS_Budget_Allocation_gne__c>> eventId_BAs_map {
        get {
            Map<String, List<EMS_Budget_Allocation_gne__c>> retMap = new Map<String, List<EMS_Budget_Allocation_gne__c>>();
            for (EMS_Budget_Allocation_gne__c BA_item : budgetAllocation_map.values()) {
                if (retMap.containsKey(BA_item.EMS_Event_gne__c)) {
                    List<EMS_Budget_Allocation_gne__c> tempList = retMap.get(BA_item.EMS_Event_gne__c);
                    tempList.add(BA_item);
                    retMap.put(BA_item.EMS_Event_gne__c, tempList);
                } else {
                    retMap.put(BA_item.EMS_Event_gne__c, new List<EMS_Budget_Allocation_gne__c>{
                            BA_item
                    });
                }
            }
            return retMap;
        }
    }

    public class CustomException extends Exception {
    }

    public class TransactionWrapper {
        public EMS_Transaction_gne__c trans { get; set; }
        private EMS_Event__c event;
        private EMS_GSD_Detail__c itemGSD = null;

        public TransactionWrapper(EMS_Transaction_gne__c trans, EMS_Event__c event) {
            this.trans = trans;
            this.event = event;
            this.itemGSD = getItemGSD(event.Id);
        }

        // Methods PRIVATE
        private EMS_GSD_Detail__c getItemGSD(String eventId) {
            EMS_GSD_Detail__c retGSD = null;
            if (eventId_itemGSD_map.containsKey(eventId)) {
                retGSD = eventId_itemGSD_map.get(eventId);
            }
            return retGSD;
        }

        private List<EMS_Cost_Center_gne__c> getCostCentersByNames(Set<String> ccNames) {
            List<EMS_Cost_Center_gne__c> retCCList = new List<EMS_Cost_Center_gne__c>();
            for (EMS_Cost_Center_gne__c costCenter : costCentersMap.values()) {
                if (ccNames.contains(costCenter.Name)) {
                    retCCList.add(costCenter);
                }
            }
            return retCCList;
        }

        // Methods PUBLIC
        public List<SelectOption> getCostCenters() {
            List<SelectOption> result = new List<SelectOption>();
            if (eventId_BAs_map.containsKey(event.Id)) {
                Set<String> costCenterNames = new Set<String>();
                for (EMS_Budget_Allocation_gne__c ba : eventId_BAs_map.get(event.Id)) {
                    costCenterNames.add(ba.Cost_Center_gne__c);
                }
                if (!costCenterNames.isEmpty()) {
                    for (EMS_Cost_Center_gne__c costCenter : getCostCentersByNames(costCenterNames)) {
                        result.add(new SelectOption(costCenter.Id, costCenter.Name + ' - ' + costCenter.Product_Indication_Department_gne__c));
                    }

                    if (trans.Cost_Center_gne__c == null && result.size() > 0) {  // set the first available value by default
                        trans.Cost_Center_gne__c = (Id) result[0].getValue();
                    }
                } else {
                    result.add(new SelectOption('', '--None--'));
                }
            }
            return result;
        }

        public List<SelectOption> getCostElements() {
            List<SelectOption> result = new List<SelectOption>();
            Boolean isHonorarium = trans.EMS_Speaker_Role_gne__r.Honorarium_gne__c;
            String gsdType = null;
            String costCenterType = null;
            if (itemGSD != null) {
                gsdType = itemGSD.GSD_Type_gne__c;
            }
            if (trans.Cost_Center_gne__c != null) {
                costCenterType = costCentersMap.get(trans.Cost_Center_gne__c).Cost_Center_Type_gne__r.Name;
            }
            List<EMS_Possible_Budget_Allocation_gne__c> mappings = [
                    SELECT Cost_Elements_gne__c
                    FROM EMS_Possible_Budget_Allocation_gne__c
                    WHERE EMS_Event_Configuration_gne__r.Event_Type_gne__c = :event.Event_Type_gne__c
                    AND EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c = :event.Event_Sub_Type_gne__c
                    AND GSD_Type_gne__c LIKE :gsdType
                    AND Budget_Type_gne__r.NAme = :costCenterType
                    AND Honorarium_gne__c = :isHonorarium
            ];

            if (!mappings.isEmpty()) {
                String availableCostElements = mappings[0].Cost_Elements_gne__c;
                if (availableCostElements != null) {
                    for (String costElement : availableCostElements.split(';')) {
                        result.add(new SelectOption(costElement, costElement));
                    }
                }
            } else {
                result.add(new SelectOption('', '--None--'));
            }
            return result;
        }
    }
}