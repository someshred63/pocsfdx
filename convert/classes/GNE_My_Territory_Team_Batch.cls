public class GNE_My_Territory_Team_Batch implements Database.Batchable<sObject>, Database.Stateful {
    private static final String CLASS_NAME = 'GNE_My_Territory_Team_Batch';
    private DateTime lastCompletedBatchStarted;
    private Boolean allTerritory = false;
    private Map<String, TerritoryHolder> territoriesHolder = new Map<String, TerritoryHolder> ();
    private Map<String, My_Territory_Team_gne__c> toDelete = new Map<String, My_Territory_Team_gne__c>();
    private Set<String> terrNumbersFromPrevBatch;
    private Boolean runedForRoster;
    private GNE_My_Territory_Team_Batch_Helper.BatchStatistic batchStatistic;
    private GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics;
    private String territoryForProcess;
    private Set<String>teritoriesToExecute;
    private BatchJobObject batchJob;
    private Boolean initialized;

    public GNE_My_Territory_Team_Batch(
        Set<String>teritoriesToExecute
    ){
        this.teritoriesToExecute = teritoriesToExecute;
    }

    public GNE_My_Territory_Team_Batch(
        Set<String>teritoriesToExecute,
        GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics,
        Integer prevBatchOrder,
        DateTime lastCompletedBatchStarted,
        Boolean runedForRoster
    ) {
        this(teritoriesToExecute);
        this.batchStatistic = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic(CLASS_NAME, prevBatchOrder);
        this.statistics = statistics;
        this.runedForRoster = runedForRoster;
        this.lastCompletedBatchStarted = lastCompletedBatchStarted;
    }

    public GNE_My_Territory_Team_Batch(
        Set<String>teritoriesToExecute,
        GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics,
        Integer prevBatchOrder,
        DateTime lastCompletedBatchStarted
    ) {
        this(teritoriesToExecute, statistics, prevBatchOrder, lastCompletedBatchStarted, false);
    }

    public GNE_My_Territory_Team_Batch(
        Set<String>teritoriesToExecute,
        GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics,
        Integer prevBatchOrder
    ) {
        this(teritoriesToExecute, statistics, prevBatchOrder, null, false);
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        if(initialized != true){
            if(statistics == null ) statistics = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic[]{};
            if(batchStatistic == null ) batchStatistic = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic(CLASS_NAME);
            if(lastCompletedBatchStarted == null) {
                initBatch(teritoriesToExecute, batchStatistic, statistics, runedForRoster);
            } else {
                initBatch(teritoriesToExecute, batchStatistic, statistics, lastCompletedBatchStarted, runedForRoster);
            }
        }

        List<String> temList = new List<String>(teritoriesToExecute);
        territoryForProcess = temList.isEmpty() ? 'fake_number_xxxxxx' : temList[0];

        String query = 'SELECT Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Number_gne__c, Zip_Code_gne__c '+
            'FROM Zip_to_Territory_gne__c '+
            'WHERE Territory_Number_gne__c = : territoryForProcess';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Zip_to_Territory_gne__c> scope) {
        Map<String, My_Territory_Team_gne__c> toUpsert = runProcess(scope);

        if(!toUpsert.isEmpty()){
            upsert toUpsert.values();
        }
        batchJob.updateStat(territoryForProcess);
        batchJob.updateQueryRowsException(getQueryRows(), territoryForProcess);
    }

    public void finish(Database.BatchableContext BC){
        batchJob.removeFromQueue(territoryForProcess);
        if(!toDelete.isEmpty()){
            batchJob.updateStatDeleted(toDelete.size());
            delete toDelete.values();
        }

        if(isSomethingToProcess()){
            batchJob.updateTimeExecuted();
            batchJob.executeNextBatch(teritoriesToExecute);
        } else if(batchJob.isDeltaMode() && !batchJob.runedForRoster() && isRosterChangeDetected()) {
            batchJob.markStatFinished();
            batchJob.addStatistics();
            GNE_My_Territory_Team_Batch batch = new GNE_My_Territory_Team_Batch(fetchAffectedTerritoriesByRoster(), batchJob.getStatistics(), batchJob.getOrder(), lastCompletedBatchStarted, true);
            Database.executeBatch(batch, 2000);
        } else {
            batchJob.markStatFinished();
            batchJob.addStatistics();
            GNE_MY_Territory_Team_CleanUp_Batch cleanBatch;
            if(batchJob.isDeltaMode()){
                cleanBatch = new GNE_MY_Territory_Team_CleanUp_Batch(batchJob.getStatistics(), batchJob.getOrder());
            } else {
                cleanBatch = new GNE_MY_Territory_Team_CleanUp_Batch(batchJob.getStatistics(), batchJob.getOrder(), true);
            }
            Database.executeBatch(cleanBatch);
        }
    }

    public Id executeBatch(){
        Id result = null;
        if(this.initialized != true){
            if(lastCompletedBatchStarted == null) {
                initBatch(teritoriesToExecute, batchStatistic, statistics, runedForRoster);
            } else {
                initBatch(teritoriesToExecute, batchStatistic, statistics, lastCompletedBatchStarted, runedForRoster);
            }
        }
        result = Database.executeBatch(this, 2000);
        initialized = true;
        return result;
    }

    private Boolean isSomethingToProcess() {
        return batchJob.getQueueSize() > 0;
    }

    private void initBatch(
        Set<String>teritoriesNumbers,
        GNE_My_Territory_Team_Batch_Helper.BatchStatistic batchStatistic,
        GNE_My_Territory_Team_Batch_Helper.BatchStatistic [] statistics,
        DateTime lastCompletedBatchStarted,
        Boolean runedForRoster
    ){
        batchJob = new BatchJobObject(teritoriesNumbers, batchStatistic, statistics, lastCompletedBatchStarted, runedForRoster);
    }

    private void initBatch(
        Set<String>teritoriesNumbers,
        GNE_My_Territory_Team_Batch_Helper.BatchStatistic batchStatistic,
        GNE_My_Territory_Team_Batch_Helper.BatchStatistic [] statistics,
        Boolean runedForRoster
    ){
        initBatch(teritoriesNumbers, batchStatistic, statistics, null, runedForRoster);
    }

    public void initBatch(BatchJobObject batchJob){
        initialized = true;
        this.batchJob = batchJob;
    }

    @testVisible
    private Map<String, My_Territory_Team_gne__c> runProcess(List<Zip_to_Territory_gne__c> scope) {
        Map<String, My_Territory_Team_gne__c> toUpsert = new Map<String, My_Territory_Team_gne__c>();
        Map<String, Set<String>> zipsFromScope = fetchZipsFromScope(scope); // terr number 2 zips
        Map<String, My_Territory_Team_gne__c> key2record = new Map<String, My_Territory_Team_gne__c>();
        
        for(My_Territory_Team_gne__c mtt : fetchExistingTeams(zipsFromScope.keySet())){
            String uniqKey = mtt.UserId_gne__c +'_'+mtt.Territory_Number_gne__c;
            key2record.put(uniqKey, mtt);
        }

        Territory2 [] processingTerritories = [
            SELECT Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Number_gne__c
            FROM Territory2
            WHERE Territory_Number_gne__c = : territoryForProcess
                AND (NOT external_id_gne__c LIKE 'INACTIVE TERRITORIES%' )
                AND External_id_gne__c LIKE 'GNE-US%'
                AND Salesforce_Code_gne__c != null
                AND Salesforce_SubTeam_Code_gne__c != null
                LIMIT 1
        ];

        for(Territory2 processingTerritory : processingTerritories){
            String terrNumber = processingTerritory.Territory_Number_gne__c;
            Map<Id,String> prodId2TA = GNE_My_Territory_Team_Batch_Helper.findProducts(new List<Territory2>{processingTerritory});
            TerritoryWrapper tw = createTerritoryWrapper(zipsFromScope.get(terrNumber), terrNumber, prodId2TA.values());

            Territory2 [] territoriesByNumbers = fetchTerritoriesByTerrNumbers(findTerritoriesNumberByZipCodes(zipsFromScope.get(terrNumber)));
            TerritoryHolder terrHolder = fetchTerrHolder(tw);

            Set<Id> medAffairUsersIds = fetchMedAffairsUsers(terrHolder, tw);
            findMedAffairsToRemove(medAffairUsersIds, key2record, terrNumber, terrHolder);
            Map<Id, Set<String>> userIdToTerritoriesIdForUser = fetchUserIdToTerritoriesIdForUser(territoriesByNumbers);//new Map<Id, Set<String>>();

            //process for create records to insert
            User [] usersByZipCodesAndMedAffairUsers = [
                SELECT Id, Name, External_ID_gne__c
                FROM User
                WHERE (Id IN : userIdToTerritoriesIdForUser.keySet()
                    AND isActive = true
                    AND Id IN : findUsersByProducts(prodId2TA.keySet()))
                        OR Id IN : medAffairUsersIds
                LIMIT :getQueryRows()
            ];

            Map<Id, Set<String>> userIdToTerritoriesIdForProcess = mapUserId2TerritoriesId(usersByZipCodesAndMedAffairUsers);//new Map<Id, Set<String>>();

            for(User u : usersByZipCodesAndMedAffairUsers) {
                String uniqKey = u.Id + '_' + processingTerritory.Territory_Number_gne__c;
                if(key2record.get(uniqKey) == null){
                    My_Territory_Team_gne__c myTT = new My_Territory_Team_gne__c(
                        Territory_Number_gne__c = processingTerritory.Territory_Number_gne__c,
                        UserId_gne__c = u.Id,
                        Common_Terriotires_gne__c = userIdToTerritoriesIdForProcess.get(u.Id) != null ? fillCommonTerriotiresField(userIdToTerritoriesIdForProcess.get(u.Id)) : '',
                        is_Med_Affair_gne__c = medAffairUsersIds.contains(u.Id)
                    );
                    toUpsert.put(uniqKey,myTT);
                } else {
                    My_Territory_Team_gne__c myTT = key2record.get(uniqKey);
                    Set<String> currentSet = myTT.Common_Terriotires_gne__c != null ? new Set<String> (myTT.Common_Terriotires_gne__c.split(';')) : new Set<String>();
                    if(medAffairUsersIds.contains(u.Id) && myTT.is_Med_Affair_gne__c != true){
                        myTT.is_Med_Affair_gne__c = true;
                        toUpsert.put(uniqKey,myTT);
                    }
                    if(currentSet.isEmpty() && userIdToTerritoriesIdForProcess.get(u.Id) != null){
                        myTT.Common_Terriotires_gne__c = fillCommonTerriotiresField(userIdToTerritoriesIdForProcess.get(u.Id)) ;
                        toUpsert.put(uniqKey,myTT);
                    } else {
                        Boolean isCorrectSet = true;
                        Set<String> commTerritories = userIdToTerritoriesIdForProcess.get(u.Id) != null ? userIdToTerritoriesIdForProcess.get(u.Id) : new Set<String>();
                        for(String curSet :currentSet){
                            if(!commTerritories.contains(curSet)){
                                isCorrectSet = false;
                            }
                        }
                        for(String commTer :commTerritories){
                            if(!currentSet.contains(commTer)){
                                isCorrectSet = false;
                            }
                        }
                        if(!isCorrectSet){
                            if(userIdToTerritoriesIdForProcess.get(u.Id) != null){
                                myTT.Common_Terriotires_gne__c = fillCommonTerriotiresField(userIdToTerritoriesIdForProcess.get(u.Id));
                                toUpsert.put(uniqKey,myTT);
                            }
                        }
                    }
                }
            }
        }
        return toUpsert;
    }

    private Map<Id, Set<String>> mapUserId2TerritoriesId(User[] usersByZipCodesAndMedAffairUsers) {
        Map<Id, Set<String>> result = new Map<Id, Set<String>>();
        UserTerritory2Association[] uts = [
            SELECT UserId, Territory2Id
            FROM UserTerritory2Association
            WHERE UserId IN : usersByZipCodesAndMedAffairUsers
            LIMIT :getQueryRows()
        ];
        for(UserTerritory2Association ut: uts ){
            Set<String> trrIds;
            if(result.get(ut.UserId) == null){
                trrIds = new Set<String>();
            } else {
                trrIds = result.get(ut.UserId);
            }
            trrIds.add(ut.Territory2Id);
            result.put(ut.UserId, trrIds);
        }

        return result;
    }

    private Map<Id, Set<String>> fetchUserIdToTerritoriesIdForUser(Territory2 [] territoriesByNumbers) {
        Map<Id, Set<String>> result = new Map<Id, Set<String>>();
        UserTerritory2Association[] uts = [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE Territory2Id IN : territoriesByNumbers LIMIT :getQueryRows()];
        for(UserTerritory2Association ut: uts ){
            Set<String> trrIds;
            if(result.get(ut.UserId) == null){
                trrIds = new Set<String>();
            } else {
                trrIds = result.get(ut.UserId);
            }
            trrIds.add(ut.Territory2Id);
            result.put(ut.UserId, trrIds);
        }
        return result;
    }

    @testVisible
    private Set<String> fetchAffectedTerritoriesByRoster() {
        Set<String> tas = new Set<String>();
        for(MA_Referral_Roster__c roster :fetchChangedRosters()){
            tas.add(roster.TA__c);
        }
        Set<String> uniqKeysCodeSubCode = new Set<String> ();
        for(Product_vod__History ph : fetchProductCatalogHistory()){
            tas.add(String.valueOf(ph.OldValue));
            tas.add(String.valueOf(ph.NewValue));
        }
        for(Team_Mapping_gne__c tm: fetchTeamMapings(tas)){
            uniqKeysCodeSubCode.add(tm.Salesforce_Code_gne__c+':'+tm.Salesforce_SubTeam_Code_gne__c);
        }
        Set<String> terrNumbers = new Set<String>();
        if(!uniqKeysCodeSubCode.isEmpty()){
            String query = buildQueryForRoster(uniqKeysCodeSubCode);
            for(Territory2 ter : Database.query(query)){
                terrNumbers.add(ter.Territory_Number_gne__c);
            }
        }

        return terrNumbers;
    }

    private String buildQueryForRoster(Set<String> uniqKeysCodeSubCode) {
        String terrQuery = 'SELECT Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Number_gne__c, external_id_gne__c '+
            'FROM Territory2 '+
            'WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association ) '+
            '    AND External_id_gne__c LIKE \'GNE-US%\'  '+
            '    AND (NOT external_id_gne__c LIKE \'INACTIVE TERRITORIES-%\') '+
            '    AND Territory_Number_gne__c != null ';
        Boolean isFirst = true;
        String subQuery = ' AND ( ';
        for(String code : uniqKeysCodeSubCode){
            String[]codes = code.split(':');
            if(isFirst){
                isFirst = false;
                subQuery += '(Salesforce_Code_gne__c = \''+codes[0]+'\' AND Salesforce_SubTeam_Code_gne__c = \''+codes[1]+'\') ';
            } else {
                subQuery += ' OR (Salesforce_Code_gne__c = \''+codes[0]+'\' AND Salesforce_SubTeam_Code_gne__c = \''+codes[1]+'\') ';
            }
        }
        subQuery += ' )';
        return terrQuery += subQuery;
   }

    private Team_Mapping_gne__c [] fetchTeamMapings(Set<String> tas) {
        return [
            SELECT Product_gne__c, Product_gne__r.Name, Product_gne__r.Therapeutic_Area_vod__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c
            FROM Team_Mapping_gne__c
            WHERE Salesforce_Code_gne__c != null AND Salesforce_SubTeam_Code_gne__c != null
            AND Product_gne__c IN (SELECT Id FROM Product_vod__c WHERE Therapeutic_Area_vod__c IN : tas)
        ];
    }

    private MA_Referral_Roster__c [] fetchChangedRosters() {
        return [
            SELECT State__c, TA__c, User__c
            FROM MA_Referral_Roster__c
            WHERE  Is_Active__c = true  AND Is_Active_User__c = true AND User__c != null AND State__c != null AND TA__c != null
                AND LastModifiedDate > :batchJob.getDeltaTime()
        ];
    }

    private Product_vod__History [] fetchProductCatalogHistory() {
        return [
            SELECT OldValue, NewValue
            FROM Product_vod__History
            WHERE Field = 'Therapeutic_Area_vod__c'
                AND CreatedDate > :batchJob.getDeltaTime()
        ];
    }

    private Boolean isRosterChangeDetected(){
        return !fetchChangedRosters().isEmpty() || !fetchProductCatalogHistory().isEmpty();
    }

    private TerritoryHolder fetchTerrHolder(TerritoryWrapper tw) {
        TerritoryHolder terrHolder = territoriesHolder.get(tw.territoryNumber) == null ? new TerritoryHolder(tw) : territoriesHolder.get(tw.territoryNumber);
        terrHolder.states.addAll(tw.states);
        territoriesHolder.put(tw.territoryNumber, terrHolder);
        return terrHolder;
    }

    private void findMedAffairsToRemove(
        Set<Id> medAffairUsersIds,
        Map<String, My_Territory_Team_gne__c>
        key2record,
        String terrNumber,
        TerritoryHolder terrHolder
    ) {
        for(String  uniqKey : key2record.keySet()){
            My_Territory_Team_gne__c mtt = key2record.get(uniqKey);
            if(mtt.is_Med_Affair_gne__c && mtt.Territory_Number_gne__c == terrNumber){
                String userId = uniqKey.split('_')[0];
                Boolean isRecordToRemove = !terrHolder.medAffairsUserCommonStates.contains(userId) && !terrHolder.medAffairsUserTAs.contains(userId);
                if(isRecordToRemove){
                    toDelete.put(uniqKey, mtt);
                } else {
                    if(toDelete.containsKey(uniqKey)) {
                        toDelete.remove(uniqKey);
                    }
                }
            }
        }
    }

    private Set<Id> fetchMedAffairsUsers(TerritoryHolder terrHolder, TerritoryWrapper tw) {
        Set<Id> userMedAffInTa = new Set<Id>();
        Set<Id> userMedAffInStates = new Set<Id>();
        Set<String> tas = tw.TA;
        Boolean hasCommonState = false;
        for(MA_Referral_Roster__c rr: DataBase.query(prepareQueryForMAReferral(terrHolder))){
            Set<String> rosterStates = new Set<String>();
            if(rr.State__c != null){
                rosterStates.addAll(rr.State__c.split(';'));
            }

            for(String state: rosterStates ){
                if(tw.states.contains(state)){
                    userMedAffInStates.add(rr.User__c);
                    hasCommonState = true;
                } else {
                    userMedAffInTa.add(rr.User__c);
                }
            }
        }

        if(hasCommonState){
            userMedAffInTa = userMedAffInStates;
        }
        terrHolder.updateUsers(userMedAffInTa, hasCommonState);
        return userMedAffInTa;
    }

    private TerritoryWrapper createTerritoryWrapper(Set<String> zips, String terrNumber, List<String> tas){
        TerritoryWrapper tw = new TerritoryWrapper();
        tw.territoryNumber = terrNumber;
        tw.zips = zips;
        tw.states = findStateByZipCodes(tw.zips);
        tw.TA = new Set<String>(tas);
        if(tw.TA.contains(null)) tw.TA.remove(null);
        return tw;
    }

    private Territory2[] fetchTerritoriesByTerrNumbers(Set<String> terrNumbersByZipCodes) {
        return [
            SELECT Id, Name, external_id_gne__c
            FROM Territory2
            WHERE Territory_Number_gne__c IN : terrNumbersByZipCodes
                AND (NOT external_id_gne__c LIKE 'INACTIVE TERRITORIES-%')
        ];
    }

    private My_Territory_Team_gne__c[] fetchExistingTeams(Set<String> terNumbers) {
        return [
            SELECT Territory_Number_gne__c, UserId_gne__c, Common_Terriotires_gne__c, is_Med_Affair_gne__c
            FROM My_Territory_Team_gne__c
            WHERE Territory_Number_gne__c IN : terNumbers
            LIMIT :getQueryRows()
        ];
    }

    private Map<String,Set<String>> fetchZipsFromScope(Zip_to_Territory_gne__c [] scope) {
        Map<String,Set<String>> zipsFromScope = new Map<String,Set<String>> ();
        for(Zip_to_Territory_gne__c  zt: scope){
            Set<String> zips;
            if(zipsFromScope.get(zt.Territory_Number_gne__c) == null){
                zips = new Set<String> ();
            } else {
                zips = zipsFromScope.get(zt.Territory_Number_gne__c);
            }
            zips.add(zt.Zip_Code_gne__c);
            zipsFromScope.put(zt.Territory_Number_gne__c, zips);
        }
        return zipsFromScope;
    }

    private String fillCommonTerriotiresField(Set<String> territories){
        String value = '';
        for(String terId : territories){
            value += terId+';';
        }
        value = value.removeEnd(';');
        return value;
    }

    private String prepareQueryForMAReferral(TerritoryHolder terrHolder) {
        List <String> statesList = new List<String>(terrHolder.states);
        String statesAsString = '\'';
        statesAsString += String.join(statesList,'\',\'');
        statesAsString +='\'';
        return 'SELECT State__c, TA__c, User__c '+
            'FROM MA_Referral_Roster__c  '+
            'WHERE  Is_Active__c = true  AND Is_Active_User__c = true AND User__c != null '+
            'AND (TA__c IN : tas OR (TA__c IN : tas AND State__c INCLUDES ('+ statesAsString +')))';
    }

    private static Map<String, String> fetchSFCodesByTerritory(List<Territory2> terrs){
        Map<String, String> codeMap = new Map<String, String>();
        for(Territory2 tr : terrs){
            codeMap.put(tr.Salesforce_Code_gne__c, tr.Salesforce_SubTeam_Code_gne__c);
        }
        return codeMap;
    }

    private Set<String> findTerritoriesNumberByZipCodes(Set<String> myZips) {
        Set<String> numbers = new Set<String>();
        Integer counterLimit = 0;
    
        for(AggregateResult ar : [
            SELECT Territory_Number_gne__c
            FROM Zip_to_Territory_gne__c 
            WHERE Zip_Code_gne__c IN : myZips
            GROUP BY Territory_Number_gne__c
            LIMIT 2000            
        ]){
            numbers.add(String.valueOf(ar.get('Territory_Number_gne__c')) );
            counterLimit++;
        }
        if(counterLimit == 2000){
            for(AggregateResult ar : [
                SELECT Territory_Number_gne__c 
                FROM Zip_to_Territory_gne__c 
                WHERE Zip_Code_gne__c IN : myZips
                    AND Territory_Number_gne__c NOT IN : numbers
                GROUP BY Territory_Number_gne__c
                LIMIT 2000
            ]){
                numbers.add(String.valueOf(ar.get('Territory_Number_gne__c')) );
                counterLimit++;
            }            
        }
        batchJob.updateAgregateStat(counterLimit, territoryForProcess);
        return numbers;
    }

    private Set<Id>  findUsersByProducts(Set<Id> prodIds) {
        Set<Id> userIds = new Set<Id>();
        for(My_Setup_Products_vod__c msp : [
            SELECT OwnerId FROM My_Setup_Products_vod__c WHERE Product_vod__c IN : prodIds LIMIT :getQueryRows()
        ]){
            userIds.add(msp.OwnerId);
        }

        return userIds;
    }

    private Set<String> findStateByZipCodes(Set<String> myZips){
        Set<String> states = new Set<String>();
        for(AggregateResult ar : [
            SELECT State_gne__c
            FROM USPS_Address_gne__c
            WHERE Zip_gne__c IN : myZips
            GROUP BY State_gne__c
        ]){
            states.add(String.valueOf(ar.get('State_gne__c')) );
        }

        return states;
    }

    private Integer getQueryRows(){
        return Limits.getLimitQueryRows() - Limits.getQueryRows();
    }

    class TerritoryWrapper{
        String territoryNumber;
        Set<String> zips;
        Set<String> states;
        Set<String> TA;
    }

    class TerritoryHolder{
        String territoryNumber;
        Set<String> states;
        Set<Id> medAffairsUserCommonStates;
        Set<Id> medAffairsUserTAs;

        public TerritoryHolder(TerritoryWrapper tw){
            this.territoryNumber = tw.territoryNumber;
            this.states = tw.states;
            medAffairsUserCommonStates = new Set<Id>();
            medAffairsUserTAs = new Set<Id>();
        }

        public void updateUsers(Set<Id> usersId, Boolean isCommonState){
            if(isCommonState){
                medAffairsUserCommonStates.addAll(usersId);
                medAffairsUserTAs.removeAll(medAffairsUserCommonStates);
            } else {
                medAffairsUserTAs.addAll(usersId);
            }
        }
    }

    private class BatchJobObject{
        private Set<String>teritoriesToExecute;
        private GNE_My_Territory_Team_Batch_Helper.BatchStatistic batchStatistic;
        private GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics;
        private Boolean allTerritory = true;
        private DateTime lastCompletedBatchStarted;
        private Boolean runedForRoster = false;

        public BatchJobObject(
            Set<String>teritoriesNumbers,
            GNE_My_Territory_Team_Batch_Helper.BatchStatistic batchStatistic,
            GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics,
            DateTime lastCompletedBatchStarted,
            Boolean runedForRoster
        ) {
            this.teritoriesToExecute = teritoriesNumbers;
            this.batchStatistic = batchStatistic;
            this.statistics = statistics;
            this.runedForRoster = runedForRoster;
            if(lastCompletedBatchStarted != null) updateDeltaStat(lastCompletedBatchStarted);
        }

        public DateTime getDeltaTime(){
            return lastCompletedBatchStarted;
        }

        public Boolean isDeltaMode(){
            return !allTerritory;
        }

        public Boolean runedForRoster() {
            return runedForRoster;
        }

        public void removeFromQueue(String procesedd){
            teritoriesToExecute.remove(procesedd);
        }

        public Integer getQueueSize(){
            return teritoriesToExecute.size();
        }

        public void updateStat(String record) {
            batchStatistic.updateStatistic(record);
        }

        public void updateQueryRowsException(Integer queryRowLimit, String territoryForProcess) {
            if(queryRowLimit < 1){
                batchStatistic.exceptions.add('LimitQueryRows exceeded ['+territoryForProcess+']');
            }
        }

        public void updateTimeExecuted(){
            batchStatistic.timesExecuted++;
        }

        public void updateDeltaStat(DateTime lastCompletedBatchStarted) {
            batchStatistic.setDelta(lastCompletedBatchStarted);
            allTerritory = false;
            this.lastCompletedBatchStarted = lastCompletedBatchStarted;
        }

        public void updateStatDeleted(Integer toDel){
            batchStatistic.deletedRecords += toDel;
        }

        public void markStatFinished() {
            batchStatistic.markFinised();
        }

        public void addStatistics() {
            statistics.add(batchStatistic);
        }
        
        public void updateAgregateStat(Integer counterLimit, String territoryForProcess) {
            batchStatistic.updateLimitsForAggregateResults(counterLimit, territoryForProcess);
        }

        public GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] getStatistics(){
            return this.statistics;
        }

        public Integer getOrder(){
            return this.batchStatistic.orderOfExecute;
        }

        public Id executeNextBatch(Set<String>teritoriesToExecute) {
            GNE_My_Territory_Team_Batch batch = new GNE_My_Territory_Team_Batch(teritoriesToExecute);
            batch.initBatch(this);
            return batch.executeBatch();
        }
    }
}