public without sharing virtual class CORE_Merge_Preprocessing implements Database.Batchable<SObject>, Database.Stateful, CORE_Merge_Interface.MergeEngineBatchInterface{
    private CORE_Merge_Util.MergeJobWrapper mergeJob;
    private Boolean isPreviewMode;
    private Set<String> winnerIds;
    private CORE_Merge_Object__c mergeObjectRecord;
    private Boolean initialized;
    private List<CORE_Merge_Candidate__c> duplicatesGroup;
    private String lastMasterId;
    private CORE_Merge_Engine mergeEngine = new CORE_Merge_Engine();
    private transient CORE_Merge_Util.MergeObjectWrapper mergeObject;
    private CORE_Merge_LongRelatedListFinder.InitDataWrapper dataWrapper;

    List<CORE_Merge_IntPreprocessing.ResultWrapper> inputWrapper;
    CORE_Merge_IntPreprocessing.ResultWrapper currentInput;
    
    public CORE_Merge_Preprocessing(List<CORE_Merge_IntPreprocessing.ResultWrapper> inputWrapper, CORE_Merge_LongRelatedListFinder.InitDataWrapper dataWrapper){
        CORE_Merge_Util.switchAdminMode(true);
        this.inputWrapper = inputWrapper;
        this.dataWrapper = dataWrapper;
        this.isPreviewMode = dataWrapper.isPreviewMode;
        this.mergeJob = dataWrapper.mergeJob;
    }
    
    public virtual Database.QueryLocator start(Database.batchableContext BC) {
        currentInput = inputWrapper.isEmpty() ? null : inputWrapper[0];
        String query;
        Set<Id> loserIds;
        if(currentInput != null) {
            loserIds = currentInput.validatedCurrentId2reparentTo.keySet();
            query = prepareQuery();
        } else {
            query = ' SELECT Id FROM Account WHERE Id IN (\'001xxxxxxxxxxxxxxx\')';
        }

        return Database.getQueryLocator(query);
    }
    
    public virtual void execute(Database.BatchableContext BC, List<SObject> scope) {
        String fieldName = currentInput.relationFieldApiName;
        for(SObject recordToReparent : scope){
            Id loserId = (Id)recordToReparent.get(fieldName);
            Id winnerId = currentInput.validatedCurrentId2reparentTo.get(loserId);
            recordToReparent.put(fieldName, winnerId);             
        } 
        System.Savepoint sp = Database.setSavepoint();
        
        Database.update(scope, false);
        

        if(isPreviewMode()) {
            Database.rollback(sp);
        }        
    }

    private String prepareQuery(){
        return String.format(
            'SELECT Id, {0} FROM {1} WHERE {0} IN : loserIds',
            new List<String> {currentInput.relationFieldApiName, currentInput.objectApiName}
        );
    }
    
    public virtual CORE_Merge_Interface.MergeEngineInterface getMergeEngine() {
        return this.mergeEngine;
    }
    
    public virtual void finish(Database.BatchableContext BC) {  
        inputWrapper.remove(0);
        CORE_Merge_Engine_Batch mergeBatch;
        Id result = null;
        if(!inputWrapper.isEmpty()){
            CORE_Merge_Preprocessing job = new CORE_Merge_Preprocessing(inputWrapper, dataWrapper);
            result = Database.executeBatch(job, 1000);
        } else {
            mergeBatch = new CORE_Merge_Engine_Batch();
            mergeBatch.initBatch(dataWrapper.mergeObjectId, dataWrapper.isPreviewMode, dataWrapper.winnerIds, dataWrapper.scopeLimit, dataWrapper.durationLimit, dataWrapper.mergeJob);
            mergeBatch.executeBatch(dataWrapper.mergeObjectId);
        }
        CORE_Merge_Util.switchAdminMode(false);
        if(result != null) {
            CORE_Merge_Job__c job = dataWrapper.mergeJob.getMergeJob();
            List<String> batchIds = String.isNotBlank(job.Batch_Ids_json_gne__c) ? (List<String>)JSON.deserialize(job.Batch_Ids_json_gne__c, List<String>.class) : new List<String>() ;
            batchIds.add(result);
            job.Batch_Ids_json_gne__c = JSON.serialize(batchIds);
            update job;
        }
    }    
    
    public virtual void initBatch(Id mergeObjectId) {
        initBatch(mergeObjectId, false, null, null, null);
    }
    
    public virtual void initBatch(Id mergeObjectId, CORE_Merge_Interface.MergeJobInterface mergeJob) {
        initBatch(mergeObjectId, false, null, null, null, mergeJob);
    }
    
    public virtual void initBatch(Id mergeObjectId, Boolean isPreviewMode, Set<String> winnerIds, Integer scopeLimit, Long durationLimit) {
        initBatch(mergeObjectId, isPreviewMode, winnerIds, scopeLimit, durationLimit, null);
    }
    
    public virtual void initBatch(Id mergeObjectId, Boolean isPreviewMode, Set<String> winnerIds, Integer scopeLimit, Long durationLimit, CORE_Merge_Interface.MergeJobInterface mergeJob) {
        CORE_Merge_Configuration.readConfiguration(mergeObjectId);
        this.mergeObjectRecord = CORE_Merge_Configuration.getMergeObject(mergeObjectId);
        this.winnerIds = winnerIds;
        this.isPreviewMode = isPreviewMode;
        this.mergeJob = (CORE_Merge_Util.MergeJobWrapper)mergeJob;
        
        if(mergeJob==null) {
            this.mergeJob = new CORE_Merge_Util.MergeJobWrapper(new CORE_Merge_Job__c(Merge_Object_gne__c = mergeObjectId));
            this.mergeJob.setPreviewMode(isPreviewMode);
            this.mergeJob.getMergeJob().Type_gne__c = getMergeJobType();
            this.mergeJob.setScopeLimit(scopeLimit);
            this.mergeJob.setDurationLimit(durationLimit);
            this.mergeJob.saveJob();
        }
        
        this.initialized = true;
    }
    
    private String getMergeJobType() {
        return isPreviewMode()
            ? (getWinnerIds()==null ? CORE_Merge_Util.MERGE_JOB_TYPE_MERGE_PERVIEW_MODE : CORE_Merge_Util.MERGE_JOB_TYPE_MERGE_PREVIEW_SINGLE_MODE)
            : (getWinnerIds()==null ? CORE_Merge_Util.MERGE_JOB_TYPE_MERGE : CORE_Merge_Util.MERGE_JOB_TYPE_MERGE_SINGLE_MODE);
    }    
    
    public virtual System.Type getBatchType() {
        return CORE_Merge_Engine_Batch.class;
    }
    
    public virtual CORE_Merge_Object__c getMergeObjectRecord() {
        return this.mergeObjectRecord;
    }
    
    public virtual CORE_Merge_Util.MergeObjectWrapper getMergeObject() {
        if(this.mergeObject==null) {
            this.mergeObject = new CORE_Merge_Util.MergeObjectWrapper(getMergeObjectRecord());
        }
        
        return this.mergeObject;
    }
    
    public virtual CORE_Merge_Util.MergeJobWrapper getMergeJob() {
        return this.mergeJob;
    }
    
    public virtual Integer getScopeSize() {
        Integer result=1;
        
        if(this.initialized==true) {
            Map<String,Object> attrs = (Map<String,Object>)getMergeObject().getPropertyAttributes(CORE_Merge_Configuration.MergeProperty.MergeEngineBatch);
            result = attrs!=null && attrs.containsKey(CORE_Merge_Configuration.ATTRIBUTE_SCOPE_SIZE) ? (Integer)attrs.get(CORE_Merge_Configuration.ATTRIBUTE_SCOPE_SIZE) : result;  
        }
        
        return result;
    }
    
    public virtual Id executeBatch(Id mergeObjectId) {
        Id result = null;
        
        if(this.initialized!=true) {
            initBatch(mergeObjectId);
        }
            
        result = Database.executeBatch(this, getScopeSize());
        getMergeJob().addBatchId(result);
        getMergeJob().saveJob();
        return result;
    }
    
    public virtual Id scheduleBatch(Id mergeObjectId, String jobName, Integer minutesFromNow) {
        Id result = null;
        
        if(this.initialized!=true) {
            initBatch(mergeObjectId);
        }
        
        if(this.initialized==true) {
            result = System.scheduleBatch(this, jobName, minutesFromNow, getScopeSize());
        }
        
        return result;
    }
    
    public void setSchedulerArguments(Map<String,String> args) {}
    
    public virtual Boolean isPreviewMode() {
        return this.isPreviewMode;
    }
    
    public virtual Set<String> getWinnerIds() {
        return this.winnerIds;
    }
}