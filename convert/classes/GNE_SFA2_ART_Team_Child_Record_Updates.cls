/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-09-17
*  Description: This is a helper class for handling ART Team child record updates
*  Test class: GNE_SFA2_ART_Team_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_ART_Team_Child_Record_Updates {
    
    private static void deleteShares(List<ART_Team_gne__c> triggerOld) {
        Set<Id> artSiteIds = new Set<Id>();
        Set<Id> teamMemberIds = new Set<Id>();
        for (ART_Team_gne__c artTeam : triggerOld) {    
            artSiteIds.add(artTeam.ART_Site_gne__c);
            teamMemberIds.add(artTeam.Team_Member_gne__c);
        }
        //Query for ART_Site_gne__Share records matching the ART_Site_gne__Share criteria 
        List<ART_Site_gne__Share> artSiteSharesToDelete = new List<ART_Site_gne__Share>([select Id from ART_Site_gne__Share where ParentId in :artSiteIds and UserOrGroupId in :teamMemberIds]);
        try {
            delete artSiteSharesToDelete;
        }
        catch (DMLException e){
            system.debug('An Exception in DELETE CASE has occured: '+e);     
        }
    }
    
    private static void addShares(List<ART_Team_gne__c> triggerNew) {
        List<ART_Site_gne__Share> sharesToInsert = new List<ART_Site_gne__Share>();
        
        for (ART_Team_gne__c artTeam : triggerNew) {  
            ART_Site_gne__Share artShare = new ART_Site_gne__Share();
            artShare.AccessLevel = 'Edit';
            artShare.ParentId = artTeam.ART_Site_gne__c;
            artShare.UserOrGroupId = artTeam.Team_Member_gne__c;
            sharesToInsert.add(artShare);
        }
        try {        
            insert sharesToInsert;
        }
        catch (DMLException e){
            system.debug('An Exception in INSERT CASE has occured: '+e);     
        }        
    }
    
    public static void onAfterInsert(List<ART_Team_gne__c> triggerNew) {
        addShares(triggerNew);
    }
    
    public static void onAfterDelete(List<ART_Team_gne__c> triggerOld) {
        deleteShares(triggerOld);
    }
}