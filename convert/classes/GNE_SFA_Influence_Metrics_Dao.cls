public without sharing class GNE_SFA_Influence_Metrics_Dao extends GNE_Base_Dao
{
    public GNE_SFA_Influence_Metrics_Dao(boolean testCase)
    {
        IsTestCase = testCase; 
    }   
    public List<Influence_Metrics_gne__c> getByPager(GNE_SFA_Influence_Metrics_Pager pager)
    {
        return searchmetrics(pager);
    }
    private List<Influence_Metrics_gne__c> searchmetrics(GNE_SFA_Influence_Metrics_Pager pager)
    {
        String acctId = pager.accountId;
        List<Influence_Metrics_gne__c> influenceMetricsList = new List<Influence_Metrics_gne__c>();
        if(acctId != null)
        {
            influenceMetricsList = [SELECT 
                                        Target_Physician_gne__c,
                                        Related_Physician_gne__c,        
                                        Related_Physician_MDMID_gne__c,                                         
                                        Physician_Name_gne__c,
                                        Physician_Name_UI_gne__c,
                                        Relationship_Type_gne__c, 
                                        Self_Influence_Formula_gne__c,                                        
                                        Inbound_Influence_Formula_gne__c,                                         
                                        Outbound_Influence_Formula_gne__c,  
                                        Total_Influence_Formula_gne__c                                        
                                    FROM 
                                        Influence_Metrics_gne__c                                       
                                    WHERE 
                                        Target_Physician_gne__c =: acctId AND 
                                        Related_Physician_gne__c <> :acctId AND
                                        Relationship_Type_gne__c <> 'Self'
                                    ORDER BY
                                        Physician_Name_gne__c];
        
            Set<String> relatedHCPs = new Set<String>();
            for (Integer i = 0; i < influenceMetricsList.size(); i++) {
                if (influenceMetricsList[i].Related_Physician_gne__c != null) {
                    relatedHCPs.add(influenceMetricsList[i].Related_Physician_gne__c);
                }
            }   
            if (!relatedHCPs.isEmpty()) {
                List<Influence_Metrics_gne__c> targetInfluenceMetricsList = [SELECT 
                                                                                Target_Physician_gne__c,
                                                                                Related_Physician_gne__c,        
                                                                                Related_Physician_MDMID_gne__c,                                         
                                                                                Physician_Name_gne__c,
                                                                                Physician_Name_UI_gne__c,
                                                                                Relationship_Type_gne__c, 
                                                                                Self_Influence_Formula_gne__c,                                                                                
                                                                                Inbound_Influence_Formula_gne__c,                                         
                                                                                Outbound_Influence_Formula_gne__c, 
                                                                                Total_Influence_Formula_gne__c  
                                                                             FROM 
                                                                                Influence_Metrics_gne__c                                       
                                                                             WHERE 
                                                                                Relationship_Type_gne__c = 'Self' AND
                                                                                Target_Physician_gne__c IN :relatedHCPs AND 
                                                                                Related_Physician_gne__c IN :relatedHCPs];
                                                                                
                Map<String, Influence_Metrics_gne__c> targetInfluenceMetricsMap = new Map<String, Influence_Metrics_gne__c>();
                if (targetInfluenceMetricsList.size() > 0) {
                    for (Integer i = 0; i < targetInfluenceMetricsList.size(); i++) 
                        targetInfluenceMetricsMap.put(targetInfluenceMetricsList[i].Target_Physician_gne__c, targetInfluenceMetricsList[i]);
                       
                    for (Integer i = 0; i < influenceMetricsList.size(); i++) {
                        if (targetInfluenceMetricsMap.containsKey(influenceMetricsList[i].Related_Physician_gne__c)) { 
                            targetInfluenceMetricsMap.get(influenceMetricsList[i].Related_Physician_gne__c).Relationship_Type_gne__c =  influenceMetricsList[i].Relationship_Type_gne__c;
                            influenceMetricsList[i] = targetInfluenceMetricsMap.get(influenceMetricsList[i].Related_Physician_gne__c);
                        }
                    }
                }
            }   
        }
            
        return influenceMetricsList;        
    }
}