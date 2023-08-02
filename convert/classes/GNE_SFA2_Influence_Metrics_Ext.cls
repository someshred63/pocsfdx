public with sharing class GNE_SFA2_Influence_Metrics_Ext {

    private final Account acct;
    public Influence_Metrics_gne__c targetInfluenceMetrics {get; set;}
    public String targetPhisicianFullName {get; set;}
    public GNE_SFA_Influence_Metrics_Pager pager {get; set;}
    public Boolean toRender {get; set;}    
    
    public GNE_SFA2_Influence_Metrics_Ext(ApexPages.StandardController controller) {
        this.acct = [SELECT Id, IsPersonAccount FROM Account WHERE Id =: ApexPages.currentPage().getParameters().get('Id') LIMIT 1];   
        targetInfluenceMetrics = targetMetrics();
        targetPhisicianFullName = targetFullName();
        Boolean IsTestCase = false; 
        pager = new GNE_SFA_Influence_Metrics_Pager(IsTestCase);
        pager.setDispRows(5);
        pager.accountId = acct.Id;
        pager.loadData();
        toRender = checkDisplay();
    }
    
    private Influence_Metrics_gne__c targetMetrics(){
        List<Influence_Metrics_gne__c> tempInfuleceMetrics = [SELECT Physician_Name_gne__c, Self_Influence_Formula_gne__c, Inbound_Influence_Formula_gne__c, Outbound_Influence_Formula_gne__c, Total_Influence_Formula_gne__c, Target_Physician_gne__r.FirstName, Target_Physician_gne__r.LastName
                               FROM Influence_Metrics_gne__c
                               WHERE Target_Physician_gne__c  = :acct.Id 
                               AND Related_Physician_gne__c = :acct.Id 
                               AND Relationship_Type_gne__c = 'Self'
                               ORDER BY LastModifiedDate DESC LIMIT 1];
                               
        Influence_Metrics_gne__c trgInfMetrics;
        if(tempInfuleceMetrics.size() == 1){
            trgInfMetrics = tempInfuleceMetrics[0];
        } else {
            trgInfMetrics = new Influence_Metrics_gne__c();
        }
        return trgInfMetrics;
    }
    
    private String targetFullName(){    
        String tmpFullName;
        if (targetInfluenceMetrics.Target_Physician_gne__c != null){            
            tmpFullName = 'Target: ' + targetInfluenceMetrics.Target_Physician_gne__r.LastName + ', ' + targetInfluenceMetrics.Target_Physician_gne__r.FirstName;
        } else { 
            tmpFullName = 'Target metrics not available';
        }
        return tmpFullName;
    } 
    
    public PageReference sortPhysicianName(){
        pager.sortList('Physician_Name_gne__c');
        return null;
    }
    
    public PageReference sortMDMID(){
        pager.sortList('Related_Physician_MDMID_gne__c');
        return null;
    }
    
    public PageReference sortPhisicianType(){
        pager.sortList('Relationship_Type_gne__c');
        return null;
    }
    
    public PageReference sortSelfInfluence(){
        pager.sortListBySelfInfluence('Self_Influence_Formula_gne__c');
        pager.changeDispData();
        return null;
    }
    
    public PageReference sortInboundInfluence(){
        pager.sortListByInboundInfluence('Inbound_Influence_Formula_gne__c');
        pager.changeDispData();
        return null;
    }
    
    public PageReference sortOutboundInfluence(){
        pager.sortListByOutboundInfluence('Outbound_Influence_Formula_gne__c');
        pager.changeDispData();
        return null;
    }
    
    public PageReference sortTotalInfluence(){
        pager.sortListByTotalInfluence('Total_Influence_Formula_gne__c');
        pager.changeDispData();
        return null;
    }
    
    public PageReference goToAccount(){
        String physicianId = System.currentPageReference().getParameters().get('pi_id');
        PageReference goToAccount = new PageReference('/'+physicianId);
        goToAccount.setRedirect(true);
        return goToAccount;
    }

    private Boolean checkDisplay(){
        List<Influence_Metrics_gne__c> tmpMetrics = [Select Id From Influence_Metrics_gne__c Where Target_Physician_gne__c =: acct.Id];
        return tmpMetrics.size() >0;
    }
}