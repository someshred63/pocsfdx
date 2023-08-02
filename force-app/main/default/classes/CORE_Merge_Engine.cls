public without sharing virtual class CORE_Merge_Engine implements CORE_Merge_Interface.MergeEngineInterface {
    protected CORE_Merge_Util.MergeJobWrapper mergeJob;
    protected Boolean isPreviewMode;
    protected Boolean isSubProcess;
    protected Boolean prevAdminMode;
    protected CORE_Merge_Util.MergeEngineCache cache;
    protected String systemTimeStamp;
    protected CORE_Merge_Util.MergeObjectWrapper mergeObject;
    protected transient List<CORE_Merge_Util.MergeGroupWrapper> mergeGroups;
    protected transient Set<String> archiveCloneFieldSet;
    protected transient Set<String> visitedIds;
    protected transient CORE_Merge_Interface.MergeProcessState currentState;
    protected transient Map<String,List<SObject>> childRecordsCache;
    
    public static final String FIELD_ATTRIBUTE_NULL_VALUES = 'nullValues';
    public static final String FIELD_ATTRIBUTE_VALUE_SEPARATOR = 'valueSeparator';
    
    public CORE_Merge_Engine() {}
    
    public virtual void initEngine() {
        initEngine((CORE_Merge_Interface.MergeJobInterface)null, false, false);
    }
    
    public virtual void initEngine(CORE_Merge_Job__c mergeJob, Boolean isPreviewMode, Boolean isSubProcess) {
        initEngine(mergeJob!=null ? new CORE_Merge_Util.MergeJobWrapper(mergeJob) : null, isPreviewMode, isSubProcess);
    }
    
    public virtual void initEngine(CORE_Merge_Interface.MergeJobInterface mergeJob, Boolean isPreviewMode, Boolean isSubProcess) {
        this.mergeJob = (CORE_Merge_Util.MergeJobWrapper)mergeJob;
        this.isPreviewMode = isPreviewMode;
        this.isSubProcess = isSubProcess;
        this.systemTimeStamp = System.now().formatGmt('yyyyMMDD_HHmmss');
    }
    
    public virtual CORE_Merge_Util.MergeJobWrapper getMergeJob() {
        return this.mergeJob;
    }
    
    public virtual Boolean isPreviewMode() {
        return this.isPreviewMode==true;
    }
    
    public virtual Boolean isSubProcess() {
        return this.isSubProcess==true;
    }
    
    public virtual CORE_Merge_Util.MergeEngineCache getCache() {
        if(this.cache==null) {
            this.cache = new CORE_Merge_Util.MergeEngineCache();
        }
        
        return this.cache;
    }
    
    public virtual String getSystemTimeStamp() {
        return this.systemTimeStamp;
    }
    
    public virtual String getCurrentState() {
        return this.currentState!=null ? this.currentState.name() : null;
    }
    
    public virtual CORE_Merge_Util.MergeObjectWrapper getMergeObject() {
        return this.mergeObject;
    }
    
    public virtual void setMergeObjectRecord(CORE_Merge_Object__c mObjRec) {
        this.mergeObject = new CORE_Merge_Util.MergeObjectWrapper(mObjRec);
    }
    
    public virtual CORE_Merge_Object__c getMergeObjectRecord() {
        return getMergeObject().getMergeObject();
    }
    
    public virtual List<CORE_Merge_Util.MergeGroupWrapper> getMergeGroups() {
        return this.mergeGroups!=null ? this.mergeGroups : new List<CORE_Merge_Util.MergeGroupWrapper>();
    }
    
    public virtual List<CORE_Merge_Util.MergeGroupWrapper> getValidMergeGroups() {
        List<CORE_Merge_Util.MergeGroupWrapper> validMergeGroups = new List<CORE_Merge_Util.MergeGroupWrapper>();
        
        for(CORE_Merge_Util.MergeGroupWrapper mergeGroup : getMergeGroups()) {
            if(mergeGroup.isValid()) {
                validMergeGroups.add(mergeGroup);
            }
        }
        
        return validMergeGroups;
    }
    
    
    public virtual CORE_Merge_Util.MergeGroupWrapper getSingleMergeGroup() {
        return this.mergeGroups!=null && !this.mergeGroups.isEmpty() ? this.mergeGroups[0] : null;
    }
    
    public virtual void doMerge(CORE_Merge_Candidate__c wmc, List<CORE_Merge_Candidate__c> allmcs) {
        doMerge(new List<CORE_Merge_Util.MergeGroupWrapper>{new CORE_Merge_Util.MergeGroupWrapper(wmc, allmcs)}, false);        
    }
    
    public virtual void doMerge(List<CORE_Merge_Util.MergeGroupWrapper> mergeGroups) {
        doMerge(mergeGroups, false); 
    }
    
    public virtual void doOtherWorkAfterMerge() {
        if(getMergeObject()!=null) {
            doMerge(new List<CORE_Merge_Util.MergeGroupWrapper>(), true);
        }
    }
    
    public virtual void doMerge(List<CORE_Merge_Util.MergeGroupWrapper> mergeGroups, Boolean isOtherMergeWorkMode) {
        CORE_Merge_Util.setMergeProcessRunning(true);
        System.Savepoint sp = Database.setSavepoint();
        getCache().getMergeGroups().addAll(mergeGroups);
        
        for(CORE_Merge_Util.MergeGroupWrapper mGroup : mergeGroups) { 
            mGroup.setInProgress(true);    
        }
        
        Boolean isOk = false;
        Exception ex = null;
        
        if(!isSubProcess()) {
            switchAdminMode(true);
        }
        
        try {
            if(!isOtherMergeWorkMode) {
                intDoMerge(mergeGroups);
            } else {
                intDoOtherMergeWork();
            }
            
            isOk = true;
        } catch(Exception e) {
            debug('doMerge() catch exception block: e=' + e);
            ex = e;
        } finally {
            debug('doMerge() finally block: isOk=' + isOk + ', isPreviewMode()=' + isPreviewMode() + ', isSubProcess()=' + isSubProcess() + ', ex=' + ex + (ex!=null ? '\n' + ex.getStackTraceString() : ''));
            
            if(!isOk || isPreviewMode()) {
                Database.rollback(sp);    
            }
            
            if(ex!=null) {
                handleException(ex, mergeGroups);
            }
            
            if(!isSubProcess()) {
                switchAdminMode(false);
                saveMergeCandidates(false);
                CORE_Merge_Util.setMergeProcessRunning(false);
            }
        }
    }
    
    public virtual void saveMergeCandidates(Boolean populateCandidatesMode) {
        Map<Id, CORE_Merge_Candidate__c> mcsToSave = new Map<Id, CORE_Merge_Candidate__c>();
        Map<String,CORE_Merge_Error__c> errsToSaveMap = new Map<String,CORE_Merge_Error__c>();
        List<CORE_Merge_Util.MergeGroupWrapper> mergeGroups = new List<CORE_Merge_Util.MergeGroupWrapper>(getCache().getMergeGroups());
        Map<Id,List<CORE_Merge_Util.MergeGroupWrapper>> childMergeGroupsToProcess = getCache().getChildMergeGroupsToProcess();
        List<CORE_Merge_Util.MergeGroupWrapper> childMergeGroupsToLoad = getCache().getChildMergeGroupsToLoad();
        List<CORE_Merge_Util.ErrorWrapper> errors = getCache().getErrors();
        Database.DmlOptions dmlOpt = new Database.DmlOptions();
        dmlOpt.allowFieldTruncation = true;
        List<Integer> idxsToRemove = new List<Integer>();
        
        for(List<CORE_Merge_Util.MergeGroupWrapper> childMergeGroups : childMergeGroupsToProcess.values()) {
            if(!childMergeGroups.isEmpty() && childMergeGroups[0].getWinnerCandidate().getCandidate().Id==null) {
                mergeGroups.addAll(childMergeGroups);
            }
        }
        
        mergeGroups.addAll(childMergeGroupsToLoad);
        
        for(CORE_Merge_Util.MergeGroupWrapper mergeGroup : mergeGroups) {
            if(mergeGroup.isInProgress()) {
                mergeGroup.markAsCompleted();
            }
            
            List<CORE_Merge_Util.MergeCandidateWrapper> mcs = new List<CORE_Merge_Util.MergeCandidateWrapper>(mergeGroup.getLoserCandidates());
            mcs.add(mergeGroup.getWinnerCandidate());
            
            for(CORE_Merge_Util.MergeCandidateWrapper mc : mcs) {
                CORE_Merge_Candidate__c mcRec = mc.getCandidate();
                
                if(isPreviewMode() && mcRec.Id==null) {
                    continue;
                } else if(isPreviewMode()) {
                    mc.markAsCompletedInPreviewMode();    
                } else {
                    mcRec.Merge_Job_gne__c = getMergeJob()!=null ? getMergeJob().getMergeJob().Id : null;    
                }
                
                mcRec.setOptions(dmlOpt);
                mcsToSave.put(mcRec.Id, mcRec);
            }
        }
        
        if(getMergeJob()!=null) {
            saveCandidatesMetrics(populateCandidatesMode);
        }
        
        
        if(!mcsToSave.isEmpty()) {
            Database.upsert(mcsToSave.values(), CORE_Merge_Candidate__c.External_Id_gne__c, true);
        }
        
        for(CORE_Merge_Util.MergeGroupWrapper mergeGroup : mergeGroups) {
            if(mergeGroup.isInProgress()) {
                for(CORE_Merge_Util.MergeCandidateWrapper mc : mergeGroup.getAllCandidates()) {
                    errsToSaveMap.putAll(getErrorRecords(mc.getErrors(), mc));
                }
            }
        }
        
        if(!errors.isEmpty()) {
            errsToSaveMap.putAll(getErrorRecords(errors));
        }
        
        if(!isPreviewMode()) {
            saveErrorRecords(errsToSaveMap);
        }
        
        if(getMergeJob()!=null) {
            saveErrorMetrics(errsToSaveMap.values());
            getMergeJob().saveJob();
        }
        
        getCache().getMergeGroups().clear();
        getCache().getChildMergeGroupsToLoad().clear();
        getCache().getErrors().clear();
        this.mergeGroups = null;
        
        if(isPreviewMode() || populateCandidatesMode) {
            getCache().getChildMergeGroupsToProcess().clear();
        }
    }
    
    public Map<String,CORE_Merge_Error__c> getErrorRecords(List<CORE_Merge_Util.ErrorWrapper> errors) {
        return getErrorRecords(errors, null);
    }
    
    private Map<String,CORE_Merge_Error__c> getErrorRecords(List<CORE_Merge_Util.ErrorWrapper> errors, CORE_Merge_Util.MergeCandidateWrapper mc) {
        Map<String,CORE_Merge_Error__c> result = new Map<String,CORE_Merge_Error__c>();
        Database.DmlOptions dmlOpt = new Database.DmlOptions();
        dmlOpt.allowFieldTruncation = true;
        List<Integer> idxsToRemove = new List<Integer>();
        
        for(CORE_Merge_Util.ErrorWrapper err : errors) {
            CORE_Merge_Error__c errRec = err.asErrorRecord(getMergeJob(), mc);
            errRec.setOptions(dmlOpt);
            result.put(errRec.Hash_Code_gne__c, errRec);
        }
        
        return result;
    }
    
    public void saveErrorRecords(Map<String,CORE_Merge_Error__c> errsToSaveMap) {
        if(!errsToSaveMap.isEmpty()) {
            Database.upsert(errsToSaveMap.values(), CORE_Merge_Error__c.Hash_Code_gne__c, false);
        }
    }
    
    protected virtual void saveCandidatesMetrics(Boolean populateCandidatesMode) {
        for(List<CORE_Merge_Util.MergeGroupWrapper> mergeGroups : getCache().getChildMergeGroupsToProcess().values()) {
            for(CORE_Merge_Util.MergeGroupWrapper mergeGroup : mergeGroups) {
                if(mergeGroup.getWinnerCandidate().getCandidate().Id==null) {
                    Id mergeGroupObjId = mergeGroup.getMergeObject().Id;
                    CORE_Merge_Util.JobMetrics jMetrics = new CORE_Merge_Util.JobMetrics(mergeGroupObjId);
                    jMetrics.increasePopulatedMergeGroupsSize(1);
                    jMetrics.increasePopulatedCandidatesSize(mergeGroup.getAllCandidates().size());
                    getMergeJob().addMetrics(jMetrics);
                }
            }
        }
        
        if(!populateCandidatesMode) {
            for(CORE_Merge_Util.MergeGroupWrapper mergeGroup : getCache().getMergeGroups()) {
                Id mergeGroupObjId = mergeGroup.getMergeObject().Id;
                CORE_Merge_Util.JobMetrics jMetrics = new CORE_Merge_Util.JobMetrics(mergeGroupObjId);
                
                if(mergeGroup.getWinnerCandidate().getCandidate().Id==null) {
                    jMetrics.increasePopulatedMergeGroupsSize(1);
                    jMetrics.increasePopulatedCandidatesSize(mergeGroup.getAllCandidates().size());
                }
                
                jMetrics.increaseMergeGroupsSize(1);
                Boolean isGroupValid = mergeGroup.isValid();
                
                if(isGroupValid) {
                    jMetrics.increaseValidMergeGroupsSize(1);
                }
                
                for(CORE_Merge_Util.MergeCandidateWrapper mc : mergeGroup.getAllCandidates()) {
                    jMetrics.increaseCandidatesSize(1);
                
                    if(String.isEmpty(mc.getCandidate().Error_Codes_gne__c)) {
                        jMetrics.increaseValidCandidatesSize(1);
                    }
                }
                
                getMergeJob().addMetrics(jMetrics);
	        }
	        
	        for(CORE_Merge_Util.MergeGroupWrapper mergeGroup : getCache().getChildMergeGroupsToLoad()) {
	           Id mergeGroupObjId = mergeGroup.getMergeObject().Id;
	           CORE_Merge_Util.JobMetrics jMetrics = new CORE_Merge_Util.JobMetrics(mergeGroupObjId);
	           jMetrics.increasePopulatedMergeGroupsSize(1);
	           jMetrics.increasePopulatedCandidatesSize(mergeGroup.getAllCandidates().size());
	           getMergeJob().addMetrics(jMetrics);
            }
        }
    }
    
    protected virtual void saveErrorMetrics(List<CORE_Merge_Error__c> errs) {
        for(CORE_Merge_Error__c err : errs) {
            CORE_Merge_Util.JobMetrics jErrMetrics = new CORE_Merge_Util.JobMetrics(err.Merge_Object_gne__c);
            jErrMetrics.increaseErrorsSize(1);
            jErrMetrics.increaseErrorCodesSize(err.Error_Code_gne__c, 1);
            getMergeJob().addMetrics(jErrMetrics);
        }
    }
    
    protected void intDoMerge(List<CORE_Merge_Util.MergeGroupWrapper> mergeGroups) {
        initMerge(mergeGroups);
        notifyOnActions(CORE_Merge_Interface.MergeProcessState.Start, CORE_Merge_Interface.MergeProcessState.BeforePopulateSourceData);
        populateSourceData();
        notifyOnActions(CORE_Merge_Interface.MergeProcessState.AfterPopulateSourceData, CORE_Merge_Interface.MergeProcessState.BeforeValidate);
        validate();
        notifyOnActions(CORE_Merge_Interface.MergeProcessState.AfterValidate, CORE_Merge_Interface.MergeProcessState.BeforePrepareArchiveData);
        prepareArchiveData();
        notifyOnActions(CORE_Merge_Interface.MergeProcessState.AfterPrepareArchiveData, CORE_Merge_Interface.MergeProcessState.BeforeUpdateWinnerFields);
        updateWinnerFields();
        notifyOnActions(CORE_Merge_Interface.MergeProcessState.AfterUpdateWinnerFields, CORE_Merge_Interface.MergeProcessState.BeforePreMergeActions);
        preMergeActions();
        notifyOnActions(CORE_Merge_Interface.MergeProcessState.AfterPreMergeActions, CORE_Merge_Interface.MergeProcessState.BeforeUpdateWinner);
        updateWinner();
        notifyOnActions(CORE_Merge_Interface.MergeProcessState.AfterUpdateWinner, CORE_Merge_Interface.MergeProcessState.BeforeMergeCandidates);
        mergeCandidates();
        notifyOnActions(CORE_Merge_Interface.MergeProcessState.AfterMergeCandidates, CORE_Merge_Interface.MergeProcessState.BeforePostMergeActions);
        postMergeActions();
        notifyOnActions(CORE_Merge_Interface.MergeProcessState.AfterPostMergeActions, CORE_Merge_Interface.MergeProcessState.BeforePopulateChildCandidates);
        populateChildCandidates();
        notifyOnActions(CORE_Merge_Interface.MergeProcessState.AfterPopulateChildCandidates, CORE_Merge_Interface.MergeProcessState.BeforeMergeChildCandidates);
        mergeChildCandidates();
        notifyOnActions(CORE_Merge_Interface.MergeProcessState.AfterMergeChildCandidates, CORE_Merge_Interface.MergeProcessState.BeforeSaveArchiveData);
        saveArchiveData();
        notifyOnActions(CORE_Merge_Interface.MergeProcessState.AfterSaveArchiveData, CORE_Merge_Interface.MergeProcessState.Finish);
    }
    
    protected void intDoOtherMergeWork() {
        notifyOnActions(CORE_Merge_Interface.MergeProcessState.Start, CORE_Merge_Interface.MergeProcessState.BeforeMergeChildCandidates);
        mergeChildCandidates();
        notifyOnActions(CORE_Merge_Interface.MergeProcessState.AfterMergeChildCandidates, CORE_Merge_Interface.MergeProcessState.BeforeSaveArchiveData);
        saveArchiveData();
        notifyOnActions(CORE_Merge_Interface.MergeProcessState.AfterSaveArchiveData, CORE_Merge_Interface.MergeProcessState.Finish);
    }
    
    public void initMerge(List<CORE_Merge_Util.MergeGroupWrapper> mergeGroups) {
        this.mergeObject = new CORE_Merge_Util.MergeObjectWrapper(mergeGroups[0].getMergeObject());
        this.mergeGroups = mergeGroups;
        
        for(CORE_Merge_Util.MergeGroupWrapper mergeGroup : this.mergeGroups) {
            mergeGroup.initCandidates();    
        }
        this.archiveCloneFieldSet = null;
        this.visitedIds = null;
        this.currentState = null;
        readConfiguration();
    }
    
    protected void readConfiguration() {
        CORE_Merge_Configuration.readConfiguration(getMergeObjectRecord());
    }
    
    protected void notifyOnActions(CORE_Merge_Interface.MergeProcessState actionEnded, CORE_Merge_Interface.MergeProcessState actionStarted) {
        this.currentState = actionEnded;
        CORE_Merge_Interface.CustomMergeEngineListnerInterface customListener = (CORE_Merge_Interface.CustomMergeEngineListnerInterface)getMergeObject().getPropertyValue(CORE_Merge_Configuration.MergeProperty.CustomMergeEngineListner);
        
        if(customListener!=null) {
            customListener.mergeNotifyOnAction(actionEnded, getMergeObject(), getMergeGroups(), this);
        }
        
        this.currentState = actionStarted;
        
        if(customListener!=null) {
            customListener.mergeNotifyOnAction(actionStarted, getMergeObject(), getMergeGroups(), this);
        }
    }
    
    public void populateSourceData() {
        String sObjectName = getMergeObject().getSObjectName();
        Set<Id> sourceIds = new Set<Id>();
        
        for(CORE_Merge_Util.MergeGroupWrapper mGroup : getMergeGroups()) {
            sourceIds.addAll(mGroup.getAllIds());
        }
        
        Set<String> fieldsToQuery = new Set<String>();
        Set<String> fieldsToQueryForArchive = new Set<String>();
        Set<String> fieldsToQueryForValidate = new Set<String>();
        
        Map<String,Map<String,Object>> fieldPropsByTypeMap = getMergeObject().getPropertiesByTypes(CORE_Merge_Configuration.FIELD_SETTINGS);
        // Fields, Field Validations, Field Archive
        for(String propType : fieldPropsByTypeMap.keySet()) {
            Set<String> fieldNames = fieldPropsByTypeMap.get(propType).keySet();
            
            if(propType==CORE_Merge_Configuration.MergeProperty.FieldToQuery.name()) {
                fieldsToQuery.addAll(fieldNames);
                fieldsToQueryForArchive.addAll(fieldNames);
                fieldsToQueryForValidate.addAll(fieldNames);
            } else if(propType.startsWithIgnoreCase('Field')) {
                fieldsToQuery.addAll(fieldNames);    
            } else if(CORE_Merge_Configuration.VALIDATION_SETTINGS.contains(propType)){
                if(propType==CORE_Merge_Configuration.MergeProperty.ExcludeMatching.name()) {
                    for(Object sObjTemplate : fieldPropsByTypeMap.get(propType).values()) {
	                    if(sObjTemplate!=null) {
	                        Set<String> excludeMatchingFieldNames = CORE_Merge_Util.getFieldNamesFromSObject((SObject)sObjTemplate);
	                        
	                        for(String fieldName : excludeMatchingFieldNames) {
	                            fieldsToQueryForValidate.add(fieldName.toUpperCase());
	                        }
	                    }
	                }
                } else {
                    fieldsToQueryForValidate.addAll(fieldNames);
                }
            } else if(propType.startsWithIgnoreCase('Archive')) {
                for(Object fieldName : fieldPropsByTypeMap.get(propType).values()) {
                    fieldsToQueryForArchive.add(((String)fieldName).toUpperCase());
                }
            }
        }
        
        
        //ArchiveCloningEnabled, ArchiveCloneExcludedFields
        Boolean archiveCloningEnabled = getMergeObject().getPropertyBooleanValue(CORE_Merge_Configuration.MergeProperty.ArchiveCloningEnabled);
        
        if(archiveCloningEnabled==true) {
            fieldsToQueryForArchive.addAll(getArchiveCloneFieldSet());
            
        }
        
        //ArchiveJsonEnabled, ArchiveJsonFields
        Boolean archiveJsonEnabled = getMergeObject().getPropertyBooleanValue(CORE_Merge_Configuration.MergeProperty.ArchiveJsonEnabled);
        
        if(archiveJsonEnabled==true) {
            List<String> archiveJsonFields = getMergeObject().getPropertyListValue(CORE_Merge_Configuration.MergeProperty.ArchiveJsonFields);
            
            if(archiveJsonFields!=null) {
                for(String fieldName : archiveJsonFields) {
                    if(String.isNotBlank(fieldName)) {
                        fieldsToQueryForArchive.add(fieldName.toUpperCase());
                    }
                }
            }
        }
        
        Map<String,String> childQueryMap = new Map<String,String>();
        //RelationshipToExclude, RelationshipToMove, RelationshipToQuery
        childQueryMap.putAll(getChildRelationshipQueries(CORE_Merge_Configuration.MergeProperty.RelationshipToExclude));
        childQueryMap.putAll(getChildRelationshipQueries(CORE_Merge_Configuration.MergeProperty.RelationshipToMove));
        childQueryMap.putAll(getChildRelationshipQueries(CORE_Merge_Configuration.MergeProperty.RelationshipToQuery));
        fieldsToQuery.addAll(childQueryMap.values());
        
        childQueryMap = new Map<String,String>();
        //DeferOnChildRelationship
        childQueryMap.putAll(getChildRelationshipQueries(CORE_Merge_Configuration.MergeProperty.DeferOnChildRelationship));
        fieldsToQueryForValidate.addAll(childQueryMap.values());
        
        //ArchiveChildRelationship
        childQueryMap = new Map<String,String>();
        childQueryMap.putAll(getChildRelationshipQueries(CORE_Merge_Configuration.MergeProperty.ArchiveChildRelationship));
        fieldsToQueryForArchive.addAll(childQueryMap.values());
        
        String sourceQuery = String.format('SELECT {0} FROM {1} WHERE ID IN :sourceIds', new String[]{
            !fieldsToQuery.isEmpty() ? String.join(new List<String>(fieldsToQuery), ',') : 'ID',
            sObjectName
        });
        
        debug('Source Query = ' + sourceQuery);
        Map<Id,SObject> sourceRecsMap = new Map<Id,SObject>(Database.query(sourceQuery));
       
        for(CORE_Merge_Util.MergeGroupWrapper mGroup : getMergeGroups()) {
            mGroup.setSourceRecords(sourceRecsMap);
        }
        
        if(!fieldsToQueryForValidate.isEmpty()) {
            sourceQuery = String.format('SELECT {0} FROM {1} WHERE ID IN :sourceIds', new String[]{
	            String.join(new List<String>(fieldsToQueryForValidate), ','),
	            sObjectName
	        });
	        
	        debug('Source Query = ' + sourceQuery);
	        sourceRecsMap = new Map<Id,SObject>(Database.query(sourceQuery));
	       
	        for(CORE_Merge_Util.MergeGroupWrapper mGroup : getMergeGroups()) {
	            mGroup.setSourceRecordsForValidate(sourceRecsMap);
	        }
        }
        
        if(!fieldsToQueryForArchive.isEmpty()) {
            sourceQuery = String.format('SELECT {0} FROM {1} WHERE ID IN :sourceIds', new String[]{
                String.join(new List<String>(fieldsToQueryForArchive), ','),
                sObjectName
            });
            
            debug('Source Query = ' + sourceQuery);
            sourceRecsMap = new Map<Id,SObject>(Database.query(sourceQuery));
           
            for(CORE_Merge_Util.MergeGroupWrapper mGroup : getMergeGroups()) {
                mGroup.setSourceRecordsForArchive(sourceRecsMap);
            }
        }
    }
    
    protected Map<String,Schema.ChildRelationship> getChildRelationshipMap() {
        return CORE_Merge_Configuration.getChildRelationshipMap(getMergeObject().getSObjectName());
    }
    
    protected Map<String,String> getChildRelationshipQueries(CORE_Merge_Configuration.MergeProperty prop) {
        Map<String,String> result = new Map<String,String>();
        Map<String,Object> childRelationshipConfig = getMergeObject().getPropertiesByType(prop);
        
        if(!childRelationshipConfig.isEmpty()) {
            Map<String,Schema.ChildRelationship> childRelationshipCache = getChildRelationshipMap();
            
            for(String key : childRelationshipConfig.keySet()) {
                CORE_Merge_Configuration.RelationshipConfigWrapper rcw = (CORE_Merge_Configuration.RelationshipConfigWrapper)childRelationshipConfig.get(key);
                String relName = rcw.getRelationshipName();
                SObjectField fld = childRelationshipCache.get(relName).getField();
                Set<String> queryFields = new Set<String>(String.join(new List<String>(rcw.getQueryFields()),',').toUpperCase().split(','));
                queryFields.remove('');
	            queryFields.add(String.valueOf(fld).toUpperCase());
	            queryFields.add('ID');
	            String query = String.format('(SELECT {0} FROM {1}{2} ORDER BY {3} LIMIT {4})', new String[]{
	               String.join(new List<String>(queryFields), ','),
	               relName,
	               rcw!=null && String.isNotEmpty(rcw.getQueryWhere()) ? ' WHERE ' + rcw.getQueryWhere() : '',
	               rcw!=null && String.isNotEmpty(rcw.getQueryOrderBy()) ? rcw.getQueryOrderBy() : 'ID DESC',
	               rcw!=null && rcw.getQueryLimit()!=null ? String.valueOf(rcw.getQueryLimit()) : (prop==CORE_Merge_Configuration.MergeProperty.DeferOnChildRelationship ? '1' : '1000')
	            });
	            result.put(relName, query);
            }    
        }
        
        return result;
    }
    
    protected Schema.DescribeSObjectResult getSObjectDescribe() {
        return CORE_Merge_Configuration.getSObjectDescribe(getMergeObject().getSObjectName());
    }
    
    protected Set<String> getArchiveCloneFieldSet() {
        if(archiveCloneFieldSet==null) {
            archiveCloneFieldSet = new Set<String>();
	        Map<String, Schema.SObjectField> fieldMap = getSObjectDescribe().fields.getMap();
	        
	        for(String fieldName : fieldMap.keySet()) {
	            String fieldNameUC = fieldName.toUpperCase();
	            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
	            
	            if(fieldDescribe.isCalculated() == false && fieldDescribe.isUpdateable() == true && fieldDescribe.isCreateable() == true && fieldDescribe.getReferenceTo().isEmpty()
	               && !fieldNameUC.endsWith('_PC')) {
	                archiveCloneFieldSet.add(fieldNameUC);
	            } 
	        }
	        
	        List<String> archiveCloneExcludedFields = getMergeObject().getPropertyListValue(CORE_Merge_Configuration.MergeProperty.ArchiveCloneExcludedFields);
	        
	        if(archiveCloneExcludedFields!=null) {
	           archiveCloneFieldSet.removeAll(archiveCloneExcludedFields);
	        }
        }
        
        return archiveCloneFieldSet;
    }
    
    public void validate() {
        for(CORE_Merge_Util.MergeGroupWrapper mGroup : getMergeGroups()) {
	        Boolean isOk = true;
	        isOk &= validateSourceRecords(mGroup);
	        isOk &= validateDeferOnConflictFields(mGroup, CORE_Merge_Configuration.MergeProperty.DeferOnConflict);
	        isOk &= validateDeferOnConflictFields(mGroup, CORE_Merge_Configuration.MergeProperty.DeferOnConflictWithNulls);
	        isOk &= validateDeferOnChildRelatioships(mGroup);
	        isOk &= validateExcludedCandidates(mGroup);
	        
	        Map<String,Object> customValidators = getMergeObject().getPropertiesByType(CORE_Merge_Configuration.MergeProperty.CustomMergeValidation);
	        
	        for(String actionName : customValidators.keySet()) {
	            CORE_Merge_Interface.CustomValidationInterface validatorInstance = (CORE_Merge_Interface.CustomValidationInterface)customValidators.get(actionName);
	            isOk &= validatorInstance.mergeValidate(actionName, getMergeObject(), mGroup, this)!=false;
	        }
	        
	        if(!isOk) {
	            mGroup.setIsValid(false);
	        }
        }
    }
    
    protected Boolean validateSourceRecords(CORE_Merge_Util.MergeGroupWrapper mGroup) {
        Boolean isOk = true;
        Boolean validateSourceRecordDisabled = getMergeObject().getPropertyBooleanValue(CORE_Merge_Configuration.MergeProperty.ValidateSourceRecordDisabled);
        
        if(validateSourceRecordDisabled!=true) {
            Integer idx=0, loserCount=0;
	        for(CORE_Merge_Util.MergeCandidateWrapper candidateWrapper : mGroup.getAllCandidates()) {
	            if(idx==0 && !candidateWrapper.isWinner()) {
	                handleException(new CORE_Merge_Util.MergeCandidateException('MissingWinnerRecord', CORE_Merge_Util.ERROR_MESSAGE_MISSING_WINNER_RECORD, candidateWrapper), candidateWrapper);
                    isOk = false;
	            } else if(idx>0 && candidateWrapper.isWinner()) {
	                handleException(new CORE_Merge_Util.MergeCandidateException('DuplicatedWinnerRecord', CORE_Merge_Util.ERROR_MESSAGE_DUPLICATED_WINNER_RECORD, candidateWrapper), candidateWrapper);
                    isOk = false;
	            } else if(idx>0) {
	                loserCount++;
	            } 
	            
	            if(!candidateWrapper.isSourceValid()) {
	                handleException(new CORE_Merge_Util.MergeCandidateException('SourceRecordIsMissing', CORE_Merge_Util.ERROR_MESSAGE_SOURCE_RECORD_IS_MISSING, candidateWrapper), candidateWrapper);
	                isOk = false;
	                if(candidateWrapper.isWinner()){
                        for(CORE_Merge_Util.MergeCandidateWrapper loser : mGroup.getLoserCandidates()) {
                            handleException(new CORE_Merge_Util.MergeCandidateException('SourceRecordIsMissing', CORE_Merge_Util.ERROR_MESSAGE_SOURCE_WINNER_RECORD_IS_MISSING, loser), loser);
                        }
                    }
	            }
	            
	            idx++;
	        }
	        
	        if(loserCount==0) {
	            handleException(new CORE_Merge_Util.MergeCandidateException('MissingLoserRecord', CORE_Merge_Util.ERROR_MESSAGE_MISSING_LOSER_RECORD, mGroup.getWinnerCandidate()), mGroup.getWinnerCandidate());
                isOk = false;
	        }
        }
        
        return isOk;
    }
    
    protected Boolean validateDeferOnConflictFields(CORE_Merge_Util.MergeGroupWrapper mGroup, CORE_Merge_Configuration.MergeProperty prop) {
        Boolean isOk = true;
        Set<String> fieldsToValidate = getMergeObject().getPropertiesByType(prop).keySet();
        Boolean useNull = prop==CORE_Merge_Configuration.MergeProperty.DeferOnConflictWithNulls;
        
        if(mGroup.getWinnerCandidate().isSourceValid()) {
            for(String fieldName : fieldsToValidate) {
                Object baseFieldValue = mGroup.getWinnerCandidate().getSourceRecordForValidate().get(fieldName);
                CORE_Merge_Util.MergeCandidateWrapper baseCandidate = mGroup.getWinnerCandidate();
                Boolean isErrorLogged = false;
                
                for(CORE_Merge_Util.MergeCandidateWrapper loserWrapper : mGroup.getLoserCandidates()) {
                    if(loserWrapper.isSourceValid()) {
                        Object loserFieldValue = loserWrapper.getSourceRecordForValidate().get(fieldName);
                        
                        if(!useNull && baseFieldValue==null && loserFieldValue!=null) {
                            baseFieldValue = loserFieldValue;
                            baseCandidate = loserWrapper;
                        }
                        
                        if ((useNull || (baseFieldValue!=null && loserFieldValue!=null)) && baseFieldValue!=loserFieldValue) {
                            String errorCode = getMergeObject().getPropertyErrorCode(prop.name(), fieldName);
                            String errorMsg = String.format(CORE_Merge_Util.ERROR_MESSAGE_FIELD_CONFLICT, new String[]{baseCandidate.print(), loserWrapper.print(), fieldName});
                            handleException(new CORE_Merge_Util.MergeCandidateException(errorCode, 'DeferOnConflict', errorMsg), loserWrapper);
                            
                            if(!isErrorLogged && baseCandidate!=mGroup.getWinnerCandidate()) {
                                handleException(new CORE_Merge_Util.MergeCandidateException(errorCode, 'DeferOnConflict', errorMsg), baseCandidate);
                                isErrorLogged = true;
                            }

                            isOk = false;
                        }
                    }
                }    
            }
        }
        
        return isOk;
    }
    
    protected Boolean validateDeferOnChildRelatioships(CORE_Merge_Util.MergeGroupWrapper mGroup) {
        Boolean isOk = true;
        Map<String,Object> deferChildRelationshipConfig = getMergeObject().getPropertiesByType(CORE_Merge_Configuration.MergeProperty.DeferOnChildRelationship);
        
        if(!deferChildRelationshipConfig.isEmpty()) {
            for(String key : deferChildRelationshipConfig.keySet()) {
                CORE_Merge_Configuration.RelationshipConfigWrapper rcw = (CORE_Merge_Configuration.RelationshipConfigWrapper)deferChildRelationshipConfig.get(key);
                String relName = rcw.getRelationshipName();
                List<CORE_Merge_Util.MergeCandidateWrapper> candidatesWithChildren = new List<CORE_Merge_Util.MergeCandidateWrapper>();
                
                for(CORE_Merge_Util.MergeCandidateWrapper cWrapper : mGroup.getAllCandidates()) {
                    if(cWrapper.isSourceValid()) {
                        List<SObject> childRecs = getChildSObject(cWrapper.getSourceRecordForValidate(), rcw);
                        if(childRecs!=null && !childRecs.isEmpty()) {
                            candidatesWithChildren.add(cWrapper);
                        }
                        
                    }
                }
                
                if(candidatesWithChildren.size()>1) {
                    for(CORE_Merge_Util.MergeCandidateWrapper cWrapper : candidatesWithChildren) {
                        if(!cWrapper.isWinner()) {
	                        String errorCode = getMergeObject().getPropertyErrorCode(CORE_Merge_Configuration.MergeProperty.DeferOnChildRelationship.name(), key);
	                        String errorMsg = String.format(CORE_Merge_Util.ERROR_MESSAGE_RELATIONSHIP_CONFLICT, new String[]{cWrapper.print(), relName});
	                        handleException(new CORE_Merge_Util.MergeCandidateException(errorCode, 'DeferOnChildRelationship', errorMsg), cWrapper);
	                        isOk = false;
                        }
                    }
                }
                
            }
        }
        
        return isOk;
    }
    
    protected Boolean validateExcludedCandidates(CORE_Merge_Util.MergeGroupWrapper mGroup) {
        Boolean isOk = true;
        
        Map<String,Object> excludeMatching = (Map<String,Object>)getMergeObject().getPropertiesByType(CORE_Merge_Configuration.MergeProperty.ExcludeMatching);
        
        if(excludeMatching!=null) {
            for(String key : excludeMatching.keySet()) {
                Object propValue = excludeMatching.get(key);
	            SObject excludedTemplate = (SObject)propValue;
	            Set<String> fieldNames = CORE_Merge_Util.getFieldNamesFromSObject(excludedTemplate);
	            
	            for(CORE_Merge_Util.MergeCandidateWrapper cWrapper : mGroup.getAllCandidates()) {
	                if(cWrapper.isSourceValid()) {
	                    SObject srcRec = cWrapper.getSourceRecordForValidate();
	                    Boolean matching = !excludeMatching.isEmpty();
	                    
	                    for(String fieldName : fieldNames) {
	                        matching &= srcRec.get(fieldName)==excludedTemplate.get(fieldName);
	                    }
	                    
	                    if(matching) {
	                        isOk = false;
	                        List<String> criteria = new List<String>();
	                        
	                        for(String fieldName : fieldNames) {
	                            criteria.add(fieldName + '=' + excludedTemplate.get(fieldName));
	                        }
	                        
	                        String errorCode = getMergeObject().getPropertyErrorCode(CORE_Merge_Configuration.MergeProperty.ExcludeMatching.name(), key);
	                        String errorMsg = String.format(CORE_Merge_Util.ERROR_MESSAGE_EXCLUDE_MATCHING_RECORD, new String[]{cWrapper.print(), String.join(criteria,', ')});
	                        handleException(new CORE_Merge_Util.MergeCandidateException(errorCode, 'ExcludeMatching', errorMsg), cWrapper);
	                    }
	                }    
	            }
            }
        }
        
        return isOk;
    }
    
    protected void prepareArchiveData() {
        Boolean archiveEnabled = getMergeObject().getPropertyBooleanValue(CORE_Merge_Configuration.MergeProperty.ArchiveEnabled);
        
        if(archiveEnabled==true) {
	        for(CORE_Merge_Util.MergeGroupWrapper mGroup : getValidMergeGroups()) {
		        for(CORE_Merge_Util.MergeCandidateWrapper cWrapper : mGroup.getAllCandidates()) {
		            if(cWrapper.isSourceValid()) {
		                prepareCandidateArchiveData(mGroup, cWrapper);
		            }    
		        }
	        }
        }
    }
    
    protected void prepareCandidateArchiveData(CORE_Merge_Util.MergeGroupWrapper mGroup, CORE_Merge_Util.MergeCandidateWrapper cWrapper) {
        cWrapper.createArchiveRecord(getSystemTimeStamp());
        Boolean archiveCloningEnabled = getMergeObject().getPropertyBooleanValue(CORE_Merge_Configuration.MergeProperty.ArchiveCloningEnabled);
        if(archiveCloningEnabled==true) {
            prepareArchiveClone(mGroup, cWrapper);
        }
        
        Boolean archiveJsonEnabled = getMergeObject().getPropertyBooleanValue(CORE_Merge_Configuration.MergeProperty.ArchiveJsonEnabled);
        
        if(archiveJsonEnabled==true) {
            archiveFieldToJSON(mGroup, cWrapper);
        }
        
        archiveChildRelationships(mGroup, cWrapper);
    }
    
    protected void prepareArchiveClone(CORE_Merge_Util.MergeGroupWrapper mGroup, CORE_Merge_Util.MergeCandidateWrapper cWrapper) {
        Id archiveOwnerId = (Id)getMergeObject().getPropertyValue(CORE_Merge_Configuration.MergeProperty.ArchiveOwner);
        Id archiveRecordTypeId = (Id)getMergeObject().getPropertyValue(CORE_Merge_Configuration.MergeProperty.ArchiveRecordType);
        String archiveMasterIdField = getMergeObject().getPropertyStringValue(CORE_Merge_Configuration.MergeProperty.ArchiveMasterIdField);
        String archiveIdField = getMergeObject().getPropertyStringValue(CORE_Merge_Configuration.MergeProperty.ArchiveIdField);
        SObject archiveCloneFieldDefaults = (SObject)getMergeObject().getPropertyValue(CORE_Merge_Configuration.MergeProperty.ArchiveCloneFieldDefaults);
        SObject archiveCloneWinnerOrLoserFieldDefaults = (SObject)getMergeObject().getPropertyValue(cWrapper.isWinner() ? CORE_Merge_Configuration.MergeProperty.ArchiveCloneWinnerFieldDefaults : CORE_Merge_Configuration.MergeProperty.ArchiveCloneLoserFieldDefaults);
        SObject archiveClone = (SObject)Type.forName(getMergeObject().getSObjectName()).newInstance();
        Set<String> fieldsSet = new Set<String>();
        fieldsSet.addAll(getArchiveCloneFieldSet());
        
        Set<String> defaultFieldNamesUC = new Set<String>();
        
        if(String.isNotBlank(archiveOwnerId)) {
            archiveClone.put('OwnerId', archiveOwnerId);
            defaultFieldNamesUC.add('OwnerId'.toUpperCase());
        }
        
        if(String.isNotBlank(archiveRecordTypeId)) {
            archiveClone.put('RecordTypeId', archiveRecordTypeId);
            defaultFieldNamesUC.add('RecordTypeId'.toUpperCase());
        }
        
        if(String.isNotBlank(archiveMasterIdField)) {
           archiveClone.put(archiveMasterIdField, cWrapper.getMasterId());
           defaultFieldNamesUC.add(archiveMasterIdField.toUpperCase()); 
        }
        
        if(String.isNotBlank(archiveIdField)) {
           archiveClone.put(archiveIdField, cWrapper.getSourceId());
           defaultFieldNamesUC.add(archiveIdField.toUpperCase()); 
        }
        
        fillArchiveCloneWithDefaultValues(archiveClone, archiveCloneFieldDefaults, defaultFieldNamesUC);
        fillArchiveCloneWithDefaultValues(archiveClone, archiveCloneWinnerOrLoserFieldDefaults, defaultFieldNamesUC);
        
        for(String fieldName : fieldsSet) {
            Object srcValue = cWrapper.getSourceRecordForArchive().get(fieldName);
            Object archiveValue = archiveClone.get(fieldName);
                    
            if(!defaultFieldNamesUC.contains(fieldName.toUpperCase()) && (srcValue!=null || archiveValue!=null)) { 
                archiveClone.put(fieldName, srcValue);
            }
        }
        
        cWrapper.setArchiveClone(archiveClone);
    }
    
    protected void fillArchiveCloneWithDefaultValues(SObject archiveClone, SObject templateRec, Set<String> defaultFieldNamesUC) {
        if(templateRec!=null) {
            Set<String> defaultFieldNames = CORE_Merge_Util.getFieldNamesFromSObject(templateRec);
            
            for(String fieldName : defaultFieldNames) {
                archiveClone.put(fieldName, templateRec.get(fieldName));
                defaultFieldNamesUC.add(fieldName.toUpperCase());
            }
        }
    }
    
    protected void archiveFieldToJSON(CORE_Merge_Util.MergeGroupWrapper mGroup, CORE_Merge_Util.MergeCandidateWrapper cWrapper) {
        List<String> archiveJsonFields = getMergeObject().getPropertyListValue(CORE_Merge_Configuration.MergeProperty.ArchiveJsonFields);
        Map<String,Object> fieldValues = new Map<String,Object>();
        
        for(String fieldName : archiveJsonFields) {
            if(String.isNotBlank(fieldName)) {
	            Object fieldValue = cWrapper.getSourceRecordForArchive().get(fieldName);
	            fieldValues.put(fieldName, fieldValue);
            }
        }
        
        if(!fieldValues.isEmpty()) {
            cWrapper.setArchiveJsonFields(fieldValues);
        }
    }
    
    protected void archiveChildRelationships(CORE_Merge_Util.MergeGroupWrapper mGroup, CORE_Merge_Util.MergeCandidateWrapper cWrapper) {
        Map<String,Object> archiveChildRelationship = getMergeObject().getPropertiesByType(CORE_Merge_Configuration.MergeProperty.ArchiveChildRelationship);
        
        for(String key : archiveChildRelationship.keySet()) {
            CORE_Merge_Configuration.RelationshipConfigWrapper rcw = (CORE_Merge_Configuration.RelationshipConfigWrapper)archiveChildRelationship.get(key);
            String relName = rcw.getRelationshipName();
            List<SObject> childRecs = getChildSObject(cWrapper.getSourceRecordForArchive(), rcw);
            
            if(childRecs!=null && !childRecs.isEmpty()) {
                SObjectField fld = getChildRelationshipMap().get(relName).getField();
                
                for(SObject childRec : childRecs) {
                    cWrapper.addChildArchiveRecord(childRec, fld, rcw, getSystemTimeStamp());
                }
            }
        }
    }
    
    protected void updateWinnerFields() {
        Map<String,Map<String,Object>> fieldSettings = getMergeObject().getPropertiesByTypes(CORE_Merge_Configuration.FIELD_SETTINGS);
        
        for(CORE_Merge_Util.MergeGroupWrapper mGroup : getValidMergeGroups()) {
            if(mGroup.getWinnerCandidate().isSourceValid()) {
                Boolean winnerChanged = false;
                
		        for(String propType : fieldSettings.keySet()) {
		            if(propType.startsWithIgnoreCase('Field')) {
			            for(String fieldName : fieldSettings.get(propType).keySet()) {
			                winnerChanged |= updateWinnerField(mGroup, propType, fieldName);
			            }
		            }
		        }
		        
		        mGroup.getWinnerCandidate().setIsChanged(winnerChanged);
	        }
        }
    }
    
    protected Boolean updateWinnerField(CORE_Merge_Util.MergeGroupWrapper mGroup, String propType, String fieldName) {
        Object oldWinnerValue = mGroup.getWinnerCandidate().getSourceRecord().get(fieldName);
        Set<Object> loserValues = new Set<Object>();
        
        for(CORE_Merge_Util.MergeCandidateWrapper loserCandidate : mGroup.getLoserCandidates()) {
            if(loserCandidate.isSourceValid()) {
                Object loserValue = loserCandidate.getSourceRecord().get(fieldName);
                loserValues.add(loserValue);
            }
        }
        
        Set<Object> allValues = new Set<Object>(loserValues);
        allValues.add(oldWinnerValue);
        Object winnerValue = intUpdateWinnerField(mGroup, propType, fieldName, oldWinnerValue, loserValues, allValues);
        
        Boolean winnerChanged = (winnerValue!=oldWinnerValue);
        
        if(winnerChanged) {
            mGroup.getWinnerCandidate().getSourceRecordToUpdate().put(fieldName, winnerValue);   
        }
        
        return winnerChanged;
    }
    
    protected Object intUpdateWinnerField(CORE_Merge_Util.MergeGroupWrapper mGroup, String propType, String fieldName, Object oldWinnerValue, Set<Object> loserValues, Set<Object> allValues) {
        Object newWinnerValue = oldWinnerValue;
        
        if(CORE_Merge_Configuration.isPropertyType(propType, CORE_Merge_Configuration.MergeProperty.FieldBooleanAND)) {
            newWinnerValue = allValues.size()==1 && allValues.contains(true);
        } else if(CORE_Merge_Configuration.isPropertyType(propType, CORE_Merge_Configuration.MergeProperty.FieldBooleanOR)) {
            newWinnerValue = allValues.contains(true);
        } else if(CORE_Merge_Configuration.isPropertyType(propType, CORE_Merge_Configuration.MergeProperty.FieldNotNull)) {
            Set<Object> winnerValues = new Set<Object>{oldWinnerValue};
            removeNullValues(propType, fieldName, loserValues);
            removeNullValues(propType, fieldName, winnerValues);
            newWinnerValue = (loserValues.isEmpty() || !winnerValues.isEmpty()) ? newWinnerValue : new List<Object>(loserValues)[0];
        } else if(CORE_Merge_Configuration.isPropertyType(propType, CORE_Merge_Configuration.MergeProperty.FieldPreferHigh)) {
            removeNullValues(propType, fieldName, allValues);
            List<Object> allValuesAsList = new List<Object>(allValues);
            allValuesAsList.sort();
            newWinnerValue = allValuesAsList.isEmpty() ? newWinnerValue : allValuesAsList[allValuesAsList.size()-1];
        } else if(CORE_Merge_Configuration.isPropertyType(propType, CORE_Merge_Configuration.MergeProperty.FieldPreferLow)) {
            removeNullValues(propType, fieldName, allValues);
            List<Object> allValuesAsList = new List<Object>(allValues);
            allValuesAsList.sort();
            newWinnerValue = allValuesAsList.isEmpty() ? newWinnerValue : allValuesAsList[0];
        } else if(CORE_Merge_Configuration.isPropertyType(propType, CORE_Merge_Configuration.MergeProperty.FieldSum)) {
            removeNullValues(propType, fieldName, allValues);
            Double sum = 0.0;
            
            for(Object val : allValues) {
                sum += Double.valueOf(val);
            }
            
            Schema.SObjectField fld = getSObjectDescribe().fields.getMap().get(fieldName);
            Boolean isIntegerType = fld!=null && fld.getDescribe().getType() == Schema.DisplayType.Integer;
            newWinnerValue = sum>0 ? (isIntegerType ? (Object)Integer.valueOf(sum.round()) : (Object)sum) : newWinnerValue;
        } else if(CORE_Merge_Configuration.isPropertyType(propType, CORE_Merge_Configuration.MergeProperty.FieldAvg)) {
            removeNullValues(propType, fieldName, allValues);
            
            Double sum = 0.0;
            Integer counter=0;
            
            for(Object val : allValues) {
                sum += Double.valueOf(val);
                counter++;
            }
            
            Double avg = counter!=0 ? sum/(Double)counter : 0.0;
            Schema.SObjectField fld = getSObjectDescribe().fields.getMap().get(fieldName);
            Boolean isIntegerType = fld!=null && fld.getDescribe().getType() == Schema.DisplayType.Integer;
            newWinnerValue = avg>0 ? (isIntegerType ? (Object)Integer.valueOf(avg.round()) : (Object)avg) : newWinnerValue;
        } else if(CORE_Merge_Configuration.isPropertyType(propType, CORE_Merge_Configuration.MergeProperty.FieldConcatenate)) {
            removeNullValues(propType, fieldName, allValues);
            List<String> valuesAsString = new List<String>();
            
            for(Object val : allValues) {
                valuesAsString.add((String)val);
            }
            
            Map<String,Object> fieldAttrs = (Map<String,Object>)getMergeObject().getPropertyAttributes(propType, fieldName);
            newWinnerValue = valuesAsString.isEmpty() ? newWinnerValue : String.join(valuesAsString, fieldAttrs!=null && fieldAttrs.containsKey(FIELD_ATTRIBUTE_VALUE_SEPARATOR) ? (String)fieldAttrs.get(FIELD_ATTRIBUTE_VALUE_SEPARATOR) : ';');
        } else if(CORE_Merge_Configuration.isPropertyType(propType, CORE_Merge_Configuration.MergeProperty.FieldCustomTransfer)) {
            CORE_Merge_Interface.CustomFieldTransferInterface handlerInstance = (CORE_Merge_Interface.CustomFieldTransferInterface)getMergeObject().getPropertyValue(propType, fieldName);
            newWinnerValue = handlerInstance.mergeTransferField(fieldName, getMergeObject(), mGroup, this);
        } else if(CORE_Merge_Configuration.isPropertyType(propType, CORE_Merge_Configuration.MergeProperty.FieldConcatenateUnique)){
            removeNullValues(propType, fieldName, allValues);
            Set<String> valuesAsString = new Set<String>();
            Map<String,Object> fieldAttrs = (Map<String,Object>)getMergeObject().getPropertyAttributes(propType, fieldName);
            String separator = fieldAttrs != null && fieldAttrs.containsKey(FIELD_ATTRIBUTE_VALUE_SEPARATOR) ? (String)fieldAttrs.get(FIELD_ATTRIBUTE_VALUE_SEPARATOR) : ';';
            for(Object val : allValues) {
                String strToSplit = (String)val;
                String[] splitValues = strToSplit.split(separator);
                for(String unit:splitValues){
                    valuesAsString.add(unit);
                }
            }

            List<String> units = new List<String>(valuesAsString);           
            newWinnerValue = units.isEmpty() ? newWinnerValue : String.join(units, separator);
        }
        
        return newWinnerValue;
    }
    
    protected void removeNullValues(String propType, String fieldName, Set<Object> values) {
        values.remove(null);
        Map<String,Object> fieldAttrs = (Map<String,Object>)getMergeObject().getPropertyAttributes(propType, fieldName);
        
        if(fieldAttrs!=null && fieldAttrs.containsKey(FIELD_ATTRIBUTE_NULL_VALUES)) {
            Set<Object> nullValues = new Set<Object>((List<Object>)fieldAttrs.get(FIELD_ATTRIBUTE_NULL_VALUES));
            
            for(Object nullValue : nullValues) {
                for(Object val : values.clone()) {
                    if(val==nullValue) {
                        values.remove(val);
                    }
                }
            }
        }
    }
    
    protected void preMergeActions() {
        Map<String,Object> customActions = getMergeObject().getPropertiesByType(CORE_Merge_Configuration.MergeProperty.CustomPreMergeAction);
        
        for(CORE_Merge_Util.MergeGroupWrapper mGroup : getValidMergeGroups()) {
            Boolean winnerChanged = false;
            
	        for(String actionName : customActions.keySet()) {
	            CORE_Merge_Interface.CustomPreMergeActionInterface handlerInstance = (CORE_Merge_Interface.CustomPreMergeActionInterface)customActions.get(actionName);
	            winnerChanged |= handlerInstance.mergeExecutePreAction(actionName, getMergeObject(), mGroup, this)==true;
	        }
	        
	        mGroup.getWinnerCandidate().setIsChanged(winnerChanged);
        }
    }
    
    protected void updateWinner() {
        List<SObject> winnersToUpdate = new List<SObject>();
        List<CORE_Merge_Util.MergeCandidateWrapper> dmlCandidates = new List<CORE_Merge_Util.MergeCandidateWrapper>();
        
        for(CORE_Merge_Util.MergeGroupWrapper mGroup : getValidMergeGroups()) {
	        if(mGroup.getWinnerCandidate().isSourceValid() && mGroup.getWinnerCandidate().isChanged()) {
	            winnersToUpdate.add(mGroup.getWinnerCandidate().getSourceRecordToUpdate());
	            dmlCandidates.add(mGroup.getWinnerCandidate());
	        }
        }
        
        if(!winnersToUpdate.isEmpty()) {
            Database.SaveResult[] saveResults = Database.update(winnersToUpdate, false);
            List<CORE_Merge_Util.DmlResult> dmlResults = new List<CORE_Merge_Util.DmlResult>();
            
            Integer idx=0;
            for(Database.SaveResult sr : saveResults) {
                dmlResults.add(new CORE_Merge_Util.DmlResult(sr, dmlCandidates[idx++]));
            }
            
            processDmlResults(dmlResults, false);
        }
    }
    
    protected void mergeCandidates() {
        List<SObject> losersToDelete = new List<SObject>();
        List<CORE_Merge_Util.DmlResult> dmlResults = new List<CORE_Merge_Util.DmlResult>();
        List<CORE_Merge_Util.MergeCandidateWrapper> dmlCandidates = new List<CORE_Merge_Util.MergeCandidateWrapper>();
        dmlResults.addAll(excludeChildRelationships());
        dmlResults.addAll(moveChildRelationships());
        
        for(CORE_Merge_Util.MergeGroupWrapper mGroup : getValidMergeGroups()) {
            List<SObject> losers = new List<SObject>();
            
            if(mGroup.getWinnerCandidate().isSourceValid()) {
                for(CORE_Merge_Util.MergeCandidateWrapper loserCandidate : mGroup.getLoserCandidates()) {
                    if(loserCandidate.isSourceValid()) {
                        SObject srcRec = loserCandidate.getSourceRecord();
                        SObject loser = srcRec.getSObjectType().newSObject(srcRec.Id);
                        losers.add(loser);
                        dmlCandidates.add(loserCandidate);
                    }
                }
            }
            
            if(!losers.isEmpty() && getSObjectDescribe().isMergeable()) {
                for(Integer i=0;i<=(losers.size()/2);i++) {
                    List<SObject> losersSubScope = new List<SObject>();
                    
                    if(2*i<losers.size()) {
                        losersSubScope.add(losers[2*i]);
                    }
                        
                    if((2*i+1)<losers.size()) {
                        losersSubScope.add(losers[2*i+1]);
                    }
                    
                    if(!losersSubScope.isEmpty()) {
                        SObject srcRec = mGroup.getWinnerCandidate().getSourceRecord();
                        SObject winner = srcRec.getSObjectType().newSObject(srcRec.Id);
                        Database.MergeResult[] mergeResults = Database.merge(winner, losersSubScope, false);
                        
                        for(Database.MergeResult mergeResult : mergeResults) {
                            dmlResults.add(new CORE_Merge_Util.DmlResult(mergeResult, mGroup.getWinnerCandidate()));
                        }
                    }
                }
            } else if(!losers.isEmpty()){
                losersToDelete.addAll(losers);
            }
        }
        
        if(!losersToDelete.isEmpty()) {
            Database.DeleteResult[] delResults = Database.delete(losersToDelete, false);
            
            Integer idx=0;
            for(Database.DeleteResult delResult : delResults) {
                dmlResults.add(new CORE_Merge_Util.DmlResult(delResult, dmlCandidates[idx++]));
            }
        }
        
        processDmlResults(dmlResults, true);
    }
    
    protected List<CORE_Merge_Util.DmlResult> excludeChildRelationships() {
        List<CORE_Merge_Util.DmlResult> dmlResults = new List<CORE_Merge_Util.DmlResult>();
        Map<String,Object> childRelationshipConfig = getMergeObject().getPropertiesByType(CORE_Merge_Configuration.MergeProperty.RelationshipToExclude);
                
        for(String key : childRelationshipConfig.keySet()) {
            CORE_Merge_Configuration.RelationshipConfigWrapper rcw = (CORE_Merge_Configuration.RelationshipConfigWrapper)childRelationshipConfig.get(key);
            String relName = rcw.getRelationshipName();
            List<SObject> childRecsToDelete = new List<SObject>();
            List<CORE_Merge_Util.MergeCandidateWrapper> dmlCandidates = new List<CORE_Merge_Util.MergeCandidateWrapper>();
        
	        for(CORE_Merge_Util.MergeGroupWrapper mGroup : getValidMergeGroups()) {
	            for(CORE_Merge_Util.MergeCandidateWrapper loserCandidate : mGroup.getLoserCandidates()) {
	                if(loserCandidate.isSourceValid()) {
	                    List<SObject> childRecs = getChildSObject(loserCandidate.getSourceRecord(), rcw);
	                    
	                    if(childRecs!=null && !childRecs.isEmpty()) {
	                        for(SObject childRec : childRecs) {
                                childRecsToDelete.add(childRec);
                                dmlCandidates.add(loserCandidate);
                            }
	                    }
	                }
	            }
	        }
	        
	        if(!childRecsToDelete.isEmpty()) {
	            Integer expectedDmlRows = Limits.getDmlRows() + childRecsToDelete.size();
                if(expectedDmlRows < Limits.getLimitDmlRows()){
	            Database.DeleteResult[] delResults = Database.delete(childRecsToDelete, false);
	            
	            Integer idx = 0;
	            for(Database.DeleteResult delResult : delResults) {
	                dmlResults.add(new CORE_Merge_Util.DmlResult(delResult, dmlCandidates[idx++]));
	            }
                } else {
                    handleException(new CORE_Merge_Util.MergeCandidateException(Core_Merge_Util.ERROR_EXPECTED_TOO_MANY_DML + expectedDmlRows), getValidMergeGroups());
                }
	        }
        }
        
        return dmlResults;
    }
    
    protected List<CORE_Merge_Util.DmlResult> moveChildRelationships() {
        List<CORE_Merge_Util.DmlResult> dmlResults = new List<CORE_Merge_Util.DmlResult>();
        Map<String,Object> childRelationshipConfig = getMergeObject().getPropertiesByType(CORE_Merge_Configuration.MergeProperty.RelationshipToMove);
        
        for(String key : childRelationshipConfig.keySet()) {
            CORE_Merge_Configuration.RelationshipConfigWrapper rcw = (CORE_Merge_Configuration.RelationshipConfigWrapper)childRelationshipConfig.get(key);
            String relName = rcw.getRelationshipName();
            SObjectField fld = getChildRelationshipMap().get(relName).getField();
            String fldName = String.valueOf(fld);
            List<SObject> childRecsToUpdate = new List<SObject>();
            List<CORE_Merge_Util.MergeCandidateWrapper> dmlCandidates = new List<CORE_Merge_Util.MergeCandidateWrapper>();
            
            for(CORE_Merge_Util.MergeGroupWrapper mGroup : getValidMergeGroups()) {
                if(mGroup.getWinnerCandidate().isSourceValid()) {
                    Id winnerId = mGroup.getWinnerCandidate().getSourceRecord().Id;
                    
	                for(CORE_Merge_Util.MergeCandidateWrapper loserCandidate : mGroup.getLoserCandidates()) {
	                    if(loserCandidate.isSourceValid()) {
	                        List<SObject> childRecs = getChildSObject(loserCandidate.getSourceRecord(), rcw);
	                        
	                        if(childRecs!=null && !childRecs.isEmpty()) {
	                            for(SObject childRec : childRecs) {
	                                childRec.put(fldName, winnerId);
	                                childRecsToUpdate.add(childRec);
	                                dmlCandidates.add(loserCandidate);
	                            }
	                        }
	                    }
	                }
                }
            }
            
            if(!childRecsToUpdate.isEmpty()) {
                Integer expectedDmlRows = Limits.getDmlRows() + childRecsToUpdate.size();
                if(expectedDmlRows < Limits.getLimitDmlRows()) {
                Database.SaveResult[] saveResults = Database.update(childRecsToUpdate, false);
                
                Integer idx = 0;
                for(Database.SaveResult saveResult : saveResults) {
                    dmlResults.add(new CORE_Merge_Util.DmlResult(saveResult, dmlCandidates[idx++]));
                    }
                } else {
                    handleException(new CORE_Merge_Util.MergeCandidateException(Core_Merge_Util.ERROR_EXPECTED_TOO_MANY_DML + expectedDmlRows), getValidMergeGroups());
                }
            }
        }
        
        return dmlResults;
    }
    
    protected void processDmlResults(List<CORE_Merge_Util.DmlResult> dmlResults, Boolean forceThrowException) {
        for(CORE_Merge_Util.DmlResult dmlResult : dmlResults) {
            if(!dmlResult.isSuccess()) {
                for(Database.Error err : dmlResult.getErrors()) {
                    CORE_Merge_Util.MergeDmlException ex = new CORE_Merge_Util.MergeDmlException(err);
                    debug('processDmlResults(): dmlResult.getCandidate()!=null == ' + String.valueOf(dmlResult.getCandidate()!=null));
                    if(dmlResult.getCandidate()!=null && forceThrowException!=true) {
                        handleException(ex, dmlResult.getCandidate());    
                    } else {
                        throw ex;
                    }
                }
            }
        }
    }
    
    protected void populateChildCandidates() {
        this.visitedIds = new Set<String>();
        List<String> childQueries = new List<String>();
        List<CORE_Merge_Util.MergeObjectWrapper> subMergeObjects = new List<CORE_Merge_Util.MergeObjectWrapper>();
        Map<String,CORE_Merge_Util.MergeObjectWrapper> subMergeObjectsMap = new Map<String,CORE_Merge_Util.MergeObjectWrapper>();
        if(!getMergeObject().isPopulateCandidatesFromParentEnabled()) {
	        for(CORE_Merge_Util.MergeObjectWrapper mObjWrapper : getMergeObject().getNextMergeObjects()) {
	            if(mObjWrapper.isPopulateCandidatesFromParentEnabled()) {
		            String sObjectName = mObjWrapper.getSObjectName().toUpperCase();
		            subMergeObjects.add(mObjWrapper);
		            subMergeObjectsMap.put(sObjectName, mObjWrapper);
	            }
	        }
        }
        
        Map<String,CORE_Merge_Util.MergeObjectWrapper> relNameToMergeObjectMap = new Map<String,CORE_Merge_Util.MergeObjectWrapper>();
        
        if(!subMergeObjects.isEmpty()) {
            Map<String,Schema.ChildRelationship> childRelationshipsMap = getChildRelationshipMap();
        
        
	        for(String relName : childRelationshipsMap.keySet()) {
	            Schema.ChildRelationship relDescriptor = childRelationshipsMap.get(relName);
	            
	            if(relDescriptor.getChildSObject()!=null) {
	                String sObjectName = relDescriptor.getChildSObject().getDescribe().getName().toUpperCase();
	                if(subMergeObjectsMap.containsKey(sObjectName)) {
	                    CORE_Merge_Util.MergeObjectWrapper childMergeObject = subMergeObjectsMap.get(sObjectName);
	                    relNameToMergeObjectMap.put(relName, subMergeObjectsMap.get(sObjectName));
	                    String query = getPopulateCandidatesQuery(childMergeObject, false, relName, relDescriptor);
	                    childQueries.add('(' + query + ')');
	                }
	            }
	        }
        }
        
        if(!childQueries.isEmpty()) {
            Set<Id> winnerIds = new Set<Id>();
            
            for(CORE_Merge_Util.MergeGroupWrapper mGroup : getValidMergeGroups()) {
                if(mGroup.getWinnerCandidate().isSourceValid()) {
                    winnerIds.add(mGroup.getWinnerCandidate().getSourceRecord().Id);
                }
            }
            
            List<SObject> winnersWithChildDuplicates = new List<SObject>();
            
            if(!winnerIds.isEmpty()) {
	            String winnerQuery = String.format('SELECT {0} FROM {1} WHERE ID IN :winnerIds', new String[]{
	                String.join(new List<String>(childQueries), ','),
	                getMergeObject().getSObjectName()
	            });
	        
	            winnersWithChildDuplicates = Database.query(winnerQuery);
            }
            
            for(SObject winnerRec : winnersWithChildDuplicates) {
	            for(String relName : relNameToMergeObjectMap.keySet()) {
	                CORE_Merge_Util.MergeObjectWrapper childMergeObject = relNameToMergeObjectMap.get(relName);
	                String uniqueFieldName = childMergeObject.getPopulateCandidatesUniqueFieldName().toUpperCase();
	                String whereFilter = childMergeObject.getPopulateCandidatesWhereClause();
	                List<String> sortByList = new List<String>{uniqueFieldName};
                    sortByList.addAll(childMergeObject.getPopulateCandidatesSortByColumns());
	                CORE_Merge_Configuration.RelationshipConfigWrapper rcw = new CORE_Merge_Configuration.RelationshipConfigWrapper(relName, new Set<String>{uniqueFieldName}, whereFilter, String.join(sortByList, ','));
	                List<SObject> childRecs = getChildSObject(winnerRec, rcw);
	                populateCandidates(childMergeObject, childRecs, true);
	            }
            }
        }
        
    }
    
    public virtual String getPopulateCandidatesQuery(CORE_Merge_Object__c mergeObjRec) {
        this.mergeObject = new CORE_Merge_Util.MergeObjectWrapper(mergeObjRec);
        return getPopulateCandidatesQuery(getMergeObject(), true, null, null);
    }
    
    private String getPopulateCandidatesQuery(CORE_Merge_Util.MergeObjectWrapper mObject, Boolean isBatchMode, String relName, Schema.ChildRelationship relDescriptor) {
        String uniqueFieldName = mObject.getPopulateCandidatesUniqueFieldName().toUpperCase();
        List<String> sortByFields = mObject.getPopulateCandidatesSortByColumns();
        String whereFilter = isBatchMode ? mObject.getPopulateCandidatesBatchWhereClause() : mObject.getPopulateCandidatesWhereClause();
        
        Set<String> queryFields = new Set<String>{'ID'};
        queryFields.add(uniqueFieldName);
        
        if(!isBatchMode) {
            queryFields.add(String.valueOf(relDescriptor.getField()).toUpperCase());
        }
        
        List<String> sortByList = new List<String>{uniqueFieldName};
        sortByList.addAll(sortByFields);
        
        String query = String.format('SELECT {0} FROM {1}{2} ORDER BY {3}{4}', new String[]{
            String.join(new List<String>(queryFields), ','),
            isBatchMode ? mObject.getSObjectName() : relName,
            String.isNotBlank(whereFilter) ? (' WHERE ' + whereFilter) : '',
            String.join(sortByList, ','),
            isBatchMode ? ' LIMIT 50000000' : ''
        });
        
        return query;
    }
    
    public virtual List<SObject> populateCandidates(CORE_Merge_Object__c mergeObjRec, List<SObject> recs, Boolean processLastGroup) {
        List<SObject> duplicates = new List<SObject>();
        
        System.Savepoint sp = Database.setSavepoint();
        Boolean isOk = false;
        Exception ex = null;
        
        try {
            this.mergeObject = new CORE_Merge_Util.MergeObjectWrapper(mergeObjRec);
            notifyOnActions(CORE_Merge_Interface.MergeProcessState.Start, CORE_Merge_Interface.MergeProcessState.BeforePopulateCandidates);
            duplicates = populateCandidates(getMergeObject(), recs, processLastGroup);
            notifyOnActions(CORE_Merge_Interface.MergeProcessState.AfterPopulateCandidates, CORE_Merge_Interface.MergeProcessState.Finish);
            isOk = true;
        } catch(Exception e) {
            ex = e;
        } finally {
            if(!isOk) {
                Database.rollback(sp);    
            }
            
            if(ex!=null) {
                handleException(ex);
            }
            
            saveMergeCandidates(true);
        }
        
        return duplicates;
    }
    
    private List<SObject> populateCandidates(CORE_Merge_Util.MergeObjectWrapper childMergeObject, List<SObject> childRecs, Boolean processLastGroup) {
        List<SObject> duplicates = new List<SObject>();
        String uniqueFieldName = childMergeObject.getPopulateCandidatesUniqueFieldName();
        
        if(childRecs!=null && !childRecs.isEmpty()) {
            Object lastUniqueKey = null;
            
            for(SObject childRec : childRecs) {
                Object uniqueKey = childRec.get(uniqueFieldName);
                
                if(lastUniqueKey!=null && uniqueKey!=lastUniqueKey) {
                    intPopulateCandidates(duplicates, childMergeObject);
                }
                            
                duplicates.add(childRec);
                lastUniqueKey = uniqueKey;
            }
                        
            if(processLastGroup==true) {
                intPopulateCandidates(duplicates, childMergeObject);
            }
        }
        
        return duplicates;
    }
    
    private void intPopulateCandidates(List<SObject> duplicates, CORE_Merge_Util.MergeObjectWrapper childMergeObject) {
        Boolean duplicatesFound = duplicates.size()>1;
        if(duplicatesFound) {
            createAutoMergeCandidates(duplicates, childMergeObject);
        }
        
        Map<String,Object> customActions = childMergeObject.getPropertiesByType(CORE_Merge_Configuration.MergeProperty.CustomPostPopulateAction);
            
        for(String actionName : customActions.keySet()) {
            CORE_Merge_Interface.CustomPostPopulateActionInterface handlerInstance = (CORE_Merge_Interface.CustomPostPopulateActionInterface)customActions.get(actionName);
            handlerInstance.mergePostPopulateAction(actionName, childMergeObject, duplicates, this);
        }
        
        duplicates.clear();
    }
    
    protected void createAutoMergeCandidates(List<SObject> duplicates, CORE_Merge_Util.MergeObjectWrapper childMergeObject) {
        List<CORE_Merge_Candidate__c> mCandidates = new List<CORE_Merge_Candidate__c>();
        
        for(SObject duplicate : duplicates) {
            CORE_Merge_Candidate__c mc = new CORE_Merge_Candidate__c(
                Id_gne__c = duplicate.Id, Master_Id_gne__c = duplicates[0].Id,
                Type_gne__c = CORE_Merge_Util.CANDIDATE_TYPE_MERGE,
                Source_gne__c = CORE_Merge_Util.CANDIDATE_SOURCE_AUTO_POPULATE,
                Status_gne__c = CORE_Merge_Util.CANDIDATE_STATUS_LOADED,
                Merge_Object_gne__c = childMergeObject.getMergeObject().Id,
                Merge_Object_gne__r = childMergeObject.getMergeObject(),
                Error_Codes_gne__c = null,
                Error_Details_gne__c = null);
            mc.External_Id_gne__c = String.format('{0}_{1}_{2}_{3}', new String[]{mc.Id_gne__c, mc.Master_Id_gne__c, mc.Type_gne__c, mc.Status_gne__c});
            
            if(this.visitedIds!=null && this.visitedIds.contains(mc.Id_gne__c.toUpperCase())) {
                if(mc.Id_gne__c==mc.Master_Id_gne__c) {
                    break;
                }
            } else {
                mCandidates.add(mc);
            }
        }
        
        if(mCandidates.size()>1) {
            if(this.visitedIds!=null) {
	            for(CORE_Merge_Candidate__c mc : mCandidates) {
	                this.visitedIds.add(mc.Id_gne__c.toUpperCase());
	            }
            }
            
            Map<Id,List<CORE_Merge_Util.MergeGroupWrapper>> mergeCandidateChildGroups = getCache().getChildMergeGroupsToProcess();
            String mObjId = childMergeObject.getMergeObject().Id;
	        
	        if(!mergeCandidateChildGroups.containsKey(mObjId)) {
	            mergeCandidateChildGroups.put(mObjId, new List<CORE_Merge_Util.MergeGroupWrapper>());
	        }
	        
	        mergeCandidateChildGroups.get(mObjId).add(new CORE_Merge_Util.MergeGroupWrapper(mCandidates[0], mCandidates));
        }
    }
    
    protected void mergeChildCandidates() {
        Map<Id,List<CORE_Merge_Util.MergeGroupWrapper>> mergeCandidateChildGroups = getCache().getChildMergeGroupsToProcess();
        
        if(!getCache().getChildMergeGroupsToProcess().isEmpty()) {
            CORE_Merge_Util.MergeObjectWrapper parentMergeObj = getMergeObject().getParentMergeObject()!=null ? getMergeObject().getParentMergeObject() : getMergeObject();
            
            for(CORE_Merge_Util.MergeObjectWrapper mObjWrapper : parentMergeObj.getChildMergeObjects()) {
                Id mObjId = mObjWrapper.getMergeObject().Id;
                
                if(getCache().getChildMergeGroupsToProcess().containsKey(mObjId)) {
                    if(mObjWrapper.isMergeFromParentEnabled()) {
                        doMergeInSubProcess(mObjId);
                    } else {
                        getCache().getChildMergeGroupsToLoad().addAll(getCache().getChildMergeGroupsToProcess().remove(mObjId));
                    }
                }
            }
        }
    }
    
    protected void doMergeInSubProcess(Id childMergeObjId) {
        if(isEnoughResourcesToExecuteSubProcess()) {
	        CORE_Merge_Engine childEngine = new CORE_Merge_Engine();
	        childEngine.initEngine(getMergeJob(), isPreviewMode(), true);
	        childEngine.doMerge(getCache().getChildMergeGroupsToProcess().remove(childMergeObjId));
	        getCache().getMergeGroups().addAll(childEngine.getCache().getMergeGroups());
	        getCache().getErrors().addAll(childEngine.getCache().getErrors());
	        getCache().getWinnerArchiveRecs().putAll(childEngine.getCache().getWinnerArchiveRecs());
	        getCache().getLoserArchiveRecs().putAll(childEngine.getCache().getLoserArchiveRecs());
	        getCache().getArchiveChildRecords().addAll(childEngine.getCache().getArchiveChildRecords());
	        getCache().getArchiveJsonParts().addAll(childEngine.getCache().getArchiveJsonParts());
        }
    }
    
    protected Boolean isEnoughResourcesToExecuteSubProcess() {
        Double cpuTimePercent = Limits.getLimitCpuTime()>0 ? (Double)Limits.getCpuTime()/(Double)Limits.getLimitCpuTime() : 0.0;
        return cpuTimePercent<=0.6;
    }
    
    protected void postMergeActions() {
        Map<String,Object> customActions = getMergeObject().getPropertiesByType(CORE_Merge_Configuration.MergeProperty.CustomPostMergeAction);
        
        for(CORE_Merge_Util.MergeGroupWrapper mGroup : getValidMergeGroups()) {
            for(String actionName : customActions.keySet()) {
                CORE_Merge_Interface.CustomPostMergeActionInterface handlerInstance = (CORE_Merge_Interface.CustomPostMergeActionInterface)customActions.get(actionName);
                handlerInstance.mergeExecutePostAction(actionName, getMergeObject(), mGroup, this);
            }    
        }
    }
    
    protected void saveArchiveData() {
        Map<String,CORE_Merge_Archive_Record__c> allWinnerArchiveRecs = getCache().getWinnerArchiveRecs(); 
        Map<String,CORE_Merge_Archive_Record__c> allLoserArchiveRecs = getCache().getLoserArchiveRecs();
        List<SObject> allArchiveChildRecords = getCache().getArchiveChildRecords();
        List<CORE_Merge_Archive_JSON_Part__c> allArchiveJsonParts = getCache().getArchiveJsonParts();
        Map<String,SObject> allArchiveClones = getCache().getArchiveClones();
        
        Map<String,CORE_Merge_Archive_Record__c> newArchiveRecs = new Map<String,CORE_Merge_Archive_Record__c>();
        Map<String,SObject> newArchiveClones = new Map<String,SObject>();
        Map<String,CORE_Merge_Util.MergeCandidateWrapper> dmlCandidates = new Map<String,CORE_Merge_Util.MergeCandidateWrapper>();
        Database.DMLOptions cloneDmlOptions = new Database.DMLOptions();
        cloneDmlOptions.allowFieldTruncation = true;
        cloneDmlOptions.DuplicateRuleHeader.AllowSave = true;
        
        for(CORE_Merge_Util.MergeGroupWrapper mGroup : getValidMergeGroups()) {
            for(CORE_Merge_Util.MergeCandidateWrapper mc : mGroup.getAllCandidates()) {
                CORE_Merge_Archive_Record__c archiveRec = mc.getArchiveRecord();
                SObject archiveClone = mc.getArchiveClone();
                
                if(archiveRec!=null && archiveClone!=null) {
                    archiveClone.setOptions(cloneDmlOptions);
                    allArchiveClones.put(archiveRec.External_Id_gne__c,archiveClone);
                    newArchiveRecs.put(archiveRec.External_Id_gne__c,archiveRec);
                    newArchiveClones.put(archiveRec.External_Id_gne__c,archiveClone);
                    dmlCandidates.put(archiveRec.External_Id_gne__c,mc);
                } 
            }
        }
        
        intSaveArchiveData(null, allArchiveClones, dmlCandidates);
        
        for(String extId : newArchiveClones.keySet()) {
            if(newArchiveRecs.containsKey(extId)) {
                newArchiveRecs.get(extId).Archive_Clone_Id_gne__c = newArchiveClones.get(extId).Id;
            }
        }
        
        for(CORE_Merge_Util.MergeGroupWrapper mGroup : getValidMergeGroups()) {
            for(CORE_Merge_Util.MergeCandidateWrapper mc : mGroup.getAllCandidates()) {
                CORE_Merge_Archive_Record__c archiveRec = mc.getArchiveRecord();
                List<SObject> archiveChildRecords = mc.getArchiveChildRecords();
                List<CORE_Merge_Archive_JSON_Part__c> archiveJsonParts = mc.getArchiveJsonParts();
                
                if(archiveRec!=null) {
                    if(archiveRec.Master_Archive_Record_gne__r==null) {
                        allWinnerArchiveRecs.put(archiveRec.External_Id_gne__c,archiveRec);
                    } else {
                        allLoserArchiveRecs.put(archiveRec.External_Id_gne__c,archiveRec);
                    }
                    
                    allArchiveChildRecords.addAll(archiveChildRecords);
                    allArchiveJsonParts.addAll(archiveJsonParts);
                }
            }
        }
        
        if(!isSubProcess()) {
            intSaveArchiveData(null, allWinnerArchiveRecs, null);
            intSaveArchiveData(null, allLoserArchiveRecs, null);
            intSaveArchiveData(sortBySObjectType(allArchiveChildRecords), null, null);
            intSaveArchiveData(allArchiveJsonParts, null, null);
        }
    }
    
    protected List<SObject> sortBySObjectType(List<SObject> recs) {
        Map<String,SObject> recsMap = new Map<String,SObject>();
         
        for(Integer i=0;i<recs.size();i++) {
            SObject rec = recs[i];
            recsMap.put(String.format('{0}_{1}', new String[]{String.valueOf(rec.getSObjectType()), String.valueOf(i)}), rec);
        }
        
        recs.clear();
        List<String> sortedKeys = new List<String>(recsMap.keySet());
        sortedKeys.sort();
        
        for(String key : sortedKeys) {
            recs.add(recsMap.get(key));
        }
        
        return recs;
    }
    
    protected void intSaveArchiveData(List<SObject> archiveCacheList, Map<String,SObject> archiveCacheMap, Map<String,CORE_Merge_Util.MergeCandidateWrapper> dmlCandidates) {
        List<SObject> archiveRecsToInsert = new List<SObject>();
        List<CORE_Merge_Util.MergeCandidateWrapper> dmlCandidatesList = new List<CORE_Merge_Util.MergeCandidateWrapper>();
        Integer remainingDmlRows = Limits.getLimitDMLRows()-Limits.getDMLRows()-getCache().getErrorsSize() - getCache().getCandidatesSize() - 10;
        Integer cacheSize = archiveCacheList!=null? archiveCacheList.size() : archiveCacheMap.size();
        Integer scopeSize = dmlCandidates==null ? Math.min(remainingDmlRows,cacheSize) : cacheSize;
        
        
        if(archiveCacheList!=null) {
	        for(Integer i=0;i<scopeSize;i++) {
	            archiveRecsToInsert.add(archiveCacheList.remove(0));
	        }
        } else {
            List<String> keys = new List<String>(archiveCacheMap.keySet());
            
            for(Integer i=0;i<scopeSize;i++) {
                archiveRecsToInsert.add(archiveCacheMap.remove(keys[i]));
                
                if(dmlCandidates!=null) {
                    dmlCandidatesList.add(dmlCandidates.remove(keys[i]));
                }
            }
        }
        
        if(!archiveRecsToInsert.isEmpty()) {
            List<CORE_Merge_Util.DmlResult> dmlResults = new List<CORE_Merge_Util.DmlResult>();
            Database.SaveResult[] saveResults = Database.insert(archiveRecsToInsert, false);
            System.debug(archiveRecsToInsert);
	    
	        Integer idx=0;
	        for(Database.SaveResult sr : saveResults) {
	           dmlResults.add(new CORE_Merge_Util.DmlResult(sr, !dmlCandidatesList.isEmpty() ? dmlCandidatesList[idx++] : null));
	        }
            
            processDmlResults(dmlResults, dmlCandidates!=null);
        }
    }
    
    protected List<SObject> getChildSObject(SObject rec, CORE_Merge_Configuration.RelationshipConfigWrapper rcw) {
        List<SObject> result = null;
        String relName = rcw.getRelationshipName();
        String key = String.format('{0}_{1}', new String[]{rec.Id, relName});
        
        if(childRecordsCache==null) {
            childRecordsCache = new Map<String,List<SObject>>();
        }
        
        if(childRecordsCache.containsKey(key)) {
            result = childRecordsCache.get(key);
        } else {
            try {
                result = rec.getSObjects(relName);
            } catch(System.QueryException ex) {
                if((Limits.getQueries()+15)>Limits.getLimitQueries()) {
                    throw ex;
                } else {
	                SObjectField fld = getChildRelationshipMap().get(relName).getField();
	                Set<String> queryFields = new Set<String>(String.join(new List<String>(rcw.getQueryFields()),',').toUpperCase().split(','));
	                queryFields.remove('');
	                queryFields.addAll(new Set<String>{String.valueOf(fld).toUpperCase(), 'ID'});
	                Id recId = rec.Id;
	                result = Database.query(String.format('SELECT {0} FROM {1} WHERE {2} = :recId{3} ORDER BY {4} LIMIT {5}', new String[]{
	                    String.join(new List<String>(queryFields), ','),
	                    getChildRelationshipMap().get(relName).getChildSObject().getDescribe().getName(),
	                    String.valueOf(fld),
	                    rcw!=null && String.isNotEmpty(rcw.getQueryWhere()) ? ' AND (' + rcw.getQueryWhere() + ')' : '',
	                    rcw!=null && String.isNotEmpty(rcw.getQueryOrderBy()) ? rcw.getQueryOrderBy() : 'ID DESC',
	                    rcw!=null && rcw.getQueryLimit()!=null ? String.valueOf(rcw.getQueryLimit()) : '10000'
	                }));
	                
	                childRecordsCache.put(key,result);
                }
            }
        }
           
        return result;
    }
    
    public virtual void handleException(Exception ex) {
        handleException(ex, null, null);
    }
    
    public virtual void handleException(Exception ex, CORE_Merge_Interface.MergeCandidateInterface mergeCandidate) {
        handleException(ex, new List<CORE_Merge_Interface.MergeGroupInterface>{mergeCandidate.getMergeGroup()}, new List<CORE_Merge_Interface.MergeCandidateInterface>{mergeCandidate});
    }
    
    public virtual void handleException(Exception ex, List<CORE_Merge_Interface.MergeGroupInterface> mergeGroups) {
        handleException(ex, mergeGroups, null);
    }
    
    public virtual void handleException(Exception ex, List<CORE_Merge_Interface.MergeGroupInterface> mergeGroups, List<CORE_Merge_Interface.MergeCandidateInterface> mergeCandidates) {
        debug('handleException(): ex=' + ex + ', mergeGroups.size()=' + (mergeGroups!=null ? mergeGroups.size() : null) + ', mergeCandidates.size()=' + (mergeCandidates!=null ? mergeCandidates.size() : null));
        
        if(mergeGroups!=null) {
            for(CORE_Merge_Interface.MergeGroupInterface mergeGroup : mergeGroups) {
                if(mergeGroup!=null) {
                    mergeGroup.setIsValid(false);
                    
                    if(mergeCandidates==null) {
	                    for(CORE_Merge_Interface.MergeCandidateInterface mc : mergeGroup.getAllCandidates()) {
	                        mc.addError(getMergeObjectRecord(), ex, false);
	                    }
                    }
                }
            }
        }
        
        if(mergeCandidates!=null) {
            for(CORE_Merge_Interface.MergeCandidateInterface mc : mergeCandidates) {
                if(mc!=null) {
                    mc.addError(getMergeObjectRecord(), ex);
                }    
            }
        } else {
            getCache().getErrors().add(new CORE_Merge_Util.ErrorWrapper(getMergeObjectRecord(), ex));
        }
    }
    
    protected void switchAdminMode(Boolean turnOnOrOff) {
        Boolean prevAdminModeValue = CORE_Merge_Util.switchAdminMode(turnOnOrOff==false && this.prevAdminMode!=null ? this.prevAdminMode : turnOnOrOff);
        
        if(this.prevAdminMode==null) {
            this.prevAdminMode = prevAdminModeValue;
        }
        
        CORE_Merge_Util.setForceTrigger(CORE_Merge_Candidate__c.sObjectType, turnOnOrOff);
        CORE_Merge_Util.setForceTrigger(CORE_Merge_Error__c.sObjectType, turnOnOrOff);
        CORE_Merge_Util.setForceTrigger(CORE_Merge_Archive_Record__c.sObjectType, turnOnOrOff);
        CORE_Merge_Util.setForceTrigger(CORE_Merge_Archive_App_Record__c.sObjectType, turnOnOrOff);
        CORE_Merge_Util.setForceTrigger(CORE_Merge_Archive_Child_Record__c.sObjectType, turnOnOrOff);
        CORE_Merge_Util.setForceTrigger(CORE_Merge_Archive_JSON_Part__c.sObjectType, turnOnOrOff);
    }
    
    protected void debug(String text) {
        System.debug('[COREMergeEngine][' + getCurrentState() + ']: ' + text);
    }
}