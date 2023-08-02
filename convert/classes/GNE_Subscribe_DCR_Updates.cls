/**
 * Subscribe batch task which runs subscribe process for DCRs.
 */
global public class GNE_Subscribe_DCR_Updates extends GNE_Subscribe_Batchable
    implements Database.Batchable<sObject>, Database.Stateful  {

    private static final String PTY_STATUS_READY        = 'ready';
    private static final String CTRB_SOURCE_CODE_SFDC   = 'SFDC';
    private static final String DCR_STATUS_SUBMITTED    = 'Submitted';
    private static final String DCR_STATUS_READYTOCLOSE = 'Ready to Close';
    private static final String DCR_STATUS_CLOSED       = 'Closed';

    private DateTime timestamp = DateTime.newInstance(2000, 1, 1);

    private GNE_Subscribe_Metrics metrics = new GNE_Subscribe_Metrics();
    private CORE_Subscribe_Metrics coreMetrics = new CORE_Subscribe_Metrics();

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
                                               AND ApexClass.Name = 'GNE_Subscribe_DCR_Updates'
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

    global Iterable<sObject> start(Database.BatchableContext BC) {
        System.debug('Starting subscribe DCR batch update');

        return Database.getQueryLocator([SELECT Id, 
                                                Account_gne__c
                                         FROM Change_Request_gne__c
                                         WHERE Account_gne__c != null 
                                         AND Status_gne__c !=: DCR_STATUS_SUBMITTED
                                         AND Status_gne__c !=: DCR_STATUS_READYTOCLOSE]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('Executing subscribe DCR batch update, scope: ' + scope.size());

        Set<String> accountIds = new Set<String>();
        for (sObject s : scope) {
            Change_Request_gne__c dcr = (Change_Request_gne__c) s;
            String id = dcr.Account_gne__c;
            accountIds.add(id);
        }

        Set<String> partyIds = new Set<String>();
        for (CORE_Pub_External_Id__c e : fetchCorePartiesByTimestamp(accountIds)) {
            partyIds.add(e.Party_Id_ref_gne__c);
        }

        Id jobId = CORE_Subscribe_Util.prepareSubscribeJobId('SUB_TIME_RANGE');
        CORE_Subscribe_Process coreProcess = new CORE_Subscribe_Process();
        coreMetrics = coreProcess.executeSubscribe(partyIds, jobId);
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Finishing subscribe DCR batch update');
        CORE_Subscribe_Base.sendSummaryMail('GNE_Subscribe_DCR_Updates', coreMetrics);
    }

    private List<CORE_Pub_External_Id__c> fetchCorePartiesByTimestamp(Set<String> setOfDCRAccountIds) {
        return [
                SELECT Party_Id_ref_gne__c
                FROM   CORE_Pub_External_Id__c 
                WHERE  Ctrb_Src_gne__c = :CTRB_SOURCE_CODE_SFDC 
                       AND Ctrb_Src_Id_gne__c IN :setOfDCRAccountIds
                       AND Party_Id_ref_gne__r.Last_Pub_Upsert_Date_gne__c >= :timestamp 
        ];
    }

}