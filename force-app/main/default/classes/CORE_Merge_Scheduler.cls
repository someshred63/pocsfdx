public without sharing class CORE_Merge_Scheduler implements Schedulable, CORE_Merge_Interface.SchedulerInterface {
    public CORE_Merge_Scheduler() {}
    
    public void execute(SchedulableContext ctx)  {
        Id mergeObjectId = getMergeObjectId();
        DateTime dtNow = DateTime.now();
        
        if(mergeObjectId!=null && !CORE_Merge_Util.getCurrentJob().isInProgress()) {
            CORE_Merge_Configuration.readConfiguration(mergeObjectId);
            CORE_Merge_Util.MergeObjectWrapper mainMergeObject = new CORE_Merge_Util.MergeObjectWrapper(CORE_Merge_Configuration.getMergeObject(mergeObjectId));
            List<CORE_Merge_Util.MergeObjectWrapper> mergeObjects = new List<CORE_Merge_Util.MergeObjectWrapper>{mainMergeObject};
            mergeObjects.addAll(mainMergeObject.getChildMergeObjects());
            Map<Id,List<CORE_Merge_Configuration.SchedulerConfig>> matchingConfigs = new Map<Id,List<CORE_Merge_Configuration.SchedulerConfig>>();
            Set<Id> matchingObjIds = new Set<Id>();
            Set<String> matchingJobTypes = new Set<String>();
            
            for(CORE_Merge_Util.MergeObjectWrapper mergeObject : mergeObjects) {
                try {
	                List<CORE_Merge_Configuration.SchedulerConfig> schedulerConfigs = (List<CORE_Merge_Configuration.SchedulerConfig>)mergeObject.getPropertyValue(CORE_Merge_Configuration.MergeProperty.SchedulerConfig);
	                
	                if(schedulerConfigs!=null) {
	                    for(CORE_Merge_Configuration.SchedulerConfig sConfig : schedulerConfigs) {
	                        if(sConfig.matches(dtNow)) {
	                            Id mObjId = mergeObject.getMergeObject().Id;
	                            
	                            if(!matchingConfigs.containsKey(mObjId)) {
	                                matchingConfigs.put(mObjId, new List<CORE_Merge_Configuration.SchedulerConfig>());
	                            }
	                            
	                            matchingConfigs.get(mObjId).add(sConfig);
	                            matchingObjIds.add(mObjId);
	                            matchingJobTypes.add(sConfig.getJobType());
	                        }
	                    }
	                }
	            } catch(Exception ex) {
                    CORE_Merge_Util.handleStandAloneException(ex, mergeObjectId);
                }
            }
            
            if(!matchingConfigs.isEmpty()) {
                List<CORE_Merge_Job__c> jobs = [
                    SELECT CreatedDate, Merge_Object_gne__c, Type_gne__c
                    FROM CORE_Merge_Job__c
                    WHERE Type_gne__c IN :matchingJobTypes
                        AND Merge_Object_gne__c IN :matchingObjIds
                        AND CreatedDate = TODAY
                    ORDER BY CreatedDate ASC
                ];
                
                Set<String> existingJobKeys = new Set<String>();
                List<CORE_Merge_Util.MergeObjectWrapper> sortedMergeObjects = new List<CORE_Merge_Util.MergeObjectWrapper>();
                List<CORE_Merge_Configuration.SchedulerConfig> sortedSConfigs = new List<CORE_Merge_Configuration.SchedulerConfig>();
                Map<Id,CORE_Merge_Util.MergeObjectWrapper> mergeObjectsMap = new Map<Id,CORE_Merge_Util.MergeObjectWrapper>();
                
                for(CORE_Merge_Job__c job : jobs) {
                    existingJobKeys.add((job.Merge_Object_gne__c + '_' + job.Type_gne__c).toUpperCase()); 
                }
                
                
                for(CORE_Merge_Util.MergeObjectWrapper mergeObject : mergeObjects) {
                    Id mObjId = mergeObject.getMergeObject().Id;
                    mergeObjectsMap.put(mObjId, mergeObject);
                    
                    if(matchingConfigs.containsKey(mObjId)) {
                        for(CORE_Merge_Configuration.SchedulerConfig sConfig : matchingConfigs.get(mObjId)) {
                            String key = (mObjId + '_' + sConfig.getJobType()).toUpperCase();
                            
                            if(!existingJobKeys.contains(key)) {
                                sortedMergeObjects.add(mergeObject);
                                sortedSConfigs.add(sConfig);
                            }
                        }
                    }
                }
                
                for(CORE_Merge_Job__c job : jobs) {
                    if(matchingConfigs.containsKey(job.Merge_Object_gne__c)) {
                        for(CORE_Merge_Configuration.SchedulerConfig sConfig : matchingConfigs.get(job.Merge_Object_gne__c)) {
                            if(sConfig.getJobType()==job.Type_gne__c) {
                                sortedMergeObjects.add(mergeObjectsMap.get(job.Merge_Object_gne__c));
                                sortedSConfigs.add(sConfig);
                            }
                        }
                    }
                }
                
                Integer idx=0;
                for(CORE_Merge_Util.MergeObjectWrapper mergeObject : sortedMergeObjects) {
                    CORE_Merge_Configuration.SchedulerConfig sConfig = sortedSConfigs[idx++];
                    Boolean somethingScheduled = false;
                    
                    try {
                        somethingScheduled = executeBatch(mergeObject, sConfig);
                    } catch(Exception ex) {
                       CORE_Merge_Util.handleStandAloneException(ex, mergeObject.getMergeObject().Id); 
                    }
                    
                    if(somethingScheduled) {
                        break;
                    }
                }
            }
        }
    }
    
    private Id getMergeObjectId() {
        Id mergeObjectId = null;
        Integer regionCode = 1;
        
        try {
            Id userId = UserInfo.getUserId();
            
            for(User u : Database.query('SELECT Region_Code_gne__c FROM User WHERE Id = :userId')) {
                regionCode = Integer.valueOf(u.get('Region_Code_gne__c'));
            }
        } catch(Exception ex) {}
            
        for(CORE_Merge_Object__c mObj : [SELECT Id FROM CORE_Merge_Object__c WHERE Region_Code_gne__c = :regionCode AND Parent_Merge_Object_gne__c = null LIMIT 1]) {
            mergeObjectId = mObj.Id;
        }
        
        return mergeObjectId;
    }
    
    private Boolean executeBatch(CORE_Merge_Util.MergeObjectWrapper mergeObject, CORE_Merge_Configuration.SchedulerConfig sConfig) {
        Boolean somethingScheduled = false;
        CORE_Merge_Interface.MergeBatchInterface mergeBatch = null;
        
        if(sConfig.getJobType()==CORE_Merge_Util.MERGE_JOB_TYPE_POPULATE_CANDIDATES) {
            mergeBatch = mergeObject.getPopulateCandidatesBatch();
        } else if(sConfig.getJobType()==CORE_Merge_Util.MERGE_JOB_TYPE_MERGE) {
            CORE_Merge_Interface.MergeEngineBatchInterface eBatch = mergeObject.getPreProcess();
	        eBatch.initBatch(mergeObject.getMergeObject().Id, false, null, sConfig.getScopeLimit(), sConfig.getDurationLimit());
	        mergeBatch = eBatch;
		}
        
	    if(mergeBatch!=null) {
            mergeBatch.setSchedulerArguments(sConfig.getJobArguments());
            mergeBatch.executeBatch(mergeObject.getMergeObject().Id);
            somethingScheduled = true;
        }
        
        return somethingScheduled;
    }
}