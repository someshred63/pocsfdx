public without sharing class GNE_SFA_Influence_Metrics_Acc_Display 
{
    private final Account acct;
    public GNE_SFA_Influence_Metrics_Pager pager {get; set;}
    
    public GNE_SFA_Influence_Metrics_Acc_Display(ApexPages.StandardController stdCtrl)
    {
        Boolean IsTestCase = false; 
        this.acct = (Account)stdCtrl.getRecord();
        pager = new GNE_SFA_Influence_Metrics_Pager(IsTestCase);
        pager.setDispRows(5);
        pager.accountId = acct.Id;
        pager.loadData();
    }
    public PageReference sortPhysicianName()
    {
        pager.sortList('Physician_Name_gne__c');
        return null;
    }
    public PageReference sortMDMID()
    {
        pager.sortList('Related_Physician_MDMID_gne__c');
        return null;
    }
    public PageReference sortPhisicianType()
    {
        pager.sortList('Relationship_Type_gne__c');
        return null;
    }
    public PageReference sortSelfInfluence()
    {
        pager.sortListBySelfInfluence('Self_Influence_Formula_gne__c');
        pager.changeDispData();
        return null;
    }
    public PageReference sortInboundInfluence()
    {
        pager.sortListByInboundInfluence('Inbound_Influence_Formula_gne__c');
        pager.changeDispData();
        return null;
    }
    public PageReference sortOutboundInfluence()
    {
        pager.sortListByOutboundInfluence('Outbound_Influence_Formula_gne__c');
        pager.changeDispData();
        return null;
    }
    public PageReference sortTotalInfluence()
    {
        pager.sortListByTotalInfluence('Total_Influence_Formula_gne__c');
        pager.changeDispData();
        return null;
    }
    public PageReference goToAccount()
    {
        String physicianId = System.currentPageReference().getParameters().get('pi_id');
        PageReference goToAccount = new PageReference('/'+physicianId);
        goToAccount.setRedirect(true);
        return goToAccount;
    }
    
}