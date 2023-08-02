public without sharing class EMS_Payment_Request_Edit_Create_Ext {

    public EMS_Event__c event { get; set; }
    public EMS_Speaker_Role_gne__c paymentRequest { get; set; }
    public EMS_Speaker_Role_gne__c oldPaymentRequest { get; set; }	// Temporary field holding payment request before changes for future comparision
    public Integer currentIndex { get; set; }
    public String requestorName { get; set; }
    public String recordTypeName { get; set; }
    public Boolean recordTypePreselected { get; set; }
    public Boolean fmvExists { get; set; }
    public Boolean gsdExists { get; set; }
    public Decimal totalAmount { get; set; }
    public Boolean amountExceeded { get; set; }
    private EMS_Attendee_gne__c fmvDetails;
    public String pagePositiveMessage { get; set; }
    public String pageErrorMessage { get; set; }

    private String retUrl;
    private EMS_Transaction_gne__c currentTransaction;
    private List<EMS_Transaction_gne__c> transactionsToRemove = new List<EMS_Transaction_gne__c>();
    private Integer counter;
    private Integer lineNumber;
    public Boolean isWitholdingTax { get { return recordTypeName == 'iHCP Payment Request' || recordTypeName == 'iPatient Payment Request';}}

    public Map<Integer, TransactionGroupWrapper> transactionGroupList { get; set; }
    public TransactionGroupWrapper taxSummaryGroup { get; set; }

    private Map<String, Id> costCentersMap = new Map<String, Id>();
    private Map<String, String> costElementsMap = new Map<String, String>();
    private Map<Id, EMS_Transaction_gne__c> oldTransactions;  // Temporary field holding transactions before changes for future comparision
    private EMS_GSD_Detail__c gsdDetail;
    private List<EMS_Possible_Budget_Allocation_gne__c> mappings;

    private Id attendeeID { get; set; }

    private EMS_Transaction_gne__c queryTransaction(Id transactionId) {
        return [
                SELECT Id, EMS_Speaker_Role_gne__c, EMS_Event_gne__c
                FROM EMS_Transaction_gne__c
                WHERE Id = :transactionId
                LIMIT 1
        ];
    }

    private EMS_Speaker_Role_gne__c queryPaymentRequest(Id requestId) {
        return [
                SELECT Address_gne__c, Alternate_Email_Address_gne__c, Approver_gne__c, Cheque_Printing_Text_gne__c,
                        Comment_gne__c, Currency_gne__c, Email_address_gne__c, EMS_Event_gne__c,
                        EMS_International_Speaker_gne__c, GST_HST_gne__c, HCP_gne__c, HCP_gne__r.Name, Honorarium_gne__c,
                        Id, Name, Non_Res_Tax_gne__c, On_Hold_Comment_gne__c, Payable_To_Name_gne__c, Payment_Date_gne__c,
                        Payment_Terms_gne__c, Payment_Type_gne__c, QST_gne__c, Recipient_Vendor_Name_gne__c, RecordType.Name,
                        RecordTypeId, Requestor_gne__c, Route_invoice_to_gne__c, Route_invoice_to_gne__r.Name,
                        Self_invoice_sent_at__c, Speaker_Topic_gne__c, Status_gne__c, Telephone_number_gne__c,
                        Vendor_Address_gne__c, Vendor_ID_gne__c, Vendor_Main_Email_Address_gne__c, HCP_HCO_iHCP_gne__c
                FROM EMS_Speaker_Role_gne__c
                WHERE Id = :requestId
                LIMIT 1
        ];
    }

    private EMS_Event__c queryEvent(Id eventId) {
        return [
                SELECT Name, Event_Type_gne__c, Event_Sub_Type_gne__c, Start_Date_gne__c, End_Date_gne__c, Event_Owner_gne__c,
                        Event_Owner_gne__r.Name, Event_Requestor_gne__c, Event_Requestor_gne__r.Name, Event_Name_gne__c,
                        Is_GSD_Event_gne__c, Cost_Center_Type_gne__c, Total_Budget_Allocated_gne__c, (SELECT GSD_Type_gne__c FROM EMS_GSD_Details__r)
                FROM EMS_Event__c
                WHERE Id = :eventId
        ];
    }

    public Boolean costElementEditable {
        get {
            return costCenterTypes.size() > 1;
        }
    }

    public Set<String> costCenterTypes {
        get {
            if (costCenterTypes == null && event != null) {
                costCenterTypes = new Set<String>();

                for (EMS_Budget_Allocation_gne__c ba : [
                        SELECT Cost_Center_Type_gne__c
                        FROM EMS_Budget_Allocation_gne__c
                        WHERE EMS_Event_gne__c = :event.Id
                ]) {
                    costCenterTypes.add(ba.Cost_Center_Type_gne__c);
                }
            }
            return costCenterTypes;
        }
        private set;
    }

    public List<EMS_Speaker_Role_gne__c> relatedPaymentRequests {
        get {
            if (String.isBlank(paymentRequest.EMS_International_Speaker_gne__c) && String.isBlank(paymentRequest.HCP_gne__c)) {
                return new List<EMS_Speaker_Role_gne__c>();
            }

            String attendeeId = '';
            if (String.isNotBlank(paymentRequest.EMS_International_Speaker_gne__c)) {
                attendeeId = paymentRequest.EMS_International_Speaker_gne__c;
            } else if (String.isNotBlank(paymentRequest.HCP_gne__c)) {
                attendeeId = paymentRequest.HCP_gne__c;
            }

            return [
                    SELECT Id,Name,HCP_HCO_iHCP_gne__c,Account_Type_gne__c,Total_Amount_gne__c,CreatedDate,Status_gne__c, (SELECT Id, Name FROM EMS_Expenses__r)
                    FROM EMS_Speaker_Role_gne__c
                    WHERE EMS_Event_gne__c = :event.Id
                    AND (
                            EMS_International_Speaker_gne__c = :attendeeId
                            OR HCP_gne__c = :attendeeId
                    )
            ];
        }
    }

    public Set<String> costElementList {
        get {
            if (costElementList == null && mappings != null) {
                costElementList = new Set<String>();
                for (EMS_Possible_Budget_Allocation_gne__c ba : mappings) {
                    if (String.isNotBlank(ba.Cost_Elements_gne__c)) {
                        costElementList.addAll(ba.Cost_Elements_gne__c.split(';'));
                    }
                }
            }
            return costElementList;
        }
        private set;
    }

    public List<EMS_Cost_Element__c> costElementMappings {
        get {
            if (costElementMappings == null && costElementList != null) {
                costElementMappings = [
                        SELECT Id, Name, Description__c
                        FROM EMS_Cost_Element__c
                        WHERE Name IN :costElementList
                ];
            }

            return costElementMappings;
        }
        private set;
    }

    public Boolean renderCostElementMessage {
        get {
            return costElementMappings != null && costElementMappings.isEmpty() == false;
        }
    }

    public EMS_Payment_Request_Edit_Create_Ext() {
        counter = 0;
        requestorName = '';
        amountExceeded = false;
        pagePositiveMessage = ApexPages.currentPage().getParameters().get('msg');
        retUrl = System.currentPageReference().getParameters().get('retURL');
        if (retUrl != null) {
            retUrl = EncodingUtil.urlDecode(retUrl, 'UTF-8');
        }

        Id objectId = ApexPages.currentPage().getParameters().get('Id');
        Id eventId = ApexPages.currentPage().getParameters().get('objectId');
        Id hcpId = ApexPages.currentPage().getParameters().get('accountId');
        Id iHcpId = ApexPages.currentPage().getParameters().get('ihcpId');
        attendeeID = ApexPages.currentPage().getParameters().get('attendeeID');

        SObjectType objectType = EMS_Speaker_Role_gne__c.SObjectType;

        if (String.isNotBlank(objectId)) {
            objectType = objectId.getSobjectType();
            if (objectType == EMS_Speaker_Role_gne__c.SObjectType) {
                paymentRequest = queryPaymentRequest(objectId);
            } else if (objectType == EMS_Transaction_gne__c.SObjectType) {
                currentTransaction = queryTransaction(objectId);
                paymentRequest = queryPaymentRequest(currentTransaction.EMS_Speaker_Role_gne__c);
            }
        } else {
            paymentRequest = new EMS_Speaker_Role_gne__c();
        }

        if(String.isNotBlank(eventId)) {
            event = queryEvent(eventId);
        } else if (currentTransaction != null && String.isNotBlank(currentTransaction.EMS_Event_gne__c)) {
            event = queryEvent(currentTransaction.EMS_Event_gne__c);
        } else if(paymentRequest != null && String.isNotBlank(paymentRequest.EMS_Event_gne__c)) {
            event = queryEvent(paymentRequest.EMS_Event_gne__c);
        }

        if (objectType == EMS_Transaction_gne__c.SObjectType) {
            if (currentTransaction.Id == null) {
                EMS_Transaction_gne__c newTransaction = new EMS_Transaction_gne__c();
                EMS_Speaker_Role_gne__c newPaymentRequest = new EMS_Speaker_Role_gne__c();

                if (String.isNotBlank(eventId)) {
                    event = queryEvent(eventId);
                    newTransaction.EMS_Event_gne__c = eventId;
                    newPaymentRequest.EMS_Event_gne__c = eventId;
                    newPaymentRequest.Status_gne__c = 'Draft';
                }

                if (String.isNotBlank(hcpId)) {
                    newPaymentRequest.HCP_gne__c = (Id) hcpId;
                } else if (String.isNotBlank(iHcpId)) {
                    newPaymentRequest.EMS_International_Speaker_gne__c = (Id) iHcpId;
                }

                newPaymentRequest.Route_invoice_to_gne__c = event.Event_Owner_gne__c;
                newPaymentRequest.Currency_gne__c = 'CAD';

                paymentRequest = newPaymentRequest;
                currentTransaction = newTransaction;
            } else {
                paymentRequest = queryPaymentRequest(currentTransaction.EMS_Speaker_Role_gne__c);
                event = queryEvent(paymentRequest.EMS_Event_gne__c);
            }
        } else if (objectType == EMS_Speaker_Role_gne__c.SObjectType) {
            if (paymentRequest.Id == null) {
                EMS_Speaker_Role_gne__c newPaymentRequest = new EMS_Speaker_Role_gne__c();
                if (String.isNotBlank(eventId)) {
                    event = queryEvent(eventId);
                    newPaymentRequest.EMS_Event_gne__c = eventId;
                    newPaymentRequest.Status_gne__c = 'Draft';
                }

                if (String.isNotBlank(hcpId)) {
                    newPaymentRequest.HCP_gne__c = (Id) hcpId;
                } else if (String.isNotBlank(iHcpId)) {
                    newPaymentRequest.EMS_International_Speaker_gne__c = (Id) iHcpId;
                }

                if (event != null) {
                    newPaymentRequest.Route_invoice_to_gne__c = event.Event_Owner_gne__c;
                }
                newPaymentRequest.Currency_gne__c = 'CAD';

                paymentRequest = newPaymentRequest;
            } else {
                paymentRequest = queryPaymentRequest(paymentRequest.Id);
                event = queryEvent(paymentRequest.EMS_Event_gne__c);
            }
        }

        if (event != null) {
            paymentRequest.Requestor_gne__c = event.Event_Requestor_gne__c;
            requestorName = event.Event_Requestor_gne__r.Name;
        }

        List<EMS_GSD_Detail__c> gsdDetails = [
                SELECT GSD_Type_gne__c, EMS_Event__c
                FROM EMS_GSD_Detail__c
                WHERE EMS_Event__c = :event.Id
                LIMIT 1
        ];
        if (gsdDetails.size() > 0) {
            gsdDetail = gsdDetails[0];
        }

        if (gsdDetail != null) {
            mappings = [
                    SELECT Cost_Elements_gne__c, Budget_Type_gne__r.Name
                    FROM EMS_Possible_Budget_Allocation_gne__c
                    WHERE EMS_Event_Configuration_gne__r.Event_Type_gne__c = :event.Event_Type_gne__c
                    AND EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c = :event.Event_Sub_Type_gne__c
                    AND GSD_Type_gne__c LIKE :gsdDetail.GSD_Type_gne__c
                    AND Budget_Type_gne__r.Name IN :costCenterTypes
            ];
        } else {
            mappings = [
                    SELECT Cost_Elements_gne__c, Budget_Type_gne__r.Name
                    FROM EMS_Possible_Budget_Allocation_gne__c
                    WHERE EMS_Event_Configuration_gne__r.Event_Type_gne__c = :event.Event_Type_gne__c
                    AND EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c = :event.Event_Sub_Type_gne__c
                    AND Budget_Type_gne__r.Name IN :costCenterTypes
            ];
        }

        fetchTransactionsList();

        DescribeSObjectResult paymentRequestDescribe = EMS_Speaker_Role_gne__c.getSObjectType().getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypesMap = paymentRequestDescribe.getRecordTypeInfosByName();

        // set default record type
        if (paymentRequest.Id == null) {
            if(attendeeID != null) {
                recordTypeName = 'Non-Stakeholder Payment Request';
            } else if (iHcpId != null) {
                recordTypeName = 'iHCP Payment Request';
            } else {
                recordTypeName = 'HCP/HCO Payment Request';
            }

            paymentRequest.RecordTypeId = recordTypesMap.get(recordTypeName).getRecordTypeId();
            if (iHcpId != null || hcpId != null || attendeeID != null) {
                recordTypePreselected = true;
            }
        } else {
            recordTypeName = paymentRequest.RecordType.Name;
            if(String.isNotBlank(paymentRequest.HCP_gne__c) || String.isNotBlank(paymentRequest.EMS_International_Speaker_gne__c)) {
                recordTypePreselected = true;
            }
        }

        for (EMS_Cost_Center_gne__c cc : [SELECT Id, Name FROM EMS_Cost_Center_gne__c]) {
            costCentersMap.put(cc.Name, cc.Id);
        }

        if (event != null) {
            if (getIsGSD()) {
                gsdExists = true;
                loadGSDDetails();
            } else {
                gsdExists = false;
                loadFMVDetails();
            }
        }

        // Temporary field holding payment request before changes for future comparision
        oldPaymentRequest = paymentRequest.clone(true, true, true, true);

		oldTransactions = new Map<Id, EMS_Transaction_gne__c>([
							SELECT Fee_Amount_gne__c, Cheque_Printing_text_gne__c, Cost_Center_gne__c, Cost_Element_gne__c,
							EMS_Speaker_Role_gne__c, Tax_gne__c, Tax_Amount_gne__c, Tax_Code_gne__c, Status_gne__c, WBS_Code__c
							FROM EMS_Transaction_gne__c
							WHERE EMS_Speaker_Role_gne__c = :paymentRequest.Id]);

    }

    public List<SelectOption> getRecordTypes() {
        List<SelectOption> result = new List<SelectOption>();
        for (RecordType recordType : [SELECT Name, DeveloperName FROM RecordType WHERE SobjectType = 'EMS_Speaker_Role_gne__c']) {
            result.add(new SelectOption(recordType.Name, recordType.Name));
        }
        return result;
    }

    public PageReference onRecordTypeChange() {
        Map<String, Schema.RecordTypeInfo> recordTypesMap = EMS_Speaker_Role_gne__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
        paymentRequest.RecordTypeId = recordTypesMap.get(recordTypeName).getRecordTypeId();

        if(isWitholdingTax) {
            paymentRequest.Non_Res_Tax_gne__c = getNonResTaxCodes()[0].getValue(); // Take the first option as a default
        } else {
            paymentRequest.Non_Res_Tax_gne__c = null; // This value is populated only for a certain "recordTypeName"
        }


        if (recordTypeName == 'iHCP Payment Request') {
            paymentRequest.HCP_gne__c = null;
        } else {
            paymentRequest.EMS_International_Speaker_gne__c = null;
        }

        onNonResTaxChange();
        return null;
    }

    public Boolean isEditable {
        get {
            return EMS_Util.isAdmin() || (
                    EMS_Access.isBPS() && (paymentRequest.Status_gne__c == 'Draft' || paymentRequest.Status_gne__c == 'On-Hold')
            );
        }
    }

    // TODO: remove in future
    public Boolean getIsEditable() {
        return isEditable;
    }

    public Boolean getCanDuplicate() {
        if (EMS_Access.isBPS() && event.Event_Sub_Type_gne__c == 'OLA/Accredited CHE Development') {
            return true;
        } else if (EMS_Util.isAdmin() && event.Event_Sub_Type_gne__c == 'OLA/Accredited CHE Development') {
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

    private Integer getLineNumber() {
        Integer index = lineNumber;
        lineNumber++;
        return index;
    }

    private void fetchTransactionsList() {
        lineNumber = 1;
        transactionGroupList = new Map<Integer, TransactionGroupWrapper>();

        List<EMS_Transaction_gne__c> transactions = [
                SELECT Status_gne__c, EMS_Speaker_Role_gne__c, EMS_Speaker_Role_gne__r.Honorarium_gne__c, Name, Cost_Center_gne__c, Payment_taxes_gne__c, Disturbance_Fee_gne__c, Fee_Amount_gne__c, Cost_Element_gne__c,
                        Tax_Code_gne__c, Tax_gne__c, Tax_Amount_gne__c, Parent_Transaction_gne__c, RecordType.DeveloperName, Cheque_Printing_text_gne__c, Line_Number_gne__c, Is_Editable_gne__c, WBS_Code__c, (
                        SELECT Status_gne__c, EMS_Speaker_Role_gne__c, EMS_Speaker_Role_gne__r.Honorarium_gne__c, Name, Cost_Center_gne__c, Cost_Center_gne__r.Name, Payment_taxes_gne__c, Disturbance_Fee_gne__c,
                                Fee_Amount_gne__c, Cost_Element_gne__c, Tax_Code_gne__c, Tax_gne__c, Tax_Amount_gne__c, Parent_Transaction_gne__c, RecordType.DeveloperName, Cheque_Printing_text_gne__c,
                                Line_Number_gne__c, Is_Editable_gne__c, WBS_Code__c
                        FROM EMS_Transactions__r
                        ORDER BY RecordType.DeveloperName DESC, Line_Number_gne__c ASC NULLS LAST, Cost_Element_gne__c ASC NULLS LAST
                )
                FROM EMS_Transaction_gne__c
                WHERE EMS_Speaker_Role_gne__c = :paymentRequest.Id AND Parent_Transaction_gne__c = NULL
                ORDER BY RecordType.DeveloperName DESC, Line_Number_gne__c ASC NULLS LAST, Cost_Element_gne__c ASC NULLS LAST
        ];

        Map<String, Decimal> costCenter_percentage = new Map<String, Decimal>();
        for (AggregateResult ar : [SELECT Cost_Center_gne__c costCenter, SUM(Percentage_Contribution_gne__c) percentage FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c = :event.Id GROUP BY Cost_Center_gne__c]) {
            String costCenter = (String) ar.get('costCenter');
            if (!costCenter_percentage.containsKey(costCenter)) {
                costCenter_percentage.put(costCenter, 0.000);
            }
            Decimal taxPercentage = (Decimal) costCenter_percentage.get(costCenter) + (Decimal) ar.get('percentage');
            costCenter_percentage.put(costCenter, taxPercentage);
        }

        List<EMS_Transaction_gne__c> taxSummaryTransactions = new List<EMS_Transaction_gne__c>();
        // Using the map below for sorting by Line Number
        Map<Integer, TransactionGroupWrapper> lineNumberToTransGroup = new Map<Integer, TransactionGroupWrapper>();
        for (EMS_Transaction_gne__c trans : transactions) {
            if (trans.RecordType.DeveloperName == 'Transaction_Group') {
                if (String.isBlank(trans.Cheque_Printing_text_gne__c)) {
                    trans.Cheque_Printing_text_gne__c = '';
                }

                List<EMS_Transaction_gne__c> transactionsList = new List<EMS_Transaction_gne__c>();
                List<EMS_Transaction_gne__c> taxLinesList = new List<EMS_Transaction_gne__c>();
                Integer tempLineOrder = null;

                Decimal totalTaxAmount = trans.Tax_Amount_gne__c;
                Integer transactionAmount = 0;
                for (EMS_Transaction_gne__c t : trans.EMS_Transactions__r) {
                    if (t.RecordType.DeveloperName == 'Transaction') {
                        transactionAmount++;
                    }
                }

                for (EMS_Transaction_gne__c t : trans.EMS_Transactions__r) {
                    String costCenter = t.Cost_Center_gne__r.Name;
                    if (t.RecordType.DeveloperName == 'Tax_Line') {
                        taxLinesList.add(t);
                    } else if (t.RecordType.DeveloperName == 'Transaction') {
                        transactionAmount--;
                        if (t.Tax_Amount_gne__c == null) {
                            // for old records Tax Amount it null (not calculated separately), it needs to be calculated based on Tax Percentage for each Cost Center
                            if (transactionAmount == 0) { // the last transaction in the row
                                // remaining tax amount goes to the last transaction
                                t.Tax_Amount_gne__c = totalTaxAmount;
                            } else {
                                t.Tax_Amount_gne__c = ((trans.Tax_Amount_gne__c * costCenter_percentage.get(costCenter)) / 100).setScale(2, System.RoundingMode.HALF_UP);
                                totalTaxAmount -= t.Tax_Amount_gne__c;
                            }
                        }

                        // recalculate Tax % per transaction each time when page is loaded.
                        t.Tax_gne__c = (trans.Tax_gne__c * costCenter_percentage.get(costCenter) / 100).setScale(3, System.RoundingMode.HALF_UP);

                        transactionsList.add(t);
                        tempLineOrder = (tempLineOrder == null) ? Integer.valueOf(t.Line_Number_gne__c) : tempLineOrder;
                        lineNumber++;
                    }
                }
                TransactionGroupWrapper transGroup = new TransactionGroupWrapper(event, trans,
                        transactionsList, taxLinesList, availableTaxCodesMap, mappings);

                lineNumberToTransGroup.put(tempLineOrder, transGroup);
            } else if (trans.RecordType.DeveloperName == 'Tax_Summary') {
                taxSummaryTransactions.add(trans);
            }

            // add tax summary if required
            if (!taxSummaryTransactions.isEmpty()) {
                TransactionGroupWrapper tempTransGroupWrapper = new TransactionGroupWrapper(event, null, taxSummaryTransactions, null, availableTaxCodesMap, mappings);
                tempTransGroupWrapper.isTaxSummaryGroup = true;
                taxSummaryGroup = tempTransGroupWrapper;
            }
        }

        // Sorting TransactionGroups by Line Numbers
        List<Integer> keys = new List<Integer>(lineNumberToTransGroup.keySet());
        keys.sort();
        for (Integer key : keys) {
            transactionGroupList.put(getNextId(), lineNumberToTransGroup.get(key));
        }
    }

    public PageReference addGSDayment() {
        // add new honorarium payment
        String gsdType = null;
        if (gsdDetail != null) {
            gsdType = gsdDetail.GSD_Type_gne__c;
        }

        // If the AARC decides to pay a portion of the allocated budget amount then we should allow them to adjust the amount field in the payment request details section
        Boolean editable = true;
        createTransGroup(event.Total_Budget_Allocated_gne__c, null, editable);

        return null;
    }

    public PageReference addFMVPayment() {
        // add new honorarium payment
        String gsdType = null;
        if (gsdDetail != null) {
            gsdType = gsdDetail.GSD_Type_gne__c;
        }

        Boolean editable = false;
        createTransGroup(fmvDetails.Total_Honoraria_gne__c, null, editable);

        return null;
    }

    public PageReference onHCPHCOCiHCPhange() {
        if (getIsGSD()) {
            gsdExists = true;
            loadGSDDetails();
        } else {
            gsdExists = false;
            loadFMVDetails();
        }
        return null;
    }


    private void loadGSDDetails() {
        String query = 'SELECT HCP_HCO_Name__c,Email_Address_gne__c,Phone_Number_gne__c,Street_1_gne__c,Street_2_gne__c,City_gne__c,Province_gne__c,Postal_Code_gne__c,Country_gne__c,Institution_gne__c FROM EMS_GSD_Detail__c WHERE EMS_Event__c = \'' + event.Id + '\' LIMIT 1';
        EMS_GSD_Detail__c gsdDetailRecord = (EMS_GSD_Detail__c) Database.query(query);

        for (EMS_Possible_Budget_Allocation_gne__c pba : [
                SELECT Cost_Elements_gne__c, Budget_Type_gne__r.Name
                FROM EMS_Possible_Budget_Allocation_gne__c
                WHERE EMS_Event_Configuration_gne__r.Event_Type_gne__c = :event.Event_Type_gne__c
                AND EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c = :event.Event_Sub_Type_gne__c
        ]) {
            costElementsMap.put(pba.Budget_Type_gne__r.Name, pba.Cost_Elements_gne__c);
        }
        String address = gsdDetailRecord.Street_1_gne__c;
        String street2 = String.isBlank(gsdDetailRecord.Street_2_gne__c)
                ? ''
                : gsdDetailRecord.Street_2_gne__c
                        .removeStartIgnoreCase('na')
                        .removeStartIgnoreCase('n/a')
                        .removeStartIgnoreCase('n.a')
                        .removeStartIgnoreCase('-');
        if (String.isNotBlank(street2)) address += '\n' + street2;
        address += '\n' + gsdDetailRecord.City_gne__c;

		if(gsdDetailRecord.Province_gne__c != null) {
			address += ', ' + gsdDetailRecord.Province_gne__c;
		}
		address += ' ' + gsdDetailRecord.Postal_Code_gne__c + '\n';
		if(gsdDetailRecord.Country_gne__c != null) {
			address += gsdDetailRecord.Country_gne__c;
		}
        paymentRequest.Payable_To_Name_gne__c = gsdDetailRecord.Institution_gne__c;
        paymentRequest.Address_gne__c = address;
        paymentRequest.Telephone_number_gne__c = gsdDetailRecord.Phone_Number_gne__c;
        paymentRequest.Email_address_gne__c = gsdDetailRecord.Email_Address_gne__c;

        if (recordTypeName == 'iHCP Payment Request') {
            paymentRequest.HCP_gne__c = null;
            paymentRequest.EMS_International_Speaker_gne__c = gsdDetailRecord.HCP_HCO_Name__c;
        }
        if (recordTypeName == 'HCP/HCO Payment Request') {
            paymentRequest.HCP_gne__c = gsdDetailRecord.HCP_HCO_Name__c;
            paymentRequest.EMS_International_Speaker_gne__c = null;
        }
    }

    private void loadFMVDetails() {
        String query = 'SELECT Total_Honoraria_gne__c, Non_Stakeholder_Name__c, Payable_To_Name_gne__c, Address_gne__c, Telephone_number_gne__c, EMS_International_Speaker_gne__c, Email_address_gne__c, Type_of_HCP_gne__c FROM EMS_Attendee_gne__c WHERE EMS_Event_gne__c = \'' + event.Id + '\'';

        if (paymentRequest.HCP_gne__c != null) {
            query += ' AND Account_gne__c = \'' + paymentRequest.HCP_gne__c + '\'';
        } else if (paymentRequest.EMS_International_Speaker_gne__c != null) {
            query += ' AND EMS_International_Speaker_gne__c = \'' + paymentRequest.EMS_International_Speaker_gne__c + '\'';
        } else if(attendeeID != null) {
            query += ' AND Id = \'' + attendeeID + '\'';
        } else {
            // clear payable to information
            paymentRequest.Payable_To_Name_gne__c = null;
            paymentRequest.Address_gne__c = null;
            paymentRequest.Telephone_number_gne__c = null;
            paymentRequest.Email_address_gne__c = null;

            fmvExists = false;
            return;
        }

        List<EMS_Attendee_gne__c> hcpHcoIhcp = (List<EMS_Attendee_gne__c>) Database.query(query);
        if (hcpHcoIhcp.size() > 0 && hcpHcoIhcp[0].Total_Honoraria_gne__c != null) {
            fmvDetails = hcpHcoIhcp[0];

            // set payable to information
            paymentRequest.Payable_To_Name_gne__c = fmvDetails.Payable_To_Name_gne__c;
            paymentRequest.Address_gne__c = fmvDetails.Address_gne__c;
            paymentRequest.Telephone_number_gne__c = fmvDetails.Telephone_number_gne__c;
            paymentRequest.Email_address_gne__c = fmvDetails.Email_address_gne__c;
            paymentRequest.HCP_HCO_iHCP_gne__c = fmvDetails.Non_Stakeholder_Name__c;

            recordTypePreselected = fmvDetails.Type_of_HCP_gne__c != 'Other' || fmvDetails.EMS_International_Speaker_gne__c != null;
            fmvExists = true;
        } else {
            // clear payable to information
            paymentRequest.Payable_To_Name_gne__c = null;
            paymentRequest.Address_gne__c = null;
            paymentRequest.Telephone_number_gne__c = null;
            paymentRequest.Email_address_gne__c = null;

            fmvExists = false;
        }
    }

    public PageReference addRemoveTaxLine() {
        TransactionGroupWrapper transWrapper = transactionGroupList.get(currentIndex);
        String taxCode = transWrapper.trans.Tax_Code_gne__c;
        Decimal taxPercentage = 0.000;
        Boolean taxable = false;
        Decimal taxAmountSum = 0;

        // calculate total tax
        List<EMS_Tax_Code_gne__c> taxCodes = [SELECT Name, Cost_Element_gne__c, Description_gne__c, Tax_Percentage_gne__c FROM EMS_Tax_Code_gne__c WHERE Name = :taxCode ORDER BY Name ASC];
        for (EMS_Tax_Code_gne__c tax : taxCodes) {
            taxPercentage += tax.Tax_Percentage_gne__c;
        }

        transWrapper.trans.Tax_gne__c = taxPercentage;
        transWrapper.trans.Tax_Amount_gne__c = ((taxPercentage / 100.00) * transWrapper.trans.Fee_Amount_gne__c).setScale(2, System.RoundingMode.HALF_UP);

        // clear old tax lines
        for (EMS_Transaction_gne__c taxLine: transWrapper.taxLines) {
            if (taxLine.Id != null) {
                transactionsToRemove.add(taxLine);
            }
        }
        transWrapper.taxLines.clear();

        for (Integer i = 0; i < taxCodes.size(); i++) { // Goup up all taxCodes with the equal name
            EMS_Tax_Code_gne__c tax = taxCodes[i];
            String costElement = tax.Cost_Element_gne__c;

            if (tax.Tax_Percentage_gne__c > 0) {

                Decimal taxAmount;
                if (i != taxCodes.size() - 1) {
                    taxAmount = ((tax.Tax_Percentage_gne__c / 100.00) * transWrapper.trans.Fee_Amount_gne__c).setScale(2, System.RoundingMode.HALF_UP);
                    taxAmountSum += taxAmount;
                } else {
                    taxAmount = (transWrapper.trans.Tax_Amount_gne__c - taxAmountSum).setScale(2, System.RoundingMode.HALF_UP);
                }
                transWrapper.taxLines.add(new EMS_Transaction_gne__c(
                        EMS_Event_gne__c = event.Id,
                        Tax_Amount_gne__c = taxAmount,
                        Tax_gne__c = tax.Tax_Percentage_gne__c,
                        Cost_Element_gne__c = costElement,
                        Fee_Amount_gne__c = taxAmount
                ));

                taxable = true;
            }

        }

        // sum taxes by cost element
        Map<String, Decimal> taxSumPerCostElement = new Map<String, Decimal>();
        for (TransactionGroupWrapper transactionGroup : transactionGroupList.values()) {
            for (EMS_Transaction_gne__c taxLine : transactionGroup.taxLines) {
                if (!taxSumPerCostElement.containsKey(taxLine.Cost_Element_gne__c)) {
                    taxSumPerCostElement.put(taxLine.Cost_Element_gne__c, taxLine.Fee_Amount_gne__c);
                } else {
                    Decimal currentSum = taxSumPerCostElement.get(taxLine.Cost_Element_gne__c);
                    taxSumPerCostElement.put(taxLine.Cost_Element_gne__c, currentSum + taxLine.Fee_Amount_gne__c);
                }
            }
        }


        if (taxable) {
            if (taxSummaryGroup == null) {
                // Create empty summary section
                taxSummaryGroup = new TransactionGroupWrapper(event, null, new List<EMS_Transaction_gne__c>(), null, availableTaxCodesMap, mappings);
            } else {
                // Clear summary section
                for (EMS_Transaction_gne__c transactionItem: taxSummaryGroup.transactions) {
                    if (transactionItem.Id != null) {
                        transactionsToRemove.add(transactionItem);
                    }
                }
                taxSummaryGroup.transactions.clear();
            }


            // Add new tax summary
            for (String costElement : taxSumPerCostElement.keySet()) {
                if (!costElement.contains('PST')) {
                    Boolean addNew = true;
                    // change existing transaction
                    for (Integer i = 0; i < taxSummaryGroup.transactions.size(); i++) {
                        if (taxSummaryGroup.transactions[i].Cost_Element_gne__c == costElement) {
                            taxSummaryGroup.transactions[i].Fee_Amount_gne__c = taxSumPerCostElement.get(costElement);
                            addNew = false;
                        }
                    }
                    // add a new transaction, if current one doesn't exist
                    if (addNew == true) {
                        taxSummaryGroup.transactions.add(new EMS_Transaction_gne__c(
                                EMS_Speaker_Role_gne__r = paymentRequest,
                                EMS_Event_gne__c = (Id) paymentRequest.get('EMS_Event_gne__c'),
                                Status_gne__c = 'Draft',
                                Cost_Element_gne__c = costElement,
                                Fee_Amount_gne__c = taxSumPerCostElement.get(costElement)
                        ));
                    }
                }
            }
        } else {
            if (taxSummaryGroup != null) {
                // Remove from taxSummaryGroup transactions which are not needed anymore, i.e. "TAX CODE" is changed to "I0 (Tax - Exempt)" which has Tax% = 0
                for (Integer i = taxSummaryGroup.transactions.size() - 1; i >= 0; i--) {
                    if (!taxSumPerCostElement.containsKey(taxSummaryGroup.transactions[i].Cost_Element_gne__c)) {
                        if (taxSummaryGroup.transactions[i].Id != null) {
                            transactionsToRemove.add(taxSummaryGroup.transactions[i]);
                        }
                        taxSummaryGroup.transactions.remove(i);
                    }
                }
            }
        }

        return null;
    }

    public List<SelectOption> getNonResTaxCodes() {
        List<SelectOption> result = new List<SelectOption>();
        Set<String> alreadyAdded = new Set<String>();
        for (EMS_Tax_Code_gne__c taxCode : [SELECT Name FROM EMS_Tax_Code_gne__c WHERE Start_Date_gne__c <= :Date.today() AND (End_Date_gne__c >= :Date.today() OR End_Date_gne__c = NULL) AND RecordType.DeveloperName = 'Non_resident_Tax_Code' ORDER BY Order_gne__c ASC NULLS LAST, Name]) {
            if (!alreadyAdded.contains(taxCode.Name)) {
                result.add(new SelectOption(taxCode.Name, taxCode.Name));
                alreadyAdded.add(taxCode.Name);
            }
        }

        if (paymentRequest.Non_Res_Tax_gne__c != null && !alreadyAdded.contains(paymentRequest.Non_Res_Tax_gne__c)) {
            result.add(new SelectOption(paymentRequest.Non_Res_Tax_gne__c, paymentRequest.Non_Res_Tax_gne__c));
        }
        return result;
    }

    private void createTransGroup(Decimal amount, String costElement, Boolean editable) {
        Map<String, Schema.RecordTypeInfo> transactionRecordTypesMap = EMS_Transaction_gne__c.getSObjectType().getDescribe().getRecordTypeInfosByName();

        if (transactionGroupList == null) {
            transactionGroupList = new Map<Integer, TransactionGroupWrapper>();
        }

        // add transactions
        List<EMS_Transaction_gne__c> transactions = new List<EMS_Transaction_gne__c>();
        for (AggregateResult ba : [SELECT Cost_Center_gne__c costCenter, MAX(Cost_Center_Type_gne__c) costCenterType FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c = :event.Id GROUP BY Cost_Center_gne__c]) {
            transactions.add(new EMS_Transaction_gne__c(
                    Tax_Code_gne__c = null,
                    Line_Number_gne__c = getLineNumber(),
                    RecordTypeId = transactionRecordTypesMap.get('Transaction').getRecordTypeId(),
                    EMS_Speaker_Role_gne__r = paymentRequest,
                    EMS_Event_gne__c = (Id) paymentRequest.get('EMS_Event_gne__c'),
                    Status_gne__c = 'Draft',
                    Cost_Center_gne__c = costCentersMap.get((String) ba.get('costCenter')),
                    Cost_Element_gne__c = (costElement != null) ? costElement : costElementsMap.containsKey((String) ba.get('costCenterType')) ? costElementsMap.get((String) ba.get('costCenterType')) : ''
            ));
        }

        // Set the sort order - "Cost_Element_gne__c"  field
        Map<String, EMS_Tax_Code_gne__c> sortedMap = new Map<String, EMS_Tax_Code_gne__c>();
        List<String> sortedKeys = new List<String>();
        for (EMS_Tax_Code_gne__c tc : taxCodeList) {
            sortedMap.put(tc.Cost_Element_gne__c, tc);
            sortedKeys.add(tc.Cost_Element_gne__c);
        }
        sortedKeys.sort();

        // add tax lines
        List<EMS_Transaction_gne__c> taxLines = new List<EMS_Transaction_gne__c>();
        String taxCode = getIsNonTaxable() ? getTaxCodeNonTaxable() : getTaxCodeDefault();
        Decimal taxPercentage = 0.000;
        Decimal taxAmountSum = 0;
        Integer sizeCounter = 0;
        Boolean taxable = false;

        for (String key : sortedKeys) {
            EMS_Tax_Code_gne__c tc = sortedMap.get(key);
            if (taxCode == tc.Name) {
                taxPercentage += tc.Tax_Percentage_gne__c;

                if (tc.Tax_Percentage_gne__c > 0) {
                    Decimal taxAmount;
                    if (sizeCounter != taxCodeList.size() - 1) {
                        taxAmount = ((tc.Tax_Percentage_gne__c / 100.00) * amount).setScale(2, System.RoundingMode.HALF_UP);
                        taxAmountSum += taxAmount;
                    } else {  // last in the row
                        taxAmount = (((taxPercentage / 100.00) * amount).setScale(2) - taxAmountSum).setScale(2, System.RoundingMode.HALF_UP);
                    }

                    // recalculate Tax % per transaction each time when page is loaded. (it is taken from database)
                    //  t.Tax_gne__c = (trans.Tax_gne__c * costCenter_percentage.get(costCenter) / 100).setScale(3, System.RoundingMode.HALF_UP);

                    taxLines.add(new EMS_Transaction_gne__c(
                            EMS_Event_gne__c = event.Id,
                            Tax_Amount_gne__c = taxAmount,
                            Tax_gne__c = tc.Tax_Percentage_gne__c,
                            Cost_Element_gne__c = tc.Cost_Element_gne__c,
                            Fee_Amount_gne__c = taxAmount
                    ));

                    taxable = true;
                }
            }
            sizeCounter++;
        }

        if (taxable) {
            Map<String, Decimal> taxSumPerCostElement = new Map<String, Decimal>();
            // Existing ones
            for (TransactionGroupWrapper transactionGroup : transactionGroupList.values()) {
                for (EMS_Transaction_gne__c taxLine : transactionGroup.taxLines) {
                    if (!taxSumPerCostElement.containsKey(taxLine.Cost_Element_gne__c)) {
                        taxSumPerCostElement.put(taxLine.Cost_Element_gne__c, taxLine.Fee_Amount_gne__c);
                    } else {
                        Decimal currentSum = taxSumPerCostElement.get(taxLine.Cost_Element_gne__c);
                        taxSumPerCostElement.put(taxLine.Cost_Element_gne__c, currentSum + taxLine.Fee_Amount_gne__c);
                    }
                }
            }
            // New ones
            for (EMS_Transaction_gne__c taxLine : taxLines) {
                if (!taxSumPerCostElement.containsKey(taxLine.Cost_Element_gne__c)) {
                    taxSumPerCostElement.put(taxLine.Cost_Element_gne__c, taxLine.Fee_Amount_gne__c);
                } else {
                    Decimal currentSum = taxSumPerCostElement.get(taxLine.Cost_Element_gne__c);
                    taxSumPerCostElement.put(taxLine.Cost_Element_gne__c, currentSum + taxLine.Fee_Amount_gne__c);
                }
            }

            // Change an existing taxSummaryGroup variable
            if (taxSummaryGroup != null) {
                for (String costElementItem : taxSumPerCostElement.keySet()) {
                    if (!costElementItem.contains('PST')) {
                        Boolean addNew = true;
                        // change existing transaction
                        for (Integer i = 0; i < taxSummaryGroup.transactions.size(); i++) {
                            if (taxSummaryGroup.transactions[i].Cost_Element_gne__c == costElementItem) {
                                taxSummaryGroup.transactions[i].Fee_Amount_gne__c = taxSumPerCostElement.get(costElementItem);
                                addNew = false;
                            }
                        }
                        // add a new transaction, if existing one doesn't exist
                        if (addNew == true) {
                            taxSummaryGroup.transactions.add(new EMS_Transaction_gne__c(
                                    EMS_Speaker_Role_gne__r = paymentRequest,
                                    EMS_Event_gne__c = (Id) paymentRequest.get('EMS_Event_gne__c'),
                                    Status_gne__c = 'Draft',
                                    Cost_Element_gne__c = costElementItem,
                                    Fee_Amount_gne__c = taxSumPerCostElement.get(costElementItem)
                            ));
                        }
                    }
                }
            } else {
                // Create a new taxSummaryGroup variable
                List<EMS_Transaction_gne__c> taxTransactions = new List<EMS_Transaction_gne__c>();
                for (String costElementItem : taxSumPerCostElement.keySet()) {
                    if (!costElementItem.contains('PST')) {
                        taxTransactions.add(new EMS_Transaction_gne__c(
                                EMS_Speaker_Role_gne__r = paymentRequest,
                                EMS_Event_gne__c = (Id) paymentRequest.get('EMS_Event_gne__c'),
                                Status_gne__c = 'Draft',
                                Cost_Element_gne__c = costElementItem,
                                Fee_Amount_gne__c = taxSumPerCostElement.get(costElementItem)
                        ));
                    }
                }
                taxSummaryGroup = new TransactionGroupWrapper(event, null, taxTransactions, null, availableTaxCodesMap, mappings);
            }
        } else {
            // left unchangeable
            taxSummaryGroup = null; // (Not sure if there should be some logic)
        }

        TransactionGroupWrapper groupWrapper = new TransactionGroupWrapper(
                event,
                new EMS_Transaction_gne__c(
                        RecordTypeId = transactionRecordTypesMap.get('Transaction Group').getRecordTypeId(),
                        EMS_Event_gne__c = event.Id,
                        EMS_Speaker_Role_gne__c = paymentRequest.Id,
                        Tax_gne__c = getTaxValue(taxCode),
                        Fee_Amount_gne__c = amount,
                        Tax_Amount_gne__c = ((taxPercentage / 100.00) * amount).setScale(2, System.RoundingMode.HALF_UP),
                        Is_Editable_gne__c = editable,
                        Tax_Code_gne__c = taxCode,
                        Cheque_Printing_text_gne__c = ''
                ),
                transactions,
                taxLines,
                availableTaxCodesMap,
                mappings
        );
        groupWrapper.trans.Cost_Element_gne__c = (costElement != null) ? costElement : groupWrapper.trans.Cost_Element_gne__c;

        transactionGroupList.put(getNextId(), groupWrapper);
    }

    private static String getTaxCodeDefault() {
        // getting first value in a row as a taxCode value
        return (availableTaxCodesMap.containsKey(0)) ? availableTaxCodesMap.get(0) : '';//
    }

    private static String getTaxCodeNonTaxable() {
        // getting Non-Taxable taxCode
        Integer index = 0;
        for (Integer key: availableTaxCodesMap.keySet()) {
            if (availableTaxCodesMap.get(key) == 'I0 (Tax - Exempt)') {
                index = key;
                break;
            }
        }

        return availableTaxCodesMap.get(index);
    }

    public Boolean getIsGSD() {
        return (event != null && event.Is_GSD_Event_gne__c);
    }

    public String getGSDType() {
        String result = null;
        if (getIsGSD()) {
            for (EMS_GSD_Detail__c gsd : event.EMS_GSD_Details__r) {
                result = gsd.GSD_Type_gne__c;
            }
        }
        return result;
    }

    private static Decimal getTaxValue(String taxCode) {
        return (taxCodesToTaxMap.containsKey(taxCode)) ? taxCodesToTaxMap.get(taxCode) : 0;
    }

    public Boolean getIsNonTaxable() {
        return (paymentRequest.Non_Res_Tax_gne__c == '02 - Non-Taxable' || paymentRequest.Non_Res_Tax_gne__c == '03 - Non-Taxable Travel Exp');
    }

    public PageReference createTransactionGroup() {
        Map<String, Schema.RecordTypeInfo> transactionRecordTypesMap = EMS_Transaction_gne__c.getSObjectType().getDescribe().getRecordTypeInfosByName();

        if (transactionGroupList == null) {
            transactionGroupList = new Map<Integer, TransactionGroupWrapper>();
        }
        List<EMS_Transaction_gne__c> transactions = new List<EMS_Transaction_gne__c>();

        // loop through budget allocations for the event
        for (AggregateResult ba : [SELECT Cost_Center_gne__c costCenter, MAX(Cost_Center_Type_gne__c) costCenterType, SUM(Percentage_Contribution_gne__c) percentage FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c = :event.Id GROUP BY Cost_Center_gne__c]) {
            // add transactions
            transactions.add(new EMS_Transaction_gne__c(Tax_Code_gne__c = null, Line_Number_gne__c = getLineNumber(), RecordTypeId = transactionRecordTypesMap.get('Transaction').getRecordTypeId(),
                    EMS_Speaker_Role_gne__r = paymentRequest,
                    EMS_Event_gne__c = (Id) paymentRequest.get('EMS_Event_gne__c'), Status_gne__c = 'Draft',
                    Cost_Center_gne__c = costCentersMap.get((String) ba.get('costCenter')),
                    Tax_Amount_gne__c = 0.00,
                    Cost_Element_gne__c = costElementsMap.containsKey((String) ba.get('costCenterType')) ? costElementsMap.get((String) ba.get('costCenterType')) : ''
            ));
        }

        // Set the sort order - "Cost_Element_gne__c"  field
        Map<String, EMS_Tax_Code_gne__c> sortedMap = new Map<String, EMS_Tax_Code_gne__c>();
        List<String> sortedKeys = new List<String>();
        for (EMS_Tax_Code_gne__c tc : taxCodeList) {
            sortedMap.put(tc.Cost_Element_gne__c, tc);
            sortedKeys.add(tc.Cost_Element_gne__c);
        }
        sortedKeys.sort();

        // add tax lines
        List<EMS_Transaction_gne__c> taxLines = new List<EMS_Transaction_gne__c>();
        String taxCode = getIsNonTaxable() ? getTaxCodeNonTaxable() : getTaxCodeDefault();
        Decimal taxPercentage = 0.000;
        Integer sizeCounter = 0;
        Boolean taxable = false;

        for (String key : sortedKeys) {
            EMS_Tax_Code_gne__c tc = sortedMap.get(key);
            if (taxCode == tc.Name) {
                taxPercentage += tc.Tax_Percentage_gne__c;

                if (tc.Tax_Percentage_gne__c > 0) {
                    Decimal taxAmount = 0.00; // for a new transactionGroup taxAmount always 0.00

                    taxLines.add(new EMS_Transaction_gne__c(
                            EMS_Event_gne__c = event.Id,
                            Tax_Amount_gne__c = taxAmount,
                            Tax_gne__c = tc.Tax_Percentage_gne__c,
                            Cost_Element_gne__c = tc.Cost_Element_gne__c,
                            Fee_Amount_gne__c = taxAmount
                    ));

                    taxable = true;
                }
            }
            sizeCounter++;
        }
        if (taxable) {
            Map<String, Decimal> taxSumPerCostElement = new Map<String, Decimal>();
            // Go through existing ones
            for (TransactionGroupWrapper transactionGroup : transactionGroupList.values()) {
                for (EMS_Transaction_gne__c taxLine : transactionGroup.taxLines) {
                    if (!taxSumPerCostElement.containsKey(taxLine.Cost_Element_gne__c)) {
                        taxSumPerCostElement.put(taxLine.Cost_Element_gne__c, taxLine.Fee_Amount_gne__c);
                    } else {
                        Decimal currentSum = taxSumPerCostElement.get(taxLine.Cost_Element_gne__c);
                        taxSumPerCostElement.put(taxLine.Cost_Element_gne__c, currentSum + taxLine.Fee_Amount_gne__c);
                    }
                }
            }
            // Go through new taxLines even if amount is 0, because there might be some new CostElements values
            for (EMS_Transaction_gne__c taxLine : taxLines) {
                if (!taxSumPerCostElement.containsKey(taxLine.Cost_Element_gne__c)) {
                    taxSumPerCostElement.put(taxLine.Cost_Element_gne__c, taxLine.Fee_Amount_gne__c);
                } else {
                    Decimal currentSum = taxSumPerCostElement.get(taxLine.Cost_Element_gne__c);
                    taxSumPerCostElement.put(taxLine.Cost_Element_gne__c, currentSum + taxLine.Fee_Amount_gne__c);
                }
            }

            // Change an existing taxSummaryGroup variable
            if (taxSummaryGroup != null) {
                for (String costElementItem : taxSumPerCostElement.keySet()) {
                    if (!costElementItem.contains('PST')) {
                        Boolean addNew = true;
                        // change existing transaction
                        for (Integer i = 0; i < taxSummaryGroup.transactions.size(); i++) {
                            if (taxSummaryGroup.transactions[i].Cost_Element_gne__c == costElementItem) {
                                taxSummaryGroup.transactions[i].Fee_Amount_gne__c = taxSumPerCostElement.get(costElementItem);
                                addNew = false;
                            }
                        }
                        // add a new transaction, if existing one doesn't exist
                        if (addNew == true) {
                            taxSummaryGroup.transactions.add(new EMS_Transaction_gne__c(
                                    EMS_Speaker_Role_gne__r = paymentRequest,
                                    EMS_Event_gne__c = (Id) paymentRequest.get('EMS_Event_gne__c'),
                                    Status_gne__c = 'Draft',
                                    Cost_Element_gne__c = costElementItem,
                                    Fee_Amount_gne__c = taxSumPerCostElement.get(costElementItem)
                            ));
                        }
                    }
                }
            } else {
                // Create a new taxSummaryGroup variable
                List<EMS_Transaction_gne__c> taxTransactions = new List<EMS_Transaction_gne__c>();
                for (String costElementItem : taxSumPerCostElement.keySet()) {
                    if (!costElementItem.contains('PST')) {
                        taxTransactions.add(new EMS_Transaction_gne__c(
                                EMS_Speaker_Role_gne__r = paymentRequest,
                                EMS_Event_gne__c = (Id) paymentRequest.get('EMS_Event_gne__c'),
                                Status_gne__c = 'Draft',
                                Cost_Element_gne__c = costElementItem,
                                Fee_Amount_gne__c = taxSumPerCostElement.get(costElementItem)
                        ));
                    }
                }
                taxSummaryGroup = new TransactionGroupWrapper(event, null, taxTransactions, null, availableTaxCodesMap, mappings);
            }
        } else {
            // left unchangeable
            taxSummaryGroup = null; // (Not sure if here should be some logic)
        }

        TransactionGroupWrapper groupWrapper = new TransactionGroupWrapper(
                event,
                new EMS_Transaction_gne__c(
                        RecordTypeId = transactionRecordTypesMap.get('Transaction Group').getRecordTypeId(),
                        EMS_Event_gne__c = event.Id,
                        EMS_Speaker_Role_gne__c = paymentRequest.Id,
                        Tax_gne__c = getTaxValue(taxCode),
                        Fee_Amount_gne__c = 0.00,
                        Tax_Amount_gne__c = 0.00,
                        Is_Editable_gne__c = true,
                        Tax_Code_gne__c = taxCode,
                        Cheque_Printing_text_gne__c = ''
                ),
                transactions,
                taxLines,
                availableTaxCodesMap,
                mappings
        );

        transactionGroupList.put(getNextId(), groupWrapper);

        amountExceeded = false;
        return null;
    }

    public PageReference removeTransactionGroup() {

        // remove existing transactions
        Integer transactionsCount = 0;
        for (EMS_Transaction_gne__c trans : transactionGroupList.get(currentIndex).transactions) {
            transactionsCount++;
            if (trans.Id != null) {
                transactionsToRemove.add(trans);
            }
        }

        for (EMS_Transaction_gne__c trans : transactionGroupList.get(currentIndex).taxLines) {
            if (trans.Id != null) {
                transactionsToRemove.add(trans);
            }
        }

        if (transactionGroupList.get(currentIndex).trans.Id != null) {
            transactionsToRemove.add(transactionGroupList.get(currentIndex).trans);
        }
        transactionGroupList.remove(currentIndex);

        // remove unncecessary tax summary lines
        Set<String> costElements = new Set<String>();
        for (TransactionGroupWrapper groupWrapper : transactionGroupList.values()) {
            for (EMS_Transaction_gne__c t : groupWrapper.taxLines) {
                costElements.add(t.Cost_Element_gne__c);
            }
        }

        if (taxSummaryGroup != null) {
            for (Integer i = taxSummaryGroup.transactions.size() - 1; i >= 0; i--) {
                if (!costElements.contains(taxSummaryGroup.transactions[i].Cost_Element_gne__c)) {
                    if (taxSummaryGroup.transactions[i].Id != null) {
                        transactionsToRemove.add(taxSummaryGroup.transactions[i]);
                    }
                    taxSummaryGroup.transactions.remove(i);
                }
            }
        }

        // update line numbers
        lineNumber -= transactionsCount;
        for (Integer i = currentIndex + 1; i < counter; i++) {
            if (transactionGroupList.get(i) != null) {
                for (EMS_Transaction_gne__c t : transactionGroupList.get(i).transactions) {
                    t.Line_Number_gne__c -= transactionsCount;
                }
            }
        }

        amountExceeded = false;
        return null;
    }

    public PageReference save() {
        if (doSave(false)) {
            if (retUrl != null) {
                PageReference pr = new PageReference(retUrl);
                return pr;
            } else {
                return Page.EMS_Home;
            }
        } else {
            return null;
        }
    }

    public PageReference cancel() {
        if (retUrl != null) {
            PageReference pr = new PageReference(retUrl);
            pr.setRedirect(true);
            return pr;
        } else {
            PageReference pr = new PageReference('/' + event.Id);
            pr.setRedirect(true);
            return pr;
        }
    }

    public PageReference deletePayment() {
        try {
            delete paymentRequest;
        } catch (DmlException ex) {

        }

        if (retUrl != null) {
            return new PageReference(retUrl);
        } else {
            return Page.EMS_Home;
        }
    }

    public PageReference duplicatePayment() {
        paymentRequest = paymentRequest.clone(false, false);
        paymentRequest.Payment_Date_gne__c = null;
        paymentRequest.Status_gne__c = 'Draft';
        paymentRequest.Self_invoice_generated_at__c = null;
        paymentRequest.Self_invoice_sent_at__c = null;
        transactionGroupList.clear();

        return null;
    }

    public Boolean doSave(Boolean submit) {
        Map<String, Schema.RecordTypeInfo> transactionRecordTypesMap = EMS_Transaction_gne__c.getSObjectType().getDescribe().getRecordTypeInfosByName();

        Boolean isSuccess = true;
        // validate vendor
        if (paymentRequest.Vendor_ID_gne__c == null) {
            paymentRequest.Vendor_ID_gne__c.addError(System.Label.Must_Enter_A_Value + ': ' + Schema.SObjectType.EMS_Speaker_Role_gne__c.fields.Vendor_ID_gne__c.label);
            return false;
        }
        List<EMS_Transaction_gne__c> transactionsToInsert = new List<EMS_Transaction_gne__c>();
        List<EMS_Transaction_gne__c> transactionsToUpdate = new List<EMS_Transaction_gne__c>();
        System.Savepoint sp = Database.setSavepoint();

        if (!transactionGroupList.isEmpty()) {
            Set<Id> insertedParentIDs = new Set<Id>();
            try {
                if (submit) {
                    paymentRequest.Status_gne__c = 'Submitted';
                }

                if (recordTypeName == 'HCP/HCO Payment Request' && String.isEmpty(paymentRequest.HCP_gne__c)) {
                    paymentRequest.HCP_gne__c.addError(System.Label.Must_Enter_A_Value + ': ' + Schema.SObjectType.EMS_Speaker_Role_gne__c.fields.HCP_gne__c.label);
                    throw new EMS_DML_Exception();
                } else if (recordTypeName == 'iHCP Payment Request' && String.isEmpty(paymentRequest.EMS_International_Speaker_gne__c)) {
                    paymentRequest.EMS_International_Speaker_gne__c.addError(System.Label.Must_Enter_A_Value + ': ' + Schema.SObjectType.EMS_Speaker_Role_gne__c.fields.EMS_International_Speaker_gne__c.label);
                    throw new EMS_DML_Exception();
                } else if (recordTypeName == 'iPatient Payment Request') {
                	if(!fmvExists) {
	                	paymentRequest.HCP_gne__c.addError('Selected Account does not have FMV Form completed.');
	                    throw new EMS_DML_Exception();
                	} else if(recordTypePreselected) {
                		paymentRequest.HCP_gne__c.addError('Selected Account must have FMV Form completed with HCP / StakeHolder Tier selected as Other.');
	                    throw new EMS_DML_Exception();
                	}
                }
                upsert paymentRequest;

                // save parent transactions first
                if (!transactionGroupList.isEmpty()) {
                    for (TransactionGroupWrapper t : transactionGroupList.values()) {
                        Boolean groupCostElement = String.isNotBlank(t.trans.Cost_Element_gne__c);
                        Boolean itemCostElement = true;
                        for(EMS_Transaction_gne__c tr : t.transactions) {
                            if(String.isBlank(tr.Cost_Element_gne__c)) {
                                itemCostElement = false;
                            }
                        }

                        // if no group CE nor all items has CE, it's problem
                        if (!groupCostElement && !itemCostElement) {
                            t.trans.Cost_Element_gne__c.addError(System.Label.Must_Enter_A_Value + ': ' + Schema.SObjectType.EMS_Transaction_gne__c.fields.Cost_Element_gne__c.label);
                            throw new EMS_DML_Exception();
                        }

                        // create parent transaction
                        t.trans.RecordTypeId = transactionRecordTypesMap.get('Transaction Group').getRecordTypeId();
                        t.trans.EMS_Event_gne__c = event.Id;
                        t.trans.EMS_Speaker_Role_gne__c = paymentRequest.Id;
                        if (submit) {
                            t.trans.Status_gne__c = 'Not Started';
                        }

                        if (t.trans.Id == null) {
                            transactionsToInsert.add(t.trans);
                        } else {
                            transactionsToUpdate.add(t.trans);
                        }
                    }

                    if (!transactionsToInsert.isEmpty()) {
                        insert transactionsToInsert;

                        insertedParentIDs.clear();
                        for (EMS_Transaction_gne__c t :transactionsToInsert) {
                            insertedParentIDs.add(t.Id);
                        }
                    }
                    if (!transactionsToUpdate.isEmpty()) {
                        update transactionsToUpdate;
                    }
                }
                transactionsToInsert.clear();
                transactionsToUpdate.clear();

                if (!transactionGroupList.isEmpty()) {
                    for (TransactionGroupWrapper t : transactionGroupList.values()) {
                        // save transcations
                        for (EMS_Transaction_gne__c trans : t.transactions) {
                            trans.RecordTypeId = transactionRecordTypesMap.get('Transaction').getRecordTypeId();
                            trans.EMS_Speaker_Role_gne__c = paymentRequest.Id;
                            trans.Parent_Transaction_gne__c = t.trans.Id;
                            trans.Cheque_Printing_text_gne__c = t.trans.Cheque_Printing_text_gne__c;

                            if (submit) {
                                trans.Status_gne__c = 'Not Started';
                            }

                            if (trans.Id == null) {
                                transactionsToInsert.add(trans);
                            } else {
                                transactionsToUpdate.add(trans);
                            }
                        }

                        // save tax lines
                        for (EMS_Transaction_gne__c trans : t.taxLines) {
                            trans.RecordTypeId = transactionRecordTypesMap.get('Tax Line').getRecordTypeId();
                            trans.EMS_Speaker_Role_gne__c = paymentRequest.Id;
                            trans.Parent_Transaction_gne__c = t.trans.Id;

                            if (submit) {
                                trans.Status_gne__c = 'Not Started';
                            }

                            if (trans.Id == null) {
                                transactionsToInsert.add(trans);
                            } else if (trans.Fee_Amount_gne__c > 0) {
                                transactionsToUpdate.add(trans);
                            } else {
                                transactionsToRemove.add(trans);
                            }
                        }
                    }

                    // save tax summary transactions
                    if (taxSummaryGroup != null) {
                        for (EMS_Transaction_gne__c trans : taxSummaryGroup.transactions) {
                            trans.RecordTypeId = transactionRecordTypesMap.get('Tax Summary').getRecordTypeId();
                            trans.EMS_Speaker_Role_gne__c = paymentRequest.Id;

                            if (submit) {
                                trans.Status_gne__c = 'Not Started';
                            }

                            if (trans.Id == null) {
                                transactionsToInsert.add(trans);
                            } else if (trans.Fee_Amount_gne__c > 0) {
                                transactionsToUpdate.add(trans);
                            } else {
                                transactionsToRemove.add(trans);
                            }
                        }
                    }
                }

                totalAmount = totalAmount.setScale(2, System.RoundingMode.HALF_UP);

                // validate total amount
                if (submit && !amountExceeded && (totalAmount > event.Total_Budget_Allocated_gne__c)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The total amount ' + totalAmount + ' exceeds the total budget allocated ' + event.Total_Budget_Allocated_gne__c + '. Please click "Submit for Payment" button.'));
                    throw new EMS_DML_Exception('amountExceeded');
                }

                if (!transactionsToInsert.isEmpty()) {
                    insert transactionsToInsert;
                }
                if (!transactionsToUpdate.isEmpty()) {
                    update transactionsToUpdate;
                }

                if (!transactionsToRemove.isEmpty()) {
                    delete transactionsToRemove;
                }

                // Refresh info about Transaction and Payement request. Fixing missing fields values on after submit page.
                fetchTransactionsList();
                paymentRequest = queryPaymentRequest(paymentRequest.Id);
            } catch (Exception ex) {
                if (ex.getMessage() != 'amountExceeded') {
                    if (ApexPages.hasMessages() == false) {
                        // Throw the system exception in a case if it is unknown
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occured when submitting a payment: ' + ex.getMessage()));
                    }
                    Database.rollback(sp);
                    isSuccess = false;
                } else { // Warning message is shown
                    if (!amountExceeded) { // the first attempt to submit
                        // Rollback the change in status and all inserted (or updated) parents.
                        Database.rollback(sp);
                        amountExceeded = true;

                        // clear parent IDs
                        for (TransactionGroupWrapper t : transactionGroupList.values()) {
                            if (insertedParentIDs.contains(t.trans.Id)) {
                                t.trans.Id = null;
                            }
                        }
                    }
                }

                // reset payment request status
                paymentRequest.Status_gne__c = 'Draft';
                // Refresh info about Payement request. Fixing missing fields values on after submit page.
                List<EMS_Speaker_Role_gne__c> paymentRequests = [
                        SELECT Name, EMS_Event_gne__c, EMS_International_Speaker_gne__c, HCP_gne__c, HCP_gne__r.Name, Payment_Type_gne__c, Payment_Date_gne__c, Status_gne__c,
                                Comment_gne__c, On_Hold_Comment_gne__c, Honorarium_gne__c, Speaker_Topic_gne__c, Recipient_Vendor_Name_gne__c, Vendor_ID_gne__c, Vendor_Address_gne__c,
                                Approver_gne__c, Requestor_gne__c, Currency_gne__c, Route_invoice_to_gne__c, Route_invoice_to_gne__r.Name, Payable_To_Name_gne__c, Address_gne__c,
                                Telephone_number_gne__c, Email_address_gne__c, Non_Res_Tax_gne__c, RecordType.Name, Cheque_Printing_Text_gne__c, Payment_Terms_gne__c, GST_HST_gne__c, QST_gne__c,
                                Vendor_Main_Email_Address_gne__c, Alternate_Email_Address_gne__c, Self_invoice_sent_at__c
                        FROM EMS_Speaker_Role_gne__c
                        WHERE Id = :paymentRequest.Id
                        LIMIT 1
                ];

                if (paymentRequests.size() > 0) {
                    EMS_Speaker_Role_gne__c tempRecord = paymentRequest;
                    paymentRequest = paymentRequests[0];

                    // Saving some field values
                    paymentRequest.HCP_gne__c = tempRecord.HCP_gne__c;
                    paymentRequest.Payment_Date_gne__c = tempRecord.Payment_Date_gne__c;
                    paymentRequest.Comment_gne__c = tempRecord.Comment_gne__c;
                    paymentRequest.Currency_gne__c = tempRecord.Currency_gne__c;
                    paymentRequest.Route_invoice_to_gne__c = tempRecord.Route_invoice_to_gne__c;
                    paymentRequest.Cheque_Printing_Text_gne__c = tempRecord.Cheque_Printing_Text_gne__c;
                    paymentRequest.Vendor_ID_gne__c = tempRecord.Vendor_ID_gne__c;
                    paymentRequest.Recipient_Vendor_Name_gne__c = tempRecord.Recipient_Vendor_Name_gne__c;
                    paymentRequest.Vendor_Address_gne__c = tempRecord.Vendor_Address_gne__c;
                    paymentRequest.Payable_To_Name_gne__c = tempRecord.Payable_To_Name_gne__c;
                    paymentRequest.Address_gne__c = tempRecord.Address_gne__c;
                    paymentRequest.Telephone_number_gne__c = tempRecord.Telephone_number_gne__c;
                    paymentRequest.Email_address_gne__c = tempRecord.Email_address_gne__c;
                    paymentRequest.Payment_Terms_gne__c = tempRecord.Payment_Terms_gne__c;
                    paymentRequest.GST_HST_gne__c = tempRecord.GST_HST_gne__c;
                    paymentRequest.QST_gne__c = tempRecord.QST_gne__c;
                    paymentRequest.Vendor_Main_Email_Address_gne__c = tempRecord.Vendor_Main_Email_Address_gne__c;
                    paymentRequest.Alternate_Email_Address_gne__c = tempRecord.Alternate_Email_Address_gne__c;
                    paymentRequest.Self_invoice_sent_at__c = tempRecord.Self_invoice_sent_at__c;
                } else {
                    paymentRequest.Id = null;

                    for (TransactionGroupWrapper t : transactionGroupList.values()) {
                        t.trans.Id = null;

                        for (EMS_Transaction_gne__c trans : t.transactions) {
                            trans.Id = null;
                        }

                        for (EMS_Transaction_gne__c trans : t.taxLines) {
                            trans.Id = null;
                        }
                    }

                    if (taxSummaryGroup != null) {
                        for (EMS_Transaction_gne__c trans : taxSummaryGroup.transactions) {
                            trans.Id = null;
                        }
                    }
                }
                isSuccess = false;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have to create at least one transaction.'));
            isSuccess = false;
        }

        return isSuccess;
    }

    public PageReference submitForPaymentClick() {
        if (!transactionGroupList.isEmpty()) {
            if (doSave(true)) {
                PageReference pr = Page.EMS_Payment_Request_Edit_Create_Layout;
                pr.getParameters().put('Id', paymentRequest.Id);
                pr.getParameters().put('objectId', event.Id);
                pr.getParameters().put('retURL', retUrl);
                pr.getParameters().put('msg', 'Your payment request was submitted successfully');
                pr.setRedirect(true);

                sendSelfInvoiceIfNecessary();
                return pr;
            } else {
                // doSave should add message
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have to create at least one transaction to submit a payment.'));
        }

        return null;
    }

    public PageReference onNonResTaxChange() {
        if (getIsNonTaxable()) {
            // set tax to 0
            for (TransactionGroupWrapper transWrapper : transactionGroupList.values()) {
                transWrapper.trans.Tax_Code_gne__c = 'I0 (Tax - Exempt)';
                transWrapper.trans.Tax_gne__c = 0;
                transWrapper.trans.Tax_Amount_gne__c = 0;

                transWrapper.taxLines.clear();
            }
        }

        if (getIsNonTaxable()) {
            // remove tax summmary
            taxSummaryGroup = null;
        }

        return null;
    }

    private static Map<Integer, String> availableTaxCodesMap {
        get {
            if (availableTaxCodesMap == null) {
                availableTaxCodesMap = new Map<Integer, String>();
                Set<String> alreadyAdded = new Set<String>();
                Integer order = 0;
                for (EMS_Tax_Code_gne__c tc: taxCodeList) { // List is already sorted by "Order" field having nulls last, therefore a new order definition is being established below
                    if (!alreadyAdded.contains(tc.Name)) {
                        availableTaxCodesMap.put(order, tc.Name);
                        alreadyAdded.add(tc.Name);
                        order++;
                    }
                }
            }
            return availableTaxCodesMap;
        }
        set;
    }

    private static Map<String, Decimal> taxCodesToTaxMap {
        get {
            if (taxCodesToTaxMap == null) {
                taxCodesToTaxMap = new Map<String, Decimal>();
                for (EMS_Tax_Code_gne__c tc: taxCodeList) {
                    // Summarize Tax_Percentage_gne__c for records with the same name
                    if (taxCodesToTaxMap.containsKey(tc.Name)) {
                        taxCodesToTaxMap.put(tc.Name, taxCodesToTaxMap.get(tc.Name) + tc.Tax_Percentage_gne__c);
                    } else {
                        taxCodesToTaxMap.put(tc.Name, tc.Tax_Percentage_gne__c);
                    }
                }
            }
            return taxCodesToTaxMap;
        }
        set;
    }

    private static List<EMS_Tax_Code_gne__c> taxCodeList {
        get {
            return [
                    SELECT Name, Order_gne__c, Cost_Element_gne__c, Tax_Percentage_gne__c
                    FROM EMS_Tax_Code_gne__c
                    WHERE RecordType.DeveloperName = 'Sales_Tax_Code'
                    AND Start_Date_gne__c <= :Date.today() AND (End_Date_gne__c >= :Date.today() OR End_Date_gne__c = NULL)
                    ORDER BY Order_gne__c ASC NULLS LAST, Name
            ];
        }
    }

    private void sendSelfInvoiceIfNecessary() {
        if(paymentRequest.Status_gne__c == 'Submitted') {
            Map<Id, EMS_Transaction_gne__c> newTransactions = new Map<Id, EMS_Transaction_gne__c>([
                    SELECT Fee_Amount_gne__c, Cheque_Printing_text_gne__c, Cost_Center_gne__c, Cost_Element_gne__c,
                            EMS_Speaker_Role_gne__c, Tax_gne__c, Tax_Amount_gne__c, Tax_Code_gne__c, Status_gne__c, WBS_Code__c
                    FROM EMS_Transaction_gne__c
                    WHERE EMS_Speaker_Role_gne__c = :paymentRequest.Id
            ]);

            Boolean paymentRequestChanged = false == EMS_Util.compareSobjects(oldPaymentRequest, paymentRequest);
            Boolean transactionCountChanged = newTransactions.size() != oldTransactions.size();
            Boolean transactionsDataChanged = false;

            for(Id key : newTransactions.keySet()) {
                transactionsDataChanged |=
                    false == oldTransactions.containsKey(key)
                    || false == EMS_Util.compareSobjects(
                            oldTransactions.get(key),
                            newTransactions.get(key)
                    );
            }
            System.debug('### paymentRequestChanged: ' + paymentRequestChanged +
                    ', transactionCountChanged: ' + transactionCountChanged +
                    ', transactionsDataChanged: ' + transactionsDataChanged);
            if(paymentRequestChanged || transactionCountChanged || transactionsDataChanged) {
                sendEmailToVendorWithSelfInvoice(paymentRequest.Id);
            }
        }
    }

    @Future(Callout=true)
    public static void sendEmailToVendorWithSelfInvoice(Id paymentId) {
    	List<String> addresses = new List<String>();
    	EMS_Speaker_Role_gne__c payment = [SELECT Id, Vendor_Main_Email_Address_gne__c, Alternate_Email_Address_gne__c, EMS_Event_gne__r.Assigned_AARC_gne__r.Email FROM EMS_Speaker_Role_gne__c WHERE Id = :paymentId];
    	if(payment.Vendor_Main_Email_Address_gne__c != null) {
    		addresses.add(payment.Vendor_Main_Email_Address_gne__c);
    	}
    	if(payment.Alternate_Email_Address_gne__c != null) {
    		addresses.add(payment.Alternate_Email_Address_gne__c);
    	}

    	if(payment.EMS_Event_gne__r.Assigned_AARC_gne__r.Email != null) {
    		addresses.add(payment.EMS_Event_gne__r.Assigned_AARC_gne__r.Email);
    	}

    	Datetime now = System.now();
        payment.Self_invoice_sent_at__c = now;
        payment.Self_invoice_generated_at__c = now;

        update payment;

    	PageReference pdf = Page.EMS_SelfInvoice;
    	pdf.getParameters().put('id',paymentId);
    	pdf.setRedirect(true);

    	Blob body = pdf.getContent();

    	Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
    	attachment.setFileName('Self_Invoice.pdf');
    	attachment.setBody(body);

    	EMS_Email.prepareSingleEmail('EMS_Notification_To_Vendor',paymentId,addresses,attachment);

    	EMS_Email.send();
    }

    @RemoteAction
    public static List<BudgetWrapper> getBudgetAllocations(String eventId) {
        List<BudgetWrapper> result = new List<BudgetWrapper>();
        for (EMS_Budget_Allocation_gne__c ba : [SELECT Cost_Center_gne__c, Percentage_Contribution_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c = :eventId]) {
            result.add(new BudgetWrapper(ba.Cost_Center_gne__c.trim(), ba.Percentage_Contribution_gne__c));
        }
        return result;
    }

    public class BudgetWrapper {
        String costCenter { get; set; }
        Decimal taxPercentage { get; set; }

        BudgetWrapper(String costCenter, Decimal taxPercentage) {
            this.costCenter = costCenter;
            this.taxPercentage = taxPercentage;
        }
    }

    @RemoteAction
    public static Map<String, Decimal> getTaxAmounts() {
        Map<String, Decimal> result = new Map<String, Decimal>();
        for (EMS_Tax_Code_gne__c taxCode : [SELECT Name, Cost_Element_gne__c, Tax_Percentage_gne__c FROM EMS_Tax_Code_gne__c]) {
            result.put(taxCode.Name + ' ' + taxCode.Cost_Element_gne__c, taxCode.Tax_Percentage_gne__c);
        }
        return result;
    }


    public class TransactionGroupWrapper {
        public EMS_Transaction_gne__c trans { get; set; }
        public List<EMS_Transaction_gne__c> transactions { get; set; }
        public List<EMS_Transaction_gne__c> taxLines { get; set; }
        public Boolean isTaxSummaryGroup { get; set; }
        private EMS_Event__c event;
        private Map<Integer, String> taxCodes;
        private List<EMS_Possible_Budget_Allocation_gne__c> mappings;

        public Boolean editable {
            get {
                return (trans != null && trans.Is_Editable_gne__c == true);
            }
            set;
        }

        //noinspection ApexUnusedDeclaration
        public List<SelectOption> getTaxCodes() {
            Set<String> existingTaxCodes = new Set<String>();
            List<SelectOption> result = new List<SelectOption>();
            for (Integer key : taxCodes.keySet()) {
                result.add(new SelectOption(taxCodes.get(key), taxCodes.get(key)));
                existingTaxCodes.add(taxCodes.get(key));
            }

            // if selected tax code is no longer available add it to the list
            if (trans.Id != null && trans.Tax_Code_gne__c != null && !existingTaxCodes.contains(trans.Tax_Code_gne__c)) {
                result.add(new SelectOption(trans.Tax_Code_gne__c, trans.Tax_Code_gne__c));
            }

            return result;
        }

        public TransactionGroupWrapper(EMS_Event__c event, EMS_Transaction_gne__c trans,
                List<EMS_Transaction_gne__c> transactions, List<EMS_Transaction_gne__c> taxLines,
                Map<Integer, String> taxCodes, List<EMS_Possible_Budget_Allocation_gne__c> mappings) {

            this.event = event;
            this.trans = trans;
            this.taxCodes = taxCodes;
            this.mappings = new List<EMS_Possible_Budget_Allocation_gne__c>(mappings);

            if (transactions != null) {
                this.transactions = transactions;
            } else {
                this.transactions = new List<EMS_Transaction_gne__c>();
            }

            if (taxLines != null) {
                this.taxLines = taxLines;
            } else {
                this.taxLines = new List<EMS_Transaction_gne__c>();
            }

            isTaxSummaryGroup = false;
        }

        public List<SelectOption> getCostElements() {
            List<SelectOption> result = new List<SelectOption>{
                    new SelectOption('', '--None--')
            };

            Integer counter = 0;
            for (EMS_Possible_Budget_Allocation_gne__c mapping : mappings) {
                if(String.isNotBlank(mapping.Cost_Elements_gne__c)) {
                    for (String costElement : mapping.Cost_Elements_gne__c.split(';')) {
                        String optionValue = costElement;
                        String optionLabel = costElement + ' - ' + mapping.Budget_Type_gne__r.Name;
                        result.add(new SelectOption(optionValue, optionLabel));
                        counter++;
                    }
                }
            }

            if(counter == 1) {
                result.remove(0);
            }

            return result;
        }
    }

    public class EMS_DML_Exception extends Exception {
    }
}