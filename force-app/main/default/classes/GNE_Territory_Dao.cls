public with sharing class GNE_Territory_Dao extends GNE_Base_Dao {
//--------------------------------------------------------------------------------
// COMPONENT: Genentech SFA
//     CLASS: GNE_Territory_Dao
//   PURPOSE: Data Access Object for retrieving user territories.
//
//   CREATED: 05/2010
//--------------------------------------------------------------------------------
    public class TerritoryException extends Exception {}

    public List <Territory2> getByUser(String inpId) {
        List<Territory2> ters = new List<Territory2>();
        Territory2 ter;
        List <Territory2> tempList;
        List<UserTerritory2Association> uts = [SELECT u.Territory2Id, u.UserId
                                               FROM UserTerritory2Association u
                                               WHERE u.UserId = :inpId];
        for (UserTerritory2Association ut : uts) {
            try {
                ter = [SELECT t.Id, t.Name
                       FROM Territory2 t
                       WHERE t.Id = :ut.Territory2Id];
            } catch (Exception e) {
                //territory was not found.... this is ok so continue on to next user territory row
                continue;
            }
            //check if we need exclude this row up becuase it is a "parent" territory (ie. division, brand or business unit)
            if (ter != null) {
                tempList = [SELECT t.Id, t.Name
                            FROM Territory2 t
                            WHERE ParentTerritory2Id = :ter.Id];

                if (tempList == null || tempList.size() == 0) {
                    ters.add(ter);
                }
            }
        }
        return ters;
    }

    public Exception alignAccountToTerritory(String acctId, String addrId, String terrId) {
        Group groupRec = [select id from group
                          where relatedId = :terrId
                                            and Type = 'Territory'];

        Territory2 terr = [Select Id, Name
                           from Territory2 t
                           where t.Id = :terrId LIMIT 1];

        if (groupRec != null) {
        	ObjectTerritory2Association territoryAssociation = new ObjectTerritory2Association(ObjectId = acctId, Territory2Id = terr.Id, AssociationCause='Territory2Manual');
            Exception ex = saveSObjectEx(territoryAssociation);
            if (ex ==  null) {
                TSF_vod__c tsf = new TSF_Vod__c();
                tsf.territory_vod__c = terr.Name;
                tsf.My_Target_vod__c = true;
                tsf.Account_vod__c = acctId;
                tsf.Address_vod__c =  addrId;
                return saveSObjectEx(tsf);
            } else {
                return ex;
            }
        }
        return new TerritoryException('Group not found for Territory2 Id =' + terrId);
    }

    public UserTerritory2Association setupTestData() {
        UserTerritory2Association ut = new UserTerritory2Association();
        Territory2 terr = [Select Id, Name from Territory2 limit 1];
        ut.Territory2Id = terr.Id;
        ut.UserId = UserInfo.getUserId();
        saveSObject(ut);
        return ut;
    }
}