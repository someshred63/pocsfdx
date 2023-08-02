/************************************************************
*  @author: Lukasz Kozminski
*  Date: 20/11/2015
*  Description: Assign products to users (MySetup) base on territory. Only users without products already assigned and assigned to only 1 territory are supported.
*
*  Modification History
*  Date         Name        Description
*  08/11/2016   Jaroslaw Laniecki
* 1. Support multiple territories if assigned to the user => the batch should assign additional products to the user in My Setup based on Team_Mapping_gne__c
* 2. Support user vacating a territory => the batch should remove products assigned to the user in My Setup per Team_Mapping_gne__c for the vacated territory/team/subteam
* 2.1 when user has no territory - remove all My Setup
* 2.2 when user has Team Maping for territory - user has to have all products from Team Maping  for territory (if need remove redundant My Setup)
* 2.3 when user has no maping for territory - keep curent assigment in My Setup
* 2.4 when user has Territory with product in Team Maping and other with out product in Team Maping add missing product for Territory 1 and keep curent assigment in My Setup
*************************************************************/

global class ProductAssigmentBatch implements Database.Batchable<sObject>, Database.Stateful {

    Boolean isCanada = false;
    Set<Id> processedMySetups;
    Integer defaultCanadaScope;

    public ProductAssigmentBatch() {

    }

    public ProductAssigmentBatch(Boolean isCanada, Integer defaultCanadaScope) {
        this.isCanada = isCanada;
        this.processedMySetups = new Set<Id>();
        this.defaultCanadaScope = defaultCanadaScope;
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Map<Id, Profile> Id2Proflie = new Map<Id,profile>([
            SELECT Id, UserLicenseId
            FROM Profile
            WHERE UserLicenseId IN (SELECT Id FROM UserLicense WHERE name IN ('Salesforce','Salesforce Platform'))]);
        Set<Id> profileIds = Id2Proflie.keySet();
        String query =
            'SELECT Id, Name '+
            'FROM User '+
            'WHERE isActive = true '+
            '    AND profileId IN : profileIds ';

        if(isCanada) {
            query += 'AND Profile.Name LIKE \'%Canada%\'';
        } else {
            query += 'AND (NOT Profile.Name LIKE \'%Canada%\')';
        }
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<User> scope){
        Map<String, My_Setup_Products_vod__c> toInsert = new Map<String, My_Setup_Products_vod__c>();
        Map<Id, My_Setup_Products_vod__c> toDelete = new Map<Id, My_Setup_Products_vod__c>();

        Map<Id, UserWrapper> userId2Wrapper = new Map<Id, UserWrapper>();
        Map<Id, List<My_Setup_Products_vod__c>> userId2MySetupProducts = new Map<Id, List<My_Setup_Products_vod__c>>();

        Map<Id, Set<Id>>territoryToUsers = fetchTerritoryToUsers(scope);
        Map<Id, Set<Id>> userId2MySetupProductsIds = fetchMySetupProductsIds(scope, userId2MySetupProducts);
        Map<TeamKey, List<Id>>teamToProducts = fetchTeamToProducts();

        prepareDataForProcess(territoryToUsers, teamToProducts, userId2MySetupProducts, toInsert, userId2Wrapper, userId2MySetupProductsIds);
        handleUsersWithOutTerritory(userId2MySetupProducts, userId2Wrapper, scope);
        runDataProcess(userId2Wrapper);
        prepareDataForDML(userId2Wrapper, toDelete);
        runFinishAction(toInsert.values(), toDelete.values());
    }

    global void finish(Database.BatchableContext context){
        if(isCanada) {
            if(processedMySetups != null && !processedMySetups.isEmpty()) {
                Database.executeBatch(new GNE_SFA2_MySetup_ChildRecordUpd_Batch(processedMySetups), defaultCanadaScope);
            }
        }
    }

    private void handleUsersWithOutTerritory(Map<Id, List<My_Setup_Products_vod__c>> userId2MySetupProducts, Map<Id, UserWrapper> userId2Wrapper, List<User> scope){
        for(User us:scope){
            if(userId2Wrapper.get(us.Id) == null){
                List<My_Setup_Products_vod__c> currSetupProd = userId2MySetupProducts.get(us.Id) != null ?
                    userId2MySetupProducts.get(us.Id) : new  List<My_Setup_Products_vod__c>();
                UserWrapper uWrapp = new UserWrapper(us.Id, currSetupProd);
                userId2Wrapper.put(us.Id, uWrapp);
            }
        }
    }

    private void prepareDataForProcess(
        Map<Id, Set<Id>> territoryToUsers,
        Map<TeamKey, List<Id>>teamToProducts,
        Map<Id, List<My_Setup_Products_vod__c>> userId2MySetupProducts,
        Map<String, My_Setup_Products_vod__c>toInsert,
        Map<Id, UserWrapper> userId2Wrapper,
        Map<Id, Set<Id>> userId2MySetupProductsIds
    ){
        Integer i=0;
        for(Territory2 terr: [
            SELECT Id, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c
            FROM Territory2
            WHERE Id IN :territoryToUsers.keySet()
                AND (NOT external_id_gne__c LIKE 'INACTIVE TERRITORIES%')
        ]){
            for(Id userId: territoryToUsers.get(terr.Id)){
                UserWrapper uWrapp = prepareUserWrapper(userId, userId2MySetupProducts, userId2Wrapper);
                TeamKey key = new TeamKey(terr.Salesforce_Code_gne__c, terr.Salesforce_SubTeam_Code_gne__c);
                if(terr.Salesforce_Code_gne__c == null || terr.Salesforce_SubTeam_Code_gne__c == null) {
                    uWrapp.hasUserNullTerritory = true;
                    userId2Wrapper.put(userId, uWrapp);
                    continue;
                }

                List<Id>products = teamToProducts.get(key);
                if(products == null){
                    uWrapp.hasUserNullTerritory = true;
                    userId2Wrapper.put(userId, uWrapp);
                    continue;
                }

                Set<Id> myProductsIds = userId2MySetupProductsIds.get(userId) != null ? userId2MySetupProductsIds.get(userId) : new Set<Id>();
                if(products != null){
                    for(Id prodId: products){
                        if(!myProductsIds.contains(prodId)){
                            toInsert.put(prodId+ '_' + userId, new My_Setup_Products_vod__c(OwnerId = userId, Product_vod__c = prodId));
                            system.debug('New mySetup ' +i++ + ';' + userId + ';' + prodId);
                        }
                    }
                }

                if(products != null){
                    uWrapp.productsBasedOnTeamCodes.addAll(products);
                }
                userId2Wrapper.put(userId, uWrapp);
            }
        }
    }

    private UserWrapper prepareUserWrapper(Id userId, Map<Id, List<My_Setup_Products_vod__c>> userId2MySetupProducts, Map<Id, UserWrapper> userId2Wrapper) {
        UserWrapper uWrapp;
        if(userId2Wrapper.get(userId) == null){
            List<My_Setup_Products_vod__c> currSetupProd = userId2MySetupProducts.get(userId) != null ?
                userId2MySetupProducts.get(userId) : new  List<My_Setup_Products_vod__c>();
            uWrapp = new UserWrapper(userId, currSetupProd);
        } else {
            uWrapp = userId2Wrapper.get(userId);
        }
        return uWrapp;
    }

    private Map<TeamKey, List<Id>> fetchTeamToProducts() {
        Map<TeamKey, List<Id>> teamToProducts = new Map<TeamKey, List<Id>>();
        for(Team_Mapping_gne__c mapping: [SELECT Product_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c FROM Team_Mapping_gne__c]){
            TeamKey tk = new TeamKey(mapping.Salesforce_Code_gne__c, mapping.Salesforce_SubTeam_Code_gne__c);
            if(!teamToProducts.containsKey(tk)){
                teamToProducts.put(tk, new List<Id>());
            }
            teamToProducts.get(tk).add(mapping.Product_gne__c);
        }

        return teamToProducts;
    }

    private Map<Id, Set<Id>>fetchTerritoryToUsers(List<User> scope){
        Map<Id, Set<Id>> territoryToUsers = new Map<Id, Set<Id>>();
        for(UserTerritory2Association ut: [SELECT Territory2Id, UserId FROM UserTerritory2Association WHERE UserId IN :scope]){
            if(!territoryToUsers.containsKey(ut.Territory2Id)){
                territoryToUsers.put(ut.Territory2Id, new Set<Id>());
            }
            territoryToUsers.get(ut.Territory2Id).add(ut.UserId);
        }

        return territoryToUsers;
    }

    private void runDataProcess(Map<Id, UserWrapper> userId2Wrapper) {
        for(UserWrapper uw: userId2Wrapper.values()){
            if(!uw.hasUserNullTerritory){
                uw.setupProductsToDelete = uw.findRecordsToDelete();
            }
        }
    }

    private void prepareDataForDML(Map<Id, UserWrapper> userId2Wrapper, Map<Id, My_Setup_Products_vod__c> toDelete) {
        for(UserWrapper uw: userId2Wrapper.values()){
            if(!uw.hasUserNullTerritory){
                toDelete.putAll(uw.setupProductsToDelete);
            }
        }
    }

    private void runFinishAction(List<My_Setup_Products_vod__c> toInsert , List<My_Setup_Products_vod__c> toDelete) {
        Database.UpsertResult[] insertResults = Database.upsert(toInsert, false);
        Database.DeleteResult[] deleteResults = Database.delete(toDelete, false);
        String errorMessage = collectErrors(insertResults, deleteResults);
        if(String.isNotBlank(errorMessage)) {
            sendEmailNotification(errorMessage);
        }
    }

    private String collectErrors(Database.UpsertResult[] results, Database.DeleteResult[] deleteResults){
        String errorMessage = '';
        for(Database.UpsertResult sr : results) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    String error = 'The following error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage()+'.';
                    System.debug(error);
                    errorMessage += error + '\n';
                }
            }
            if(sr.isSuccess() && isCanada) {
                processedMySetups.add(sr.getId());
            }
        }
        for(Database.DeleteResult sr : deleteResults) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    String error = 'The following error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage()+'.';
                    System.debug(error);
                    errorMessage += error + '\n';
                }
            }
        }
        return errorMessage;
    }

    private void sendEmailNotification(String message){
        if(GNE_Foun_Misc_Config_Items_gne__c.getValues('Batch_FRM_Rep2TerritoryNotifyEmail') == null ||
           String.isBlank(GNE_Foun_Misc_Config_Items_gne__c.getValues('Batch_FRM_Rep2TerritoryNotifyEmail').Configuration_Value_gne__c)
        ) {
            return;
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setPlainTextBody(message);
        email.setSubject('Problem during Auto Assign Product To User at: '+ System.now());
        email.setToAddresses(new List<String>{GNE_Foun_Misc_Config_Items_gne__c.getValues('Batch_FRM_Rep2TerritoryNotifyEmail').Configuration_Value_gne__c});
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        emails.add(email);
        Messaging.sendEmail(emails);
    }

    private Map<Id, Set<Id>> fetchMySetupProductsIds(List<User> scope, Map<Id, List<My_Setup_Products_vod__c>> userId2MySetupProducts) {
        Map<Id, Set<Id>> userId2MySetupProductsIds = new Map<Id, Set<Id>>();
        for(My_Setup_Products_vod__c setProd : [
            SELECT OwnerId, Product_vod__c
            ,Product_vod__r.Name, Owner.Name
            FROM My_Setup_Products_vod__c
            WHERE OwnerId IN : scope
        ]) {
            Set<Id> setupProdsIds = userId2MySetupProductsIds.get(setProd.OwnerId) == null ?
                new Set<Id>() : userId2MySetupProductsIds.get(setProd.OwnerId);
            List<My_Setup_Products_vod__c> mySetup = userId2MySetupProducts.get(setProd.OwnerId) == null ?
                new List<My_Setup_Products_vod__c>() : userId2MySetupProducts.get(setProd.OwnerId);

            setupProdsIds.add(setProd.Product_vod__c);
            userId2MySetupProductsIds.put(setProd.OwnerId, setupProdsIds);
            mySetup.add(setProd);
            userId2MySetupProducts.put(setProd.OwnerId, mySetup);
        }
        return userId2MySetupProductsIds;
    }

    class TeamKey {
        String team;
        String subteam;

        public TeamKey(String teamCode, String subteamCode){
            this.team = teamCode;
            this.subteam = subteamCode;
        }

        public Boolean equals(Object obj) {
            TeamKey compareToKey = (TeamKey)obj;
            return team == compareToKey.team && subteam == compareToKey.subteam;
        }

        public Integer hashCode(){
            return (31 * team.hashCode()) ^ subteam.hashCode();
        }
    }

    class UserWrapper{
        Id userId;
        Map<Id, My_Setup_Products_vod__c> productId2setupProduct = new Map<Id, My_Setup_Products_vod__c>();
        Set<Id> productsBasedOnTeamCodes = new Set<Id>();
        Map<Id, My_Setup_Products_vod__c> setupProductsToDelete = new Map<Id, My_Setup_Products_vod__c>();
        Boolean hasUserNullTerritory = false;

        public UserWrapper(Id userId, List<My_Setup_Products_vod__c> currentSetupProducts){
            this.userId = userId;
            for(My_Setup_Products_vod__c msp:currentSetupProducts){
                productId2setupProduct.put(msp.Product_vod__c, msp);
            }
        }

        private Map<Id, My_Setup_Products_vod__c> findRecordsToDelete(){
            for(Id prodId:productId2setupProduct.keySet()){
                if(!productsBasedOnTeamCodes.contains(prodId)){
                    My_Setup_Products_vod__c msp = productId2setupProduct.get(prodId);
                    setupProductsToDelete.put(msp.Id, msp);
                }
            }

            return setupProductsToDelete;
        }
    }
}