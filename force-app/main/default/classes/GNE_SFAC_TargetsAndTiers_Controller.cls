public class GNE_SFAC_TargetsAndTiers_Controller {

    private Id accountId;
    private Map<String, GroupedByTerritory> groupedByTerritoryMap;
    private DatabaseWithSharingExecutor dbWithSharingExecutor;

    public List<GroupedByTerritory> groupByTerritoryList {
        get { return groupedByTerritoryMap == null ? null : groupedByTerritoryMap.values(); }
        set;
    }

    public String changedTSFvalue { get; set;}

    public GNE_SFAC_TargetsAndTiers_Controller(ApexPages.StandardController controller) {
        this.accountId = controller.getId();
        this.dbWithSharingExecutor = new DatabaseWithSharingExecutor();
    }

    private void onInit(){
        if (this.groupedByTerritoryMap != null && this.groupedByTerritoryMap.size() > 0){
            this.groupedByTerritoryMap.clear();
        }
        this.groupedByTerritoryMap = null;
    }

    public PageReference prepareTSFs(){
        onInit();
        PageReference result = null;
        Id userId = UserInfo.getUserId();

        Set<String> userFilteredTerritories = getUserAccountTerritoriesNames(userId, this.accountId);
        if (userFilteredTerritories.size() == 0){
            return result;
        }

        Set<Id> userProductIds = getUserProductsIds(userId);
        Set<Id> brandAffilationsProductIds = getAccountBrandAffilationsProductsIds(this.accountId, userProductIds);

        this.groupedByTerritoryMap = tntMapping(this.accountId, userProductIds, brandAffilationsProductIds, userFilteredTerritories);

        List<Targets_and_Tiers_can_gne__c> tntToInsert = new List<Targets_and_Tiers_can_gne__c>();
        for (String terr : userFilteredTerritories){
            for (Id prod : userProductIds){
                if (!this.groupedByTerritoryMap.containsKey(terr) || (this.groupedByTerritoryMap.containsKey(terr) && !this.groupedByTerritoryMap.get(terr).allTntsProducts.contains(prod))){
                    tntToInsert.add(
                        new Targets_and_Tiers_can_gne__c(
                            Product_Catalog_gne__c = prod,
                            Account_can_gne__c = this.accountId,
                            Territory_gne__c = terr
                        )
                    );
                }
            }
        }
        if (tntToInsert.size() > 0){
            try {
                insert tntToInsert;
            } catch (Exception e) {
                System.debug('Exception during inserting Targets and Tiers: ' + e);
            } finally {
                this.groupedByTerritoryMap = tntMapping(this.accountId, userProductIds, brandAffilationsProductIds, userFilteredTerritories);
            }
        }
        return result;
    }

    private Map<String,GroupedByTerritory> tntMapping(Id accountId, Set<Id> userProductIds, Set<Id> brandAffilationsProductIds, Set<String> userFilteredTerritories){
        List<Targets_and_Tiers_can_gne__c> tnts = getTargetsAndTiersByTerritories(accountId, userProductIds, userFilteredTerritories);

        Map<String, GroupedByTerritory> groupedByTerrMap = new Map<String, GroupedByTerritory>();
        for(Targets_and_Tiers_can_gne__c tnt : tnts){
            if(!groupedByTerrMap.containsKey(tnt.Territory_gne__c)){
                groupedByTerrMap.put(tnt.Territory_gne__c, new GroupedByTerritory(tnt.Territory_gne__c));
            }

            TargetsAndTiers newTntWrapper = new TargetsAndTiers();
            newTntWrapper.targetAndTier = tnt;
            newTntWrapper.tntId = tnt.id;
            newTntWrapper.productIndication = tnt.Product_Catalog_gne__r.Name;
            newTntWrapper.tier = tnt.Tier_can_gne__c;
            newTntWrapper.myTarget = tnt.My_Target_gne__c;
            newTntWrapper.segment = tnt.Segment_gne__c;
            newTntWrapper.target = tnt.Target_gne__c;
            newTntWrapper.editable = brandAffilationsProductIds.contains(tnt.Product_Catalog_gne__c) ? true : false;

            GroupedByTerritory groupByTerr = groupedByTerrMap.get(tnt.Territory_gne__c);
            groupByTerr.targetsAndTiersList.add(newTntWrapper);
            groupByTerr.allTntsProducts.add(tnt.Product_Catalog_gne__c);
        }

        return groupedByTerrMap;
    }

    public PageReference saveTSFChange(){
        Targets_and_Tiers_can_gne__c changedTnT = null;
        Boolean isFound = false;
        for(GroupedByTerritory groupedByTerritory : this.groupedByTerritoryMap.values()){
            for (TargetsAndTiers tntWrapper : groupedByTerritory.targetsAndTiersList){
                if (tntWrapper.tntId == changedTSFvalue){
                    tntWrapper.confirmChanges();
                    changedTnT = tntWrapper.targetAndTier;
                    isFound = true;
                    break;
                }
            }
            if (isFound == true){
                break;
            }
        }
        if (changedTnT != null){
            update changedTnT;
        }
        return null;
    }

    public List<SelectOption> getMyTarget() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult;
        if(getHasSAMProfile()) {
            fieldResult = Targets_and_Tiers_can_gne__c.SAM_My_Target_gne__c.getDescribe();
        } else if(getHasRAMAProfile()) {
            fieldResult = Targets_and_Tiers_can_gne__c.RAMA_Roche_My_Target_gne__c.getDescribe();
        }
        else {
            fieldResult = Targets_and_Tiers_can_gne__c.My_Target_gne__c.getDescribe();
        }

        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '-None-'));
        for(Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return options;
    }

    //method to indicate whether the logged on user is a Canada SAM user
    public Boolean getHasSAMProfile() {
        String profileName = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        return (profileName != null && profileName.toUpperCase().equals('RCANADA-SFA-SAM')) ? true : false;
    }

    public Boolean getHasRAMAProfile() {
        String profileName = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        return (profileName != null && profileName.toUpperCase().equals('RCANADA-SFA-RAMA')) ? true : false;
    }

    public PageReference refreshTaT() {
        prepareTSFs();
        return null;
    }

    private Set<String> getUserAccountTerritoriesNames(Id userId, Id accountId){
        Set<String> territoriesNames = new Set<String>();

        Set<Id> territoriesIds = new Set<Id>();
        for (Group groupItem : [SELECT RelatedId FROM Group
            WHERE Type = 'Territory'
            AND Id IN (SELECT UserOrGroupId FROM AccountShare WHERE AccountId = :accountId AND RowCause IN ('Territory2AssociationManual','Territory'))
            AND RelatedId In (Select Territory2Id From UserTerritory2Association Where userId = :userId)]){
            territoriesIds.add(groupItem.RelatedId);
        }

        if (territoriesIds.size() == 0){
            return territoriesNames;
        }

        Set<String> territoriesIdsNames = new Set<String>();
        for (Territory2 territory : [Select Name FROM Territory2 WHERE Id IN :territoriesIds]){
            territoriesIdsNames.add(territory.Name);
        }

        for (TSF_vod__c tsf : [SELECT Territory_vod__c FROM TSF_vod__c
            WHERE Account_vod__c = :accountId
            AND Territory_vod__c IN :territoriesIdsNames
            AND External_Id_vod__c != null
            AND Address_vod__c != null]){
            territoriesNames.add(tsf.Territory_vod__c);
        }

        return territoriesNames;
    }

    private List<Targets_and_Tiers_can_gne__c> getTargetsAndTiersByTerritories(Id accountId, Set<Id> productsIds, Set<String> territories){
        return [
            SELECT
                Id,
                Account_can_gne__c,
                Territory_gne__c,
                My_Target_gne__c,
                Product_Catalog_gne__c,
                Product_Catalog_gne__r.Name,
                Segment_gne__c,
                Target_gne__c,
                Tier_can_gne__c
           FROM
                Targets_and_Tiers_can_gne__c
           WHERE
                    Territory_gne__c IN :territories
                AND Account_can_gne__c = :accountId
                AND Product_Catalog_gne__c in :productsIds
           ORDER BY Product_Catalog_gne__r.Name
        ];
    }

    private Set<Id> getUserProductsIds(Id userId){
        Set<Id> userProducts = new Set<Id>();
        String query = String.format('SELECT Id FROM Product_vod__c WHERE Id IN (SELECT Product_vod__c FROM My_Setup_Products_vod__c WHERE OwnerId = \'\'{0}\'\')',
            new String[]{userId}
        );
        for (Product_vod__c userProduct : (List<Product_vod__c>)this.dbWithSharingExecutor.executeQuery(query)){
            userProducts.add(userProduct.Id);
        }
        return userProducts;
    }

    private Set<Id> getAccountBrandAffilationsProductsIds(Id accountId, Set<Id> productsIds){
        Set<Id> productIds = new Set<Id>();
        for (Product_Metrics_vod__c product : [SELECT Products_vod__c FROM Product_Metrics_vod__c WHERE Account_vod__c = :accountId AND Products_vod__c IN :productsIds]){
            productIds.add(product.Products_vod__c);
        }
        return productIds;
    }

    private with sharing class DatabaseWithSharingExecutor {
        public DatabaseWithSharingExecutor(){}
        public List<SObject> executeQuery(String query){
            return Database.query(query);
        }
    }

    private class GroupedByTerritory {
        public String territory { get; private set;}
        public List<TargetsAndTiers> targetsAndTiersList { get; set;}
        public Set<Id> allTntsProducts { get; set; }

        public GroupedByTerritory(String territoryName){
            this.territory = territoryName;
            this.targetsAndTiersList = new List<TargetsAndTiers>();
            this.allTntsProducts = new Set<Id>();
        }
    }

    private class TargetsAndTiers {
        public Id tntId { get; set;}
        public String tier { get; set;}
        public String myTarget { get; set;}
        public String productIndication { get; set;}
        public String segment { get; set;}
        public String target { get; set;}
        public Boolean editable { get; set;}
        public Targets_and_Tiers_can_gne__c targetAndTier { get; set;}

        public void confirmChanges(){
            targetAndTier.My_Target_gne__c = this.myTarget;
            this.setTargetValue();
        }

        private void setTargetValue() {
            targetAndTier.Target_gne__c = this.myTarget;
            this.target = this.myTarget;
        }
    }
}