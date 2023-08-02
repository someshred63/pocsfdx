public with sharing class EMS_Ariba_Payment_Queue_Export_Ctrl {

    private static final List<String> allowedRecordTypes = new List<String>{
            '', // records without RT - old records
            'Transaction',
            'Tax Line'
    };
    private static Id parentTransactionRTId = Schema.SObjectType.EMS_Transaction_gne__c.getRecordTypeInfosByName().get('Transaction Group').getRecordTypeId();
    private static String separator = ',';

    public String csvName { get; set; }
    public List<String> exportLines { get; set; }

    public String fileContent {
        get {
            return String.join(exportLines, '');
        }
    }

    public EMS_Ariba_Payment_Queue_Export_Ctrl() {
        csvName = 'EMS_' + System.currentPageReference().getParameters().get('bid') + '_' + String.valueOf(Date.today()); //EMS_<Batchid>_<date>

        exportLines = new List<String>();
        String ids = System.currentPageReference().getParameters().get('ids');
        if (String.isBlank(ids)) return;

        // payment requests list
        List<EMS_Speaker_Role_gne__c> paymentRecords = [
                SELECT Vendor_ID_gne__c, Payment_Date_gne__c, Name, Transactions_Total_Amount_gne__c, Currency_gne__c, Route_invoice_to_gne__r.External_ID_gne__c, Comment_gne__c,
                        Non_Res_Tax_gne__c, Cheque_Printing_Text_gne__c, Total_Amount_gne__c, EMS_Event_gne__c, EMS_Event_gne__r.Name
                FROM EMS_Speaker_Role_gne__c
                WHERE Id IN :ids.split(',')
        ];

        Map<Id, Set<Id>> eventIdToPaymentIds = new Map<Id, Set<Id>>();
        for (EMS_Speaker_Role_gne__c paymentRecord : paymentRecords) {
            if (!eventIdToPaymentIds.containsKey(paymentRecord.EMS_Event_gne__c)) {
                eventIdToPaymentIds.put(paymentRecord.EMS_Event_gne__c, new Set<Id>{
                        paymentRecord.Id
                });
            } else {
                eventIdToPaymentIds.get(paymentRecord.EMS_Event_gne__c).add(paymentRecord.Id);
            }
        }

        // transactions list for each payment request record
        List<EMS_Transaction_gne__c> transactionRecords = [
                SELECT EMS_Speaker_Role_gne__c, Name, Fee_Amount_gne__c, Tax_Amount_gne__c, Tax_gne__c, Cheque_Printing_text_gne__c, Cost_Element_gne__c, Cost_Center_gne__r.Name, Tax_Code_gne__c,
                        Line_Number_gne__c, Parent_Transaction_gne__c, RecordType.Name, Parent_Transaction_gne__r.WBS_Code__c, Parent_Transaction_gne__r.Tax_Amount_gne__c, Parent_Transaction_gne__r.Cost_Element_gne__c, Parent_Transaction_gne__r.EMS_Event_gne__c,
                        EMS_Speaker_Role_gne__r.EMS_Event_gne__r.Name, WBS_Code__c
                FROM EMS_Transaction_gne__c
                WHERE EMS_Speaker_Role_gne__c IN :paymentRecords AND RecordType.Name IN:allowedRecordTypes
                ORDER BY Parent_Transaction_gne__c, RecordTypeId DESC
        ];

        // Parent Transaction (Transaction Group record) is a record which has Record Type = 'Transaction Group' and related transactions
        Set<Id> parentTransactionIDs = new Set<Id>();
        for (EMS_Transaction_gne__c transactionRecord : transactionRecords) {
            if (transactionRecord.Parent_Transaction_gne__c != null) {
                parentTransactionIDs.add(transactionRecord.Parent_Transaction_gne__c);
            }
        }
        Map<Id, EMS_Transaction_gne__c> parentTransactionRecords = new Map<Id, EMS_Transaction_gne__c>([
                SELECT Tax_Code_gne__c, Tax_gne__c, Fee_Amount_gne__c, Tax_Amount_gne__c, EMS_Speaker_Role_gne__c, EMS_Event_gne__c, WBS_Code__c, (SELECT Id FROM EMS_Transactions__r WHERE Id IN :transactionRecords)
                FROM EMS_Transaction_gne__c
                WHERE Id IN :parentTransactionIDs AND RecordTypeId = :parentTransactionRTId
        ]);

        Map<String, PaymentInfo> paymentIdToPayment = new Map<String, PaymentInfo>();
        // preparing "Tax Code" to "Total Tax Amount" data
        for (EMS_Transaction_gne__c transactionGroup : parentTransactionRecords.values()) {
            String paymentID = (String) transactionGroup.EMS_Speaker_Role_gne__c;
            String eventID = (String) transactionGroup.EMS_Event_gne__c;
            Decimal taxAmount = (Decimal) transactionGroup.Tax_Amount_gne__c;
            String transGroupID = (String) transactionGroup.Id;

            if (!paymentIdToPayment.containsKey(paymentID)) {
                // no record is in the collection? add it.
                paymentIdToPayment.put(paymentID, new PaymentInfo(eventID));
            }
            // get payment record
            PaymentInfo payment = paymentIdToPayment.get(paymentID);

            // preparing a collection which represents relation between tax code and total tax amount
            if (!payment.transGroupIDToTaxAmount.containsKey(transGroupID)) {
                payment.transGroupIDToTaxAmount.put(transGroupID, taxAmount);
            }

            payment.transGroupIDToTransactionCount.put(transGroupID, transactionGroup.EMS_Transactions__r.size());
        }

        // preparing "Cost Center" to "Tax Percentage" data
        for (AggregateResult ar : [SELECT Cost_Center_gne__c costCenter, SUM(Percentage_Contribution_gne__c) percentage, EMS_Event_gne__c eventID FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c IN :eventIdToPaymentIds.keySet() GROUP BY Cost_Center_gne__c, EMS_Event_gne__c]) {
            String eventID = (String) ar.get('eventID');
            String costCenter = (String) ar.get('costCenter');
            Set<Id> paymentIDs = eventIdToPaymentIds.get(eventID);

            for (Id paymentID : paymentIDs) {
                if (!paymentIdToPayment.containsKey(paymentID)) {
                    // no record in collection? then add a new one
                    paymentIdToPayment.put(paymentID, new PaymentInfo(paymentID, eventID));
                }
                // get payment record
                PaymentInfo payment = paymentIdToPayment.get(paymentID);
                // calculation tax percentage per each cost center
                if (!payment.constCenterToPercentage.containsKey(costCenter)) {
                    payment.constCenterToPercentage.put(costCenter, 0.00);
                }
                Decimal taxPercentage = payment.constCenterToPercentage.get(costCenter) + (Decimal) ar.get('percentage');
                payment.constCenterToPercentage.put(costCenter, taxPercentage);
            }
        }

        Map<Id, String> taxCodes = new Map<Id, String>();
        // collection represents all transactions for each payment request record
        Map<Id, List<EMS_Transaction_gne__c>> paymentToTransactions = new Map<Id, List<EMS_Transaction_gne__c>>();
        for (EMS_Speaker_Role_gne__c paymentRecord : paymentRecords) {
            paymentToTransactions.put(paymentRecord.Id, new List<EMS_Transaction_gne__c>());
        }

        for (EMS_Transaction_gne__c transactionRecord : transactionRecords) {
            Id key = transactionRecord.EMS_Speaker_Role_gne__c;
            paymentToTransactions.get(key).add(transactionRecord);

            // filling taxCode map
            if (parentTransactionRecords.containsKey(transactionRecord.Parent_Transaction_gne__c)) {
                EMS_Transaction_gne__c parentTRecord = parentTransactionRecords.get(transactionRecord.Parent_Transaction_gne__c);
                taxCodes.put(transactionRecord.Parent_Transaction_gne__c, parentTRecord.Tax_Code_gne__c);
            }
        }

        Integer paymentCounter = 0;

        // loop thought all selected payment requests
        for (EMS_Speaker_Role_gne__c paymentRecord : paymentRecords) {
            paymentCounter++;
            // "H" - row
            Integer rowsCounter = 1;
            PaymentWrapper exportPayment = new PaymentWrapper(paymentRecord, paymentCounter);

            exportLines.add(exportPayment.toSimpleBuyLine());

            List<TransactionWrapper> transactions = new List<TransactionWrapper>();
            if (paymentToTransactions.get(paymentRecord.Id).size() > 0) {
                PaymentInfo payment = paymentIdToPayment.get(paymentRecord.Id);

                for (EMS_Transaction_gne__c transaction_i : paymentToTransactions.get(paymentRecord.Id)) {
                    rowsCounter++;

                    TransactionWrapper exportTransaction = new TransactionWrapper(transaction_i, payment, taxCodes);
                    transactions.add(exportTransaction);

                    exportLines.add(exportTransaction.toSimpleBuyLine());
                }
            }
        }
    }

    public static String getValue(Object value) {
        if (value == null) {
            return '""';
        } else {
            if (value instanceof Decimal) {
                return '"' + String.valueOf(((Decimal) value).setScale(2)) + '"';
            } else {
                return '"' + String.valueOf(value) + '"';
            }
        }
    }

    public static String toSimpleBuyDate(Date inputDate) {
        // MM/DD/YYYY format
        return String.valueOf(inputDate.month()).leftPad(2, '0') + '/' +
                String.valueOf(inputDate.day()).leftPad(2, '0') + '/' +
                String.valueOf(inputDate.year()).leftPad(4, '0');
    }

    public class PaymentWrapper {
        public List<TransactionWrapper> transactions { get; set; }

        public String getLineTypeHeader() {
            return 'H';
        }

        public Decimal totalAmount { get; private set; }            // EMS_Speaker_Role_gne__c.Transactions_Total_Amount_gne__c
        public Integer exchangeRate { get; private set; }
        public Integer paymentIndex { get; private set; }
        public String barcode { get; private set; }
        public String barcodeBase { get; private set; }
        public String companyCode { get; private set; }             // System to pass value =  "2286"
        public String currencyValue { get; private set; }           // EMS_Speaker_Role_gne__c.Currency_gne__c
        public String documentType { get; private set; }            // System to pass value = "KE"
        public String paymentRecordName { get; private set; }       // Event Management System ID in the ARIBA payment queue
        public String eventName { get; private set; }
        public String invoiceDate { get; private set; }             // EMS_Speaker_Role_gne__c.Payment_Date_gne__c = YYYYMMDD date formatted
        public String paymentPrintingText { get; private set; }     // EMS_Speaker_Role_gne__c.Cheque_Printing_Text_gne__c
        public String postingDate { get; private set; }
        public String routeInvoiceTo { get; private set; }          // EMS_Speaker_Role_gne__c.Route_invoice_to_gne__r.Alias
        public String vendorNumber { get; private set; }            // EMS_Speaker_Role_gne__c.Vendor_ID_gne__c
        public String whTaxCode { get; private set; }               // EMS_Speaker_Role_gne__c.Non_Res_Tax_gne__c

        private EMS_Speaker_Role_gne__c payment;
        PaymentWrapper(EMS_Speaker_Role_gne__c paymentRecord, Integer paymentCounter) {
            payment = paymentRecord;
            paymentIndex = paymentCounter;

            documentType = 'KR';
            companyCode = '2286';
            barcodeBase = companyCode + '8';

            vendorNumber = paymentRecord.Vendor_ID_gne__c.trim();
            invoiceDate = toSimpleBuyDate(payment.Payment_Date_gne__c);
            totalAmount = paymentRecord.Total_Amount_gne__c;
            currencyValue = String.valueOf(paymentRecord.Currency_gne__c);
            paymentPrintingText = String.valueOf(paymentRecord.Cheque_Printing_Text_gne__c.removeStartIgnoreCase('*').trim());
            paymentRecordName = paymentRecord.Name;
            routeInvoiceTo = paymentRecord.Route_invoice_to_gne__r.External_ID_gne__c;
            whTaxCode = paymentRecord.Non_Res_Tax_gne__c != null ? String.valueOf(paymentRecord.Non_Res_Tax_gne__c).left(2) : '0';

            barcode = barcodeBase + String.valueOf(paymentIndex).leftPad(5, '0');
            exchangeRate = 1;
            eventName = paymentRecord.EMS_Event_gne__r.Name;
            postingDate = toSimpleBuyDate(Date.today());
        }

        private String getValue(Object valueParam) {
            return EMS_Ariba_Payment_Queue_Export_Ctrl.getValue(valueParam);
        }

        public String toSimpleBuyLine() {
            List<String> line = new List<String>{
                    /* A  */ getLineTypeHeader(),     // LINE HEADER
                    /* B  */ getValue(companyCode),   // COMPANY CODE
                    /* C  */ getValue(barcode),       // BARCODE (228680XXXX) companyCode + padding + idx
                    /* D  */ getValue(vendorNumber),  // VENDOR NUMBER
                    /* E  */ getValue(''),            // PO/CONTACT NUMBER
                    /* F  */ getValue(invoiceDate),   // DOCUMENT DATE
                    /* G  */ getValue(postingDate),   // POSTING DATE
                    /* H  */ getValue(paymentRecordName),     // PAYMENT REFERENCE
                    /* I  */ getValue(totalAmount),   // TOTAL AMOUNT
                    /* J  */ getValue(''),            // TAX AMOUNT
                    /* K  */ getValue(''),            // TAX CODE
                    /* L  */ getValue(currencyValue), // CURRENCY
                    /* M  */ getValue(whTaxCode),            // W/H TAX EXEMPT
                    /* N  */ getValue(''),            // CREDIT MEMO
                    /* O  */ getValue(routeInvoiceTo),// ASSIGNMENT
                    /* P  */ getValue(documentType),  // DOCUMENT TYPE
                    /* Q  */ getValue(eventName),     // ASSIGNMENT
                    /* R  */ getValue(exchangeRate),  // EXCHANGE RATE
                    /* S  */ getValue(paymentPrintingText),   // REFERENCE
                    /* T  */ getValue(''),            // VAT REPORTING DATE
                    /* U  */ getValue(''),            // ISR SUBSCRIBER NUMBER
                    /* V  */ getValue(''),            // ISR REFERENCE NUMBER
                    /* W  */ getValue(''),            // ISR CHECK DIGIT
                    /* X  */ getValue(''),            // PAYMENT METHOD
                    /* Y  */ getValue(''),            // PAYMENT METHOD SUPPLEMENT
                    /* Z  */ getValue(''),            // UNPLANNED DELIVERY COSTS
                    /* AA */ getValue(''),            // BANK TYPE
                    /* AB */ getValue(eventName)      // EVENT CODE
            };

            return String.join(line, separator) + '\r\n';
        }
    }

    private class TransactionWrapper {
        public String getLineType() {
            return 'D';
        }

        public String itemPrice { get; set; }               // EMS_Transaction_gne__c.Fee_Amount_gne__c - Pre-pop the total honorarium if possible. Check HCP/HCO for honorarium.
        public String accountNumber { get; set; }           // EMS_Transaction_gne__c.Cost_Element_gne__c
        public String costCenter { get; set; }              // EMS_Transaction_gne__c.Cost_Center_gne__r.Name
        public String taxCode { get; set; }                 // EMS_Transaction_gne__c.Tax_Code_gne__c - Line item tax code. Required for direct invoice
        public String taxJurisdiction { get; private set; }
        public String eventName { get; private set; }
        public String wbsElement { get; private set; }

        private EMS_Speaker_Role_gne__c paymentRequest { get; set; }

        TransactionWrapper(EMS_Transaction_gne__c transactionRecord, PaymentInfo paymentInfo, Map<Id, String> taxCodes) {
            paymentRequest = transactionRecord.EMS_Speaker_Role_gne__r;

            itemPrice = String.valueOf(transactionRecord.Fee_Amount_gne__c);
            costCenter = transactionRecord.Cost_Center_gne__r.Name;
            accountNumber = transactionRecord.Cost_Element_gne__c.trim();

            // Cost element is expected to be numeric value.
            if (!accountNumber.isNumeric() && accountNumber.containsIgnoreCase('PST')) {
                // Tax entries might be 6% PST or 7% PST or 8% PST or etc
                // In such case take selected Cost Element value and first Cost Center
                accountNumber = transactionRecord.Parent_Transaction_gne__r.Cost_Element_gne__c.trim();
                costCenter = paymentInfo.costCenter;
            }

            taxCode = (taxCodes.containsKey(transactionRecord.Parent_Transaction_gne__c)) ? taxCodes.get(transactionRecord.Parent_Transaction_gne__c) : '';
            taxCode = taxCode.left(2);

            wbsElement = transactionRecord.WBS_Code__c;
            if(String.isBlank(wbsElement) && String.isNotBlank(transactionRecord.Parent_Transaction_gne__c)) {
                wbsElement = transactionRecord.Parent_Transaction_gne__r.WBS_Code__c;
            }

            eventName = paymentRequest.EMS_Event_gne__r.Name;
            taxJurisdiction = '7001512401';
        }

        private String getValue(Object valueParam) {
            return EMS_Ariba_Payment_Queue_Export_Ctrl.getValue(valueParam);
        }

        public String toSimpleBuyLine() {
            List<String> line = new List<String>{
                    /* A  */ getLineType(),                  // HEADER
                    /* B  */ getLineType(),                  // D/C INDICATOR
                    /* C  */ getValue(''),                   // PO/CONTACT LINE NUMBER
                    /* D  */ getValue(''),                   // QUANTITY
                    /* E  */ getValue(''),                   // UNIT OF MEASURE
                    /* F  */ getValue(itemPrice),            // TOTAL AMOUNT
                    /* G  */ getValue(taxCode),              // TAX CODE
                    /* H  */ getValue(accountNumber),        // GENERAL LEDGER
                    /* I  */ getValue(costCenter),           // COST CENTER
                    /* J  */ getValue(''),                   // INTERNAL ORDER
                    /* K  */ getValue(wbsElement),           // WBS ELEMENT
                    /* L  */ getValue(''),                   // ASSET
                    /* M  */ getValue(''),                   // SUB NUMBER
                    /* N  */ getValue(''),                   // PROFIT CENTER
                    /* O  */ getValue(taxJurisdiction),      // TAX JURISDICTION CODE
                    /* P  */ getValue(''),                   // BUSINESS AREA
                    /* Q  */ getValue(eventName),            // ASSIGNMENT
                    /* R  */ getValue(''),                   // ITEM TEXT
                    /* S  */ getValue(''),                   // PERNELL NO
                    /* T  */ getValue(''),                   // VALUE DATE
                    /* U  */ getValue(''),                   // ENTRY SHEET NUMBER
                    /* V  */ getValue(''),                   // LINE NUMBER
                    /* W  */ getValue(''),                   // DOCUMENT NO OF A REFERENCE DOCUMENT
                    /* X  */ getValue(''),                   // FISCAL YEAR OF CURRENT PERIOD
                    /* Y  */ getValue(''),                   // ITEM OF A REFERENCE DOCUMENT
                    /* Z  */ getValue(''),                   // PADDING
                    /* AA */ getValue(''),                   // PADDING
                    /* AB */ getValue('')                    // PADDING
            };

            return String.join(line, separator) + '\r\n';
        }
    }

    public class PaymentInfo {
        String eventID { get; set; }
        String paymentID { get; set; }
        Map<String, Decimal> constCenterToPercentage { get; set; }
        Map<String, Decimal> transGroupIDToTaxAmount { get; set; }
        Map<String, Integer> transGroupIDToTransactionCount { get; set; }

        public List<String> costCenterList {
            get {
                return new List<String>(constCenterToPercentage.keySet());
            }
        }

        public String costCenter {
            get {
                if (String.isBlank(costCenter)) {
                    costCenter = costCenterList[0];
                }
                return costCenter;
            }
            private set;
        }

        PaymentInfo(String paymentID, String eventID) {
            this.eventID = eventID;
            this.paymentID = paymentID;
            this.constCenterToPercentage = new Map<String, Decimal>();
            this.transGroupIDToTaxAmount = new Map<String, Decimal>();
            this.transGroupIDToTransactionCount = new Map<String, Integer>();
        }

        PaymentInfo(String eventID) {
            this.eventID = eventID;
            this.constCenterToPercentage = new Map<String, Decimal>();
            this.transGroupIDToTaxAmount = new Map<String, Decimal>();
            this.transGroupIDToTransactionCount = new Map<String, Integer>();
        }
    }
}