public with sharing class EMS_Payment_Queue_Manual_Ext extends List_View_Base_Controller {

    public List_View_Base_Controller thisController { get; set; }
    public String selectedId { get; set; }

    private final static Integer TRANSACTION_LIMIT = 10000;
    transient private Map<String, AribaPaymentQueueWrapper> transactionsMap;

    //export to excel fields
    public List<String> fieldAPINames { get; set; }
    public Map<String, String> fieldLabels { get; set; }// fieldAPIName, field header
    public List<EMS_Transaction_gne__c> transList { get; set; }

    public EMS_Payment_Queue_Manual_Ext() {
        super(EMS_Transaction_gne__c.sObjectType.getDescribe().getName());
        thisController = this;
        fetchTransactionsAndFillMap();
    }

    private void fetchTransactionsAndFillMap() {
        List<EMS_Transaction_gne__c> transactions = [
                SELECT Name, Cost_Center_gne__c, Status_gne__c, EMS_Speaker_Role_gne__r.EMS_Event_gne__c, EMS_Speaker_Role_gne__r.Vendor_ID_gne__c,
                        EMS_Speaker_Role_gne__r.Recipient_Vendor_Name_gne__c, EMS_Speaker_Role_gne__c
                FROM EMS_Transaction_gne__c
                LIMIT :TRANSACTION_LIMIT
        ];

        transactionsMap = new Map<String, AribaPaymentQueueWrapper>();
        for (EMS_Transaction_gne__c t : transactions) {
            transactionsMap.put(t.Id, new AribaPaymentQueueWrapper(t));
        }
    }

    public PageReference exportToExcel() {
        if (getSelectedView() != null) {
            PageReference pageRef = new PageReference('/apex/EMS_Payment_Queue_Manual_Export');
            pageRef.setredirect(true);
            pageRef.getParameters().put('selectedViewId', getSelectedView());
            pageRef.getParameters().put('selectedIds', selectedRecordsString);
            return pageRef;
        } else {
            return null;
        }
    }

    public PageReference selectFunction() {
        fetchTransactionsAndFillMap();
        List<EMS_Transaction_gne__c> transactionsToUpdate = new List<EMS_Transaction_gne__c>();
        for (String id : getSelectedRecords()) {
            if (transactionsMap.containsKey(id)) {
                transactionsMap.get(id).trans.Status_gne__c = 'In Progress';
                transactionsToUpdate.add(transactionsMap.get(id).trans);
                transactionsMap.get(id).selected = false;
            }
        }
        if (transactionsToUpdate.size() > 0) {
            try {
                update transactionsToUpdate;
            } catch (DMLException ex) {
                //show error at the page
                return null;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'At least one payment needs to be selected.'));
        }

        return null;
    }

    public PageReference completeFunction() {
        fetchTransactionsAndFillMap();
        List<EMS_Transaction_gne__c> transactionsToUpdate = new List<EMS_Transaction_gne__c>();
        for (String id : getSelectedRecords()) {
            if (transactionsMap.containsKey(id)) {
                transactionsMap.get(id).trans.Status_gne__c = 'Completed';
                transactionsToUpdate.add(transactionsMap.get(id).trans);
                transactionsMap.get(id).selected = false;
            }
        }
        if (transactionsToUpdate.size() > 0) {
            try {
                update transactionsToUpdate;
            } catch (DMLException ex) {
                //show error at the page
                return null;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'At least one payment needs to be selected.'));
        }

        return null;
    }

    public PageReference cancelFunction() {
        fetchTransactionsAndFillMap();
        List<EMS_Transaction_gne__c> transactionsToUpdate = new List<EMS_Transaction_gne__c>();
        for (String id : getSelectedRecords()) {
            if (transactionsMap.containsKey(id)) {
                transactionsMap.get(id).trans.Status_gne__c = 'Cancelled';
                transactionsToUpdate.add(transactionsMap.get(id).trans);
                transactionsMap.get(id).selected = false;
            }
        }
        if (transactionsToUpdate.size() > 0) {
            try {
                update transactionsToUpdate;
            } catch (DMLException ex) {
                //show error at the page
                return null;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'At least one payment needs to be selected.'));
        }

        return null;
    }

    public String getFileName() {
        return 'Transactions_' + Datetime.now().format('M/d/yyyy KK:mm a', UserInfo.getTimeZone().getID());
    }

    public void generateExport() {
        String selectedIds = ApexPages.currentPage().getParameters().get('selectedIds');

        String query = 'SELECT Name, EMS_Event_gne__r.Name, EMS_Speaker_Role_gne__r.Recipient_Vendor_Name_gne__c, EMS_Speaker_Role_gne__r.Vendor_ID_gne__c, Cost_Center_gne__r.Name, Cost_Element_gne__c, ' +
                'EMS_Speaker_Role_gne__r.Requestor_gne__c, EMS_Speaker_Role_gne__r.Approver_gne__c, Disturbance_Fee_gne__c, Fee_Amount_gne__c, HCP_HCO_gne__c, Payment_Date_gne__c, Payment_taxes_gne__c, Payment_Type_gne__c, Product_Indication_gne__c, Status_gne__c, CreatedDate FROM EMS_Transaction_gne__c ';
        if (String.isNotEmpty(selectedIds) && selectedIds != 'all') {
            List<String> selectedIdsLst = selectedIds.split(',');
            query += ' WHERE id IN : selectedIdsLst ';
        }
        transList = Database.query(query);
    }


    public class AribaPaymentQueueWrapper {
        public EMS_Transaction_gne__c trans { get; set; }
        public Boolean selected { get; set; }
        public Boolean completed { get; set; }

        public AribaPaymentQueueWrapper(EMS_Transaction_gne__c trans) {
            this.trans = trans;
            this.selected = false;
            this.completed = (trans.Status_gne__c != null && trans.Status_gne__c == 'Completed') ? true : false;
        }
    }
}



/*  
	private View_Config_gne__c getView(Id viewId){
        return [
        	SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c
            FROM View_Config_gne__c
            WHERE Id =: viewId
        ];
    }

    public void generateExport() {
        
       String selectedIds = ApexPages.currentPage().getParameters().get('selectedIds');
        
       String query = 'SELECT Name, EMS_Event_gne__r.Name, EMS_Speaker_Role_gne__r.Recipient_Vendor_Name_gne__c, EMS_Speaker_Role_gne__r.Vendor_ID_gne__c, Cost_Center_gne__r.Name, Cost_Element_gne__c, ' +
       			'EMS_Speaker_Role_gne__r.Requestor_gne__c, EMS_Speaker_Role_gne__r.Approver_gne__c, Disturbance_Fee_gne__c, Fee_Amount_gne__c, HCP_HCO_gne__c, Payment_Date_gne__c, Payment_taxes_gne__c, Payment_Type_gne__c, Product_Indication_gne__c, Status_gne__c, CreatedDate FROM EMS_Transaction_gne__c ';
       if(String.isNotEmpty(selectedIds) && selectedIds != 'all') {
            List<String> selectedIdsLst = selectedIds.split(',');
       		query += ' WHERE id IN : selectedIdsLst ';
       }
       transList = Database.query(query);
    }
    
    private void fetchHeadersRow(String viewFields){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('EMS_Transaction_gne__c');
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        fieldLabels = new Map<String,String>();
        for(String s : viewFields.split(';')) {
            fieldLabels.put(s, fieldMap.get(s).getDescribe().getLabel());
        }
    }

*/