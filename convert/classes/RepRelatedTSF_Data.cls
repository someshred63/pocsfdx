public class RepRelatedTSF_Data
{
//------------------------------
//
// Description:
//   This controller extension is for editing ref specific territory
//   information in Account detail page. Existing controller is totally
//   rewritten to support multi picklist. Also object fields are refered
//   in vf page instead of inputtext, checkbox and select list
//
//
//
//------------------------------
    private final ApexPages.standardController theController;
    private final Account acc;
    private Id accountId;

    public List <TSF_vod__c> tsfList {get; set;}

    public Boolean CanEdit {get; set;}
    public Boolean isEditRepinfo {get; set;}
    public Integer territory_count {get; set;}
    public Boolean enableEdit {get; set; }

    public RepRelatedTSF_Data(ApexPages.StandardController controller)
    {
        this.acc = (Account)controller.getRecord();
        theController = controller;
        accountId = acc.Id;
        Id uId = UserInfo.getUserId();

        CanEdit = true;
        enableEdit = true;

        // Get user data

        User User_data = [Select id,Profile_Name_gne__c, Open_for_Target_Update_gne__c
                            From User
                            where id = :uId];
        isEditRepinfo = User_data.Open_for_Target_Update_gne__c;

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
        [Select t.Territory_vod__c,t.Zone_gne__c,t.Split_gne__c,
                t.My_Target_vod__c,t.Rival_Speaker_gne__c,
                t.Genentech_Speaker_gne__c,t.My_Frequency_gne__c, t.Id,
                t.Account_vod__c,t.Key_Account_gne__c,
                t.Field_Force_Initiative_gne__c
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