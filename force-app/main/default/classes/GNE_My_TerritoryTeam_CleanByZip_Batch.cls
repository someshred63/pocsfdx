public class GNE_My_TerritoryTeam_CleanByZip_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    private DateTime lastCompletedBatchStarted;
    private Boolean allTerritory = false;
    private Boolean limitException = false;
    private Boolean firstQueryLimitException = false;
    private static final String CLASS_NAME = 'GNE_My_TerritoryTeam_CleanByZip_Batch';
    private GNE_My_Territory_Team_Batch_Helper.BatchStatistic batchStatistic;
    private GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic[]{};

    public GNE_My_TerritoryTeam_CleanByZip_Batch(Boolean allTerritory){
        this.allTerritory = allTerritory;
        batchStatistic = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic(CLASS_NAME);
        GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic[]{};
    }

    public GNE_My_TerritoryTeam_CleanByZip_Batch(
        GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics,
        Integer lastOrder
    ) {
        this(false);
        this.statistics.addAll(statistics);
        batchStatistic = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic(CLASS_NAME, lastOrder);
    }

    public GNE_My_TerritoryTeam_CleanByZip_Batch(
        GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics,
        Integer lastOrder,
        Boolean allTerritory
    ) {
        this(allTerritory);
        this.statistics.addAll(statistics);
        batchStatistic = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic(CLASS_NAME, lastOrder);
    }

    public GNE_My_TerritoryTeam_CleanByZip_Batch(
        Boolean allTerritory,
        Boolean firstQueryLimitException,
        Integer prevBatchOrder,
        GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics
    ) {
        this.allTerritory = allTerritory;
        this.firstQueryLimitException = firstQueryLimitException;
        this.batchStatistic = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic(CLASS_NAME, prevBatchOrder);
        this.statistics = statistics;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(!allTerritory){
            allTerritory = fetchLastBatch().isEmpty();
        }

        Set<String> terrNumbers;
        String whereClauze = 'WHERE is_Med_Affair_gne__c = false AND isManualAdded_gne__c = false ';
        if(!allTerritory){
            terrNumbers = fetchTerrNumbers();
            whereClauze += 'AND Territory_Number_gne__c IN :terrNumbers ';
        }
        String query = 'SELECT Territory_Number_gne__c, UserId_gne__c '+
            'FROM My_Territory_Team_gne__c '+
             whereClauze +
            'ORDER BY Territory_Number_gne__c';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<My_Territory_Team_gne__c> scope) {
        My_Territory_Team_gne__c [] toDelete = new My_Territory_Team_gne__c []{};
        //check is Territory active
        Set<String> terrNumbers = new Set<String>();
        for(My_Territory_Team_gne__c mtt :scope){
            terrNumbers.add(mtt.Territory_Number_gne__c);
        }
        Map<String, Boolean> terNumber2isActive = new Map<String, Boolean>();
        Set<String> activTerritories = new Set<String>();
        for(Territory2 terr : [
            SELECT Territory_Number_gne__c, external_id_gne__c
            FROM Territory2
            WHERE Territory_Number_gne__c IN : terrNumbers
        ]){
            terNumber2isActive.put(terr.Territory_Number_gne__c, true);
            if(terr.external_id_gne__c.startsWith('INACTIVE TERRITORIES') && !activTerritories.contains(terr.Territory_Number_gne__c)){
                terNumber2isActive.put(terr.Territory_Number_gne__c, false);
            } else {
                activTerritories.add(terr.Territory_Number_gne__c);
                terNumber2isActive.put(terr.Territory_Number_gne__c, true);
            }
        }
        //check the MTT for territory has still connection by zip code for territory from MTT
        for(My_Territory_Team_gne__c mtt: scope){
            if(terNumber2isActive.get(mtt.Territory_Number_gne__c) == null || !terNumber2isActive.get(mtt.Territory_Number_gne__c)){
                toDelete.add(mtt);
                continue;
            }
            Boolean hasCommonZip = false;
            for(Territory2 terr : [
                SELECT Territory_Number_gne__c, external_id_gne__c
                FROM Territory2
                WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :mtt.UserId_gne__c)
                    AND (NOT external_id_gne__c LIKE 'INACTIVE TERRITORIES-%')
            ]){
                Set<String> tNumbers = new Set<String>();
                if(mtt.Territory_Number_gne__c == terr.Territory_Number_gne__c){
                    hasCommonZip = true;
                } else {
                    tNumbers.add(mtt.Territory_Number_gne__c);
                    tNumbers.add(terr.Territory_Number_gne__c);
                    hasCommonZip |= ![
                        SELECT Zip_Code_gne__c, COUNT_DISTINCT(Territory_Number_gne__c)
                        FROM Zip_to_Territory_gne__c
                        WHERE  Territory_Number_gne__c IN : tNumbers
                        GROUP BY Zip_Code_gne__c
                        HAVING COUNT_DISTINCT(Territory_Number_gne__c) > 1
                        LIMIT 1
                    ].isEmpty();
                }
            }

            if(!hasCommonZip){
                toDelete.add(mtt);
            }
        }
        batchStatistic.deletedRecords += toDelete.size();
        if(!toDelete.isEmpty()) {
            batchStatistic.deletedRecords += toDelete.size();
            delete toDelete;
        }
        batchStatistic.updateStatistic();
    }

    public void finish(Database.BatchableContext BC) {
        batchStatistic.markFinised();
        statistics.add(batchStatistic);
        if(!Test.isRunningTest()) {
            if(limitException && !firstQueryLimitException ){
                System.debug(' LIMIT EXCEPTION DECTECTED: ');
                GNE_My_TerritoryTeam_CleanByZip_Batch mainBatch = new GNE_My_TerritoryTeam_CleanByZip_Batch(true, true, batchStatistic.orderOfExecute, statistics);
                Database.executeBatch(mainBatch, 5);
            } else {
                GNE_My_Territory_Team_Clean_MedAffairs nextBatch = new GNE_My_Territory_Team_Clean_MedAffairs(statistics, batchStatistic.orderOfExecute);
                Database.executeBatch(nextBatch, 50);
            }
        }
    }

    private Set<String> fetchTerrNumbers() {
        AsyncApexJob [] apexJobs = fetchLastBatch();
        lastCompletedBatchStarted = apexJobs.isEmpty() ? System.now().addDays(-50) : apexJobs[0].CreatedDate;
        Set<String> terrNumbers = new Set<String>();
        batchStatistic.setDelta(lastCompletedBatchStarted);

        for(OTR_Deleted_Record_gne__c dr: [
            SELECT Deleted_Record_Id__c
            FROM OTR_Deleted_Record_gne__c
            WHERE Object_name__c ='ZipToTerritory_gne'
            AND CreatedDate > :lastCompletedBatchStarted
            LIMIT :getQueryRows()
        ]){
            String terrNum = dr.Deleted_Record_Id__c.split('_')[0];
            System.debug(terrNum);
            terrNumbers.add(terrNum);
        }

        for(Territory2 terr : [
            SELECT external_id_gne__c, Territory_Number_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c
            FROM Territory2
            WHERE LastModifiedDate > :lastCompletedBatchStarted
        ]){
            terrNumbers.add(terr.Territory_Number_gne__c);
        }
        String lastModifiedDateCondition = lastCompletedBatchStarted == null || allTerritory ? '' : ' WHERE LastModifiedDate > :lastCompletedBatchStarted';
        String query = 'SELECT Territory_Number_gne__c FROM Zip_to_Territory_gne__c '+lastModifiedDateCondition +' LIMIT '+getQueryRows();

        Zip_to_Territory_gne__c[] zips = Database.query(query);
        for(Zip_to_Territory_gne__c ztt : zips){
            terrNumbers.add(ztt.Territory_Number_gne__c);
        }
        limitException = getQueryRows() < 1;

        return terrNumbers;
    }

    private Integer getQueryRows(){
        return Limits.getLimitQueryRows() - Limits.getQueryRows();
    }

    private AsyncApexJob [] fetchLastBatch() {
        return [
            SELECT CreatedDate
            FROM AsyncApexJob
            WHERE ApexClass.Name = 'GNE_My_TerritoryTeam_CleanByZip_Batch'
                AND ParentJobId = null AND Status = 'Completed' AND JobType = 'BatchApex'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
    }
}