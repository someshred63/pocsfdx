public without sharing virtual class CORE_Merge_Engine_Batch implements Database.Batchable<SObject>, Database.Stateful, CORE_Merge_Interface.MergeEngineBatchInterface {
    private CORE_Merge_Util.MergeJobWrapper mergeJob;
    private Boolean isPreviewMode;
    private Set<String> winnerIds;
    private CORE_Merge_Object__c mergeObjectRecord;
    private Boolean initialized;
    private List<CORE_Merge_Candidate__c> duplicatesGroup;
    private String lastMasterId;
    private CORE_Merge_Interface.MergeEngineInterface mergeEngine;
    private transient CORE_Merge_Util.MergeObjectWrapper mergeObject;

    public CORE_Merge_Engine_Batch() {}
    
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
        return getMergeJob().isPreviewMode();
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
    
    public virtual Set<String> getWinnerIds() {
        return this.winnerIds;
    }
    
    public virtual CORE_Merge_Interface.MergeEngineInterface getMergeEngine() {
        return this.mergeEngine;
    }
    
    private Set<Id> getNextMergeObjectIds() {
        Set<Id> result = new Set<Id>();
        List<CORE_Merge_Util.MergeObjectWrapper> childMergeObjs = getMergeObject().getChildMergeObjects();
        
        if(childMergeObjs.isEmpty() && isSomethingToProcess(new Set<Id> {getMergeObjectRecord().Id})) {
            result.add(getMergeObjectRecord().Id);
        } else if(!childMergeObjs.isEmpty()) {
            for(CORE_Merge_Util.MergeObjectWrapper childMergeObj : childMergeObjs) {
                Id mergeObjId = childMergeObj.getMergeObject().Id;
                
                if(!getVisitedMergeObjectIds().contains(mergeObjId) && isSomethingToProcess(new Set<Id> {mergeObjId})) {
                    result.add(mergeObjId);
                    
                    if(!Test.isRunningTest()) { break; }
                } else {
                    getVisitedMergeObjectIds().add(mergeObjId);    
                }
            }
        }
        
        return result;
    }
    
    private Set<Id> getVisitedMergeObjectIds() {
        return getMergeJob().getVisitedMergeObjectIds();
    }
    
    private Boolean isSomethingToProcess(Set<Id> mergeObjIds) {
        CORE_Merge_Candidate__c [] candidates;
        if(isPreviewMode()){
            CORE_Merge_Util.MergeJobWrapper currentJob = CORE_Merge_Util.getCurrentJob();
            candidates = [
            SELECT Id , LastModifiedDate
            FROM CORE_Merge_Candidate__c
            WHERE Merge_Object_gne__c IN :mergeObjIds
                AND Status_gne__c IN (:CORE_Merge_Util.CANDIDATE_STATUS_LOADED)
                AND Type_gne__c IN (:CORE_Merge_Util.CANDIDATE_TYPE_MERGE)
                AND LastModifiedDate <  :currentJob.getMergeJob().CreatedDate
            LIMIT 1
            ];
        } else {
            candidates = [
            SELECT Id 
            FROM CORE_Merge_Candidate__c
            WHERE Merge_Object_gne__c IN :mergeObjIds
                AND Status_gne__c IN (:CORE_Merge_Util.CANDIDATE_STATUS_LOADED)
                AND Type_gne__c IN (:CORE_Merge_Util.CANDIDATE_TYPE_MERGE)
            LIMIT 1
            ];
    }
    
        return !candidates.isEmpty();
    }
    
    public virtual Database.QueryLocator start(Database.batchableContext BC) {
        initOnStart(BC);
        
        Set<Id> mObjIds = getNextMergeObjectIds();
        getVisitedMergeObjectIds().addAll(mObjIds);
        
        Database.QueryLocator queryLocator = null;
        
        if(getWinnerIds() == null) {
            Integer scopeLimit = getMergeJob().getRemainingScopeLimit();
            
            queryLocator = Database.getQueryLocator([
                SELECT
	               Id, External_Id_gne__c, Id_gne__c, Master_Id_gne__c, Merge_Object_gne__c
	            FROM CORE_Merge_Candidate__c
	            WHERE Merge_Object_gne__c IN :mObjIds
	               AND Status_gne__c IN (:CORE_Merge_Util.CANDIDATE_STATUS_LOADED)
	               AND Type_gne__c IN (:CORE_Merge_Util.CANDIDATE_TYPE_MERGE)
	            ORDER BY Merge_Object_gne__r.Order_gne__c, Master_Id_gne__c, Candidate_Type_calc_gne__c DESC
	            LIMIT :scopeLimit
	        ]);
        } else {
            queryLocator = Database.getQueryLocator([
                SELECT
                    Id, External_Id_gne__c, Id_gne__c, Master_Id_gne__c, Merge_Object_gne__c
                FROM CORE_Merge_Candidate__c
                WHERE Merge_Object_gne__c IN :mObjIds
                    AND Status_gne__c IN (:CORE_Merge_Util.CANDIDATE_STATUS_LOADED)
                    AND Type_gne__c IN (:CORE_Merge_Util.CANDIDATE_TYPE_MERGE)
                    AND (Master_Id_gne__c IN :getWinnerIds() OR MDM_Id_gne__c IN :getWinnerIds())
                ORDER BY Merge_Object_gne__r.Order_gne__c, Master_Id_gne__c, Candidate_Type_calc_gne__c DESC
            ]);
        }
        
        return queryLocator;
    }
    
    protected virtual void initOnStart(Database.batchableContext BC) {
        if(BC!=null) {
            this.getMergeJob().addBatchId(BC.getJobId());
        }
        
        this.getMergeJob().markAsInProgress();
        this.duplicatesGroup = new List<CORE_Merge_Candidate__c>();
        this.lastMasterId = null;
        CORE_Merge_Interface.MergeEngineInterface mergeEngine = (CORE_Merge_Interface.MergeEngineInterface)getMergeObject().getPropertyValue(CORE_Merge_Configuration.MergeProperty.MergeEngine);
        this.mergeEngine = mergeEngine!=null ? mergeEngine : new CORE_Merge_Engine();
        this.mergeEngine.initEngine(mergeJob, isPreviewMode(), false);
    }
    
    public virtual void execute(Database.BatchableContext BC, List<SObject> scope) {
        if(!getMergeJob().isDurationLimitExceeded()) {
            getMergeJob().increaseScopeSize(scope.size());
	        List<CORE_Merge_Candidate__c> mcs = (List<CORE_Merge_Candidate__c>)scope;
	        
	        for(CORE_Merge_Candidate__c mc : mcs) {
	            if(lastMasterId!=null && lastMasterId!=mc.Master_Id_gne__c) {
	                if(!duplicatesGroup.isEmpty()) {
	                    this.getMergeEngine().doMerge(duplicatesGroup[0], duplicatesGroup);
	                }
	        
	                duplicatesGroup.clear();
	            }
	    
	            duplicatesGroup.add(mc);
	            lastMasterId = mc.Master_Id_gne__c;
	        }
	        
	        intExecute(BC, false);
        }
    }
        
    protected virtual void intExecute(Database.BatchableContext BC, Boolean isOnFinish) {
        if(!duplicatesGroup.isEmpty() && (isOnFinish || isLastProcessJob(BC))) {
            Boolean otherDuplicatesExist = getMergeJob().getScopeLimit()!=null && ![
                SELECT Id
                FROM  CORE_Merge_Candidate__c
                WHERE Master_Id_gne__c = :duplicatesGroup[0].Master_Id_gne__c
                    AND Status_gne__c IN (:CORE_Merge_Util.CANDIDATE_STATUS_LOADED)
                    AND Type_gne__c IN (:CORE_Merge_Util.CANDIDATE_TYPE_MERGE)
                    AND Id NOT IN :duplicatesGroup
                LIMIT 1
            ].isEmpty();
            
            if(!otherDuplicatesExist) {
                getMergeEngine().doMerge(duplicatesGroup[0], duplicatesGroup);
            }
            
            duplicatesGroup.clear();
        } else {
            doOtherMergeActivities(isOnFinish);
        }
    }
    
    protected virtual void doOtherMergeActivities(Boolean isOnFinish) {
        getMergeEngine().doOtherWorkAfterMerge();
    }
    
    public virtual void finish(Database.BatchableContext BC) {        
        try {
            if(!getMergeJob().isDurationLimitExceeded()) {
                intExecute(BC, true);
            }
        } finally {
	        Set<Id> mObjIds = getNextMergeObjectIds();
	        Id newJobId = null;

	        if(getWinnerIds()==null && !mObjIds.isEmpty() && !getMergeJob().isScopeLimitExceeded() && !getMergeJob().isDurationLimitExceeded() ) {
	            try {
                    newJobId = getMergeObject().executeMergeJob(getMergeJob());
                } catch(Exception ex) {
                    List<String> emails = new List<String>();
                    if(String.isNotBlank(CORE_Merge_Configuration.MergeProperty.ReportEmail.name()))emails.add(CORE_Merge_Configuration.MergeProperty.ReportEmail.name());
                    if(String.isNotBlank(CORE_Merge_Configuration.MergeProperty.SupportEmail.name()))emails.add(CORE_Merge_Configuration.MergeProperty.SupportEmail.name());
                    emails = !emails.isEmpty() ? new List<String>(emails) : new List<String>{UserInfo.getUserEmail()};
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(emails);
                    mail.setSubject('Error during execute new job');
                    mail.setHtmlBody(ex.getStackTraceString() + '\n'+ex.getMessage() );
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail}, false);
                }
	        }

	        if(newJobId==null) {
	            Boolean stillSomethingToProcess = false;

	            if(!isPreviewMode() && (getMergeJob().isScopeLimitExceeded() || getMergeJob().isDurationLimitExceeded())) {
	                stillSomethingToProcess = isSomethingToProcess(mObjIds);
	            }
	            
                getMergeJob().markAsCompleted(stillSomethingToProcess);
            }
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