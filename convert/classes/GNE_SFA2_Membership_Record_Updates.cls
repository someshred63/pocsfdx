/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2015-02-11
*  Description: Helper class for GNE_SFA2_Membership_Contacts_Trigger
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_Membership_Record_Updates{
    public static void onAfterInsert(List<Membership_Contracts_gne__c> triggerNewList){
        checkNewContracts(triggerNewList);
    }
    
    public static void onAfterUpdate(Map<Id, Membership_Contracts_gne__c> triggerOldMap, Map<Id, Membership_Contracts_gne__c> triggerNewMap){
        List<Membership_Contracts_gne__c> removedContracts = new List<Membership_Contracts_gne__c>();
        List<Membership_Contracts_gne__c> addedContracts = new List<Membership_Contracts_gne__c>();
        for(Id mcId : triggerOldMap.keySet()){
            if(triggerOldMap.get(mcId).Speaker_Bureau_Membership_gne__c != triggerNewMap.get(mcId).Speaker_Bureau_Membership_gne__c){
                removedContracts.add(triggerOldMap.get(mcId));
                addedContracts.add(triggerNewMap.get(mcId));
            }
        }
        checkNewContracts(addedContracts);
        uncheckContracts(removedContracts);
    }
    
    public static void onAfterDelete(List<Membership_Contracts_gne__c> triggerOldList){
        uncheckContracts(triggerOldList);
    }

    private static void checkNewContracts(List<Membership_Contracts_gne__c> newContracts){
        List<Speaker_Bureau_Membership_gne__c> membershipsToUpdate = [SELECT Id, Is_Contracted_Speaker_gne__c
                                                                      FROM Speaker_Bureau_Membership_gne__c
                                                                      WHERE Id IN :getSpeakerBureauMembershipIds(newContracts) for update];
        for(Speaker_Bureau_Membership_gne__c sbm :membershipsToUpdate){
            sbm.Is_Contracted_Speaker_gne__c = true;
        }
        update membershipsToUpdate;
    }

    private static void uncheckContracts(List<Membership_Contracts_gne__c> removedContracts){
        List<Speaker_Bureau_Membership_gne__c> membershipsToUpdate = new List<Speaker_Bureau_Membership_gne__c>();
        for(Speaker_Bureau_Membership_gne__c sbm :[SELECT Id, Is_Contracted_Speaker_gne__c, (SELECT Id FROM Membership_Contracts__r) 
                                                   FROM Speaker_Bureau_Membership_gne__c 
                                                   WHERE Id IN :getSpeakerBureauMembershipIds(removedContracts) for update]){
            if(sbm.Membership_Contracts__r.size()==0){
                sbm.Is_Contracted_Speaker_gne__c = false;  
                membershipsToUpdate.add(sbm);  
            }
        }
        update membershipsToUpdate;
    }

    private static List<Id> getSpeakerBureauMembershipIds(List<Membership_Contracts_gne__c> contractList){
        Set<Id> speakerBureauMembershipIds = new Set<Id>();
        for(Membership_Contracts_gne__c mc :contractList){
            speakerBureauMembershipIds.add(mc.Speaker_Bureau_Membership_gne__c);
        }
        List<Id> idsList = new List<Id>();
        idsList.addAll(speakerBureauMembershipIds);
        return idsList;
    }
}