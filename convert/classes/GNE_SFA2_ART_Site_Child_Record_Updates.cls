/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-09-17
*  Description: This is a helper class for handling ART Site child record updates
*  Test class: GNE_SFA2_ART_Site_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_ART_Site_Child_Record_Updates {
    
    public static void addShares(List<ART_Site_gne__c> triggerOld, List<ART_Site_gne__c> triggerNew) {
        List<String> art_site = new List<String>();
    
        Set<Id> sitesWithChangedOwnership = new Set<Id>();
        
        for(Integer i = 0; i < triggerNew.size(); i++){
            if(triggerOld[i].OwnerID != triggerNew[i].OwnerID){
                sitesWithChangedOwnership.add(triggerNew[i].Id);
            }
        }
        
        List<Art_Site_gne__Share> sharesToAdd = new List<Art_Site_gne__Share>();
        for(Art_Team_gne__c team : [ SELECT Id, Team_Member_gne__c, ART_Site_gne__c FROM Art_Team_gne__c WHERE ART_Site_gne__c IN :sitesWithChangedOwnership ]){
            sharesToAdd.add(new Art_Site_gne__Share(AccessLevel = 'Edit', ParentID = team.ART_Site_gne__c, UserOrGroupID = team.Team_Member_gne__c));
        }
        
        insert sharesToAdd;  
    }
    
    public static void onAfterUpdate(List<ART_Site_gne__c> triggerOld, List<ART_Site_gne__c> triggerNew) {
        addShares(triggerOld, triggerNew);
    }
}