public with sharing class EMS_SelfInvoice_Ext {
    public SelfInvoice selfInvoiceItem { get; private set; }
    EMS_Speaker_Role_gne__c paymentRequest;
    private Id requestsID;

    public EMS_SelfInvoice_Ext() {
        requestsID = ApexPages.currentPage().getParameters().get('id');
        paymentRequest = [
                SELECT HCP_gne__c, HCP_gne__r.Name, EMS_International_Speaker_gne__c, EMS_International_Speaker_gne__r.Name, Recipient_Vendor_Name_gne__c, Vendor_Address_gne__c, Payment_Date_gne__c, Name, EMS_Event_gne__r.Name,
                        Payment_Terms_gne__c, QST_gne__c, GST_HST_gne__c, Cheque_Printing_Text_gne__c, Total_Amount_gne__c, Self_invoice_generated_at__c, Comment_gne__c
                FROM EMS_Speaker_Role_gne__c
                WHERE Id = :requestsID
        ];
        selfInvoiceItem = new SelfInvoice(paymentRequest);

        List<EMS_Transaction_gne__c> transactions = [
                SELECT Status_gne__c, EMS_Speaker_Role_gne__c, EMS_Speaker_Role_gne__r.Honorarium_gne__c, Name, Cost_Center_gne__c, Payment_taxes_gne__c, Disturbance_Fee_gne__c, Fee_Amount_gne__c, Cost_Element_gne__c,
                        Tax_Code_gne__c, Tax_gne__c, Tax_Amount_gne__c, Parent_Transaction_gne__c, RecordType.DeveloperName, Cheque_Printing_text_gne__c, Line_Number_gne__c, Is_Editable_gne__c
                FROM EMS_Transaction_gne__c
                WHERE EMS_Speaker_Role_gne__c = :requestsID AND Parent_Transaction_gne__c = NULL AND RecordType.DeveloperName = 'Transaction_Group'
                ORDER BY RecordType.DeveloperName DESC, Line_Number_gne__c ASC NULLS LAST, Cost_Element_gne__c ASC NULLS LAST
        ];
        selfInvoiceItem.addTransactions(transactions);
    }

    public class SelfInvoice {
        public Date requestDate { get; private set; }
        public Decimal totalAmount { get; private set; }
        public List<TransactionGroup> transactionGroups { get; private set; }
        public String accountName { get; private set; }
        public String chequeText { get; private set; }
        public String eventName { get; private set; }
        public String GSTHST { get; private set; }
        public String invoiceComment { get; private set; }
        public String paymentRequestName { get; private set; }
        public String paymentTerms { get; private set; }
        public String QST { get; private set; }
        public String vendorAddress { get; private set; }
        public String vendorName { get; private set; }

        public SelfInvoice(EMS_Speaker_Role_gne__c paymentRequest) {
            if(String.isNotBlank(paymentRequest.HCP_gne__c)) {
                this.accountName = paymentRequest.HCP_gne__r.Name;
            } else if (String.isNotBlank(paymentRequest.EMS_International_Speaker_gne__c)) {
                this.accountName = paymentRequest.EMS_International_Speaker_gne__r.Name;
            }

            this.vendorAddress = paymentRequest.Vendor_Address_gne__c;
            this.vendorName = paymentRequest.Recipient_Vendor_Name_gne__c;
            this.requestDate = paymentRequest.Payment_Date_gne__c;
            this.paymentRequestName = paymentRequest.Name;
            this.paymentTerms = paymentRequest.Payment_Terms_gne__c;
            this.eventName = paymentRequest.EMS_Event_gne__r.Name;
            this.totalAmount = paymentRequest.Total_Amount_gne__c;
            this.invoiceComment = paymentRequest.Comment_gne__c;
            this.chequeText = paymentRequest.Cheque_Printing_Text_gne__c;
            this.GSTHST = String.isNotBlank(paymentRequest.GST_HST_gne__c) ? ' GST/HST#: ' + paymentRequest.GST_HST_gne__c : '';
            this.QST = String.isNotBlank(paymentRequest.QST_gne__c) ? ' QST#: ' + paymentRequest.QST_gne__c : '';
            this.transactionGroups = new List<TransactionGroup>();
        }

        public void addTransactions(List<EMS_Transaction_gne__c> transactions) {
            for (EMS_Transaction_gne__c t : transactions) {
                transactionGroups.add(new TransactionGroup(t));
            }
        }
    }

    public class TransactionGroup {
        public EMS_Transaction_gne__c transactionGroup { get; private set; }

        public String groupComment { get; private set; }
        public String groupFeeAmount { get; private set; }
        public String groupTaxAmount { get; private set; }
        public String groupTaxCode { get; private set; }

        TransactionGroup(EMS_Transaction_gne__c transactionGroup) {
            this.transactionGroup = transactionGroup;

            this.groupComment = String.valueOf(transactionGroup.Cheque_Printing_text_gne__c);
            this.groupFeeAmount = String.valueOf(transactionGroup.Fee_Amount_gne__c);
            this.groupTaxAmount = String.valueOf(transactionGroup.Tax_Amount_gne__c);
            this.groupTaxCode = String.valueOf(transactionGroup.Tax_Code_gne__c) + ' ' + String.valueOf(transactionGroup.Tax_gne__c) + '%';
        }
    }
}