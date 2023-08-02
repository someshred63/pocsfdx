/**
* @author Bartosz Osowiecki
* @date 2016
*
* @description Container for all CORE Merge Interfaces.
*/
public class CORE_Merge_Interface {
    /**
    * @description Current State of Merge Process.
    */
    public enum MergeProcessState {
            Start, 
            BeforePopulateSourceData, AfterPopulateSourceData,
            BeforeValidate, AfterValidate, 
            BeforePrepareArchiveData, AfterPrepareArchiveData,
            BeforeUpdateWinnerFields, AfterUpdateWinnerFields,
            BeforePreMergeActions, AfterPreMergeActions,
            BeforeUpdateWinner, AfterUpdateWinner,
            BeforeMergeCandidates, AfterMergeCandidates,
            BeforePopulateChildCandidates, AfterPopulateChildCandidates,
            BeforeMergeChildCandidates, AfterMergeChildCandidates,
            BeforePostMergeActions, AfterPostMergeActions,
            BeforeSaveArchiveData, AfterSaveArchiveData,
            //Populate Candidates mode
            BeforePopulateCandidates, AfterPopulateCandidates,
            Finish
    }
    
    /**
    * @description Responsible for managing environment Admin Mode setting. It can turn on/off or check current status of Admin Mode.
    */
    public interface AdminModeManagerInterface {
        /**
        * @description Used to turn on/off Admin Mode
        * @param turnOnOrOff - Turns on or off Admin Mode
        * @return previous Admin Mode setting
        */
        Boolean switchAdminMode(Boolean turnOnOrOff);
        /**
        * @description Determinies if Admin Mode is turned on or off
        * @return (true/false)
        */
        Boolean isAdminMode();
    }
    
    /**
    * @description Config Manager responsible for reading and storing Merge Configuration.
    */
    public interface ConfigManagerInterface {
        void readProperty(CORE_Merge_Configuration__c propRec);
        Object getPropertyValue(String propName);
        Object getPropertyValue(String propType, String propKey);
        Set<String> getPropertyKeysByType(String propType);
        Map<String,Object> getPropertiesByType(String propType);
        String getPropertyErrorCode(String propType, String propKey);
        Map<String,Map<String,Object>> getPropertiesByTypes(Set<String> propTypes);
        Object getPropertyAttributes(String propKey);
        Object getPropertyAttributes(String propType, String propKey);
    }
    
    /**
    * @description Interface for Merge Scheduler.
    */
    public interface SchedulerInterface {
        
    }
    
    /**
    * @description Merge Process Batch Interface.
    */
    public interface MergeEngineBatchInterface extends MergeBatchInterface {
        void initBatch(Id mergeObjectId, Boolean isPreviewMode, Set<String> winnerIds, Integer scopeLimit, Long durationLimit);
        void initBatch(Id mergeObjectId, MergeJobInterface mergeJob);
        Boolean isPreviewMode();
        Set<String> getWinnerIds();
    }
    
    /**
    * @description Populate Candidates Batch Interface.
    */
    public interface PopulateCandidatesBatchInterface extends MergeBatchInterface {}
    
    /**
    * @description Populate Candidates Batch Interface.
    */
    
    public interface MergeBatchInterface {
        void initBatch(Id mergeObjectId);
        System.Type getBatchType();
        CORE_Merge_Object__c getMergeObjectRecord();
        MergeObjectInterface getMergeObject();
        MergeJobInterface getMergeJob();
        Integer getScopeSize();
        Id executeBatch(Id mergeObjectId);
        Id scheduleBatch(Id mergeObjectId, String jobName, Integer minutesFromNow);
        void setSchedulerArguments(Map<String,String> args);
    }
    
    /**
    * @description Merge Process Engigne Interface.
    */
    public interface MergeEngineInterface {
        void initEngine();
        void initEngine(CORE_Merge_Job__c mergeJob, Boolean isPreviewMode, Boolean isSubProcess);
        void initEngine(MergeJobInterface mergeJob, Boolean isPreviewMode, Boolean isSubProcess);
        Boolean isPreviewMode();
        MergeEnigneCacheInterface getCache();
        String getSystemTimeStamp();
        String getCurrentState();
        MergeObjectInterface getMergeObject();
        MergeJobInterface getMergeJob();
        CORE_Merge_Object__c getMergeObjectRecord();
        List<MergeGroupInterface> getMergeGroups();
        MergeGroupInterface getSingleMergeGroup();
        List<MergeGroupInterface> getValidMergeGroups();
        void doMerge(CORE_Merge_Candidate__c wmc, List<CORE_Merge_Candidate__c> allmcs);
        void doOtherWorkAfterMerge();
        String getPopulateCandidatesQuery(CORE_Merge_Object__c mergeObjRec);
        List<SObject> populateCandidates(CORE_Merge_Object__c mergeObjRec, List<SObject> recs, Boolean processLastGroup);
        void handleException(Exception ex, MergeCandidateInterface mc);
        void handleException(Exception ex, List<MergeGroupInterface> mergeGroups);
        void handleException(Exception ex, List<MergeGroupInterface> mergeGroups, List<MergeCandidateInterface> mcs);
    }
    
