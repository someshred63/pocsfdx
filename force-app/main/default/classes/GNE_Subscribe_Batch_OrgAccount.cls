/**
 * Subscribe batch task which runs subscribe process.
 */
global public class GNE_Subscribe_Batch_OrgAccount extends GNE_Subscribe_Batchable implements Database.Batchable<sObject>, Database.Stateful {

    private static final String PARTY_TYPE_ORGANIZATION_CODE = 'ORG';
    private DateTime startTimeStamp = DateTime.newInstance(2010, 1, 1);
    private DateTime endTimeStamp = null;
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
                                                   AND apexclass.name = 'GNE_Subscribe_Batch_OrgAccount' 
                                            ORDER  BY createddate DESC 
                                          ];

        if (asyncApexJobList.size() > 0) {
            startTimeStamp = asyncApexJobList[0].CreatedDate;
        }
    }

    public void setSelectByTimestamp(DateTime startTimeStamp) {
        this.startTimeStamp = startTimeStamp;
    }

    public void setEndTimeStamp (DateTime endTimeStamp ) {
        this.endTimeStamp = endTimeStamp;
    }

    public GNE_Subscribe_Metrics getMetrics() {
        return metrics;
    }

    public CORE_Subscribe_Metrics getCoreMetrics() {
        return coreMetrics;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Starting subscribe batch update');
        return CORE_Subscribe_Util.fetchPartiesByTimestampAndType(startTimestamp, endTimestamp, PARTY_TYPE_ORGANIZATION_CODE);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('Executing subscribe batch update, scope: ' + scope.size());

        List<CORE_Pub_Party__c> parties = (List<CORE_Pub_Party__c>) scope;
        Id jobId = CORE_Subscribe_Util.prepareSubscribeJobId('SUB_TIME_RANGE');

        CORE_Subscribe_Process coreProcess = new CORE_Subscribe_Process();
        coreMetrics = coreProcess.executeSubscribe(parties, jobId);
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Finishing subscribe batch update.');
        CORE_Subscribe_Base.sendSummaryMail('GNE_Subscribe_Batch_OrgAccount', coreMetrics);
    }
}