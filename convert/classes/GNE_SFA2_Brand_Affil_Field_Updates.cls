/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-09-12
*  Description: This is a class used for handling Brand Affiliation field updates
*  Test class: GNE_SFA2_Brand_Affiliation_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_Brand_Affil_Field_Updates {
    
    public static List<Product_Metrics_vod__c> updateUniqueKey(List<Product_Metrics_vod__c> triggerNew) {
        List<Product_Metrics_vod__c> changedRecs = new List<Product_Metrics_vod__c>();
        
        for(Product_Metrics_vod__c brandAffiliation : triggerNew) {
            String oldValue = String.isNotBlank(brandAffiliation.Unique_Key_gne__c) ? brandAffiliation.Unique_Key_gne__c : '';
            brandAffiliation.Unique_Key_gne__c = brandAffiliation.Unique_Key_Calc_gne__c;
            String newValue = String.isNotBlank(brandAffiliation.Unique_Key_gne__c) ? brandAffiliation.Unique_Key_gne__c : '';
            
            if(!oldValue.equals(newValue)) {
                changedRecs.add(brandAffiliation);
            }
        }
        
        return changedRecs;
    }
    
    private static void updateSpeakerContract(List<Product_Metrics_vod__c> triggerNew) {
        Set<Id> accountIds = new Set<Id>();
        for(Product_Metrics_vod__c brandAffiliation : triggerNew) {
              accountIds.add(brandAffiliation.Account_vod__c);
        }
        
        for(Speaker_Contract_gne__c speakerContract : [ SELECT Id, Contracted_Party_ID__c FROM Speaker_Contract_gne__c WHERE Contracted_Party_ID__c IN :accountIds ]){
            for(Product_Metrics_vod__c brandAffiliation : triggerNew){
                if(brandAffiliation.Account_vod__c == speakerContract.Contracted_Party_ID__c) {
                    brandAffiliation.Speaker_Contract__c = speakerContract.Id ;
                }
            }
        }
    }
    
    public static void onBeforeInsertUpdate(List<Product_Metrics_vod__c> triggerNew) {
        updateUniqueKey(triggerNew);
        updateSpeakerContract(triggerNew);
    }
}