public without sharing class GNE_FRM_Rep2Territory_Clean_Batch implements Database.Batchable<sObject>, Database.Stateful{
    private BatchJobObject batchJob;
    private Boolean initialized;
    private Set<String> userTerritoryIds;
    private String query;

    public Database.QueryLocator start(Database.BatchableContext BC){
        if(initialized != true){
            initBatch();
        }
        if(batchJob.getJobInProgress().getRunQuery()){
            userTerritoryIds = fetchUserTerritoryIds();
        }

        query = batchJob.getJobInProgress().getQuery();

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<FRM_Rep_2_Terr_gne__c> scope){
        delete scope;
    }

    public void finish(Database.BatchableContext BC){
        if(!isSomethingToProcess()){
            if(batchJob.getNextJobProcess() != null){
                batchJob.executeCleanBatch();
            }
        }
    }

    private void initBatch(){
        batchJob = new BatchJobObject();
    }

    public void initBatch(BatchJobObject batchJob){
        initialized = true;
        this.batchJob = batchJob;
    }

    public Id executeBatch(){
        Id result = null;
        if(this.initialized != true){
            initBatch();
        }
        result = Database.executeBatch(this);
        initialized = true;
        return result;
    }

    private Boolean isSomethingToProcess() {
        String queryWithLimit = query + ' LIMIT 1';
        return !Database.query(queryWithLimit).isEmpty();
    }

    private Set<String> fetchUserTerritoryIds(){
        if(userTerritoryIds == null){
            userTerritoryIds = new Set<String>();
            for (UserTerritory2Association record : [
                SELECT Id FROM UserTerritory2Association WHERE UserId IN (SELECT Id FROM User WHERE (Profile.Name LIKE 'GNE-MCCO-FRM%' OR Profile.Name LIKE 'GNE-CRM%') AND IsActive = true)
            ]){
                userTerritoryIds.add(record.Id);
            }
        }
        return userTerritoryIds;
    }

    /*
     * If in the future will be need to delete something else just
     * add new BatchJobProcess to createProcesses() method
     * where:
     *  query this is query to run
     *  runQuery if true we run fetchUserTerritoryIds method from batch
     */
    private class BatchJobObject{
        String query1 = 'SELECT Id FROM FRM_Rep_2_Terr_gne__c WHERE UserTerritory_Id__c NOT IN : userTerritoryIds';
        private List<BatchJobProcess> jobs = new List<BatchJobProcess>();
        private BatchJobProcess jobInProgress;
        private Integer jobProcessIndex = 0;
        public BatchJobObject(){
            createProcesses();
            jobInProgress = jobs[jobProcessIndex];
        }

        private void createProcesses(){
            jobs.add(new BatchJobProcess(true, query1));
        }

        public BatchJobProcess getJobInProgress() {
            return jobInProgress;
        }

        public BatchJobProcess getNextJobProcess() {
            jobProcessIndex ++;
            if(jobs.size() - 1 < jobProcessIndex) {
                return null;
            } else {
                jobInProgress = jobs.get(jobProcessIndex);
                return jobInProgress;
            }
        }

        public Id executeCleanBatch() {
            GNE_FRM_Rep2Territory_Clean_Batch batch = new GNE_FRM_Rep2Territory_Clean_Batch();
            batch.initBatch(this);
            return batch.executeBatch();
        }
    }

    private class BatchJobProcess{
        private Boolean runQuery;
      private String query;

        BatchJobProcess(Boolean runQuery, String query) {
            this.runQuery = runQuery;
            this.query = query;
        }

        public Boolean getRunQuery() {
            return runQuery;
        }

        public String getQuery() {
            return query;
        }
    }
}