public class RepRelatedTSF_Data_Pegasys
{
//------------------------------
// Author:      Nathan
// Date:        08/17/2010
// Description:
//   This controller extension is for editing ref specific territory
//   information in Account detail page for Pegasys
//
// Change History:
//    08/17/2010 Nathan: This is under development
//    09/13/2010 Nathan: Removed enabling edit button logic based on 'Open for Target Update' user flag
//------------------------------
    private final ApexPages.standardController theController;
    private final Account acc;
    private Id accountId;

    public List <TSF_vod__c> tsfList {get; set;}

    public Boolean CanEdit {get; set;}
    public Integer territory_count {get; set;}
    public Boolean enableEdit {get; set; }

    public RepRelatedTSF_Data_Pegasys(ApexPages.StandardController controller)
    {
        this.acc = (Account)controller.getRecord();
        theController = controller;
        accountId = acc.Id;
        Id uId = UserInfo.getUserId();

        CanEdit = true;
        enableEdit = true;

        // Get user data

        User User_data = [Select id,Profile_Name_gne__c
                            From User
                            where id = :uId];

        // Get user territories

        List<UserTerritory2Association> User_Terr =
        [Select u.Id,u.Territory2Id
            from UserTerritory2Association u
            where u.userid = :uId];

        List<ID> TerrIds = new List<ID>();
        for( UserTerritory2Association TerrId :User_Terr )
        {
            TerrIds.add(TerrId.Territory2Id);
        }

        // If the user is DM then include all child territories

        if (User_data.Profile_Name_gne__c.contains('-DM'))
        {
            if (TerrIds.size() > 0)
            {
                List<Territory2> childTerrIds =
                    [Select Id
                    from Territory2
                    where ParentTerritory2Id in :TerrIds];

                for(Territory2 terr : childTerrIds)
                {
                    TerrIds.add(terr.Id);
                }
            }
        }

        // Get territory detail

        List<Territory2> Account_Terr =
        [Select t.Id, t.Name, t.Territory_Number_gne__c
            from Territory2 t
            where t.id in :TerrIds];
        List<String>  TerritoryLevelTerrNames = new List<String>();
        for( Territory2 TerrId :Account_Terr )
        {
            If( TerrId.Territory_Number_gne__c != Null && TerrId.Territory_Number_gne__c.length()==7)
                TerritoryLevelTerrNames.add(TerrId.Name);
        }

        // Get the Terrritory level Data

        tsfList =
        [Select t.Territory_vod__c,
                t.My_Tier_gne__c,
                t.My_Segment_gne__c,
                t.Account_vod__c
            From TSF_vod__c t
            where t.Account_vod__c = :AccountId  and
                t.Territory_vod__c in :TerritoryLevelTerrNames];

        territory_count = tsfList.size();
        if (territory_count > 0)
        {
            enableEdit = true;
        }
        else
        {
            enableEdit = false;
        }
    }

    public PageReference editRatings()
    {
        CanEdit = false ;

        return null;
    }

    public PageReference save()
    {
        update(tsfList);

        CanEdit = true ;
        return null;
    }

    public PageReference cancel()
    {
        CanEdit = true ;
        return null;

    }
}