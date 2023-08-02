/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-04
*  Description: This is a trigger for handling Time Off Territory child record updates
*  Test class: GNE_SFA2_Time_Off_Territory_Trigger_Test
*    
*  Modification History
*  Date        Name               Description
*  2014-01-16  Piotr Przesmycki   Replaced commented code with new one. We used only two users and selected all users from environment (over 31000 records on MIG)
*************************************************************/
public without sharing class GNE_SFA2_ToT_Child_Record_Updates {

    private static void shareTimeOffTerritoryWithManager(List<Time_Off_Territory_gne__c> triggerNew) {
        User currentUser = [SELECT Id, Name, ProfileId, ManagerId, Manager.IsActive, IsActive FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
        
        if(GNE_SFA2_Util.isSFA2User()) {
            
            List<Time_Off_Territory_gne__Share> timeOffTerritorySharesToInsert = new List<Time_Off_Territory_gne__Share>();
            if(currentUser.ManagerId != null && currentUser.Manager.IsActive) {        // user has to have manager specified in order to share a record
                for(Time_Off_Territory_gne__c timeOffTerritory : triggerNew) {
                    Time_Off_Territory_gne__Share totSharing = new Time_Off_Territory_gne__Share();
                    totSharing.AccessLevel = 'Read'; 
                    totSharing.ParentID = timeOffTerritory.Id;
                    totSharing.UserOrGroupId = currentUser.ManagerId;
                    timeOffTerritorySharesToInsert.add(totSharing);
                }
            }   
            insert timeOffTerritorySharesToInsert;
        }
        /*Map<Id, User> allUsers = new Map<Id, User>([SELECT Id, Name, ProfileId, ManagerId, IsActive FROM User]);
        User currentUser = allUsers.get(UserInfo.getUserId());
        
        if(GNE_SFA2_Util.isSFA2User()) {
            
            List<Time_Off_Territory_gne__Share> timeOffTerritorySharesToInsert = new List<Time_Off_Territory_gne__Share>();
        
            for(Time_Off_Territory_gne__c timeOffTerritory : triggerNew) {
                 if(currentUser.ManagerId != null) {        // user has to have manager specified in order to share a record
                    User managerUser = allUsers.get(currentUser.ManagerId);
                    if(managerUser != null && managerUser.IsActive) {
                        Time_Off_Territory_gne__Share totSharing = new Time_Off_Territory_gne__Share();
                        totSharing.AccessLevel = 'Read'; 
                        totSharing.ParentID = timeOffTerritory.Id;
                        totSharing.UserOrGroupId = currentUser.ManagerId;
                        timeOffTerritorySharesToInsert.add(totSharing);
                    }
                 }
            }   
            insert timeOffTerritorySharesToInsert;
        }*/
    }
    
    public static void onAfterInsert(List<Time_Off_Territory_gne__c> triggerNew) {
        shareTimeOffTerritoryWithManager(triggerNew);
    }
}