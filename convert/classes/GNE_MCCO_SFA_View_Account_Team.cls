public class GNE_MCCO_SFA_View_Account_Team {

	public List<User> UserList {get; set;}

    public GNE_MCCO_SFA_View_Account_Team() {

    	List<ID> teamMembers = new List<ID>();
    	List<ID> groupIds = new List<ID>();
    	List<ID> allIds = new List<ID>();

        ID ThisAccount = ApexPages.currentPage().getParameters().get('id'); //SFA2 test: 001Q00000046VMD;

        //Get All AccountShare Records associated to this Account
        Map<ID, AccountShare> Shareq =
        new Map<ID, AccountShare>
        ([Select UserOrGroupId, RowCause from AccountShare
                    	where AccountId =:ThisAccount //]);
                    	//and (RowCause = 'Team' or
                    	//RowCause = 'Territory')]);
                    	and (RowCause = 'Rule' or
                    	RowCause = 'Territory2AssociationManual' or
                    	RowCause = 'TerritoryRule'
                    	)]);


        //Setup List of Ids for AccountTeam Users Group Ids
        for (ACcountShare act_sh : Shareq.values()) {
        	if (act_sh.RowCause == 'Team')
        	 	teamMembers.add(act_sh.UserOrGroupId);
        	else
        	 	groupIds.add(act_sh.UserOrGroupId);
        }

        //Find Users in associated Groups

        //Get All Territory Records associated to those UserOrGroupIds (GroupIds essentially)
        Map<ID, Territory2> TerrList	= new Map<ID, Territory2>
        			([select id from Territory2 where id in (select relatedId from Group where id in :groupIds)]);

        //Get All Users belonging to those territories
        //This will be a list of all the Users assigned to the Territories that the Account is in
        //We will still need to loop through Shareq Map to get those Users associated to the Account via the AccountTeam
        List<UserTerritory2Association> userTerr = new List<UserTerritory2Association>
        			([select UserId from UserTerritory2Association where Territory2Id in :TerrList.KeySet()]);

        //Build Final List of All UserIds
        for (UserTerritory2Association ut_x : userTerr){
        	allIds.add(ut_x.userId);
        }

        allIds.addAll(teamMembers);

        //Query for User information. NOTE: ADD APPROPRIATE FIELDS HERE TO MAKE GROUPINGS IN VF
        userList = new List<User>([select id, Name, Email, Business_Role_gne__c, gne_Team_frm_gne__c, Brand_Name_gne__c
        						 from User
        						 where id in :allIds and gne_Team_frm_gne__c != 'Other' order by gne_Team_frm_gne__c desc ]);
 								 //where id = '00570000001B2Do']); test query with a user
    }


}