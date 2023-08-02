public class GNE_MY_Territory_Team_CleanUp_Batch implements Database.Batchable<sObject>, Database.Stateful{
    private static final String CLASS_NAME = 'GNE_MY_Territory_Team_CleanUp_Batch';
    private GNE_My_Territory_Team_Batch_Helper.BatchStatistic batchStatistic;
    private GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics;
    private Boolean allTerritory = false;

    public GNE_MY_Territory_Team_CleanUp_Batch(){
        batchStatistic = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic(CLASS_NAME);
        statistics = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic[]{};
    }

    public GNE_MY_Territory_Team_CleanUp_Batch(GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] prevStatistics, Integer prevOrder) {
        batchStatistic = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic(CLASS_NAME, prevOrder);
        batchStatistic.mode = 'ALL RECORDS MODE';
        statistics = prevStatistics;
    }

    public GNE_MY_Territory_Team_CleanUp_Batch(GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] prevStatistics, Integer prevOrder, Boolean allTerritory) {
        batchStatistic = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic(CLASS_NAME, prevOrder);
        batchStatistic.mode = 'ALL RECORDS MODE';
        statistics = prevStatistics;
        this.allTerritory = allTerritory;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Territory_Number_gne__c, UserId_gne__c, isManualAdded_gne__c, Unix_User_Id_gne__c '+
            'FROM My_Territory_Team_gne__c '+
            'WHERE is_Med_Affair_gne__c = false '+
            'ORDER BY Territory_Number_gne__c';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<My_Territory_Team_gne__c> scope) {
        My_Territory_Team_gne__c [] toDelete = new My_Territory_Team_gne__c[]{};

        Map<String, List<My_Territory_Team_gne__c>> territoryNumbers2TerTeams = new Map<String, List<My_Territory_Team_gne__c>>();
        Set<Id> userIds = new Set<Id>();
        Set<String> unixIDs = new Set<String>();
        List<My_Territory_Team_gne__c> mttWithOutReferenceToUser = new List<My_Territory_Team_gne__c>();

        for(My_Territory_Team_gne__c mtt : scope) {
            if(!mtt.isManualAdded_gne__c){
                List<My_Territory_Team_gne__c> myTTs = territoryNumbers2TerTeams.get(mtt.Territory_Number_gne__c) == null ?
                    new List<My_Territory_Team_gne__c>() : territoryNumbers2TerTeams.get(mtt.Territory_Number_gne__c);
                myTTs.add(mtt);
                territoryNumbers2TerTeams.put(mtt.Territory_Number_gne__c, myTTs);
                userIds.add(mtt.UserId_gne__c);
            } else if(mtt.isManualAdded_gne__c && mtt.UserId_gne__c == null) {
                mttWithOutReferenceToUser.add(mtt);
                unixIDs.add(mtt.Unix_User_Id_gne__c);
            }
        }

        TerritoryWrapperHolder territoryHolder = new TerritoryWrapperHolder(territoryNumbers2TerTeams.keySet());
        String query = prepareQueryForTeamMaping(territoryHolder.getTerritories());
        CodeKeyProduct keyProducts = new CodeKeyProduct((Team_Mapping_gne__c[])Database.query(query));

        for(String key : keyProducts.codeKeyToProductIds.keySet()){
            System.debug(key + ' : '+keyProducts.codeKeyToProductIds.get(key));
        }

        territoryHolder.assignProductsToTerritory(keyProducts.codeKeyToProductIds);

        for(TerritoryWrapper terr : territoryHolder.getTerritories()){
            System.debug(terr.terrNumber +' code: '+ terr.codeKey + ' : '+terr.productIds);
        }

        Map<Id, Set<Id>> usersConnectedToProducts = findUsersByProducts(keyProducts.productIds);

        for(TerritoryWrapper terr : territoryHolder.getTerritories()){
            for(My_Territory_Team_gne__c mtt : territoryNumbers2TerTeams.get(terr.terrNumber)){
                //if user from mtt has no product from territory -> mtt delete
                Boolean isUserProductInTerritoryProduct = false;
                if(usersConnectedToProducts.get(mtt.UserId_gne__c) != null){
                    for(Id prodId : usersConnectedToProducts.get(mtt.UserId_gne__c)){
                        if(terr.productIds.contains(prodId) ){
                            isUserProductInTerritoryProduct = true;
                        }
                    }
                }

                if(!isUserProductInTerritoryProduct){
                    toDelete.add(mtt);

                }
            }
        }
        if(!toDelete.isEmpty()) {
            batchStatistic.deletedRecords += toDelete.size();
            Set<My_Territory_Team_gne__c> todelSet = new Set<My_Territory_Team_gne__c>(toDelete);
            delete new List<My_Territory_Team_gne__c>(todelSet);
        }
        //for manual added mtt we check if user and if exist add user Id to UserId_gne__c field
        Map<String, Id> unixId2UserId = new Map<String, Id>();
        for(User u :[
            SELECT Id, External_ID_gne__c FROM User WHERE External_ID_gne__c IN : unixIDs
        ]){
            unixId2UserId.put(u.External_ID_gne__c, u.Id);
        }
        My_Territory_Team_gne__c[] toUpdateUser = new My_Territory_Team_gne__c[]{};
        for(My_Territory_Team_gne__c mtt: mttWithOutReferenceToUser){
            if(unixId2UserId.containsKey(mtt.Unix_User_Id_gne__c)){
                mtt.UserId_gne__c = unixId2UserId.get(mtt.Unix_User_Id_gne__c);
                toUpdateUser.add(mtt);
            }
        }
        if(!toUpdateUser.isEmpty()) update toUpdateUser;

        batchStatistic.updateStatistic();
    }

    public void finish(Database.BatchableContext BC) {
        batchStatistic.markFinised();
        statistics.add(batchStatistic);
        GNE_My_TerritoryTeam_CleanByZip_Batch batch;
        if(allTerritory) {
            batch = new GNE_My_TerritoryTeam_CleanByZip_Batch(statistics, batchStatistic.orderOfExecute, true);
        } else {
            batch = new GNE_My_TerritoryTeam_CleanByZip_Batch(statistics, batchStatistic.orderOfExecute);
        }

        Database.executeBatch(batch, 5);
    }

    private static Map<Id, Set<Id>> findUsersByProducts(Set<Id> prodIds) {
        Map<Id, Set<Id>> userId2Products = new Map<Id, Set<Id>>();
        for(My_Setup_Products_vod__c msp : [
            SELECT OwnerId, Product_vod__c FROM My_Setup_Products_vod__c WHERE Product_vod__c IN : prodIds
        ]){
            Set<Id> productIds = userId2Products.get(msp.OwnerId) == null ? new Set<Id>() : userId2Products.get(msp.OwnerId) ;
            productIds.add(msp.Product_vod__c);
            userId2Products.put(msp.OwnerId, productIds);
        }
        return userId2Products;
    }

    private static String prepareQueryForTeamMaping(List<TerritoryWrapper> terrs){
        String query = 'SELECT Product_gne__c, Product_gne__r.Name, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c '+
                'FROM Team_Mapping_gne__c WHERE (';
        Boolean isFirst = true;
        for(TerritoryWrapper ter : terrs){
            if(isFirst){
                isFirst = false;
                query += '(Salesforce_Code_gne__c = \''+ter.code+'\' AND Salesforce_SubTeam_Code_gne__c = \''+ter.subCode+'\') ';
            } else {
                query += ' OR (Salesforce_Code_gne__c = \''+ter.code+'\' AND Salesforce_SubTeam_Code_gne__c = \''+ter.subCode+'\')';
            }
        }
        query += ') AND Product_gne__r.Brand_Code_gne__c != \'NONE\' ';

        return query;
    }

    class CodeKeyProduct{
        Map<String, List<Id>> codeKeyToProductIds = new Map<String, List<Id>>();
        Set<Id> productIds = new Set<Id>();

        public CodeKeyProduct(List<Team_Mapping_gne__c> teamMappings){
            for(Team_Mapping_gne__c tm : teamMappings){
                List<Id> ids;
                String keyCode = tm.Salesforce_Code_gne__c + '_' + tm.Salesforce_SubTeam_Code_gne__c;
                if(codeKeyToProductIds.get(keyCode) == null){
                    ids = new List<Id>();
                } else {
                    ids = codeKeyToProductIds.get(keyCode);
                }
                ids.add(tm.Product_gne__c);
                codeKeyToProductIds.put(keyCode, Ids);
                productIds.add(tm.Product_gne__c);
            }
        }
    }

    class TerritoryWrapperHolder{
        Map<Id, TerritoryWrapper> territoriesMap = new Map<Id, TerritoryWrapper>();

        public TerritoryWrapperHolder(Set<String> territoryNumbers){
            for(Territory2 t : [
                SELECT Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Number_gne__c
                FROM Territory2
                WHERE Territory_Number_gne__c IN : territoryNumbers
                    AND (NOT external_id_gne__c LIKE 'INACTIVE TERRITORIES%' )
            ]){
                territoriesMap.put(t.Id, new TerritoryWrapper(t));
            }
        }

        public List<TerritoryWrapper> getTerritories(){
            return territoriesMap.values();
        }

        public void assignProductsToTerritory(Map<String, List<Id>> codeKeyToProductIds){
            for(TerritoryWrapper tw :territoriesMap.values()){
                if(codeKeyToProductIds.get(tw.codeKey) != null){
                    tw.productIds = new Set<Id>(codeKeyToProductIds.get(tw.codeKey));
                }
            }
        }
    }

    class TerritoryWrapper{
        Territory2 terr;
        String code;
        String subCode;
        String codeKey;
        String terrNumber;
        Set<Id> productIds;

        public TerritoryWrapper(Territory2 terr){
            this.code = terr.Salesforce_Code_gne__c;
            this.subCode = terr.Salesforce_SubTeam_Code_gne__c;
            this.codeKey = code + '_'+subCode;
            this.terrNumber = terr.Territory_Number_gne__c;
            this.productIds = new Set<Id>();
        }
    }
}