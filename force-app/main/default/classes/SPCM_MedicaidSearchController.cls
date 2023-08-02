public virtual with sharing class SPCM_MedicaidSearchController extends SPCM_SearchBase {
	
    public List<SPCM_Medicaid_Payment_Packet__c> ResultList {get; set;}

    protected override string GetObjectName()
    {
        return 'SPCM_Medicaid_Payment_Packet__c';
    }

    // returns selectOptions collection with field api name and field name
    protected override List<SelectOption> GetFields()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
        options.add(new SelectOption('Appr_Approver_1__c', 'Actual Approver'));
        options.add(new SelectOption('Approval_Amount__c', 'Approval Amount'));
        options.add(new SelectOption('Name', 'Approval Id'));
        options.add(new SelectOption('Initiated_By__c', 'Initiated By'));
        options.add(new SelectOption('Payment_Due_Date__c', 'Payment Due Date'));
        options.add(new SelectOption('Period__c', 'Period'));
        options.add(new SelectOption('Program__c', 'Program'));
        options.add(new SelectOption('Settlement_Number__c', 'Settlement Number'));
        options.add(new SelectOption('State__c', 'State'));
        options.add(new SelectOption('Year__c', 'Year'));
        
        
        return options;
    }

    public void SubmitSearch()
    {
        ResultList = (List<SPCM_Medicaid_Payment_Packet__c>)Search();
    }

    public PageReference Export()
    {
        return Page.SPCM_Medicaid_search_Download;
    }



}