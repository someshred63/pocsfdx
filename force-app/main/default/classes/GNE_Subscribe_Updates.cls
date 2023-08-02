/**
 * Subscribe batch task which runs subscribe process.
 */
global public class GNE_Subscribe_Updates extends GNE_Subscribe_Batchable implements Database.Batchable<sObject>, Database.Stateful {

    private static final String PTY_STATUS_READY = 'ready';
    private DateTime timestamp                   = DateTime.newInstance(2010, 1, 1);
    private GNE_Subscribe_Metrics metrics        = new GNE_Subscribe_Metrics();
    private CORE_Subscribe_Metrics coreMetrics   = new CORE_Subscribe_Metrics();

    public void setSelectByTimestamp() {

        AsyncApexJob[] asyncApexJobList = [SELECT Id, 
                                                  CreatedDate, 
                                                  Status, 
                                                  NumberOfErrors,
                                                  JobItemsProcessed, 
                                                  TotalJobItems, 
                                                  CreatedBy.Email
                                           FROM AsyncApexJob
                                           WHERE NumberOfErrors = 0
                                               AND Status IN ('Completed')
                                               AND ApexClass.Name = 'GNE_Subscribe_Updates'
                                           ORDER BY CreatedDate DESC];

        if (asyncApexJobList.size() > 0) {
            timestamp = asyncApexJobList[0].CreatedDate;
        }
    }

    public void setSelectByTimestamp(DateTime timestamp) {
        this.timestamp = timestamp;
    }

    public GNE_Subscribe_Metrics getMetrics() {
        return metrics;
    }

    public CORE_Subscribe_Metrics getCoreMetrics() {
        return coreMetrics;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Starting subscribe batch update');
        return fetchCorePartiesByTimestamp();
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('Executing subscribe batch update, scope: ' + scope.size());
        Set<String> partyIds = new Set<String>();
        for (sObject s : scope) {
            CORE_Pub_Party__c pty = (CORE_Pub_Party__c) s;
            partyIds.add(pty.Id);
        }

        Id jobId = CORE_Subscribe_Util.prepareSubscribeJobId('SUB_TIME_RANGE');
        CORE_Subscribe_Process coreProcess = new CORE_Subscribe_Process();
        coreMetrics = coreProcess.executeSubscribe(partyIds, jobId);
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Finishing subscribe batch update.');
        CORE_Subscribe_Base.sendSummaryMail('GNE_Subscribe_Updates', coreMetrics);
    }

    private Database.QueryLocator fetchCorePartiesByTimestamp() {
        return Database.getQueryLocator([
            SELECT Id 
            FROM   CORE_Pub_Party__c 
            WHERE  Last_Pub_Upsert_Date_gne__c >= :timestamp 
        ]);
    }
}