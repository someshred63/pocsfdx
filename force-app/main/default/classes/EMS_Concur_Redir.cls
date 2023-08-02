public without sharing class EMS_Concur_Redir {
    public EMS_Concur_Redir() {

    }

    public PageReference redirect() {
        String expenseType;
        String expkey;
        String transactionamount;

        String itemURL = ApexPages.currentPage().getParameters().get('itemurl');

        if (itemURL == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No parameters passed.'));
            return null;
        }

        String reportId = itemURL.substringBetween('/report/', '/entry/');
        String entryId = itemURL.substringAfterLast('/entry/');

        // do a callout to get expense type
        EMS_Concur_Util.ConcurWebserviceResponse response = EMS_Concur_Webservice.getExpense(reportId, entryId);

        // parse response
        if (response.statusCode != 200) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while fetching expense details.'));
            return null;
        }

        Dom.Document doc = new Dom.Document();
        doc.load(response.body);
        Dom.XMLNode root = doc.getRootElement();

        // parse details
        expenseType = root.getChildElement('ExpenseName', 'http://www.concursolutions.com/api/expense/expensereport/2011/03').getText().trim();
        expkey = root.getChildElement('ExpenseKey', 'http://www.concursolutions.com/api/expense/expensereport/2011/03').getText().trim();
        transactionamount = root.getChildElement('TransactionAmount', 'http://www.concursolutions.com/api/expense/expensereport/2011/03').getText().trim();

        // read config
        Map<String, String> mappings = new Map<String, String>();
        for (EMS_Concur_Expense_Type_Mapping_gne__c mapping : [SELECT Expense_Type_gne__c, Page_URL_gne__c FROM EMS_Concur_Expense_Type_Mapping_gne__c]) {
            mappings.put(mapping.Expense_Type_gne__c, mapping.Page_URL_gne__c);
        }

        if (mappings.containsKey(expenseType)) {
            EMS_Concur_Settings_gne__c concurSettings = EMS_Concur_Util.getConcurSettingsForSite();
            PageReference pr = new PageReference(concurSettings.Domain_URL_gne__c + mappings.get(expenseType));
            pr.getParameters().put('expenseType', expenseType);
            pr.getParameters().put('expKey', expkey);
            pr.getParameters().put('transactionAmount', transactionamount);
            pr.getParameters().put('itemUrl', itemURL);
            return pr;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid expense type: >>' + expenseType + '<<'));
            return null;
        }
    }
}