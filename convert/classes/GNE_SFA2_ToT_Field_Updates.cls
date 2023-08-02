/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-04
*  Description: This is a trigger for handling Time Off Territory child record updates
*  Test class: GNE_SFA2_Time_Off_Territory_Trigger_Test
*
*  Modification History
*  Date        Name        Description
*
*************************************************************/
public without sharing class GNE_SFA2_ToT_Field_Updates {

    private static void updateTerritoryField(List<Time_Off_Territory_gne__c> triggerNew) {
        List<Id> ownerIds = new List<Id> ();
        Map <String, List <String>> userToTerritories = new Map <String, List <String>>();

        for(Time_Off_Territory_gne__c timeOffTerritory : triggerNew) {
            ownerIds.add(timeOffTerritory.OwnerId);
        }

        List<Id> territoryIds = new List<Id> ();
        for(UserTerritory2Association userTerr :  [ SELECT Territory2Id,UserId FROM UserTerritory2Association WHERE UserId IN :ownerIds ]) {
            territoryIds.add(userTerr.Territory2Id);
        }
        Map<Id, Territory2> territoryMap = new Map<Id, Territory2> ([SELECT Id, Name FROM Territory2 WHERE Id IN :territoryIds]);
        for(UserTerritory2Association userTerr :  [ SELECT Territory2Id,UserId FROM UserTerritory2Association WHERE UserId IN :ownerIds ]) {
            List <String> userTerritory = userToTerritories.get(userTerr.UserId);
            if (userTerritory == null) {
                userTerritory = new List<String>();
            }
            Territory2 terrFromMap = territoryMap.get(userTerr.Territory2Id);
            userTerritory.add(terrFromMap.Name);
            userToTerritories.put(userTerr.UserId, userTerritory);
        }

        for(Time_Off_Territory_gne__c timeOffTerritory : triggerNew) {
            String territoryString = '';
            if (userToTerritories.get(timeOffTerritory.OwnerId) != null) {
                for (String terrName : userToTerritories.get(timeOffTerritory.OwnerId)) {
                    territoryString += terrName + '';
                }
            }
            timeOffTerritory.Territory_gne__c = territoryString;
        }
    }

    public static void onAfterInsertUpdate(List<Time_Off_Territory_gne__c> triggerOld, List<Time_Off_Territory_gne__c> triggerNew) {
        updateTerritoryField(triggerNew);
    }
}