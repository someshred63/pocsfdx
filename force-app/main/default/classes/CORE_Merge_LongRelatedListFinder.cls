public class CORE_Merge_LongRelatedListFinder implements Database.Batchable<SObject>, Database.Stateful, CORE_Merge_Interface.MergeEngineBatchInterface{
    private CORE_Merge_Util.MergeJobWrapper mergeJob;
    private Set<String> winnerIds;
    private CORE_Merge_Object__c mergeObjectRecord;
    private Boolean initialized;
    private List<CORE_Merge_Candidate__c> duplicatesGroup;
    private String lastMasterId;
    private transient CORE_Merge_Util.MergeObjectWrapper mergeObject;
    
    private Set<Id> objectsWithRelationsToMove;
    private Map<Id, Set<Id>> mergeObjectId2winnersIds;
   	private CORE_Merge_Object__c mObjRec;
    private CORE_Merge_Engine mergeEngine;
    private Boolean isPreviewMode;
    private InitDataWrapper dataWrapper;
    private Id MergeObjectId;
    
    public CORE_Merge_LongRelatedListFinder(){ }   
    
    public CORE_Merge_LongRelatedListFinder(Map<Id, Set<Id>> mergeObjectId2winnersIds, Set<Id> objectsWithRelationsToMove, CORE_Merge_Util.MergeObjectWrapper mergeObject, InitDataWrapper dataWrapper){
        this.mergeObjectId2winnersIds = mergeObjectId2winnersIds;
        this.objectsWithRelationsToMove = objectsWithRelationsToMove;
        this.mergeObject = mergeObject;
        this.dataWrapper = dataWrapper;
    }
    
    public Database.QueryLocator start(Database.batchableContext BC) {
        initProcess();
        Id mergObjectId = getFirstId();
        CORE_Merge_Object__c [] confMergObject = [SELECT Id, Name, Object_Name_gne__c, Object_Type_gne__c from CORE_Merge_Object__c WHERE Id = :mergObjectId];
        mObjRec = confMergObject.isEmpty() ? null : confMergObject[0];
        if(mObjRec != null){
            mergeEngine = new CORE_Merge_Engine();
        	mergeEngine.setMergeObjectRecord(mObjRec);
        }
        if(dataWrapper.winnerIds != null){
            return Database.getQueryLocator([
                SELECT Id, External_Id_gne__c, Id_gne__c, Master_Id_gne__c, Merge_Object_gne__c, Candidate_Type_calc_gne__c
                FROM CORE_Merge_Candidate__c
                WHERE Status_gne__c IN (:CORE_Merge_Util.CANDIDATE_STATUS_LOADED)
                    AND Type_gne__c IN (:CORE_Merge_Util.CANDIDATE_TYPE_MERGE)
                    AND Merge_Object_gne__c = :mergObjectId
                    AND Candidate_Type_calc_gne__c = :CORE_Merge_Util.CANDIDATE_TYPE_WINNER
                    AND Master_Id_gne__c IN : dataWrapper.winnerIds
            ]);
        }
        return Database.getQueryLocator([
            SELECT Id, External_Id_gne__c, Id_gne__c, Master_Id_gne__c, Merge_Object_gne__c, Candidate_Type_calc_gne__c
            FROM CORE_Merge_Candidate__c
            WHERE Status_gne__c IN (:CORE_Merge_Util.CANDIDATE_STATUS_LOADED)
                AND Type_gne__c IN (:CORE_Merge_Util.CANDIDATE_TYPE_MERGE)
                AND Merge_Object_gne__c = :mergObjectId
                AND Candidate_Type_calc_gne__c = :CORE_Merge_Util.CANDIDATE_TYPE_WINNER
        ]);
        
    }
    public void execute(Database.BatchableContext BC, List<CORE_Merge_Candidate__c> scope) {        
        Set<id> candidateIds = new Set<Id>();     
        Set<Id> masterIds = new Set<Id>();
        
        for(CORE_Merge_Candidate__c cmc : scope){
            masterIds.add(cmc.Master_Id_gne__c);
        }
        
        Map<Id, List<CORE_Merge_Candidate__c>> master2Grups = new Map<Id, List<CORE_Merge_Candidate__c>>();
        Set<Id> losers = new Set<Id>();
        Map<Id, List<CORE_Merge_Candidate__c>> loserId2candidates = new Map<Id, List<CORE_Merge_Candidate__c>>();
        
        for(CORE_Merge_Candidate__c cmc : [
            SELECT Id, External_Id_gne__c, Id_gne__c, Master_Id_gne__c, Merge_Object_gne__c, Candidate_Type_calc_gne__c
            FROM CORE_Merge_Candidate__c
            WHERE Status_gne__c IN (:CORE_Merge_Util.CANDIDATE_STATUS_LOADED)
                AND Type_gne__c IN (:CORE_Merge_Util.CANDIDATE_TYPE_MERGE)
                AND Master_Id_gne__c IN : masterIds
        ]){
            List<CORE_Merge_Candidate__c> cands = master2Grups.get(cmc.Master_Id_gne__c) == null ? new List<CORE_Merge_Candidate__c>() : master2Grups.get(cmc.Master_Id_gne__c);
            cands.add(cmc);
            master2Grups.put(cmc.Master_Id_gne__c, cands);
            
            if(cmc.Candidate_Type_calc_gne__c == CORE_Merge_Util.CANDIDATE_TYPE_LOSER){
                losers.add(cmc.Id_gne__c);
                List<CORE_Merge_Candidate__c> candidates = loserId2candidates.get(cmc.Id_gne__c) == null ? new List<CORE_Merge_Candidate__c>() : loserId2candidates.get(cmc.Id_gne__c) ;
                candidates.add(cmc);
                loserId2candidates.put(cmc.Id_gne__c, candidates);
            }            
        }

        Map<String,Object> childRelationshipConfig = mergeEngine.getMergeObject().getPropertiesByType(CORE_Merge_Configuration.MergeProperty.RelationshipToMove);

        for(String key : childRelationshipConfig.keySet()){
            CORE_Merge_Configuration.RelationshipConfigWrapper rcw = (CORE_Merge_Configuration.RelationshipConfigWrapper)childRelationshipConfig.get(key);
            String relName = rcw.getRelationshipName();
            SObjectField fld = CORE_Merge_Configuration.getChildRelationshipMap(mergeEngine.getMergeObject().getSObjectName()).get(relName).getField();
            String fldName = String.valueOf(fld);

            String fromSObject = CORE_Merge_Configuration.getChildRelationshipMap(mergeEngine.getMergeObject().getSObjectName()).get(relName).getChildSObject().getDescribe().getName();
            Set<Id> winnerIds = mergeObjectId2winnersIds.get(mObjRec.Id) != null ? mergeObjectId2winnersIds.get(mObjRec.Id) : new Set<Id>();

            for(AggregateResult ar :Database.query(String.format(
                'SELECT count(Id), {0} FROM {1} WHERE {0} IN : losers GROUP BY {0} HAVING count(Id) > {2} LIMIT 2000', 
                new List<String> {fldName, fromSObject, String.valueOf(getLimitSize())}
            )) ){
                Id loserRecordId = String.valueOf(ar.get(fldName));
                Id winnerRecordId =  loserId2candidates.get(loserRecordId)[0].Master_Id_gne__c;
                winnerIds.add(winnerRecordId);
            }
            mergeObjectId2winnersIds.put(mObjRec.Id,winnerIds);
        } 
    }
    
    public void finish(Database.BatchableContext BC) {
        if(!objectsWithRelationsToMove.isEmpty()) objectsWithRelationsToMove.remove(mObjRec.Id);
        Id result = null;
        if(objectsWithRelationsToMove.isEmpty()){
            Map<Id, Set<Id>> finalMergeObjectId2winnersIds = removeEmptyLists();
            CORE_Merge_IntPreprocessing job = new CORE_Merge_IntPreprocessing(finalMergeObjectId2winnersIds, dataWrapper);
            result = Database.executeBatch(job, 1);            
        } else {
            CORE_Merge_LongRelatedListFinder newJob = new CORE_Merge_LongRelatedListFinder(mergeObjectId2winnersIds, objectsWithRelationsToMove, mergeObject, dataWrapper);
            result =  Database.executeBatch(newJob);
        }   

        if(result != null){
            CORE_Merge_Job__c job = dataWrapper.mergeJob.getMergeJob();
            List<String> batchIds = String.isNotBlank(job.Batch_Ids_json_gne__c) ? (List<String>)JSON.deserialize(job.Batch_Ids_json_gne__c, List<String>.class) : new List<String>() ;
            batchIds.add(result);
            job.Batch_Ids_json_gne__c = JSON.serialize(batchIds);
            update job;
        }
    }
    
    private Id getFirstId() {
        Id result = null;
        for(Id rId : objectsWithRelationsToMove){
            return rId;
        }
        return result;        
    }
    
    private Map<Id, Set<Id>> removeEmptyLists(){
        Map<Id, Set<Id>> finalMergeObjectId2winnersIds = new Map<Id, Set<Id>>();
        for(Id key :mergeObjectId2winnersIds.keySet()){
            Set<Id> winnersIds = mergeObjectId2winnersIds.get(key);
            if(!winnersIds.isEmpty()){
                finalMergeObjectId2winnersIds.put(key, winnersIds);
            }
        }
        return finalMergeObjectId2winnersIds;
    }
    
    private void initProcess() {
        if(objectsWithRelationsToMove == null) {
            objectsWithRelationsToMove = initRelationToMove();
            this.mergeObjectId2winnersIds = new Map<Id, Set<Id>>();            
        }
        
    }
    
    
    private Set<Id> initRelationToMove() {
        Set<Id> objectIds = new Set<Id>();
        CORE_Merge_Object__c objectFromInput;
        CORE_Merge_Object__c [] confMergObjects = [SELECT Id, Name, Object_Name_gne__c, Object_Type_gne__c from CORE_Merge_Object__c WHERE Id = :dataWrapper.mergeObjectId];
        if(!confMergObjects.isEmpty()){
            objectFromInput = confMergObjects[0];
        }

        String query = 'SELECT Merge_Object_gne__c FROM CORE_Merge_Configuration__c WHERE Type_gne__c = \'RelationshipToMove\' AND Active_gne__c = true';
        query = dataWrapper.mergeObjectId != null && objectFromInput.Object_Type_gne__c != 'ALL' ? query + ' AND Merge_Object_gne__c = \''+ dataWrapper.mergeObjectId +'\'' : query;
        
        for(CORE_Merge_Configuration__c cmc : Database.query(query)){
            objectIds.add(cmc.Merge_Object_gne__c);
        }
         
        return objectIds;
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
            this.dataWrapper = new InitDataWrapper(mergeObjectId, isPreviewMode, winnerIds, scopeLimit, durationLimit, this.mergeJob);
            this.getMergeJob().markAsInProgress();
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
        Integer result = 1000;
        
        if(this.initialized == true) {
            Map<String,Object> attrs = (Map<String,Object>)getMergeObject().getPropertyAttributes(CORE_Merge_Configuration.MergeProperty.PreProcessBatch);
            result = attrs!=null && attrs.containsKey(CORE_Merge_Configuration.ATTRIBUTE_SCOPE_SIZE) ? (Integer)attrs.get(CORE_Merge_Configuration.ATTRIBUTE_SCOPE_SIZE) : result;  
        }
       
        return result;
    }
    
    public virtual Integer getLimitSize() {
        Integer result = 1000;
        
        if(this.initialized == true) {
            Map<String,Object> attrs = (Map<String,Object>)getMergeObject().getPropertyAttributes(CORE_Merge_Configuration.MergeProperty.PreProcessBatch);
            result = attrs!=null && attrs.containsKey(CORE_Merge_Configuration.ATTRIBUTE_LIMIT_QUERY_SIZE) ? (Integer)attrs.get(CORE_Merge_Configuration.ATTRIBUTE_LIMIT_QUERY_SIZE) : result;  
        }
        if(dataWrapper.queryLimit == null) dataWrapper.queryLimit = result;

        return result;
    }
    
    public virtual Id executeBatch(Id mergeObjectId) {
        Id result = null;
        
        if(this.initialized!=true) {
            initBatch(mergeObjectId);
        }
            
        result = Database.executeBatch(this, getScopeSize());
        CORE_Merge_Job__c job = getMergeJob().getMergeJob();
        List<String> batchIds = String.isNotBlank(job.Batch_Ids_json_gne__c) ? (List<String>)JSON.deserialize(job.Batch_Ids_json_gne__c, List<String>.class) : new List<String>() ;
        batchIds.add(result);
        job.Batch_Ids_json_gne__c = JSON.serialize(batchIds);
        update job;
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
    
    public virtual Set<String> getWinnerIds() {
        return this.winnerIds;
    }
    
    
    public class InitDataWrapper {
        public Id mergeObjectId {get;private set;}
        public Boolean isPreviewMode {get;private set;}
        public Set<String> winnerIds {get;private set;}
        public Integer scopeLimit {get;private set;}
        public Long durationLimit {get;private set;}
        public String startedDate {get;private set;}
        public CORE_Merge_Util.MergeJobWrapper mergeJob  {get;private set;}
        public Integer queryLimit {get;private set;}
        
        public InitDataWrapper(Id mergeObjectId, Boolean isPreviewMode, Set<String> winnerIds, Integer scopeLimit, Long durationLimit, CORE_Merge_Util.MergeJobWrapper mergeJob) {
            this.mergeObjectId = mergeObjectId;
            this.isPreviewMode = isPreviewMode;
            this.winnerIds = winnerIds;
            this.scopeLimit = scopeLimit;
            this.durationLimit = durationLimit;
            this.startedDate = DateTime.now().formatGmt(CORE_Merge_Util.DEFAULT_DATETIME_FORMAT);
            this.mergeJob =mergeJob;
        }
    }
}