    /**
    * @description Merge Process Cache used to store data used between Apex transactions.
    */
    public interface MergeEnigneCacheInterface {
        List<MergeGroupInterface> getMergeGroups();
        Map<Id,List<MergeGroupInterface>> getChildMergeGroupsToProcess();
        List<MergeGroupInterface> getChildMergeGroupsToLoad();
        List<ErrorInterface> getErrors();
        Map<String,CORE_Merge_Archive_Record__c> getWinnerArchiveRecs();
        Map<String,CORE_Merge_Archive_Record__c> getLoserArchiveRecs();
        List<SObject> getArchiveChildRecords();
        List<CORE_Merge_Archive_JSON_Part__c> getArchiveJsonParts();
        Map<String,SObject> getArchiveClones();
    }
    
    /**
    * @description Merge Object Interface.
    */
    public interface MergeObjectInterface {
        CORE_Merge_Object__c getMergeObject();
        String getSObjectName();
        String getMergeObjectLabel();
        Double getOrder();
        Object getPropertyValue(String propName);
        Object getPropertyValue(String propType, String propKey);
        Boolean getPropertyBooleanValue(String propName);
        String getPropertyStringValue(String propName);
        List<String> getPropertyListValue(String propName);
        Set<String> getPropertyKeysByType(String propType);
        Map<String,Object> getPropertiesByType(String propType);
        Map<String,Map<String,Object>> getPropertiesByTypes(Set<String> propTypes);
        Object getPropertyAttributes(String propName);
        Object getPropertyAttributes(String propType, String propKey);
        String getPropertyErrorCode(String propType, String propKey);
        List<MergeObjectInterface> getChildMergeObjects();
        List<MergeObjectInterface> getNextMergeObjects();
        MergeEngineBatchInterface getMergeBatch();
        MergeEngineBatchInterface getPreProcess();
        PopulateCandidatesBatchInterface getPopulateCandidatesBatch();
        Id executeMergeJob();
        Id executeMergeJob(Boolean isPreviewMode, Set<String> winnerIds, Integer scopeLimit, Long durationLimit);
        Id executeMergeJob(MergeJobInterface mergeJob);
        Id executePopulateCandidatesJob();
        Id executePreProcessJob(Boolean isPreviewMode, Set<String> winnerIds, Integer scopeLimit, Long durationLimit);
    }
    
    /**
    * @description Merge Job Interface.
    */
    public interface MergeJobInterface {
        CORE_Merge_Job__c getMergeJob();
        MergeObjectInterface getMergeObject();
        String getMergeObjectLabel();
        String getStatus();
        String getStatusLabel();
        String getType();
        String getTypeLabel();
        Boolean isPopulateCandidates();
        DateTime getLastModifiedDate();
        List<String> getBatchIds();
        void addBatchId(String batchId);
        List<AsyncApexJob> getBatchJobs();
        String getSummary();
        void setSummary(String summary);
        String prepareSummary();
        void markAsInProgress();
        void markAsCompleted();
        void saveJob();
        Boolean isBatchInProgress();
        Boolean isInProgress();
        Map<String,JobMetricsInterface> getMetrics();
        void addMetrics(JobMetricsInterface jobMetrics);
        String getLastBatchStatus();
        Integer getProcessedBatchesSize();
        Integer getAllBatchesSize();
        Integer getBatchFailuresSize();
        Integer getMergeGroupsSize();
        Integer getValidMergeGroupsSize();
        Integer getCandidatesSize();
        Integer getValidCandidatesSize();
        Integer getPopulatedMergeGroupsSize();
        Integer getPopulatedCandidatesSize();
        Integer getRuntimeErrorsSize();
        Integer getErrorsSize();
        Map<String,Integer> getErrorCodesSize();
        String getProgressDescription();
        String getDurationDescription();
        List<String> getMetricsDescription();
        Integer getScopeSize();
        void increaseScopeSize(Integer scopeSize);
        Integer getRemainingScopeLimit();
        Boolean isScopeLimitExceeded();
        Long getDurationLimit();
        void setDurationLimit(Long durationLimit);
        Boolean isDurationLimitExceeded();
        Set<Id> getVisitedMergeObjectIds();
        Boolean isPreviewMode();
        void setPreviewMode(Boolean isPreviewMode);
    }
    
