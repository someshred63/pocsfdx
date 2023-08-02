/**
 * Subscribe batch task which runs subscribe process.
 */

global public class GNE_Subscribe_Batch_SFDC_OrgAccount extends GNE_Subscribe_Batchable implements Database.Batchable<sObject>, Database.Stateful {

    private static final String CNNCL_ENTY_TYP_CODE   = 'PTY';
    private static final String SFDC_CTRB_SOURCE_CODE = 'SFDC';
    private static final String MDM_CTRB_SOURCE_CODE  = 'MDM';
    private GNE_Subscribe_Metrics metrics = new GNE_Subscribe_Metrics();
    private CORE_Subscribe_Metrics coreMetrics = new CORE_Subscribe_Metrics();

    private DateTime createdStartDate = null;
    private DateTime createdEndDate  = null;

    public GNE_Subscribe_Metrics getMetrics() {
        return metrics;
    }

    public CORE_Subscribe_Metrics getCoreMetrics() {
        return coreMetrics;
    }


    public GNE_Subscribe_Batch_SFDC_OrgAccount (DateTime createdStartDate, DateTime createdEndDate) {
        this.createdStartDate = createdStartDate;
        this.createdEndDate   = createdEndDate;
    }


    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Starting subscribe batch update');
        String recordTypeNamesNotToProcess = 'Archived Account';

        String query  = 'SELECT id, mdmid_gne__c FROM account ' +
                        'WHERE recordType.Name != :recordTypeNamesNotToProcess ' +
                        'AND ispersonaccount = false ' +
                        'AND createdDate >= :createdStartDate ' +
                        'AND createdDate <= :createdEndDate ' +
                        'ORDER BY mdmid_gne__c ASC, createddate ASC ';

        return Database.getQueryLocator ( query ) ;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        System.debug('Executing subscribe batch update, scope: ' + scope.size());

        // SFDC Id, MDM Ids to get Party Ids
        Set<String> sfdcIdSet = new Set<String>();
        Set<String> mdmIdSet  = new Set<String>();

        for (Account acct : (Account[]) scope ) {
            sfdcIdSet.add (acct.Id);
            if (String.isNotBlank(acct.mdmid_gne__c)) {
                mdmIdSet.add(acct.mdmid_gne__c);
            }
        }

        List<CORE_Pub_External_Id__c> externals = [
            SELECT Party_Id_ref_gne__c 
            FROM   CORE_Pub_External_Id__c 
            WHERE  ( ( Ctrb_Src_Id_gne__c IN :mdmIdSet 
                AND Ctrb_Src_gne__c = :MDM_CTRB_SOURCE_CODE ) 
                OR ( Ctrb_Src_Id_gne__c IN :sfdcIdSet 
                    AND Ctrb_Src_gne__c = :SFDC_CTRB_SOURCE_CODE ) ) 
                AND Cnncl_Enty_Type_gne__c = :CNNCL_ENTY_TYP_CODE
         ];

        Set<String> partyIds = new Set<String>();
        for(CORE_Pub_External_Id__c e : externals) {
            partyIds.add(e.Party_Id_ref_gne__c);
        }

        Id jobId = CORE_Subscribe_Util.prepareSubscribeJobId('SUB_PARTY_LIST');

        CORE_Subscribe_Process coreProcess = new CORE_Subscribe_Process();
        coreMetrics = coreProcess.executeSubscribe(partyIds, jobId);
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Finishing subscribe batch update.');
        CORE_Subscribe_Base.sendSummaryMail('GNE_Subscribe_Batch_SFDC_OrgAccount', coreMetrics);
    }
}