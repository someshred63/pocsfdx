/**
* Subscribe batch task which runs subscribe process.
*/

global class GNE_Subscribe_Batch_Alignment extends GNE_Subscribe_Batch_Base implements Database.Batchable<SObject>, Database.Stateful {

    private Map<String, Staging_Alignment_gne__c> stgAlignmentsMap = new Map<String, Staging_Alignment_gne__c>();
    private Map<String, Staging_Alignment_gne__c> stgAlignmentsMapForLastTerritory = new Map<String, Staging_Alignment_gne__c>();
    private Map<String, Account> accountsMap = new Map<String, Account>();
    private Map<String, Account> accountsMapLastScope = new Map<String, Account>();

    private transient Set<Id> validStagingAlignments;
    private transient Map<String, String> ptyIdToAccountId;
    private transient Map<Id, String> partySfdcIdToPartyId;
    private transient Map<String, String> accountIdToPtyId;
    private transient Map<String, Set<String>> ptyIdToPtyLocIds;
    private transient Set<String> internallyStewardedParties;

    private Map<String, Territory2> territoryMap = new Map<String, Territory2>();
    private Map<Id, Map<Id, ObjectTerritory2Association>> territoryAssociationsMap = new Map<Id, Map<Id, ObjectTerritory2Association>>();
    private Map<Id, Map<Id, TSF_vod__c>> tsfsMap = new Map<Id, Map<Id, TSF_vod__c>>();

    private Map<String, List<Staging_Alignment_gne__c>> territoryToStagingAlignments = new Map<String, List<Staging_Alignment_gne__c>>();
    private Map<String, Map<Id, SObject>> territoryToRecsToDelete = new Map<String, Map<Id, SObject>>();

    private Datetime lastSyncDateTime;
    private Set<String> internallyStewardedAccountTypes;
    //territories processed in all batches so far
    private Set<String> alreadyProcessedTerritories = new Set<String>();
    //territories exists in current batch chunk and not exists in previous chunks
    private Set<String> uniqueTerrNamesPerChunk;

    private transient GNE_Subscribe_Batch_Base.MetricTypeName currentMetricType;

    public static final String BATCH_NAME = 'Subscribe Alignment';
    public static final String ACCOUNT_ID_IS_MISSING = 'Missing Account ID';
    public static final String ACCOUNT_SFDC_ID_MISSING = 'No Account with given SFDC ID';
    public static final String ACCOUNT_MISSING_IN_CADS_STAGING = 'WARNING! Account missing in CADS Staging Tables';
    public static final String ACCOUNT_SUBSCRIBE_ERROR = 'Subscription Error';
    public static final String ACCOUNT_SUBSCRIBE_WARNING = 'Subscription Warning';
    public static final String TERRITORY_NOT_VALID = 'Invalid Territory';
    public static final String TERRITORY_DUPLICATED = 'Duplicated Territory';
    public static final String EMPTY_TERRITORY = 'EMPTY_TERRITORY';

    public static final String STATUS_OK = 'OK';
    public static final String STATUS_ERROR = 'ERROR';

    private CORE_Subscribe_Process coreProcess;
    private CORE_Subscribe_Metrics coreMetrics;
    private Map<String, List<CORE_Subscribe_Mapping_Configuration__c>> mappingConfiguration;
    private Boolean isInitialized;
    private Alignment_Job_gne__c alignmentJob;
    private Boolean jobMode;
    private String previousLastTerritoryInChunk;
    private String lastTerritoryInChunk;
    private Integer batchIndex;
    private Boolean isAutoSubscribe;
    private Boolean isSystemMode;

    private Map<String, AlignmentDetail> statistics;

    private String additionalInfo;

    public GNE_Subscribe_Batch_Alignment() {
        this(false);
    }

    global GNE_Subscribe_Batch_Alignment(Boolean prevMode) {
        this(null, prevMode);
    }

    global GNE_Subscribe_Batch_Alignment(String jobId, Boolean prevMode, Integer batchIndex) {
        this(jobId, prevMode, batchIndex, false);
    }

    global GNE_Subscribe_Batch_Alignment(String jobId, Boolean prevMode, Integer batchIndex, Boolean isSystemMode) {
        this.batchIndex = batchIndex;
        isAutoSubscribe = batchIndex != null;
        setInternallyStewardedAccountTypes();
        previewMode = prevMode;
        isInitialized = false;
        this.isSystemMode = isSystemMode;
        if (jobId == null) {
            alignmentJob = new Alignment_Job_gne__c();
            jobMode = false;
        } else {
            alignmentJob = [SELECT Id, Subscribe_Job_gne__c, ETL_LastSynch_gne__c, Batch_Ids_json_gne__c FROM Alignment_Job_gne__c WHERE Id = :jobId];
            jobMode = true;
        }
        setAlignmentLastSyncDateTime();
    }

    global GNE_Subscribe_Batch_Alignment(String jobId, Boolean prevMode) {
        this(jobId, prevMode, null);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        initBatch();
        if (isAutoSubscribe) {
            return Database.getQueryLocator ([
                    SELECT Id, Account_ID_gne__c, MDM_Address_Id_gne__c, MDM_ID_gne__c,
                            Territory_Key_gne__c, Target_gne__c, Zip_Code_gne__c, Source_gne__c, Activaction_Date_gne__c,
                            SFDC_Account_gne__c, SFDC_TSF_gne__c, SFDC_Group_gne__c,
                            Status_gne__c, Comment_gne__c
                    FROM Staging_Alignment_gne__c
                    WHERE Batch_Index_gne__c = :batchIndex
                    AND Status_gne__c = :GNE_Subscribe_Batch_Base.STATUS_LOADED
                    AND Activaction_Date_gne__c <= TODAY
                    ORDER BY Territory_Key_gne__c NULLS FIRST, Account_ID_gne__c NULLS FIRST

            ]);
        } else if (jobMode) {
            return Database.getQueryLocator ([
                    SELECT Id, Account_ID_gne__c, MDM_Address_Id_gne__c, MDM_ID_gne__c,
                            Territory_Key_gne__c, Target_gne__c, Zip_Code_gne__c, Source_gne__c, Activaction_Date_gne__c,
                            SFDC_Account_gne__c, SFDC_TSF_gne__c, SFDC_Group_gne__c,
                            Status_gne__c, Comment_gne__c
                    FROM Staging_Alignment_gne__c
                    WHERE Alignment_Job_gne__c = :alignmentJob.Id
                    AND Status_gne__c = :GNE_Subscribe_Batch_Base.STATUS_LOADED
                    AND Activaction_Date_gne__c <= TODAY
                    ORDER BY Territory_Key_gne__c NULLS FIRST, Account_ID_gne__c NULLS FIRST

            ]);
        } else {
            return Database.getQueryLocator ([
                    SELECT Id, Account_ID_gne__c, MDM_Address_Id_gne__c, MDM_ID_gne__c,
                            Territory_Key_gne__c, Target_gne__c, Zip_Code_gne__c, Source_gne__c, Activaction_Date_gne__c,
                            SFDC_Account_gne__c, SFDC_TSF_gne__c, SFDC_Group_gne__c,
                            Status_gne__c, Comment_gne__c
                    FROM Staging_Alignment_gne__c
                    WHERE Status_gne__c = :GNE_Subscribe_Batch_Base.STATUS_LOADED
                    AND Activaction_Date_gne__c <= TODAY
                    ORDER BY Territory_Key_gne__c NULLS FIRST, Account_ID_gne__c NULLS FIRST
            ]);
        }
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        previousLastTerritoryInChunk = lastTerritoryInChunk;
        List<Staging_Alignment_gne__c> stgAlignments = (List<Staging_Alignment_gne__c>) scope;

        for (Staging_Alignment_gne__c sAlign : stgAlignments) {
            if (String.isNotBlank(sAlign.Territory_Key_gne__c)) {
                String terrName = sAlign.Territory_Key_gne__c.toUpperCase();
                if (!territoryToStagingAlignments.containsKey(terrName)) {
                    territoryToStagingAlignments.put(terrName, new List<Staging_Alignment_gne__c>());
                }
                territoryToStagingAlignments.get(terrName).add(sAlign);
            } else {
                if (!territoryToStagingAlignments.containsKey(EMPTY_TERRITORY)) {
                    territoryToStagingAlignments.put(EMPTY_TERRITORY, new List<Staging_Alignment_gne__c>());
                }
                territoryToStagingAlignments.get(EMPTY_TERRITORY).add(sAlign);
            }
        }

        validStagingAlignments = new Set<Id>();
        executeSubscribe(stgAlignments);
        List<Staging_Alignment_gne__c> stgAlignmentsToAlign = new List<Staging_Alignment_gne__c>();

        for (Staging_Alignment_gne__c sAlign : stgAlignments) {
            if (isValidForAlignment(sAlign)) {
                stgAlignmentsToAlign.add(sAlign);
            }
            lastTerritoryInChunk = sAlign.Territory_Key_gne__c != null ? sAlign.Territory_Key_gne__c : EMPTY_TERRITORY;
        }
        if (!stgAlignmentsToAlign.isEmpty()) {
            executeAlignments(stgAlignmentsToAlign);
        }
        for (Staging_Alignment_gne__c sAlignment : stgAlignments) {
            sAlignment.Alignment_Job_gne__c = alignmentJob.Id;
        }
        executeDml(stgAlignments, GNE_Subscribe_Batch_Base.DmlType.STAGING_UPDATE);
        if (uniqueTerrNamesPerChunk != null) {
            alreadyProcessedTerritories.addAll(uniqueTerrNamesPerChunk);
        }
        deleteTerritoryRecords(lastTerritoryInChunk);
        Boolean isLastTerrFullyProcessed = false;
        Boolean isLastChunk = false;
        if (BC != null) {
            AsyncApexJob a = [SELECT Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
            isLastTerrFullyProcessed = previousLastTerritoryInChunk != null && (previousLastTerritoryInChunk != lastTerritoryInChunk);
            isLastChunk = a.JobItemsProcessed == (a.TotalJobItems - 1);
        } else {
            isLastChunk = true;
            isLastTerrFullyProcessed = true;
        }
        if (isLastChunk) {
            deleteTerritoryRecords(null);
        }
        for (String terr : territoryToStagingAlignments.keySet()) {
            if ((terr != previousLastTerritoryInChunk && terr != lastTerritoryInChunk) || (terr == previousLastTerritoryInChunk && isLastTerrFullyProcessed) || (terr == lastTerritoryInChunk && isLastChunk)) {
                updateAlignmentStatistics(statistics, territoryToStagingAlignments.remove(terr), terr);
            }
        }

        clearCache();
    }

    private Alignment_Job_gne__c getAlignmentJobForUpdate(Id alignmentJobId) {
        return [SELECT Id, Batch_Ids_json_gne__c, Comments_json_gne__c, Comments_gne__c, Subscribe_Job_gne__c FROM Alignment_Job_gne__c WHERE Id = :alignmentJobId FOR UPDATE];
    }

    global void finish(Database.BatchableContext BC) {
        if (isAutoSubscribe) {
            alignmentJob = getAlignmentJobForUpdate(alignmentJob.Id);
            if (!statistics.isEmpty()) {
                Map<String, AlignmentDetail> allStatistics;
                if (alignmentJob.Comments_json_gne__c != null) {
                    allStatistics = (Map<String, AlignmentDetail>) JSON.deserialize(alignmentJob.Comments_json_gne__c, Map<String, AlignmentDetail>.class);
                }
                if (allStatistics != null) {
                    allStatistics.putAll(statistics);
                } else {
                    allStatistics = statistics;
                }
                String newComment = JSON.serialize(allStatistics);
                Integer len = SObjectType.Alignment_Job_gne__c.fields.Comments_json_gne__c.length;
                if (newComment.length() < len) {
                    alignmentJob.Comments_json_gne__c = JSON.serialize(allStatistics);
                }
            }
            Database.upsert(alignmentJob, false);

            if (alignmentJob.Subscribe_Job_gne__c != null) {
                CORE_Subscribe_Job__c subscribeJob = CORE_Subscribe_DAO.getSubscribeJobForUpdate(alignmentJob.Subscribe_Job_gne__c);
                CORE_Subscribe_Util.addJSONMetricsToSubJob(subscribeJob, coreMetrics);
            }
        }
        if (!isAutoSubscribe || (isAutoSubscribe && GNE_Subscribe_Alignment_Auto.isLastAutoBatch(alignmentJob))) {
            if (isAutoSubscribe) {
                alignmentJob = getAlignmentJobForUpdate(alignmentJob.Id);
                if (String.isNotBlank(alignmentJob.Comments_json_gne__c)) {
                    statistics = (Map<String, AlignmentDetail>) JSON.deserialize(alignmentJob.Comments_json_gne__c, Map<String, AlignmentDetail>.class);
                } else {
                    statistics = new Map<String, AlignmentDetail>();
                }
            }
            Map<String, CORE_Found_Misc_Config__c> configItemsMap = CORE_Found_Misc_Config__c.getAll();
            List<String> addresses = configItemsMap.get('SubscribeNotifyEmail').Configuration_Value_gne__c.split(',');
            AlignmentDetail totals = getTotals(statistics.values());
            String territoryDetails = printDetailTable(statistics, totals);
            String info = territoryDetails;
            info += '<br/><br/>DEBUG INFO<br/>';
            info += 'Alignment Last Sync Date Time: ' + lastSyncDateTime + '<br/>';
            if (additionalInfo != null) {
                info += additionalInfo + '<br/>';
            }

            alignmentJob.Total_Alignments_gne__c = totals.sa;
            alignmentJob.Successfully_Aligned_gne__c = totals.sa - totals.er;
            alignmentJob.Alignment_Errors_gne__c = totals.er;
            alignmentJob.Salesforce_Team_gne__c = totals.tc;

            if (alignmentJob.Subscribe_Job_gne__c != null) {
                CORE_Subscribe_Job__c subscribeJob = CORE_Subscribe_DAO.getSubscribeJobForUpdate(alignmentJob.Subscribe_Job_gne__c);

                if (subscribeJob.Status_gne__c != 'Error') {
                    if (isAutoSubscribe) {
                        coreMetrics = CORE_Subscribe_Util.mergeMetrics(subscribeJob);
                    }
                    CORE_Subscribe_Util.finishJob(subscribeJob, coreMetrics);
                    if (alignmentJob.Total_Alignments_gne__c > 0) {
                        CORE_Subscribe_Base.sendSummaryMail(subscribeJob, addresses, coreMetrics, info, true);
                    }
                }
            }

            alignmentJob.Alignment_Execution_Date_gne__c = System.now();
            alignmentJob.Status_gne__c = 'Processed';

            try {
                if (alignmentJob.Comments_json_gne__c == null && statistics != null) {
                    alignmentJob.Comments_json_gne__c = JSON.serialize(statistics);
                }
            } catch (Exception e) {
                //ignore
            }
            Database.upsert(alignmentJob, false);
            Integer errorsThreshold = GNE_Foun_Misc_Config_Items_gne__c.getValues('AutoSubscribeErrorThreshold') != null ? Integer.valueOf(GNE_Foun_Misc_Config_Items_gne__c.getValues('AutoSubscribeErrorThreshold').Configuration_Value_gne__c) : 5;

            if (previewMode && isSystemMode && alignmentJob.Total_Alignments_gne__c > 0) {
                Decimal errorsRatio = alignmentJob.Alignment_Errors_gne__c / alignmentJob.Total_Alignments_gne__c * 100;
                if (errorsRatio < errorsThreshold) {
                    GNE_Subscribe_Alignment_Auto subscribeAlignmentAuto = new GNE_Subscribe_Alignment_Auto();
                    subscribeAlignmentAuto.execute(false, true);
                }
            }
        }
    }

    protected override String getBatchName() {
        return BATCH_NAME;
    }

    public virtual void initBatch() {
        if (!isInitialized) {
            String jobName = 'SA';
            if (previewMode) {
                jobName += '_PREVIEW';
            }

            this.coreProcess = new CORE_Subscribe_Process();
            CORE_Subscribe_Object__c subscribeObject = [SELECT Id FROM CORE_Subscribe_Object__c WHERE Name = 'SFA_US' LIMIT 1];
            this.mappingConfiguration = CORE_Subscribe_DAO.getMappingConfiguration(subscribeObject.Id);
            this.coreMetrics = new CORE_Subscribe_Metrics();
            isInitialized = true;
            if (!jobMode) {
                alignmentJob.Name = jobName + ' ' + Datetime.now().format('MM/dd/yyyy hh:mm a');
            }
            if (!isAutoSubscribe) {
                alignmentJob.Status_gne__c = 'In Progress';
                alignmentJob.Subscribe_Job_gne__c = CORE_Subscribe_Util.prepareSubscribeJobId(jobName);
                alignmentJob.Alignment_Errors_gne__c = 0;
                alignmentJob.Successfully_Aligned_gne__c = 0;
                alignmentJob.Total_Alignments_gne__c = 0;
                alignmentJob.Alignment_Execution_Date_gne__c = null;
                alignmentJob.Comments_gne__c = '';
                Database.upsert(alignmentJob, true);
            }
            statistics = new Map<String, AlignmentDetail>();
        }
    }

    public CORE_Subscribe_Metrics getCoreMetrics() {
        return coreMetrics;
    }

    protected override void initCache(List<SObject> stgObjs) {
        super.initCache(stgObjs);
        Set<String> sfdcIds = new Set<String>();
        ptyIdToAccountId = new Map<String, String>();
        partySfdcIdToPartyId = new Map<Id, String>();
        accountIdToPtyId = new Map<String, String>();
        ptyIdToPtyLocIds = new Map<String, Set<String>>();
        internallyStewardedParties = new Set<String>();

        Set<String> mdmIds = new Set<String>();
        Set<String> mdmAddrIds = new Set<String>();
        Set<String> terrNames = new Set<String>();

        Set<String> accountsWithoutAdressesSfdcIds = new Set<String>();
        Set<String> accountsWithoutAdressesMdmIds = new Set<String>();

        for (Staging_Alignment_gne__c sAlign : (List<Staging_Alignment_gne__c>) stgObjs) {
            clearStagingObjectComment(sAlign);

            if (String.isNotBlank(sAlign.Account_ID_gne__c) || String.isNotBlank(sAlign.MDM_ID_gne__c)) {
                try {
                    Id sfdcId = Id.valueOf(sAlign.Account_ID_gne__c);
                    sfdcIds.add(sfdcId);
                    if (String.isBlank(sAlign.MDM_Address_Id_gne__c)) {
                        accountsWithoutAdressesSfdcIds.add(sfdcId);
                    }
                } catch (Exception e) {
                    if (String.isNotBlank(sAlign.MDM_ID_gne__c)) {
                        mdmIds.add(sAlign.MDM_ID_gne__c);
                    } else {
                        mdmIds.add(sAlign.Account_ID_gne__c);
                    }
                    if (String.isBlank(sAlign.MDM_Address_Id_gne__c)) {
                        accountsWithoutAdressesMdmIds.add(sAlign.Account_ID_gne__c);
                    }
                }
            }

            if (String.isNotBlank(sAlign.MDM_Address_Id_gne__c)) {
                mdmAddrIds.add(sAlign.MDM_Address_Id_gne__c);
            }

            String terrName = String.isNotBlank(sAlign.Territory_Key_gne__c) ? sAlign.Territory_Key_gne__c : null;

            if (String.isNotBlank(terrName) && !territoryMap.containsKey(terrName)) {
                terrNames.add(terrName);
            }
        }

        Map<String, String> mdmIdToSfdcId = new Map<String, String>();

        if (!sfdcIds.isEmpty() || !mdmIds.isEmpty()) {

            for (Account acc : [SELECT Id, MDMID_gne__c FROM Account WHERE Id IN :sfdcIds OR MDMID_gne__c IN :mdmIds]) {
                accountsMap.put(acc.Id, acc);

                if (String.isNotBlank(acc.MDMID_gne__c)) {
                    mdmIds.add(acc.MDMID_gne__c);
                    mdmIdToSfdcId.put(acc.MDMID_gne__c, acc.Id);
                    mdmIdToSfdcId.put(acc.Id, acc.MDMID_gne__c);
                    accountsMap.put(acc.MDMID_gne__c, acc);
                }
            }

            List<CORE_Pub_External_Id__c> externals = [
                    SELECT Party_Id_gne__c, Party_Id_ref_gne__c, Party_Id_ref_gne__r.Type_gne__c, Party_Id_ref_gne__r.Org_Type_json_gne__c, Party_Location_Id_gne__c, Party_Location_Id_ref_gne__c, Party_Location_Id_ref_gne__r.Party_Id_gne__c, Party_Location_Id_ref_gne__r.Party_Id_ref_gne__r.Type_gne__c, Party_Location_Id_ref_gne__r.Party_Id_ref_gne__r.Org_Type_json_gne__c, Cnncl_Enty_Type_gne__c, Ctrb_Src_Id_gne__c, Ctrb_Src_gne__c
                    FROM CORE_Pub_External_Id__c
                    WHERE (Cnncl_Enty_Type_gne__c = :CORE_Subscribe_Base.CNNCL_PARTY_LOC AND Party_Location_Id_ref_gne__c != NULL AND Ctrb_Src_gne__c = :CORE_Subscribe_Base.MDM_CTRB_SOURCE_CODE AND Ctrb_Src_Id_gne__c IN :mdmAddrIds)
                    OR ((Cnncl_Enty_Type_gne__c = :CORE_Subscribe_Base.CNNCL_PARTY AND Ctrb_Src_gne__c = :CORE_Subscribe_Base.MDM_CTRB_SOURCE_CODE AND Ctrb_Src_Id_gne__c IN :mdmIds) OR
                    (Cnncl_Enty_Type_gne__c = :CORE_Subscribe_Base.CNNCL_PARTY AND Ctrb_Src_gne__c = :CORE_Subscribe_Base.SFDC_CTRB_SOURCE_CODE AND Ctrb_Src_Id_gne__c IN :sfdcIds)
                    )
                    ORDER BY Cnncl_Enty_Type_gne__c
            ];

            //if there is account specified without adress, we should subcribe account with all available addresses
            Set<String> partiesWithoutLocations = new Set<String>();

            if (!accountsWithoutAdressesSfdcIds.isEmpty() || !accountsWithoutAdressesMdmIds.isEmpty()) {
                for (CORE_Pub_External_Id__c e : externals) {
                    if (e.Cnncl_Enty_Type_gne__c == CORE_Subscribe_Base.CNNCL_PARTY &&
                            ((e.Ctrb_Src_gne__c == CORE_Subscribe_Base.SFDC_CTRB_SOURCE_CODE && accountsWithoutAdressesSfdcIds.contains(e.Ctrb_Src_Id_gne__c)) ||
                                    (e.Ctrb_Src_gne__c == CORE_Subscribe_Base.MDM_CTRB_SOURCE_CODE && accountsWithoutAdressesMdmIds.contains(e.Ctrb_Src_Id_gne__c)))) {
                        partiesWithoutLocations.add(e.Party_Id_gne__c);
                    }
                }

                if (!partiesWithoutLocations.isEmpty()) {
                    externals.addAll([
                            SELECT Party_Id_gne__c, Party_Id_ref_gne__c, Party_Location_Id_gne__c, Party_Location_Id_ref_gne__c, Party_Location_Id_ref_gne__r.Party_Id_gne__c, Cnncl_Enty_Type_gne__c, Ctrb_Src_Id_gne__c
                            FROM CORE_Pub_External_Id__c
                            WHERE (Cnncl_Enty_Type_gne__c = :CORE_Subscribe_Base.CNNCL_PARTY_LOC AND Party_Location_Id_ref_gne__c != NULL AND Party_Location_Id_ref_gne__r.Party_Id_gne__c IN :partiesWithoutLocations)
                    ]);

                }
            }
            ////end section for no locations

            for (CORE_Pub_External_Id__c e : externals) {
                Boolean isParty = e.Cnncl_Enty_Type_gne__c == CORE_Subscribe_Base.CNNCL_PARTY;
                String ptyId = isParty ? e.Party_Id_gne__c : e.Party_Location_Id_ref_gne__r.Party_Id_gne__c;
                String ptySfdcId = isParty ? e.Party_Id_ref_gne__c : e.Party_Location_Id_ref_gne__c;

                if (String.isNotBlank(ptyId)) {
                    if (isParty) {
                        String accKey = e.Ctrb_Src_Id_gne__c;

                        if (!accountsMap.containsKey(accKey)) {
                            ptyIdToAccountId.put(ptyId, accKey);
                        }
                        partySfdcIdToPartyId.put(ptySfdcId, ptyId);
                        accountIdToPtyId.put(accKey, ptyId);

                        if (mdmIdToSfdcId.containsKey(accKey)) {
                            accountIdToPtyId.put(mdmIdToSfdcId.get(accKey), ptyId);
                        }
                        if (isInternallyStewarded(e.Party_Id_ref_gne__r)) {
                            internallyStewardedParties.add(ptyId);
                        }

                        if (!ptyIdToPtyLocIds.containsKey(ptyId)) {
                            ptyIdToPtyLocIds.put(ptyId, new Set<String>());
                        }
                    } else {
                        String ptyLocId = e.Party_Location_Id_gne__c;

                        if (!ptyIdToPtyLocIds.containsKey(ptyId)) {
                            ptyIdToPtyLocIds.put(ptyId, new Set<String>());
                        }
                        ptyIdToPtyLocIds.get(ptyId).add(ptyLocId);
                    }
                }
            }
        }

        uniqueTerrNamesPerChunk = new Set<String>();
        if (!terrNames.isEmpty()) {
            Map<Id, Territory2> terrs = new Map<Id, Territory2>([SELECT Id, Name, Salesforce_Code_gne__c FROM Territory2 WHERE Name IN :terrNames AND Name NOT IN :alreadyProcessedTerritories]);

            for (Territory2 terr : terrs.values()) {
                territoryMap.put(terr.Name.toUpperCase(), terr);
                territoryMap.put(terr.Id, terr);
                uniqueTerrNamesPerChunk.add(terr.Name.toUpperCase());
            }

            List<ObjectTerritory2Association> territoryAssociations = [SELECT Id, ObjectId, Territory2Id FROM ObjectTerritory2Association WHERE Territory2Id IN :terrs.keySet()];

            for (ObjectTerritory2Association territoryAssociation : territoryAssociations) {
                Territory2 terr = territoryMap.get(territoryAssociation.Territory2Id);

                if (!territoryAssociationsMap.containsKey(terr.Id)) {
                    territoryAssociationsMap.put(terr.Id, new Map<Id, ObjectTerritory2Association>());
                }
                territoryAssociationsMap.get(terr.Id).put(territoryAssociation.ObjectId, territoryAssociation);
            }

            //territory should be processed only once
            List<TSF_vod__c> tsfs = [
                    SELECT Id, Account_vod__c, Account_vod__r.MDMID_gne__c, My_Target_vod__c, Territory_vod__c, Zip_Code_gne__c, Aligment_Source_gne__c, CreatedDate
                    FROM TSF_vod__c
                    WHERE Territory_vod__c IN :uniqueTerrNamesPerChunk
            ];

            for (TSF_vod__c tsf : tsfs) {
                String terrName = tsf.Territory_vod__c.toUpperCase();
                Territory2 terr = territoryMap.get(terrName);

                if (!tsfsMap.containsKey(terr.Id)) {
                    tsfsMap.put(terr.Id, new Map<Id, TSF_vod__c>());
                }

                tsfsMap.get(terr.Id).put(tsf.Account_vod__c, tsf);
            }
        }
    }

    protected override void clearStagingObjectComment(SObject stgObj) {
        super.clearStagingObjectComment(stgObj);
        Staging_Alignment_gne__c sAlign = (Staging_Alignment_gne__c) stgObj;
        sAlign.SFDC_Account_gne__c = null;
        sAlign.SFDC_Group_gne__c = null;
        sAlign.SFDC_TSF_gne__c = null;
    }

    protected override String getKeyFromTargetObject(SObject target) {
        String targetKey = null;

        if (target instanceof TSF_vod__c) {
            TSF_vod__c tsf = (TSF_vod__c) target;
            targetKey = getStagingKey(tsf.Account_vod__c, tsf.Territory_vod__c);
        } else if (target instanceof ObjectTerritory2Association) {
            ObjectTerritory2Association territoryAssociation = (ObjectTerritory2Association) target;
            targetKey = getStagingKey(territoryAssociation.ObjectId, territoryAssociation.Territory2Id);
        }
        return targetKey;
    }

    public override SObject getStagingForTargetObject(SObject target) {
        return stgAlignmentsMap.get(getKeyFromTargetObject(target));
    }

    private String getStagingKey(Id accountId, String territory) {
        return String.format('{0}:{1}', new String[]{
                accountId, (String.isNotBlank(territory) ? territory.toUpperCase() : null)
        });
    }

    protected override String getKeyFromStagingObject(SObject staging) {
        Staging_Alignment_gne__c sAlign = (Staging_Alignment_gne__c) staging;
        return String.format('{0}:{1}', new String[]{
                getAccountIdentifier(sAlign), sAlign.Territory_Key_gne__c
        }).toUpperCase();
    }

    protected override void processStagingDmlSuccess(SObject stgObj) {
        if (stgObj instanceof Staging_Alignment_gne__c) {
            updateSubscribeMetrics(stgObj, GNE_Subscribe_Batch_Base.MetricTypeName.REC_UPDATE, coreMetrics);
        } else {
            updateSubscribeMetrics(stgObj, GNE_Subscribe_Batch_Base.MetricTypeName.INSERT_UPDATE, coreMetrics);
        }
    }

    protected override void processStagingDmlErrors(Database.Error[] errors, SObject stgObj) {
        updateSubscribeMetrics(stgObj, GNE_Subscribe_Batch_Base.MetricTypeName.ERROR, coreMetrics);
    }

    protected override void processDmlSuccess(SObject targetObj, SObject stgObj) {
        super.processDmlSuccess(targetObj, stgObj);

        if (currentMetricType == GNE_Subscribe_Batch_Base.MetricTypeName.INSERT_UPDATE) {
            Staging_Alignment_gne__c sAlign = (Staging_Alignment_gne__c) stgObj;

            if (targetObj instanceof ObjectTerritory2Association) {
                sAlign.SFDC_Group_gne__c = territoryMap.get(((ObjectTerritory2Association) targetObj).Territory2Id).Id;
            } else if (targetObj instanceof TSF_vod__c) {
                sAlign.SFDC_TSF_gne__c = targetObj.Id;
            }
        }

        updateSubscribeMetrics(targetObj, currentMetricType, coreMetrics);
    }

    protected override void processDmlErrors(Database.Error[] errors, SObject targetObj, SObject stgObj) {
        if (stgObj != null) {
            super.processDmlErrors(errors, targetObj, stgObj);
        }

        updateSubscribeMetrics(targetObj, GNE_Subscribe_Batch_Base.MetricTypeName.ERROR, coreMetrics);
    }

    protected override void markStgObjectInPreviewMode(SObject stgObj) {
        super.markStgObjectInPreviewMode(stgObj);
        if (previewMode == true) {
            Staging_Alignment_gne__c sAlign = (Staging_Alignment_gne__c) stgObj;
            sAlign.SFDC_Account_gne__c = null;
            sAlign.SFDC_Group_gne__c = null;
            sAlign.SFDC_TSF_gne__c = null;
        }
    }

    private void clearCache() {
        accountsMapLastScope = accountsMap;
        accountsMap = new Map<String, Account>();
        if (previousLastTerritoryInChunk != null && lastTerritoryInChunk != previousLastTerritoryInChunk) {
            stgAlignmentsMapForLastTerritory.clear();
        }
        for (String key : stgAlignmentsMap.keySet()) {
            if (key.endsWith(':' + lastTerritoryInChunk.toUpperCase())) {
                stgAlignmentsMapForLastTerritory.put(key, stgAlignmentsMap.get(key));
            }
        }
        stgAlignmentsMap.clear();
    }

    private Boolean isValidForAlignment(Staging_Alignment_gne__c sAlign) {
        return validStagingAlignments.contains(sAlign.Id);
    }

    private void executeSubscribe(List<Staging_Alignment_gne__c> stgAlignments) {
        Savepoint sp = null;

        if (previewMode) {
            currentSavePoint = sp = Database.setSavepoint();
        }

        try {
            intExecuteSubscribe(stgAlignments);
        } catch (Exception e) {
            CORE_Subscribe_Job__c job = CORE_Subscribe_DAO.getSubscribeJobForUpdate(alignmentJob.Subscribe_Job_gne__c);
            String summary = e.getMessage() + '\n' + e.getStackTraceString();
            if (String.isEmpty(job.Summary_gne__c)) {
                job.Summary_gne__c = summary;
            } else {
                job.Summary_gne__c += summary;
            }
            job.Status_gne__c = 'Error';
            update job;
        } finally {
            if (previewMode) {
                Database.rollback(sp);
                currentSavePoint = null;
            }
        }
    }

    private void intExecuteSubscribe(List<Staging_Alignment_gne__c> stgAlignments) {
        initCache(stgAlignments);
        CORE_Subscribe_Metrics metrics = new CORE_Subscribe_Metrics();
        Set<Id> accIds = new Set<Id>();
        Map<String, Set<String>> subscribeErrorKeys = new Map<String, Set<String>>();

        Map<String, Set<String>> externallyStewardedParties = new Map<String, Set<String>>();
        for (String ptyId : ptyIdToPtyLocIds.keySet()) {
            if (!internallyStewardedParties.contains(ptyId)) {
                externallyStewardedParties.put(ptyId, ptyIdToPtyLocIds.get(ptyId));
            }
        }
        if (!externallyStewardedParties.isEmpty()) {
            CORE_Subscribe_Job__c subscribeJob = CORE_Subscribe_DAO.getSubscribeJob(alignmentJob.Subscribe_Job_gne__c);
            if (subscribeJob.Status_gne__c != 'Error') {
                coreProcess.executeSubscribe(externallyStewardedParties, new Map<String, Set<String>>(), mappingConfiguration, subscribeJob, metrics);
                coreMetrics = CORE_Subscribe_Util.mergeMetrics(coreMetrics, metrics);
            }
            if (metrics.relatedMetrics != null) {
                for (CORE_Subscribe_Metrics metric : metrics.relatedMetrics) {
                    if (metric.targetObject == 'Account' && metric.upsertedRecords != null) {
                        for (SObject record : metric.upsertedRecords) {
                            if (record.getSObjectType() == Schema.Account.getSObjectType()) {
                                Account acc = (Account) record;
                                accIds.add(acc.Id);
                            }
                        }
                    }
                }
            }
            if (metrics.partyToErrors != null) {
                for (Id partySfdcId : metrics.partyToErrors.keySet()) {
                    String partyId = partySfdcIdToPartyId.get(partySfdcId);
                    for (CORE_Subscribe_Error__c error : metrics.partyToErrors.get(partySfdcId)) {
                        if (String.isNotBlank(error.Description_gne__c)) {
                            if (!subscribeErrorKeys.containsKey(partyId)) {
                                subscribeErrorKeys.put(partyId, new Set<String>());
                            }
                            subscribeErrorKeys.get(partyId).add(error.Description_gne__c);
                        }
                    }
                }
                for (Id partySfdcId : metrics.partyToValidationErrors.keySet()) {
                    CORE_Subscribe_Error__c error = metrics.partyToValidationErrors.get(partySfdcId);
                    String partyId = partySfdcIdToPartyId.get(partySfdcId);
                    if (String.isNotBlank(error.Description_gne__c)) {
                        if (!subscribeErrorKeys.containsKey(partyId)) {
                            subscribeErrorKeys.put(partyId, new Set<String>());
                        }
                        subscribeErrorKeys.get(partyId).add(error.Description_gne__c);
                    }
                }
            }
        }
        if (!accIds.isEmpty()) {
            List<Account> accs = [SELECT Id, MDMID_gne__c FROM Account WHERE Id IN :accIds];

            for (Account acc : accs) {
                accountsMap.put(acc.Id, acc);
                accountsMap.put(acc.MDMID_gne__c, acc);
            }
        }

        for (Staging_Alignment_gne__c sAlign : stgAlignments) {
            String accKey = getAccountIdentifier(sAlign);
            Account acc = accountsMap.get(accKey);
            if (!validate(sAlign, subscribeErrorKeys)) {
                //skip
            } else if (acc != null && String.isNotBlank(sAlign.Territory_Key_gne__c)) {
                String key = getStagingKey(acc.Id, sAlign.Territory_Key_gne__c);
                stgAlignmentsMap.put(key, sAlign);
                sAlign.SFDC_Account_gne__c = acc.Id;
                markStagingObjectAsProcessed(sAlign, false);
                validStagingAlignments.add(sAlign.Id);
            } else {
                sAlign.SFDC_Account_gne__c = acc != null ? acc.Id : null;
                markStagingObjectAsProcessed(sAlign, false);
            }
        }
    }

    /*Validate object and put comment and status */
    private Boolean validate(Staging_Alignment_gne__c sAlign, Map<String, Set<String>> subscribeErrorKeys) {
        Boolean isValid = false;
        String accKey = getAccountIdentifier(sAlign);
        Account acc = accountsMap.get(accKey);
        if (acc == null) {
            acc = accountsMapLastScope.get(accKey);
        }
        String ptyId = accountIdToPtyId.get(accKey);

        if (String.isBlank(accKey)) {
            markStagingObjectWithError(sAlign, ACCOUNT_ID_IS_MISSING);
        } else if (internallyStewardedParties.contains(ptyId) && acc == null) {
            markStagingObjectWithError(sAlign, ACCOUNT_SFDC_ID_MISSING + '(INTERNALLY STEWARDED)');
        } else if (acc == null && subscribeErrorKeys.containsKey(ptyId)) {
            String errorDesc = getSubscribeErrorDesc(ptyId, subscribeErrorKeys);
            markStagingObjectWithError(sAlign, ACCOUNT_SUBSCRIBE_ERROR + (String.isNotBlank(errorDesc) ? ': ' + errorDesc : ''));
        } else if (acc == null && ptyId == null) {
            markStagingObjectWithError(sAlign, ACCOUNT_SFDC_ID_MISSING);
        } else if (acc == null && ptyIdToAccountId.containsKey(ptyId)) {
            String errorDesc = getSubscribeErrorDesc(ptyId, subscribeErrorKeys);
            markStagingObjectWithError(sAlign, ACCOUNT_SUBSCRIBE_ERROR + (String.isNotBlank(errorDesc) ? ': ' + errorDesc : ''));
        } else if (String.isNotBlank(sAlign.Territory_Key_gne__c) && !territoryMap.containsKey(sAlign.Territory_Key_gne__c.toUpperCase())) {
            markStagingObjectWithError(sAlign, TERRITORY_NOT_VALID);
        } else if (acc != null && String.isNotBlank(sAlign.Territory_Key_gne__c) && (stgAlignmentsMap.containsKey(getStagingKey(acc.Id, sAlign.Territory_Key_gne__c)) || stgAlignmentsMapForLastTerritory.containsKey(getStagingKey(acc.Id, sAlign.Territory_Key_gne__c)))) {
            markStagingObjectWithError(sAlign, TERRITORY_DUPLICATED);
        } else if (ptyId == null) {
            markStagingObjectWithComment(sAlign, ACCOUNT_MISSING_IN_CADS_STAGING);
            isValid = true;
        } else if (subscribeErrorKeys.containsKey(ptyId)) {
            String errorDesc = getSubscribeErrorDesc(ptyId, subscribeErrorKeys);
            markStagingObjectWithComment(sAlign, ACCOUNT_SUBSCRIBE_WARNING + (String.isNotBlank(errorDesc) ? ': ' + errorDesc : ''));
            isValid = true;
        } else {
            isValid = true;
        }
        return isValid;
    }

    private String getSubscribeErrorDesc(String ptyId, Map<String, Set<String>> subscribeErrorKeys) {
        return subscribeErrorKeys.containsKey(ptyId)
                ? String.join(new List<String>(subscribeErrorKeys.get(ptyId)), ', ')
                : String.isNotBlank(ptyId) ? getSubscribeErrorDesc(null, subscribeErrorKeys) : null;
    }

    private List<Staging_Alignment_gne__c> executeAlignments(List<Staging_Alignment_gne__c> stgAlignments) {
        Savepoint sp = null;

        if (previewMode) {
            currentSavePoint = sp = Database.setSavepoint();
        }

        List<Staging_Alignment_gne__c> sAlignsToUpdate;

        try {
            sAlignsToUpdate = intExecuteAlignments(stgAlignments);
        } finally {
            if (previewMode) {
                Database.rollback(sp);
                currentSavePoint = null;
            }
        }
        return sAlignsToUpdate;
    }

    private List<Staging_Alignment_gne__c> intExecuteAlignments(List<Staging_Alignment_gne__c> stgAlignments) {
        List<Staging_Alignment_gne__c> sAlignsToUpdate = new List<Staging_Alignment_gne__c>();
        Map<String, Set<Id>> terrToAccMap = new Map<String, Set<Id>>();

        for (Staging_Alignment_gne__c sAlign : stgAlignments) {
            String terrName = sAlign.Territory_Key_gne__c.toUpperCase();
            String accKey = getAccountIdentifier(sAlign);
            Account acc = accountsMap.get(accKey);

            if (!terrToAccMap.containsKey(terrName)) {
                terrToAccMap.put(terrName, new Set<Id>());
            }
            terrToAccMap.get(terrName).add(acc.Id);
        }

        if (!terrToAccMap.isEmpty()) {
            alignAccountsToTerritories(terrToAccMap);
        }

        for (Staging_Alignment_gne__c sAlign : stgAlignments) {
            if (sAlign.Status_gne__c == GNE_Subscribe_Batch_Base.STATUS_ERROR_PROCESSING || sAlign.SFDC_Group_gne__c != null || sAlign.SFDC_TSF_gne__c != null) {
                sAlignsToUpdate.add(sAlign);
            }
        }
        return sAlignsToUpdate;
    }

    private void alignAccountsToTerritories(Map<String, Set<Id>> terrToAccMap) {
        List<TSF_vod__c> tsfsToUpsert = new List<TSF_vod__c>();
        List<ObjectTerritory2Association> territoryAssociationsToInsert = new List<ObjectTerritory2Association>();

        // Get only these accounts which are still in the database (only for Preview Mode)
        Set<Id> existingAccIds = new Set<Id>();
        if (previewMode == true) {
            for (Set<Id> accIds : terrToAccMap.values()) {
                existingAccIds.addAll(accIds);
            }

            existingAccIds = new Set<Id>(new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :existingAccIds]).keySet());
        }

        for (String terrName : terrToAccMap.keySet()) {
            Territory2 terr = territoryMap.get(terrName);
            Map<Id, ObjectTerritory2Association> territoryAssociations = territoryAssociationsMap.get(terr.Id);
            Map<Id, TSF_vod__c> tsfs = tsfsMap.get(terr.Id);
            Set<Id> accIds = terrToAccMap.get(terrName);

            //remove existing tsfes and related account shares

            if (tsfs != null && !alreadyProcessedTerritories.contains(terrName.toUpperCase())) {
                for (TSF_vod__c tsf : tsfs.values()) {
                    if (lastSyncDateTime >= tsf.CreatedDate) {
                        if (!territoryToRecsToDelete.containsKey(terrName)) {
                            territoryToRecsToDelete.put(terrName, new Map<Id, SObject>());
                        }

                        territoryToRecsToDelete.get(terrName).put(tsf.Id, tsf);
                        ObjectTerritory2Association territoryAssociation = territoryAssociations != null ? territoryAssociations.get(tsf.Account_vod__c) : null;

                        if (territoryAssociation != null) {
                            territoryToRecsToDelete.get(terrName).put(territoryAssociation.Id, territoryAssociation);
                        }
                    }
                }
            }
            for (Id accId : accIds) {
                Account acc = accountsMap.get(accId);
                Staging_Alignment_gne__c sAlign = stgAlignmentsMap.get(getStagingKey(acc.Id, terrName));

                if (!previewMode || existingAccIds.contains(acc.Id)) {
                    ObjectTerritory2Association territoryAssociation = territoryAssociations != null ? territoryAssociations.get(acc.Id) : null;
                    TSF_vod__c tsf = tsfs != null ? tsfs.get(acc.Id) : null;

                    if (tsf == null) {
                        tsf = new TSF_vod__c(Account_vod__c = acc.Id, Territory_vod__c = terr.Name);
                    } else {
                        if (territoryToRecsToDelete.containsKey(terrName)) {
                            territoryToRecsToDelete.get(terrName).remove(tsf.Id);
                        }
                    }

                    tsf.My_Target_vod__c = sAlign.Target_gne__c;
                    tsf.Aligment_Source_gne__c = String.isNotBlank(sAlign.Source_gne__c) ? sAlign.Source_gne__c : 'JAMS';

                    if (String.isNotBlank(sAlign.Zip_Code_gne__c)) {
                        tsf.Zip_Code_gne__c = sAlign.Zip_Code_gne__c;
                    }

                    tsfsToUpsert.add(tsf);

                    if (territoryAssociation == null) {
                        territoryAssociation = new ObjectTerritory2Association(ObjectId = acc.Id, Territory2Id = terr.Id, AssociationCause = 'Territory2Manual');
                        territoryAssociationsToInsert.add(territoryAssociation);
                        stgAlignmentsMap.put(getStagingKey(acc.Id, terr.Id), sAlign);
                    } else {
                        if (territoryToRecsToDelete.containsKey(terrName)) {
                            territoryToRecsToDelete.get(terrName).remove(territoryAssociation.Id);
                        }
                        sAlign.SFDC_Group_gne__c = terr.Id;
                    }
                }
            }
        }

        currentMetricType = GNE_Subscribe_Batch_Base.MetricTypeName.INSERT_UPDATE;
        if (!territoryAssociationsToInsert.isEmpty()) {
            executeDml(territoryAssociationsToInsert, GNE_Subscribe_Batch_Base.DmlType.TARGET_INSERT);
        }

        if (!tsfsToUpsert.isEmpty()) {
            executeDml(tsfsToUpsert, GNE_Subscribe_Batch_Base.DmlType.TARGET_UPSERT);
        }
    }

    private void deleteTerritoryRecords(String skipTerritory) {
        if (!territoryToRecsToDelete.isEmpty()) {
            currentMetricType = GNE_Subscribe_Batch_Base.MetricTypeName.UNALIGN;
            List<TSF_vod__c> tsfsToDelete = new List<TSF_vod__c>();
            List<ObjectTerritory2Association> sharesToDelete = new List<ObjectTerritory2Association>();
            Integer remainingDmlRows = Limits.getLimitDmlRows() - Limits.getDmlRows() - 100;
            Integer dmlCounter = 0;
            for (String terr : territoryToRecsToDelete.keySet()) {
                if (terr != skipTerritory) {
                    for (SObject rec : new List<SObject>(territoryToRecsToDelete.get(terr).values())) {
                        dmlCounter += rec instanceof TSF_vod__c ? 3 : 1;

                        if (dmlCounter <= remainingDmlRows) {
                            if (rec instanceof TSF_vod__c) {
                                tsfsToDelete.add((TSF_vod__c) rec);
                            } else {
                                sharesToDelete.add((ObjectTerritory2Association) rec);
                            }

                            territoryToRecsToDelete.get(terr).remove(rec.Id);
                        } else {
                            additionalInfo = String.isBlank(additionalInfo) ? 'Due to limits not all records deleted.' : additionalInfo + ' Due to limits not all records deleted.';
                            break;
                        }
                    }
                }
            }
            if (!tsfsToDelete.isEmpty()) {
                executeDml(tsfsToDelete, GNE_Subscribe_Batch_Base.DmlType.TARGET_DELETE);
            }
            if (!sharesToDelete.isEmpty()) {
                executeDml(sharesToDelete, GNE_Subscribe_Batch_Base.DmlType.TARGET_DELETE);
            }
        }
    }

    private void setInternallyStewardedAccountTypes() {
        internallyStewardedAccountTypes = new Set<String>();
        GNE_Foun_Misc_Config_Items_gne__c item = GNE_Foun_Misc_Config_Items_gne__c.getValues('InternallyStewardedAccounts');
        if (item != null && String.isNotBlank(item.Configuration_Value_gne__c)) {
            internallyStewardedAccountTypes.addAll(item.Configuration_Value_gne__c.split(','));
        }
    }

    private void setAlignmentLastSyncDateTime() {
        if (jobMode && alignmentJob.ETL_LastSynch_gne__c != null) {
            lastSyncDateTime = alignmentJob.ETL_LastSynch_gne__c;
        } else {
            GNE_Foun_Misc_Config_Items_gne__c configItem = GNE_Foun_Misc_Config_Items_gne__c.getAll().get('AccountAlignmentETLLastSynchDateTime');
            String lastSyncAsString = configItem != null ? configItem.Configuration_Value_gne__c : null;
            lastSyncDateTime = String.isNotBlank(lastSyncAsString) ? Datetime.valueOfGmt(lastSyncAsString) : System.now();
        }
    }

    private String getOrganizationType(String jsonString) {
        CORE_Subscribe_Base.JsonCodeValueList orgTypeWrapper = ((List<CORE_Subscribe_Base.JsonCodeValueList>) JSON.deserialize(jsonString, List<CORE_Subscribe_Base.JsonCodeValueList>.class))[0];
        return orgTypeWrapper.code;
    }

    private Boolean isInternallyStewarded(CORE_Pub_Party__c party) {
        Boolean isOrganization = party.Type_gne__c == 'ORG';
        if (isOrganization) {
            String organizationType = getOrganizationType(party.Org_Type_json_gne__c);
            if (internallyStewardedAccountTypes.contains(organizationType)) {
                return true;
            }
        }
        return false;
    }

    /*Return sfdc id if present otherwise mdmid. */
    private String getAccountIdentifier(Staging_Alignment_gne__c sAlign) {
        String identifier;
        try {
            identifier = Id.valueOf(sAlign.Account_ID_gne__c);
        } catch (Exception e) {
            if (String.isNotBlank(sAlign.MDM_ID_gne__c)) {
                identifier = sAlign.MDM_ID_gne__c;
            } else {
                identifier = sAlign.Account_ID_gne__c;
            }
        }
        return identifier;
    }

    private static String printDetailTable(Map<String, AlignmentDetail> details, AlignmentDetail totals) {
        List<String> territories = new List<String>(details.keySet());
        territories.sort();
        String result = '<table>';
        result += '<tr><th>Territory</th><th>Alignment Count based on Staging Alignment</th><th>Aligned in TSF Post ETL LastSynch DateTime</th><th>Expected # Accounts Aligned in TSF</th><th>Actual # Accounts Aligned in TSF</th><th># Accounts Aligned without any address</th><th>Alignment Errors</th><th>Overall Status</th></tr>';

        for (String territory : territories) {
            AlignmentDetail detail = details.get(territory);
            String[] reportData = new String[]{
                    detail.tr, String.valueOf(detail.sa), String.valueOf(detail.sy), String.valueOf(detail.ea), String.valueOf(detail.aa), String.valueOf(detail.na), String.valueOf(detail.er), String.valueOf(detail.getStatus())
            };
            result += String.format('<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td><td>{5}</td><td>{6}</td><td>{7}</td></tr>', reportData);
        }
        String[] reportData = new String[]{
                totals.tr, String.valueOf(totals.sa), String.valueOf(totals.sy), String.valueOf(totals.ea), String.valueOf(totals.aa), String.valueOf(totals.na), String.valueOf(totals.er), String.valueOf(totals.getStatus())
        };
        result += String.format('<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td><td>{5}</td><td>{6}</td><td>{7}</td></tr>', reportData);
        result += '</table>';
        return result;
    }

    private void updateAlignmentStatistics(Map<String, AlignmentDetail> statistics, List<Staging_Alignment_gne__c> stagingAlignments, String terrName) {
        Set<Id> accountsInTerr = new Set<Id>();
        Map<String, Set<Id>> territoryToAccounts = new Map<String, Set<Id>>();
        for (TSF_vod__c tsf : [SELECT Territory_vod__c, Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c = :terrName LIMIT 50000]) {
            if (!territoryToAccounts.containsKey(tsf.Territory_vod__c)) {
                territoryToAccounts.put(tsf.Territory_vod__c, new Set<Id>());
            }
            territoryToAccounts.get(tsf.Territory_vod__c).add(tsf.Account_vod__c);
            accountsInTerr.add(tsf.Account_vod__c);
        }
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, MDMID_gne__c, (SELECT Id FROM Address_vod__r) FROM Account WHERE Id IN :accountsInTerr LIMIT 50000]);

        Integer accountsInTsfPostLastSych = 0;
        Id terrId = null;
        if (territoryMap.containsKey(terrName)) {
            terrId = territoryMap.get(terrName).Id;
        }

        Integer errors = 0;

        //contains account id or account mdmid
        Set<String> accountsIds = new Set<String>();
        for (Staging_Alignment_gne__c alignment : stagingAlignments) {
            if (alignment.Status_gne__c == GNE_Subscribe_Batch_Base.STATUS_ERROR_PROCESSING || (previewMode && alignment.Comment_gne__c.contains(GNE_Subscribe_Batch_Base.STATUS_ERROR_PROCESSING))) {
                errors++;
            }
            accountsIds.add(getAccountIdentifier(alignment));
        }
        Integer expectedAccountsInTerr = terrName == EMPTY_TERRITORY ? 0 : stagingAlignments.size();

        Integer noAddress = 0;
        String code = '';
        if (terrId != null) {
            if (tsfsMap.containsKey(terrId)) {
                for (TSF_vod__c tsf : tsfsMap.get(terrId).values()) {
                    if (lastSyncDateTime < tsf.CreatedDate) {
                        accountsInTsfPostLastSych++;
                        if (!accountsIds.contains(tsf.Account_vod__c) && !accountsIds.contains(tsf.Account_vod__r.MDMID_gne__c)) {
                            expectedAccountsInTerr++;
                        }
                    }
                }
            }
            if (territoryToAccounts.containsKey(terrName)) {
                for (String accId : territoryToAccounts.get(terrName)) {
                    if (accounts.containsKey(accId)) {
                        noAddress += accounts.get(accId).Address_vod__r.size() == 0 ? 1 : 0;
                    } else {
                        System.debug('No account with id: ' + accId + '. Territory id: ' + terrId);
                    }
                }
            }
            if (territoryMap.containsKey(terrName)) {
                code = territoryMap.get(terrName).Salesforce_Code_gne__c;
            } else {
                System.debug('Missing terr: ' + terrName);
            }
        }
        Integer actualAlignedAccounts = territoryToAccounts.containsKey(terrName) ? territoryToAccounts.get(terrName).size() : 0;
        if (!statistics.containsKey(terrName)) {
            statistics.put(terrName, new AlignmentDetail(previewMode, terrName, code, stagingAlignments.size(), accountsInTsfPostLastSych, expectedAccountsInTerr, actualAlignedAccounts, noAddress, errors));
        } else {
            AlignmentDetail detail = statistics.get(terrName);
            detail.sa += stagingAlignments.size();
            detail.aa = actualAlignedAccounts;
            detail.na = noAddress;
            detail.er += errors;
            detail.ea += expectedAccountsInTerr;
        }
    }

    class AlignmentDetail {
        private Boolean previewMode;
        //territory
        public String tr { get; private set; }
        //teamCode
        public String tc { get; private set; }
        //alignmentBaseOnStagingAlignment
        private Integer sa { get; set; }
        //alignedInTsfPostETLLastSynch
        private Integer sy { get; set; }
        //expectedAlignedAccounts
        private Integer ea { get; set; }
        //actualAlignedAccounts
        private Integer aa { get; set; }
        //alignedAccountsWithoutAdresses
        private Integer na { get; set; }
        //alignmentsErros
        private Integer er { get; set; }

        public AlignmentDetail(Boolean previewMode, String territory, String teamCode, Integer alignmentBaseOnStagingAlignment, Integer alignedInTsfPostETLLastSynch, Integer expectedAlignedAccounts, Integer actualAlignedAccounts, Integer alignedAccountsWithoutAdresses, Integer alignmentsErros) {
            this.previewMode = previewMode;
            this.tr = territory;
            this.tc = teamCode;
            this.sa = alignmentBaseOnStagingAlignment;
            this.sy = alignedInTsfPostETLLastSynch;
            this.ea = expectedAlignedAccounts;
            this.aa = actualAlignedAccounts;
            this.na = alignedAccountsWithoutAdresses;
            this.er = alignmentsErros;
        }

        public String getStatus() {
            if (previewMode) {
                return er == 0 ? STATUS_OK : STATUS_ERROR;
            }
            return ea == aa && er == 0 ? STATUS_OK : STATUS_ERROR;
        }
    }

    public static AlignmentDetail getTotals(List<AlignmentDetail> statistics) {
        Integer totalAlignments = 0;
        Integer totalAccountsInTsfPostLastSych = 0;
        Integer totalTsfes = 0;
        Integer totalErrors = 0;
        Integer totalExpectedAccounts = 0;
        Integer totalNoAddress = 0;
        String codes = '';
        Boolean previewMode = false;
        Set<String> uniqueCodes = new Set<String>();
        for (AlignmentDetail detail : statistics) {
            previewMode = detail.previewMode;
            totalAlignments += detail.sa;
            totalAccountsInTsfPostLastSych += detail.sy;
            totalExpectedAccounts += detail.ea;
            totalTsfes += detail.aa;
            totalNoAddress += detail.na;
            totalErrors += detail.er;
            if (String.isNotEmpty(detail.tc) && uniqueCodes.add(detail.tc)) {
                codes += detail.tc + ';';
            }
        }
        codes = codes.removeEnd(';');
        if (codes.length() > 200) {
            codes = codes.substring(0, 200);
        }
        return new AlignmentDetail(previewMode, 'Total', codes, totalAlignments, totalAccountsInTsfPostLastSych, totalExpectedAccounts, totalTsfes, totalNoAddress, totalErrors);
    }

    public static String getHtmlReport(String jsonReport) {
        Map<String, AlignmentDetail> statistics = (Map<String, AlignmentDetail>) JSON.deserialize(jsonReport, Map<String, AlignmentDetail>.class);
        AlignmentDetail totals = getTotals(statistics.values());
        return printDetailTable(statistics, totals);
    }

}