    /**
    * @description Job Metrics Interface.
    */
    public interface JobMetricsInterface {
        Id getMergeObjectId();
        Integer getMergeGroupsSize();
        Integer getValidMergeGroupsSize();
        Integer getCandidatesSize();
        Integer getValidCandidatesSize();
        Integer getPopulatedMergeGroupsSize();
        Integer getPopulatedCandidatesSize();
        Integer getErrorsSize();
        Integer getRuntimeErrorsSize();
        Map<String,Integer> getErrorCodesSize();
        void add(JobMetricsInterface jobMetric);
        void increaseMergeGroupsSize(Integer val);
        void increaseValidMergeGroupsSize(Integer val);
        void increaseCandidatesSize(Integer val);
        void increaseValidCandidatesSize(Integer val);
        void increasePopulatedMergeGroupsSize(Integer val);
        void increasePopulatedCandidatesSize(Integer val);
        void increaseErrorsSize(Integer val);
        void increaseErrorCodesSize(String errCode, Integer val);
    }
    
    /**
    * @description Duplicates (Merge Candidates with the same Winner) Group Interface.
    */
    public interface MergeGroupInterface {
        Id getWinnerId();
        List<Id> getAllIds();
        MergeCandidateInterface getWinnerCandidate();
        List<MergeCandidateInterface> getAllCandidates();
        List<MergeCandidateInterface> getLoserCandidates();
        CORE_Merge_Object__c getMergeObject();
        String getSObjectName();
        void setIsValid(Boolean isValid);
        Boolean isValid();
    }
    
    /**
    * @description Merge Candidate (Winner or Loser) Interface.
    */
    public interface MergeCandidateInterface {
        CORE_Merge_Candidate__c getCandidate();
        MergeGroupInterface getMergeGroup();
        String print();
        SObject getSourceRecord();
        SObject getSourceRecordForValidate();
        SObject getSourceRecordForArchive();
        SObject getSourceRecordToUpdate();
        String getSourceId();
        String getMasterId();
        Boolean isWinner();
        Boolean isSourceValid();
        void setIsChanged(Boolean isChanged);
        Boolean isChanged();
        SObject getArchiveClone();
        CORE_Merge_Archive_Record__c getArchiveRecord();
        List<SObject> getArchiveChildRecords();
        List<CORE_Merge_Archive_JSON_Part__c> getArchiveJsonParts();
        void addError(CORE_Merge_Object__c mObj, Exception ex);
        void addError(CORE_Merge_Object__c mObj, Exception ex, Boolean isOwnError);
        List<ErrorInterface> getErrors();
    }
    
    /**
    * @description Merge Error Interface.
    */
    public interface ErrorInterface {
        CORE_Merge_Object__c getMergeObject();
        String getSObjectName();
        String getCode();
        String getType();
        String getShortDescription();
        String getDescription();
        String getStackTrace();
        CORE_Merge_Error__c asErrorRecord(MergeJobInterface job, MergeCandidateInterface mc);
    }
    
    /**
    * @description Merge Error Interface.
    */
    public interface RelationshipConfigInterface {
        Set<String> getQueryFields();
        String getQueryWhere();
        String getQueryOrderBy();
        Integer getQueryLimit();
        String getRelationshipName();
        void setRelationshipName(String relationshipName);
        String getArchiveType();
    }
    
    /**
    * @description Merge Error Interface.
    */
    public interface PopulateCandidateConfigInterface {
        Boolean isEnabled();
        Boolean isPopulateFromParentEnabled();
        Boolean isMergeFromParentEnabled();
        String getQueryUniqueField();
        String getQueryWhere();
        String getQueryBatchWhere();
        List<String> getQuerySortBy();
    }
    
    /**
    * @description Scheduler Merge Job Interface.
    */
    public interface SchedulerConfigInterface {
        String getCronExpression();
        String getJobType();
        Integer getScopeLimit();
        Long getDurationLimit();
        Map<String,String> getJobArguments();
        void validateJobType();
        void parseCronExpression();
        Boolean matches(DateTime dTime);
    }
    
