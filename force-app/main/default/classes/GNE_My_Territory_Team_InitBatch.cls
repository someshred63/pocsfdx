public class GNE_My_Territory_Team_InitBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable,  Database.AllowsCallouts{
    private GNE_My_Territory_Team_Batch_Helper.BatchStatistic batchStatistic;
    private GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics;
    private String uname;
    private String passwd;
    private Set<String>teritoriesToExecute = new Set<String>();
    private static final String CLASS_NAME = 'GNE_My_Territory_Team_InitBatch';
    private DateTime lastCompletedBatchStarted;
    private Boolean allTerritory = false;
    private Boolean limitException = false;

    public void execute(SchedulableContext sc){
        GNE_My_Territory_Team_InitBatch batch = new GNE_My_Territory_Team_InitBatch();
        Database.executeBatch(batch);
    }

    public GNE_My_Territory_Team_InitBatch(){
        this(false);
    }

    public GNE_My_Territory_Team_InitBatch(Boolean allTerritory){
        this.allTerritory = allTerritory;
        this.batchStatistic = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic(CLASS_NAME);
        this.statistics = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic[]{};
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        if(!allTerritory && !Test.isRunningTest()){
            allTerritory = fetchLastBatch().isEmpty();
        }

        String query = 'SELECT Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Number_gne__c, external_id_gne__c '+
            'FROM Territory2 '+
            'WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association ) '+
            '    AND External_id_gne__c LIKE \'GNE-US%\'  '+
            '    AND (NOT external_id_gne__c LIKE \'INACTIVE TERRITORIES-%\') '+
            '    AND Territory_Number_gne__c != null  ';

        if(!allTerritory){
            Set<String> terrNumbers = fetchTerritoryNumbers();
             query += ' AND Territory_Number_gne__c IN : terrNumbers ';
             batchStatistic.setDelta(lastCompletedBatchStarted);
        }
        limitException = getQueryRows() < 1;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Territory2> scope) {
        for(Territory2 terr : scope){
            teritoriesToExecute.add(terr.Territory_Number_gne__c);
        }
        batchStatistic.updateStatistic();
    }

    public void finish(Database.BatchableContext BC){
        batchStatistic.markFinised();
        statistics.add(batchStatistic);
        GNE_My_Territory_Team_Batch batch;
        if(limitException){
            GNE_My_Territory_Team_InitBatch rerunBatch = new GNE_My_Territory_Team_InitBatch(true);
            Database.executeBatch(rerunBatch, 2000);
        } else if(lastCompletedBatchStarted != null && !allTerritory){
            batch = new GNE_My_Territory_Team_Batch(teritoriesToExecute, statistics, batchStatistic.orderOfExecute, lastCompletedBatchStarted);
            Database.executeBatch(batch, 2000);
        } else {
            batch = new GNE_My_Territory_Team_Batch(teritoriesToExecute, statistics, batchStatistic.orderOfExecute);
            Database.executeBatch(batch, 2000);
        }
    }

    private AsyncApexJob [] fetchLastBatch () {
        return [
            SELECT CreatedDate
            FROM AsyncApexJob
            WHERE ApexClass.Name = :CLASS_NAME
                AND ParentJobId = null AND Status = 'Completed' AND JobType = 'BatchApex'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
    }

    private Set<String> fetchTerritoryNumbers() {
        Set<String> terrNumbers = new Set<String>();
        for(Territory2 ter : Database.query(prepareInitQuery())){
            terrNumbers.add(ter.Territory_Number_gne__c);
        }
        terrNumbers.addAll(getTerrForNewZip());
        terrNumbers.addAll(getTerrForUserTerritory());

        return terrNumbers;
    }

    private String prepareInitQuery() {
        String query = 'SELECT Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Number_gne__c, external_id_gne__c '+
            'FROM Territory2 '+
            'WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association ) '+
            '    AND External_id_gne__c LIKE \'GNE-US%\'  '+
            '    AND (NOT external_id_gne__c LIKE \'INACTIVE TERRITORIES-%\') '+
            '    AND Salesforce_Code_gne__c != null '+
            '    AND Salesforce_SubTeam_Code_gne__c != null '+
            '    AND Territory_Number_gne__c != null ';

        query += addConditions();
        System.debug(':: INIT QUERY :: '+query);
        return query;
    }

    private String addConditions() {
        String dateCondition = addWhereCondition();
        String orCondition = '';
        Set<String> productsFromMySetup = new Set<String>();

        for(My_Setup_Products_vod__c msp :[
            SELECT OwnerId, Product_vod__c
            FROM  My_Setup_Products_vod__c
            WHERE LastModifiedDate > :lastCompletedBatchStarted
        ]){
            productsFromMySetup.add(msp.Product_vod__c);
        }

        Set<String> uniqKeysCodeSubCode = new Set<String> ();
        for(Team_Mapping_gne__c tm :[
            SELECT Product_gne__c, Product_gne__r.Name , Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c
            FROM Team_Mapping_gne__c
            WHERE Product_gne__c IN : productsFromMySetup
                OR LastModifiedDate > :lastCompletedBatchStarted
        ]){
            uniqKeysCodeSubCode.add(tm.Salesforce_Code_gne__c+':'+tm.Salesforce_SubTeam_Code_gne__c);
        }

        Boolean isFirst = true;
        for(String code : uniqKeysCodeSubCode){
            String[]codes = code.split(':');
            if(isFirst){
                isFirst = false;
                orCondition += '(Salesforce_Code_gne__c = \''+codes[0]+'\' AND Salesforce_SubTeam_Code_gne__c = \''+codes[1]+'\') ';
            } else {
                orCondition += ' OR (Salesforce_Code_gne__c = \''+codes[0]+'\' AND Salesforce_SubTeam_Code_gne__c = \''+codes[1]+'\')';
            }
        }
        orCondition += ' ) ';

        if(uniqKeysCodeSubCode.isEmpty()){
            orCondition = '';
            if(String.isNotBlank(dateCondition)){
                 dateCondition += ')';
                 orCondition += dateCondition;
            }
        } else {
            if(String.isNotBlank(dateCondition)){
                orCondition = ' OR ( ' + orCondition;
                orCondition = dateCondition + orCondition + ')';
            } else {
                orCondition = ' AND ( ' + orCondition;
            }
        }

        return orCondition;
    }

    private String addWhereCondition() {
        AsyncApexJob [] apexJobs = fetchLastBatch();
        lastCompletedBatchStarted = apexJobs.isEmpty() ? System.now().addDays(-50) : apexJobs[0].CreatedDate;
        String lastModifiedDateCondition = lastCompletedBatchStarted == null || allTerritory ? '' : ' AND ( LastModifiedDate > :lastCompletedBatchStarted';

        return lastModifiedDateCondition;
    }

    private Set<String> getTerrForNewZip(){
        Set<String> result = new Set<String>();
        Set<String> terrNumbers = new Set<String>();
        String lastModifiedDateCondition = lastCompletedBatchStarted == null || allTerritory ? '' : ' WHERE LastModifiedDate > :lastCompletedBatchStarted';

        String query = 'SELECT Territory_Number_gne__c FROM Zip_to_Territory_gne__c '+lastModifiedDateCondition +' GROUP BY Territory_Number_gne__c LIMIT 2000';
        Zip_to_Territory_gne__c [] changedZips = new Zip_to_Territory_gne__c [] {};

        for(AggregateResult ar :Database.query(query)) {
            terrNumbers.add(String.valueOf(ar.get('Territory_Number_gne__c')));
        }  

        String queryForTerritories = 'SELECT Territory_Number_gne__c '+
            'FROM Territory2 '+
            'WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association ) '+
            '    AND External_id_gne__c LIKE \'GNE-US%\'  '+
            '    AND (NOT external_id_gne__c LIKE \'INACTIVE TERRITORIES-%\') '+
            '    AND Salesforce_Code_gne__c != null '+
            '    AND Salesforce_SubTeam_Code_gne__c != null '+
            '    AND Territory_Number_gne__c IN : terrNumbers'+
            ' LIMIT '+getQueryRows();
        Territory2[] terrs = Database.query(queryForTerritories);

        for(Territory2 terr : terrs){
            result.add(terr.Territory_Number_gne__c);
        }

        return result;
    }

    private Set<String> getTerrForUserTerritory() {
        Set<String> result = new Set<String>();
        String queryForTerritories = 'SELECT Territory_Number_gne__c '+
            'FROM Territory2 '+
            'WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE LastModifiedDate > :lastCompletedBatchStarted ) '+
            '    AND External_id_gne__c LIKE \'GNE-US%\'  '+
            '    AND (NOT external_id_gne__c LIKE \'INACTIVE TERRITORIES-%\') '+
            '    AND Salesforce_Code_gne__c != null '+
            '    AND Salesforce_SubTeam_Code_gne__c != null '+
            ' LIMIT '+getQueryRows();
        Territory2[] terrs = Database.query(queryForTerritories);
        for(Territory2 terr : terrs){
            result.add(terr.Territory_Number_gne__c);
        }

        return result;
    }

    private Integer getQueryRows(){
        return Limits.getLimitQueryRows() - Limits.getQueryRows();
    }
}