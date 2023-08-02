//TODO
public class CORE_Merge_IntPreprocessing implements Database.Batchable<SObject>, Database.Stateful{
    private Set<id> winnersIds;
    private CORE_Merge_Object__c mObjRec;
    //private Set<Id> objectsWithRelationsToMove;
    Map<Id, Set<Id>> mergeObjectId2winnersIds;
    //private Set<Id> masterSetIds;
    private Map<String, ResultWrapper> resultMap;
    CORE_Merge_Engine mergeEngine;
    private CORE_Merge_LongRelatedListFinder.InitDataWrapper dataWrapper;
    
    public CORE_Merge_IntPreprocessing(Map<Id, Set<Id>> mergeObjectId2winnersIds, Map<String, ResultWrapper> resultMap, CORE_Merge_LongRelatedListFinder.InitDataWrapper dataWrapper){
        this.mergeObjectId2winnersIds = mergeObjectId2winnersIds;
        this.resultMap = resultMap;
        this.dataWrapper = dataWrapper; 
    }
    
    public CORE_Merge_IntPreprocessing(Map<Id, Set<Id>> mergeObjectId2winnersIds, CORE_Merge_LongRelatedListFinder.InitDataWrapper dataWrapper) {
        this(mergeObjectId2winnersIds, null, dataWrapper);
    }
    
    public Database.QueryLocator start(Database.batchableContext BC) {
        initProcess();
        Id mergObjectId = getFirstId();
        CORE_Merge_Object__c [] confMergObject = [SELECT Id, Name, Object_Name_gne__c, Object_Type_gne__c from CORE_Merge_Object__c WHERE Id = :mergObjectId];
        mObjRec = confMergObject.isEmpty() ? null : confMergObject[0];
        mergeEngine = new CORE_Merge_Engine();
        mergeEngine.setMergeObjectRecord(mObjRec);
        Set<id> inputIds = mergeObjectId2winnersIds.get(mergObjectId);
        winnersIds = new Set<Id>();
        return Database.getQueryLocator([
            SELECT Id, External_Id_gne__c, Id_gne__c, Master_Id_gne__c, Merge_Object_gne__c, Candidate_Type_calc_gne__c
            FROM CORE_Merge_Candidate__c
            WHERE Status_gne__c IN (:CORE_Merge_Util.CANDIDATE_STATUS_LOADED)
                AND Type_gne__c IN (:CORE_Merge_Util.CANDIDATE_TYPE_MERGE)
                AND Merge_Object_gne__c = :mergObjectId
                AND Candidate_Type_calc_gne__c = 'WINNER'
            	AND Master_Id_gne__c IN : inputIds
        ]);
    }
    
