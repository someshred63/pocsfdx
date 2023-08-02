public without sharing virtual class CORE_Merge_Populate_Candidates_Batch implements Database.Batchable<SObject>, Database.Stateful, CORE_Merge_Interface.PopulateCandidatesBatchInterface {
    protected CORE_Merge_Util.MergeJobWrapper mergeJob;
    protected CORE_Merge_Object__c mergeObjectRecord;
    protected Boolean initialized;
    protected List<SObject> duplicatesGroup;
    protected CORE_Merge_Interface.MergeEngineInterface mergeEngine;
    protected transient CORE_Merge_Util.MergeObjectWrapper mergeObject;
    
    public CORE_Merge_Populate_Candidates_Batch() {}
    
    public virtual void initBatch(Id mergeObjectId) {
        initBatch(mergeObjectId, null, false);
    }
    
    public virtual void initBatch(Id mergeObjectId, Set<Id> winnerIds, Boolean isPreviewMode) {
        CORE_Merge_Configuration.readConfiguration(mergeObjectId);
        this.mergeObjectRecord = CORE_Merge_Configuration.getMergeObject(mergeObjectId);
        this.mergeJob = new CORE_Merge_Util.MergeJobWrapper(new CORE_Merge_Job__c(Merge_Object_gne__c = getMergeObjectRecord().Id, Type_gne__c = CORE_Merge_Util.MERGE_JOB_TYPE_POPULATE_CANDIDATES));
        this.mergeJob.saveJob();
        this.initialized = true;
    }
    
    public virtual System.Type getBatchType() {
        return CORE_Merge_Populate_Candidates_Batch.class;
    }
    
    public virtual Integer getScopeSize() {
        Integer result=1;
        
        if(this.initialized==true) {
            Map<String,Object> attrs = (Map<String,Object>)getMergeObject().getPropertyAttributes(CORE_Merge_Configuration.MergeProperty.PopulateCandidatesBatch);
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
        
        if(this.initialized==true) {
            result = System.scheduleBatch(this, jobName, minutesFromNow, getScopeSize());
        }
        
        return result;
    }
    
    public void setSchedulerArguments(Map<String,String> args) {}
    
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
    
    public virtual CORE_Merge_Interface.MergeEngineInterface getMergeEngine() {
        return this.mergeEngine;
    }
    
    public virtual Database.QueryLocator start(Database.batchableContext BC) {
        initOnStart(BC);
        Database.QueryLocator queryLocator = null;
        
        if(getMergeObject().isPopulateCandidatesEnabled()) {
            String query = getMergeEngine().getPopulateCandidatesQuery(getMergeObjectRecord());
            queryLocator = Database.getQueryLocator(query);
        }
        
        return queryLocator;
    }
    
    protected virtual void initOnStart(Database.batchableContext BC) {
        if(BC!=null) {
            getMergeJob().addBatchId(BC.getJobId());
        }
        
        this.mergeJob.markAsInProgress();
        this.duplicatesGroup = new List<SObject>();
        CORE_Merge_Interface.MergeEngineInterface mergeEngine = (CORE_Merge_Interface.MergeEngineInterface)getMergeObject().getPropertyValue(CORE_Merge_Configuration.MergeProperty.MergeEngine);
        this.mergeEngine = mergeEngine!=null ? mergeEngine : new CORE_Merge_Engine();
        this.mergeEngine.initEngine(mergeJob, false, false);
    }
    
    public virtual void execute(Database.BatchableContext BC, List<SObject> scope) {
        duplicatesGroup = getMergeEngine().populateCandidates(getMergeObjectRecord(), scope, isLastProcessJob(BC));
    }
    
    public virtual void finish(Database.BatchableContext BC) {
        try {
	        if(duplicatesGroup.size()>1) {
	            getMergeEngine().populateCandidates(getMergeObjectRecord(), duplicatesGroup, true);
	        }
        } finally {
	        getMergeJob().markAsCompleted();
        }
    }
    
    protected virtual Boolean isLastProcessJob(Database.BatchableContext BC) {
        Boolean isLastProcessJob = false;
        
        if(BC!=null) {
	        List<AsyncApexJob> jobs = [SELECT JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :BC.getJobId() LIMIT 1];
	        
	        for(AsyncApexJob job : jobs) {
	            if(job.JobItemsProcessed!=null && job.TotalJobItems!=null) {
	                isLastProcessJob = (job.JobItemsProcessed+1)>=job.TotalJobItems;
	            }
	        }
        }
                    
        return isLastProcessJob;
    }
}