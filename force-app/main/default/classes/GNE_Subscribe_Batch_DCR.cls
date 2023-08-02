/**
 * Subscribe batch task which runs subscribe process for DCRs.
 */
global public class GNE_Subscribe_Batch_DCR extends GNE_Subscribe_Batchable implements Database.Batchable<sObject>, Database.Stateful  {

    private static final String CTRB_SOURCE_CODE_SFDC   = 'SFDC';
    private static final String DCR_STATUS_SUBMITTED    = 'Submitted';
    private static final String DCR_STATUS_READYTOCLOSE = 'Ready to Close';
    private static final String DCR_STATUS_CLOSED       = 'Closed';

    private DateTime timestamp = DateTime.newInstance(2000, 1, 1);
    private GNE_Subscribe_Metrics metrics = new GNE_Subscribe_Metrics();
    private CORE_Subscribe_Metrics coreMetrics = new CORE_Subscribe_Metrics();

    public void setSelectByTimestamp() {

        AsyncApexJob[] asyncApexJobList = [
            SELECT id, 
                   createddate, 
                   status, 
                   numberoferrors, 
                   jobitemsprocessed, 
                   totaljobitems, 
                   createdby.email 
            FROM   asyncapexjob 
            WHERE  numberoferrors = 0 
                   AND status IN ( 'Completed' ) 
                   AND apexclass.name = 'GNE_Subscribe_Batch_DCR' 
            ORDER  BY createddate DESC 
        ];

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

        return Database.getQueryLocator([
            SELECT id, 
                   account_gne__c 
            FROM   change_request_gne__c 
            WHERE  account_gne__c != NULL 
                   AND status_gne__c != :DCR_STATUS_SUBMITTED 
                   AND status_gne__c != :DCR_STATUS_READYTOCLOSE 
                   AND status_gne__c != :DCR_STATUS_CLOSED 
                   AND createddate > :timestamp 
        ]);
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
        CORE_Subscribe_Base.sendSummaryMail('GNE_Subscribe_Batch_DCR', coreMetrics);
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