    private void initProcess() {
        if(resultMap == null) {
            resultMap = new Map<String, ResultWrapper>();
        }
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
                AND Merge_Object_gne__c = :mObjRec.Id
        ]){
            List<CORE_Merge_Candidate__c> cands = master2Grups.get(cmc.Master_Id_gne__c) == null ? new List<CORE_Merge_Candidate__c>() : master2Grups.get(cmc.Master_Id_gne__c);
            cands.add(cmc);
            master2Grups.put(cmc.Master_Id_gne__c, cands);
            
            if(cmc.Candidate_Type_calc_gne__c == 'LOSER'){
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
                
            String mapKey = mObjRec.Id +'_'+ fromSObject + '_'+fldName;
            ResultWrapper wrapper = resultMap.get(mapKey) != null ? resultMap.get(mapKey) : new ResultWrapper(fromSObject, mObjRec.Id, fldName );

            for(AggregateResult ar :Database.query(String.format(
                'SELECT count(Id), {0} FROM {1} WHERE {0} IN : losers GROUP BY {0} HAVING count(Id) > {2} LIMIT 2000', 
                new List<String> {fldName, fromSObject, String.valueOf(getLimitSize())}
            )) ){
                Id loserRecordId = String.valueOf(ar.get(fldName));
                Id winnerRecordId =  loserId2candidates.get(loserRecordId)[0].Master_Id_gne__c;
                candidateIds.add(String.valueOf(ar.get(fldName)));
                wrapper.updateMap(loserRecordId, winnerRecordId);
            }

            resultMap.put(mapKey,wrapper);
        }

        if(candidateIds.isEmpty()){
            return;
        }
        
        Set<id> mastersTovalidate = new Set<Id>();
        for(Id cId :candidateIds){
            for(CORE_Merge_Candidate__c loser : loserId2candidates.get(cId)){
                mastersTovalidate.add(loser.Master_Id_gne__c);
            }
        }
        
        List<CORE_Merge_Util.MergeGroupWrapper> tempmergeGroups = new List<CORE_Merge_Util.MergeGroupWrapper>();
        for(Id masterId :mastersTovalidate){
            if(master2Grups.get(masterId) == null )continue;
            CORE_Merge_Candidate__c masterCand;
            Integer index = 0;
            for(CORE_Merge_Candidate__c cmc :master2Grups.get(masterId)){
                if(cmc.Candidate_Type_calc_gne__c == 'WINNER'){
                    masterCand = cmc;                    
                    break;
                }
                index++;
            }
            CORE_Merge_Candidate__c [] cList = master2Grups.get(masterId);
            if(index != 0){
                cList.set(index, cList.get(0));
                cList.set(0, masterCand);   
            }

            tempmergeGroups.add(new CORE_Merge_Util.MergeGroupWrapper(masterCand, cList));                     
        }        
        
        mergeEngine.initEngine();
        mergeEngine.initMerge(tempmergeGroups); 
        mergeEngine.populateSourceData();
        mergeEngine.validate();
        
        for(CORE_Merge_Util.MergeGroupWrapper gw: mergeEngine.getMergeGroups()){
            if(gw.isValid()){
                winnersIds.add(gw.getWinnerId());
            }
        }
        
        for(ResultWrapper rw :resultMap.values() ){            
            for(Id validatedWinnerId : winnersIds){
                rw.updateValidatedMap(validatedWinnerId);
            }
        }        
    }
    
    public virtual void finish(Database.BatchableContext BC) {
        if(!mergeObjectId2winnersIds.isEmpty()) mergeObjectId2winnersIds.remove(mObjRec.Id);
        Id result = null;
        if(mergeObjectId2winnersIds.isEmpty()){
            ResultWrapper[] finalMap = removeEmptyLists();
            if(finalMap.isEmpty()){
                CORE_Merge_Engine_Batch mergeBatch = new CORE_Merge_Engine_Batch();
            	mergeBatch.initBatch(dataWrapper.mergeObjectId, dataWrapper.isPreviewMode, dataWrapper.winnerIds, dataWrapper.scopeLimit, dataWrapper.durationLimit, dataWrapper.mergeJob);
            	mergeBatch.executeBatch(dataWrapper.mergeObjectId);
            } else {
                CORE_Merge_Preprocessing job = new CORE_Merge_Preprocessing(finalMap, dataWrapper);
                result = Database.executeBatch(job, 1000);
            }
        } else {
             CORE_Merge_IntPreprocessing newJob = new CORE_Merge_IntPreprocessing(mergeObjectId2winnersIds, resultMap, dataWrapper);
             result = Database.executeBatch(newJob, 1);
        }      
        if(result != null) {
            CORE_Merge_Job__c job = dataWrapper.mergeJob.getMergeJob();
            List<String> batchIds = String.isNotBlank(job.Batch_Ids_json_gne__c) ? (List<String>)JSON.deserialize(job.Batch_Ids_json_gne__c, List<String>.class) : new List<String>() ;
            batchIds.add(result);
            job.Batch_Ids_json_gne__c = JSON.serialize(batchIds);
            update job;
        }
    } 
    
    private ResultWrapper[] removeEmptyLists() {
        ResultWrapper[] result = new ResultWrapper[]{};
        for(ResultWrapper rw  :resultMap.values()){
            if(!rw.validatedCurrentId2reparentTo.isEmpty()){
                result.add(rw);
            }     
        }    
        return result;        
    }
    
    private Set<Id> initRelationToMove() {
        Set<Id> objectIds = new Set<Id>();
        for(CORE_Merge_Configuration__c cmc :[
            SELECT Merge_Object_gne__c FROM CORE_Merge_Configuration__c WHERE Type_gne__c = 'RelationshipToMove' AND Active_gne__c = true
        ]){
            objectIds.add(cmc.Merge_Object_gne__c);
        }
        return objectIds;
    }
    
    private Id getFirstId() {
        Id result = null;
        for(Id rId : mergeObjectId2winnersIds.keySet()){
            return rId;
        }
        return result;        
    }
    
    public Integer getLimitSize() {
        Integer result = 1000;
        if(dataWrapper.queryLimit != null) result = dataWrapper.queryLimit;
        return result;
    }

    public class ResultWrapper {
        public String objectApiName {get;set;}
        public Id coreMergeObjectId {get;set;}
        public String relationFieldApiName {get;set;}        
        public Map<Id,Map<Id, Id>> winner2MapCurrentId2reparentTo {get;set;}
        public Map<Id, Id> validatedCurrentId2reparentTo {get;set;}
        
        public ResultWrapper(String objectApiName, Id coreMergeObjectId, String relationFieldApiName){
            this.winner2MapCurrentId2reparentTo = new Map<Id,Map<Id, Id>>();
            validatedCurrentId2reparentTo = new Map<Id, Id> ();
            this.objectApiName = objectApiName;
            this.coreMergeObjectId = coreMergeObjectId;
            this.relationFieldApiName = relationFieldApiName;
        }
        
        public void updateMap(Id key, Id value){
            Map<Id, Id> currentId2reparentTo = winner2MapCurrentId2reparentTo.get(value) != null ? winner2MapCurrentId2reparentTo.get(value) : new Map<Id, Id>();
            currentId2reparentTo.put(key, value);
            winner2MapCurrentId2reparentTo.put(value, currentId2reparentTo);
        }
        
        public void updateValidatedMap(Id validatedWinnerId){
            if(winner2MapCurrentId2reparentTo.containsKey(validatedWinnerId)){
                validatedCurrentId2reparentTo.putAll(winner2MapCurrentId2reparentTo.get(validatedWinnerId));                
            }
        }
    }
}