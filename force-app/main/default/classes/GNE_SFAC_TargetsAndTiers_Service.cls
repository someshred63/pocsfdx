public class GNE_SFAC_TargetsAndTiers_Service {

     public static List<String> getUserTerritoriesNames(Id uId){

        // Get user territories
        List<UserTerritory2Association> userTerritories = [Select u.Id,u.Territory2Id
                                               from UserTerritory2Association u
                                               where u.userid = :uId];

        List<ID> terrIds = new List<ID>();

        for(UserTerritory2Association terrId :userTerritories) {
            terrIds.add(terrId.Territory2Id);
        }

        // Get territory detail
        List<Territory2> accountTerritories = [Select t.Id, t.Name, t.Territory_Number_gne__c
                                              from Territory2 t
                                              where t.id in :terrIds];

        List<String> territoryLevelTerrNames = new List<String>();
        for(Territory2 terrId :accountTerritories) {
            territoryLevelTerrNames.add(terrId.Name);
        }

        return territoryLevelTerrNames;

    }

    public static Set<String> getAllAccountSharedTerritories(Id accountId){
        Set<String> accountSharedTerritories = new Set<String>();

        //Get userOrGroupIds list from AccountShare
        List<AccountShare> accountShareList = [SELECT
                                                    AccountId,
                                                    Id,
                                                    RowCause,
                                                    UserOrGroupId
                                                FROM AccountShare
                                                WHERE AccountId = :accountId
                                                AND RowCause IN ('Territory2AssociationManual','Territory')];
        Set<Id> userOrGroupIds = new Set<Id>();
        for(AccountShare accSher : accountShareList){
            userOrGroupIds.add(accSher.UserOrGroupId);
        }

        //Collect list of Territories name from Group
        List<Group> groupRec = [SELECT Id,
                                       RelatedId,
                                       Type
                                FROM Group
                                WHERE Type = 'Territory'
                                AND Id IN :userOrGroupIds
                           ];

        Set<Id> territoriesIds = new Set<Id>();
        for(Group groupItem : groupRec){
            territoriesIds.add(groupItem.RelatedId);
        }
        List<Territory2> territories = [Select Id, Name
                                       FROM Territory2 WHERE Id IN :territoriesIds];
        for(Territory2 terr : territories){
            accountSharedTerritories.add(terr.Name);
        }

        return accountSharedTerritories;

    }
    /*
    public static List<Targets_and_Tiers_can_gne__c> getTargetsAndTiersByAccount(Id accountId, List<Id> productsIds, List<Id> tsfIds){
        List<Targets_and_Tiers_can_gne__c> tnts = [SELECT id,
                                                        Territory_Field_parent_gne__c,
                                                        Territory_Field_parent_gne__r.Account_vod__c,
                                                        Territory_Field_parent_gne__r.Territory_vod__c,
                                                        My_Target_gne__c,
                                                        Product_Catalog_gne__c,
                                                        Product_Catalog_gne__r.Name,
                                                        Segment_gne__c,
                                                        Target_gne__c,
                                                        Tier_can_gne__c
                                                     FROM Targets_and_Tiers_can_gne__c
                                                     WHERE
                                                        Territory_Field_parent_gne__c in :tsfIds
                                                        AND
                                                        Territory_Field_parent_gne__r.Account_vod__c = :accountId
                                                        AND
                                                        Product_Catalog_gne__c in :productsIds];
        return  tnts;
    }*/

    public static List<Targets_and_Tiers_can_gne__c> getTargetsAndTiersByTerritories(Id accountId, List<Id> productsIds, Set<String> territories){

        List<Targets_and_Tiers_can_gne__c> tnts = [SELECT id,
                                                        Account_can_gne__c,
                                                        Territory_gne__c,
                                                        //Territory_Field_parent_gne__c,
                                                        //Territory_Field_parent_gne__r.Account_vod__c,
                                                        //Territory_Field_parent_gne__r.Territory_vod__c,
                                                        My_Target_gne__c,
                                                        Product_Catalog_gne__c,
                                                        Product_Catalog_gne__r.Name,
                                                        Segment_gne__c,
                                                        Target_gne__c,
                                                        Tier_can_gne__c
                                                     FROM Targets_and_Tiers_can_gne__c
                                                     WHERE
                                                        Territory_gne__c in :territories AND
                                                        Account_can_gne__c = :accountId
                                                        AND Product_Catalog_gne__c in :productsIds
                                                        ORDER BY Product_Catalog_gne__r.Name];
        return  tnts;
    }

    public static List<Id> getProductsIds(Id uId){
         //collect user My setups
         List<My_Setup_Products_vod__c>  mySetupProducts = [Select
                                                                 Id,
                                                                 OwnerId,
                                                                 Product_vod__c,
                                                                 Product_vod__r.id
                                                             From My_Setup_Products_vod__c
                                                             where OwnerId = :uId];

         //prepar list of all user products ids
         Map<Id,Id> productIdsMap = new Map<Id,Id>();
         for(My_Setup_Products_vod__c mySetupProduct : mySetupProducts){
             if(mySetupProduct.Product_vod__r.id != null){
                productIdsMap.put(mySetupProduct.Product_vod__r.id,mySetupProduct.Product_vod__r.id);
             }
         }

         return productIdsMap.values();
    }

    public static List<TSF_vod__c> getTSFs(Id accountId, List<String> territoryLevelTerrNames){

        // Get the Terrritory level Data
        List<TSF_vod__c> tsfsList = [Select t.Id,
                          t.Territory_vod__c,
                          t.Account_vod__c
                   From TSF_vod__c t
                   where t.Account_vod__c = :AccountId
                         and
                         t.Territory_vod__c in :territoryLevelTerrNames];
        return tsfsList;
    }

    public static List<Product_Metrics_vod__c> getAccountBrandAffilationsByProductsIds(Id accountId, List<Id> productsIds){
        System.debug('product Ids'+productsIds);
        List<Product_Metrics_vod__c> brandAffilations = [SELECT id,
                                                                Products_vod__c,
                                                                Products_vod__r.Name,
                                                                Products_vod__r.Id,
                                                                Account_vod__c,
                                                                Account_vod__r.Id,
                                                                Target_can_gne__c,
                                                                Segment_can_gne__c,
                                                                Tier_can_gne__c
                                                         FROM Product_Metrics_vod__c

                                                         WHERE Account_vod__c = :accountId
                                                            AND
                                                              Products_vod__c in :productsIds];
        return  brandAffilations;
    }
    /* TODO: functionality not finished -
    public static void insertBrandAffiliation(String accountId) {

        //1. Get Account territories name
        Set<String> accountTerritories = getAllAccountSharedTerritories(accountId);

        //2. Get list of Product_Ind_To_Terr_gne__c
        List<Product_Ind_To_Terr_gne__c> indToTerrList = [SELECT Product_Indication_Name_gne__c FROM Product_Ind_To_Terr_gne__c
                                                          WHERE Territory_Code_gne__c IN :accountTerritories];
        Set<Id> indtoTerrIds = new Set<Id>();
        for(Product_Ind_To_Terr_gne__c ind : indToTerrList){
            indtoTerrIds.add(Product_Indication_Name_gne__c);
        }

        //3. Check and remove Product_Ind_To_terr which existes
        List<Product_Metrics_vod__c> existsBrandAffiliations = [SELECT Id, Name, Products_Vod__c from Product_Metrics_vod__c
                                             WHERE Products_Vod__c in :indtoTerrIds and Account_vod__c =:AccountId];

        //4. Create list of Brand Affiliation to add and persists it

        //GetTerritoryName
      String terrName = getTerritoryName(Territory2Id);
      String terrCode = GetTerritoryCode(terrName);//terrName.substring(0,3);// This should be determined based on Length of the TerrCode
      List<Product_Metrics_vod__c> brand_Affl_list  = new List<Product_Metrics_vod__c> ();

        for (Product_Ind_To_Terr_gne__c pi : [ select Product_Indication_Name_gne__c from Product_Ind_To_Terr_gne__c
                           where  Territory_Code_gne__c = :terrCode ] ) {
             if (CheckBrandAfflExists(pi.Product_Indication_Name_gne__c,accountId) == false){
             Product_Metrics_vod__c ba = new Product_Metrics_vod__c();
             ba.Account_vod__c = accountId ;
             ba.Products_vod__c = pi.Product_Indication_Name_gne__c ;
             brand_Affl_list.add ( ba );
             System.debug('ProductId: '+ pi.Product_Indication_Name_gne__c);
             isInsert  = true;
        }
        }

   }*/
}