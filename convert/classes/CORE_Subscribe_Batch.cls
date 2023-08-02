/**
 * Subscribe batch task which runs subscribe process.
 */
global without sharing class CORE_Subscribe_Batch implements Database.Batchable<SObject>, Database.Stateful {

    public enum JobType {
        SUB_SINGLE_PARTY, SUB_PARTY_LIST, SUB_TIME_RANGE, SUB_AUTO
    }

    private CORE_Subscribe_Process subscribeProcess;
    private Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> mappingConfiguration;
    private Id subscribeJobId;

    private Boolean initialized;
    private JobType jType;
    private Set<Id> partyIds;
    private Datetime startTimestamp;
    private Datetime endTimestamp;
    private Integer batchIndex;
    private CORE_Subscribe_Metrics metrics;

    private static final String SELECT_QUERY = 'SELECT Id, Alt_Names_json_gne__c, Birthdate_gne__c, Comm_Channel_json_gne__c, Credentials_json_gne__c, Do_Not_Contact_gne__c, ' +
            'Education_json_gne__c, FirstName_gne__c, Gender_gne__c, LastName_gne__c, Mdm_Id_gne__c, Mdm_Updt_Date_gne__c, ' +
            'MiddleName_gne__c, Org_Name_gne__c, Org_Type_json_gne__c, Party_Id_gne__c, PDRP_Opt_Out_Date_gne__c, PDRP_Opt_Out_gne__c, ' +
            'Prof_Type_json_gne__c, Salutation_gne__c, Specialties_json_gne__c, Status_gne__c, Suffix_gne__c, Type_gne__c ' +
            'FROM CORE_Pub_Party__c';

    public CORE_Subscribe_Batch() {
        initialized = false;
    }

    global Iterable<SObject> start(Database.BatchableContext BC) {
        if (jType == JobType.SUB_AUTO) {
            return fetchPartiesByBatchIndex(batchIndex, startTimestamp, endTimestamp);
        } else if (jType == JobType.SUB_TIME_RANGE) {
            return fetchPartiesByTimestamp(startTimestamp, endTimestamp);
        } else {
            return fetchPartiesByIds(partyIds);
        }
        return null;
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        try {
            if (!initialized) {
                throw new CORE_Subscribe_Exception('Batch not initialized.');
            }
            CORE_Subscribe_Job__c subscribeJob = CORE_Subscribe_DAO.getSubscribeJob(subscribeJobId);
            if (subscribeJob.Status_gne__c != 'Error') {
                List<CORE_Pub_Party__c>parties = (List<CORE_Pub_Party__c>) scope;
                subscribeProcess.executeSubscribe(parties, mappingConfiguration, subscribeJob, metrics);
            }
        } catch (Exception e) {
            //record can be access concurently so we need to block it for update
            CORE_Subscribe_Job__c job = CORE_Subscribe_DAO.getSubscribeJobForUpdate(subscribeJobId);
            String summary = e.getMessage() + '\n' + e.getStackTraceString();
            if (String.isEmpty(job.Summary_gne__c)) {
                job.Summary_gne__c = summary;
            } else {
                job.Summary_gne__c += summary;
            }
            job.Status_gne__c = 'Error';
            update job;
        }
    }

    global void finish(Database.BatchableContext BC) {
        Map<String, CORE_Found_Misc_Config__c> configItemsMap = CORE_Found_Misc_Config__c.getAll();
        List<String> addresses = configItemsMap.get('SubscribeNotifyEmail').Configuration_Value_gne__c.split(',');

        CORE_Subscribe_Job__c subscribeJob = CORE_Subscribe_DAO.getSubscribeJobForUpdate(subscribeJobId);
        if (jType != JobType.SUB_AUTO) {
            if (subscribeJob.Status_gne__c != 'Error') {
                CORE_Subscribe_Util.finishJob(subscribeJob, metrics);
            }
            CORE_Subscribe_Base.sendSummaryMail(subscribeJob, addresses, metrics);
        } else {
            CORE_Subscribe_Util.addJSONMetricsToSubJob(subscribeJob, metrics);
            if (CORE_Subscribe_Util.isLastAutoBatch(subscribeJob)) {
                CORE_Subscribe_Metrics allMetrics = CORE_Subscribe_Util.mergeMetrics(subscribeJob);
                if (subscribeJob.Status_gne__c != 'Error') {
                    CORE_Subscribe_Util.finishJob(subscribeJob, allMetrics);
                }

                CORE_Found_Misc_Config__c fmc = CORE_Found_Misc_Config__c.getValues('AutoSubscribeLastSynchDateTime');
                fmc.Configuration_Value_gne__c = Datetime.now().format('yyyy-MM-dd HH:mm:ss');
                update fmc;

                CORE_Subscribe_Base.sendSummaryMail(subscribeJob, addresses, allMetrics);
            }
        }
    }

    public virtual void initBatch(Id subscribeObjectId, Id partyId) {
        initBatch(subscribeObjectId, null, JobType.SUB_SINGLE_PARTY, new Set<Id>{
                partyId
        }, null, null, null);
    }

    public virtual void initBatch(Id subscribeObjectId, Set<Id>partyIds) {
        initBatch(subscribeObjectId, null, JobType.SUB_PARTY_LIST, partyIds, null, null, null);
    }

    public virtual void initBatch(Id subscribeObjectId, Datetime startTimestamp, Datetime endTimestamp) {
        if (startTimestamp == null) {
            startTimestamp = Datetime.newInstance(2016, 1, 1);
        }
        if (endTimestamp == null) {
            endTimestamp = Datetime.now();
        }
        initBatch(subscribeObjectId, null, JobType.SUB_TIME_RANGE, null, startTimestamp, endTimestamp, null);
    }

    public virtual void initBatch(Id subscribeObjectId, Id subscribeJobId, Integer batchIndex, Datetime startTimestamp, Datetime endTimestamp) {
        if (startTimestamp == null) {
            startTimestamp = Datetime.newInstance(2016, 1, 1);
        }
        initBatch(subscribeObjectId, subscribeJobId, JobType.SUB_AUTO, null, startTimestamp, endTimestamp, batchIndex);
    }

    private void initBatch(Id subscribeObjectId, Id subscribeJobId, JobType jType, Set<Id>partyIds, Datetime startTimestamp, Datetime endTimestamp, Integer batchIndex) {
        if (String.isNotBlank(subscribeJobId)) {
            this.subscribeJobId = subscribeJobId;
        } else {
            String jobName = jType.name() + ' ' + Datetime.now().format('MM/dd/yyyy hh:mm a');
            CORE_Subscribe_Job__c subscribeJob = new CORE_Subscribe_Job__c(Name = jobName, Status_gne__c = 'In Progress', Subscribe_Object_gne__c = subscribeObjectId);
            insert subscribeJob;
            this.subscribeJobId = subscribeJob.Id;
        }

        this.jType = jType;
        this.partyIds = partyIds;
        this.startTimestamp = startTimestamp;
        this.endTimestamp = endTimestamp;
        this.batchIndex = batchIndex;
        this.initialized = true;
        subscribeProcess = new CORE_Subscribe_Process();
        mappingConfiguration = CORE_Subscribe_DAO.getMappingConfiguration(subscribeObjectId);
        metrics = new CORE_Subscribe_Metrics();
    }

    private Database.QueryLocator fetchPartiesByTimestamp(Datetime startTimestamp, Datetime endTimestamp) {
        String conditions = ' WHERE Last_Pub_Upsert_Date_gne__c > :startTimestamp AND Last_Pub_Upsert_Date_gne__c < :endTimestamp';
        return Database.getQueryLocator(SELECT_QUERY + conditions);
    }

    private Database.QueryLocator fetchPartiesByIds(Set<Id>partyIds) {
        String conditions = ' WHERE Id IN :partyIds';
        return Database.getQueryLocator(SELECT_QUERY + conditions);
    }

    private Database.QueryLocator fetchPartiesByBatchIndex(Integer batchIndex, Datetime startTimestamp, Datetime endTimestamp) {
        String conditions = ' WHERE Last_Pub_Upsert_Date_gne__c > :startTimestamp AND Last_Pub_Upsert_Date_gne__c < :endTimestamp AND Batch_Index_gne__c = :batchIndex';
        return Database.getQueryLocator(SELECT_QUERY + conditions);
    }

}