    /**
    * @description Candidate Exception Interface.
    */
    public interface MergeCandidateExceptionInterface {
        String getErrorCode();
        String getErrorType();
    }
    
    /**
    * @description DML Result Interface. Used for all kinds of DMLs e.g. Insert, Upsert, Delete
    */
    public interface DmlResultInterface {
        Boolean isSuccess();
        List<Database.Error> getErrors();
        MergeCandidateInterface getCandidate();
    }
    
    /**
    * @description Custom Merge Process Listener Interface. Can be used in CustomMergeEngineListner Merge Configuration Rule
    */
    public interface CustomMergeEngineListnerInterface {
        /**
        * @description Listener Notification Action
        * @param state - Current Merge Process state
        * @param mergeObject - Current Merge Object
        * @param mergeGroup - Current Merge Group (Set of Merge Candidates with the same Winner)
        * @param mergeEngine - Merge Engine
        */
        void mergeNotifyOnAction(MergeProcessState state, MergeObjectInterface mergeObject, List<MergeGroupInterface> mergeGroups, MergeEngineInterface mergeEngine);
    }
    
    /**
    * @description Custom Merge Validation Interface. Can be used in CustomMergeValidation Merge Configuration Rule
    */
    public interface CustomValidationInterface {
        /**
        * @description Custom Validation Action
        * @param vrName - Unique Validation Rule Name
        * @param mergeObject - Current Merge Object
        * @param mergeGroup - Current Merge Group (Set of Merge Candidates with the same Winner)
        * @param mergeEngine - Merge Engine
        * @return True - Candidates are valid, False - otherwise
        */
        Boolean mergeValidate(String vrName, MergeObjectInterface mergeObject, MergeGroupInterface mergeGroup, MergeEngineInterface mergeEngine);
    }
    
    /**
    * @description Custom Merge Pre-Action Interface. Can be used in CustomPreMergeAction Merge Configuration Rule
    */
    public interface CustomPreMergeActionInterface {
        /**
        * @description Custom Merge Pre-Action
        * @param actionName - Unique Action Name
        * @param mergeObject - Current Merge Object
        * @param mergeGroup - Current Merge Group (Set of Merge Candidates with the same Winner)
        * @param mergeEngine - Merge Engine
        * @return True - Winner was changed, False - otherwise
        */
        Boolean mergeExecutePreAction(String actionName, MergeObjectInterface mergeObject, MergeGroupInterface mergeGroup, MergeEngineInterface mergeEngine);
    }
    
    /**
    * @description Custom Merge Post-Action Interface. Can be used in CustomPostMergeAction Merge Configuration Rule
    */
    public interface CustomPostMergeActionInterface {
        /**
        * @description Custom Merge Post-Action
        * @param actionName - Unique Action Name
        * @param mergeObject - Current Merge Object
        * @param mergeGroup - Current Merge Group (Set of Merge Candidates with the same Winner)
        * @param mergeEngine - Merge Engine
        */
        void mergeExecutePostAction(String actionName, MergeObjectInterface mergeObject, MergeGroupInterface mergeGroup, MergeEngineInterface mergeEngine);
    }
    
    /**
    * @description Custom Merge Field Transition Interface. Can be used in FieldCustomTransfer Merge Configuration Rule
    */
    public interface CustomFieldTransferInterface {
        /**
        * @description Custom Field Transition Action
        * @param fieldName - Field API Name
        * @param mergeObject - Current Merge Object
        * @param mergeGroup - Current Merge Group (Set of Merge Candidates with the same Winner)
        * @param mergeEngine - Merge Engine
        * @return New Field Value
        */
        Object mergeTransferField(String fieldName, MergeObjectInterface mergeObject, MergeGroupInterface mergeGroup, MergeEngineInterface mergeEngine);
    }
    
    /**
    * @description Custom Merge Populate Candidate Post-Action Interface. Can be used in CustomPostPopulateAction Merge Configuration Rule
    */
    public interface CustomPostPopulateActionInterface {
        /**
        * @description Post Populate Action
        * @param actionName - Unique Action Name
        * @param mergeObject - Current Merge Object
        * @param duplicates - List of duplicated sObjects
        * @param mergeEngine - Merge Engine
        */
        void mergePostPopulateAction(String actionName, MergeObjectInterface mergeObject, List<SObject> duplicates, MergeEngineInterface mergeEngine);
    }
    
}