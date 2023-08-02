public without sharing class GNE_SFA_Target_Influence_Metrics_Display 
{
    private final Account acct;
    private Influence_Metrics_gne__c trgInfMetrics = null;
    private List<Influence_Metrics_gne__c> tempInfuleceMetrics = null;
    public Influence_Metrics_gne__c targetInfluenceMetrics {get; set;}
    public String targetPhisicianFullName {get; set;}
    
    public GNE_SFA_Target_Influence_Metrics_Display(ApexPages.StandardController stdCtrl)
    {
        this.acct = (Account)stdCtrl.getRecord();   
        targetInfluenceMetrics = targetMetrics();
        targetPhisicianFullName = targetFullName();
    }
    private Influence_Metrics_gne__c targetMetrics()
    {
        trgInfMetrics = new Influence_Metrics_gne__c();
        tempInfuleceMetrics = new List<Influence_Metrics_gne__c>();
        tempInfuleceMetrics = [SELECT 
                                Physician_Name_gne__c,
                                Self_Influence_Formula_gne__c,
                                Inbound_Influence_Formula_gne__c,
                                Outbound_Influence_Formula_gne__c,                   
                                Total_Influence_Formula_gne__c,
                                Target_Physician_gne__r.FirstName,
                                Target_Physician_gne__r.LastName
                               FROM
                                Influence_Metrics_gne__c
                               WHERE 
                                Target_Physician_gne__c  = :acct.Id AND 
                                Related_Physician_gne__c = :acct.Id AND
                                Relationship_Type_gne__c = 'Self'
                               ORDER BY
                                LastModifiedDate DESC
                               LIMIT 1];
                               
        if(tempInfuleceMetrics.size() == 1)
        {
            trgInfMetrics = tempInfuleceMetrics[0];
        }
        else
        {
            trgInfMetrics = new Influence_Metrics_gne__c();
        }
        return trgInfMetrics;
    }
    private String targetFullName()
    {    
        String tmpFullName = '';
        if (targetInfluenceMetrics.Target_Physician_gne__c != null)            
            tmpFullName = 'Target: ' + targetInfluenceMetrics.Target_Physician_gne__r.LastName + ', ' + targetInfluenceMetrics.Target_Physician_gne__r.FirstName;
        else 
            tmpFullName = 'Target metrics not available';
        return tmpFullName;
    }    
}