/************************************************************
*  @author: Lukasz Bieniawski
*  Date: 2012-01-15
*  This class is used to get the list of users associated to the Account
*  Modification History
*  Date        Name        Description
*************************************************************/

public class GNE_SFA2_MCCO_View_Account_Team {

    public GNE_SFA2_MCCO_View_Account_Team(ApexPages.StandardController controller){
    }

    @RemoteAction
    public static List<User> getViewAccountTeam(String accountId, Boolean forFrm) {
        List<User> userList = new List<User>();

        //Get All AccountShare Records associated to this Account
        Map<ID, AccountShare> listOfAccountShare;
        if (forFrm){
                listOfAccountShare = new Map<ID, AccountShare>([Select UserOrGroupId, RowCause from AccountShare
                where AccountId = :accountId]);
        } else {
                listOfAccountShare = new Map<ID, AccountShare>([Select UserOrGroupId, RowCause from AccountShare
                where AccountId = :accountId and (RowCause = 'Rule' or RowCause = 'Territory2AssociationManual' or RowCause = 'TerritoryRule' or RowCause = 'Team')]);
        }

        if (listOfAccountShare != null && listOfAccountShare.size() > 0){
            //Setup List of Ids for AccountTeam Users Group Ids
            List<ID> teamMembers = new List<ID>();
            List<ID> groupIds = new List<ID>();
            List<ID> allIds = new List<ID>();

            for (AccountShare actShare : listOfAccountShare.values()) {
                if (actShare.RowCause == 'Team') {
                    teamMembers.add(actShare.UserOrGroupId);
                } else {
                    groupIds.add(actShare.UserOrGroupId);
                }
            }

            //Find Users in associated Groups
            //Get All Territory Records associated to those UserOrGroupIds (GroupIds essentially)
            Map<ID, Territory2> listOfTerritories;
            if (forFrm){
                listOfTerritories = new Map<ID, Territory2>([Select id from Territory2
                        where id in (select relatedId from Group where Type = 'Territory' and id in :groupIds)]);
            } else {
                listOfTerritories = new Map<ID, Territory2>([Select id from Territory2
                        where id in (select relatedId from Group where id in :groupIds)]);
            }

            //Get All Users belonging to those territories
            //This will be a list of all the Users assigned to the Territories that the Account is in
            //We will still need to loop through listOfAccountShare to get those Users associated to the Account via the AccountTeam
            if (listOfTerritories != null){
                List<UserTerritory2Association> userTerr = new List<UserTerritory2Association>([Select UserId from UserTerritory2Association where Territory2Id in :listOfTerritories.KeySet()]);

                //Build Final List of All UserIds
                for (UserTerritory2Association userInT : userTerr){
                    allIds.add(userInT.userId);
                }
            }

            allIds.addAll(teamMembers);

            //Query for User information. NOTE: ADD APPROPRIATE FIELDS HERE TO MAKE GROUPINGS IN VF
            userList = new List<User>([select id, Name, Email, Business_Role_gne__c, gne_Team_frm_gne__c, Brand_Name_gne__c
                from User where id in :allIds and gne_Team_frm_gne__c != 'Other' order by gne_Team_frm_gne__c desc ]);
        }

        return userList;
    }
}