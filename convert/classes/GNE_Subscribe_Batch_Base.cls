public with sharing abstract class GNE_Subscribe_Batch_Base {
    public enum MetricTypeName {INSERT_UPDATE, ERROR, UNALIGN, REC_UPDATE}
    public static final String STATUS_LOADED = 'Loaded';
    public static final String STATUS_ERROR_PROCESSING = 'Error Processing';
    public static final String STATUS_PROCESSED = 'Processed';
    public static final String COMMENT_FIELD_API_NAME = 'Comment_gne__c';
    public static final String STATUS_FIELD_API_NAME = 'Status_gne__c';
    public static final String COMMENT_PREVIEW_MODE_PREFIX = 'PREVIEW';
    public static final String COMMENT_PREVIEW_MODE_DELIMETER = '||';
    
    public enum DmlType {TARGET_INSERT, TARGET_UPSERT, TARGET_UPDATE, TARGET_DELETE, STAGING_UPDATE}
    
    protected Boolean previewMode = false;
    protected Map<String,SObject> targetCache;
    protected Map<String,SObject> stagingCache;
    protected transient Savepoint currentSavePoint;
    
    protected abstract String getBatchName();
    
    protected virtual void initCache(List<SObject> stgObjs) {
        stagingCache = new Map<String,SObject>();
        targetCache = new Map<String,SObject>();
        
        for(SObject stgObj : stgObjs) {
            cacheStagingObject(stgObj);
        }
    }
    
    protected virtual void cacheStagingObject(SObject stg) {
        String key = getKeyFromStagingObject(stg);
        stagingCache.put(key,stg);
    }
    
    protected virtual void cacheTargetObject(SObject target) {
        String key = getKeyFromTargetObject(target);
        targetCache.put(key,target);
    }
    
    public virtual SObject getStagingForTargetObject(SObject target) {
        return stagingCache.get(getKeyFromTargetObject(target));
    }
    
    public virtual SObject getTargetForStagingObject(SObject staging) {
        return targetCache.get(getKeyFromStagingObject(staging));
    }
    
    protected abstract String getKeyFromTargetObject(SObject target);
    
    protected abstract String getKeyFromStagingObject(SObject staging);
    
    protected virtual void executeDml(List<SObject> objs, DmlType dType) {
        if(!objs.isEmpty()) {
            if(dType == DmlType.STAGING_UPDATE) {
                executeDmlForStagingObjects(objs);
            } else {
                Savepoint sp = null;
                
                if(previewMode && currentSavePoint == null) {
                    currentSavePoint = sp = Database.setSavepoint();
                }
                
                try {
                    executeDmlForTargetObjects(objs, dType);
                } finally {
                    if(sp != null) {
                        Database.rollback(sp);
                        currentSavePoint = null;
                    }
                }
            }
        }
    }
    
    protected virtual void executeDmlForStagingObjects(List<SObject> objs) {
    	if(previewMode) {
            for(SObject stgObj : objs) {
                markStgObjectInPreviewMode(stgObj);
            }
        }
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.allowFieldTruncation = true;
        dml.optAllOrNone = false;
        Database.SaveResult[] results = Database.update(objs, dml);
        
        Integer idx=0;
        for(Database.SaveResult result : results) {

            SObject stgObj = objs[idx++];
            if(result.isSuccess()) {
                processStagingDmlSuccess(stgObj);
            } else {
                processStagingDmlErrors(result.getErrors(), stgObj);
            }
        }
    }
    
    protected virtual void processStagingDmlSuccess(SObject stgObj) {
        // By default do nothing, but it can be overriden.
    }
    
    protected virtual void processStagingDmlErrors(Database.Error[] errors, SObject stgObj) {
        // By default do nothing, but it can be overriden.
    }
    
    protected virtual void executeDmlForTargetObjects(List<SObject> objs, DmlType dType) {
        Database.SaveResult[]   sResults = null;
        Database.UpsertResult[] uResults = null;
        Database.DeleteResult[] dResults = null;
        
        if(dType == DmlType.TARGET_INSERT) {
            sResults = Database.insert(objs, false);
        } else if(dType == DmlType.TARGET_UPSERT) {
            uResults = Database.upsert(objs, false);
        } else if(dType == DmlType.TARGET_UPDATE) {
            sResults = Database.update(objs, false);
        } else if(dType == DmlType.TARGET_DELETE) {
            dResults = Database.delete(objs, false);
        }
        
        Integer idx = 0;
        if(sResults!=null) {
            for(Database.SaveResult result : sResults) {
                SObject targetObj = objs.get(idx++);
                SObject stgObj = getStagingForTargetObject(targetObj);
                
                if(result.isSuccess()) {
                    processDmlSuccess(targetObj, stgObj);
                } else {
                    processDmlErrors(result.getErrors(), targetObj, stgObj);
                }
            }
        } else if(uResults!=null) {
            for(Database.UpsertResult result : uResults) {
                SObject targetObj = objs.get(idx++);
                SObject stgObj = getStagingForTargetObject(targetObj);
                
                if(result.isSuccess()) {
                    processDmlSuccess(targetObj, stgObj);
                } else {
                    processDmlErrors(result.getErrors(), targetObj, stgObj);
                }
            }
        } else if(dResults!=null) {
            for(Database.DeleteResult result : dResults) {
                SObject targetObj = objs.get(idx++);
                SObject stgObj = getStagingForTargetObject(targetObj);
                
                if(result.isSuccess()) {
                    processDmlSuccess(targetObj, stgObj);
                } else {
                    processDmlErrors(result.getErrors(), targetObj, stgObj);
                }
            }
        }
    }
    
    protected virtual void processDmlSuccess(SObject targetObj, SObject stgObj) {
        // By default do nothing, but it can be overriden.
    }
    
    protected virtual void processDmlErrors(Database.Error[] errors, SObject targetObj, SObject stgObj) {
        List<String> errorMsgs = new List<String>();
        
        for(Database.Error err : errors) {
            errorMsgs.add(err.getMessage());
        }
        
        markStagingObjectWithError(stgObj, String.join(errorMsgs,'|'));
    }
    
    protected virtual void markStgObjectInPreviewMode(SObject stgObj) {
        if(previewMode) {
            String comment = (String)stgObj.get(COMMENT_FIELD_API_NAME);
            String status = (String)stgObj.get(STATUS_FIELD_API_NAME);
            String previewComment = '[' + COMMENT_PREVIEW_MODE_PREFIX + ' Status:' + status + ']' + 
            (String.isBlank(comment) ? '' : COMMENT_PREVIEW_MODE_DELIMETER + comment);
            
            stgObj.put(COMMENT_FIELD_API_NAME, previewComment);
            stgObj.put(STATUS_FIELD_API_NAME, STATUS_LOADED);
        }
    }
    
    protected virtual void markStagingObjectWithError(SObject stgObj, String errorMsg) {
        stgObj.put(STATUS_FIELD_API_NAME, STATUS_ERROR_PROCESSING);
        markStagingObjectWithComment(stgObj, errorMsg);
    }
    
    protected virtual Boolean isMarkedAsError(SObject stgObj) {
        return stgObj.get(STATUS_FIELD_API_NAME) == STATUS_ERROR_PROCESSING;
    }
    
    protected virtual Boolean isMarkedAsProcessed(SObject stgObj) {
        return stgObj.get(STATUS_FIELD_API_NAME) == STATUS_PROCESSED;
    }
    
    protected virtual void markStagingObjectWithComment(SObject stgObj, String msg) {
        String prevComment = (String)stgObj.get(COMMENT_FIELD_API_NAME);
        
        if(String.isNotBlank(prevComment)) {
            stgObj.put(COMMENT_FIELD_API_NAME, prevComment + ', ' + msg);
        } else {
            stgObj.put(COMMENT_FIELD_API_NAME, msg);
        }
    }
    
    protected virtual void markStagingObjectAsProcessed(SObject stgObj) {
        markStagingObjectAsProcessed(stgObj, true);
    }
    
    protected virtual void markStagingObjectAsProcessed(SObject stgObj, Boolean clearComments) {
        stgObj.put(STATUS_FIELD_API_NAME, STATUS_PROCESSED);
        
        if (clearComments == true) {
            stgObj.put(COMMENT_FIELD_API_NAME, '');
        }
    }
    
    protected virtual void clearStagingObjectComment(SObject stgObj) {
        stgObj.put(COMMENT_FIELD_API_NAME, '');
    }
    
    protected virtual void doFinish(Database.BatchableContext BC) {
        System.debug('Batch ' + getBatchName() + ' is completed!');
    }
    
    protected virtual void sendSummaryMail(String jobName, CORE_Subscribe_Metrics metrics) {
        sendSummaryMail(jobName, printMetrics(metrics), 'SubscribeNotfyEmail', false);
    }
    
    protected virtual void sendSummaryMail(String jobName, String metricsText) {
        sendSummaryMail(jobName, metricsText, 'SubscribeNotfyEmail', false);
    }
    protected virtual void sendSummaryMail(String jobName, String metricsText, Boolean isHtml) {
        sendSummaryMail(jobName, metricsText, 'SubscribeNotfyEmail', isHtml);
    }
    
    protected virtual void sendSummaryMail(String jobName, CORE_Subscribe_Metrics metrics, String configName) {
        sendSummaryMail(jobName, printMetrics(metrics), configName, false);
    }
    
    protected virtual void sendSummaryMail(String jobName, String metricsText, String configName) {
        sendSummaryMail(jobName, metricsText, configName, false);
    }
    
    protected virtual void sendSummaryMail(String jobName, String metricsText, String configName, Boolean isHtml) {
        //Create a new single email message object
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        //Address
        Map<String, GNE_Foun_Misc_Config_Items_gne__c> configItemsMap = GNE_Foun_Misc_Config_Items_gne__c.getAll();
        if (configItemsMap.containsKey(configName)) {
            String addr = configItemsMap.get(configName).Configuration_Value_gne__c;
            String[] addrs = (addr != null ? addr : UserInfo.getUserEmail()).split(';');
            email.setToAddresses(addrs);
            // Subject
            email.setSubject(jobName + ' finished');
            if(isHtml){
                email.setHtmlBody(String.format('{0} finished: {1}<BR>Metrics:<BR>{2}', new String[]{
                    jobName,
                    DateTime.now().format('M/d/yyyy h:mm a (zzzz)'),
                    metricsText
                })); 
            } else {
            email.setPlainTextBody(String.format('{0} finished: {1}\nMetrics:\n{2}', new String[]{
                jobName,
                DateTime.now().format('M/d/yyyy h:mm a (zzzz)'),
                metricsText
            }));
            }
            
            //Send
            List<Messaging.Sendemailresult> error = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}, false);
            if (!error[0].isSuccess()){
                System.debug('Couldn\'t send metrics summary email!');
            }
        }
    }
    
    protected virtual String printMetrics(CORE_Subscribe_Metrics metrics) {
        List<String> lines = new List<String>();
        
        lines.add(String.format('{0} (Upserted/Deleted/Errors): {1}/{2}/{3}', new String[]{
            metrics.targetObject,
            String.valueOf(metrics.upsertCount),
            String.valueOf(metrics.deleteCount),
            String.valueOf(metrics.errorsCount)
        }));
        
        if (metrics.relatedMetrics != null) {
            for (CORE_Subscribe_Metrics m : metrics.relatedMetrics) {
                lines.add(printMetrics(m));
            }
        }
        
        return String.join(lines,'\n');
    }
    
    protected virtual void mergeSubscribeMetrics(CORE_Subscribe_Metrics metrics, CORE_Subscribe_Metrics mainMetrics) {
        CORE_Subscribe_Metrics rm;
        for(CORE_Subscribe_Metrics m : mainMetrics.relatedMetrics){
            if(m.targetObject == metrics.targetObject){
                rm = m;
                break;
            }
        }
        if(rm != null){
            rm.errorsCount += metrics.errorsCount;
            rm.insertCount+= metrics.insertCount; 
            rm.updateCount+= metrics.updateCount;
            rm.upsertCount+= metrics.upsertCount;
            rm.deleteCount+= metrics.deleteCount;
        }else{
            mainMetrics.relatedMetrics.add(metrics);
        }
    }
    
    protected virtual void updateSubscribeMetrics(SObject obj, MetricTypeName metricType, CORE_Subscribe_Metrics subscribeMetrics) {
        CORE_Subscribe_Metrics metricTemp = new CORE_Subscribe_Metrics();
        metricTemp.mType = CORE_Subscribe_Metrics.MetricType.DETAIL;
        
        metricTemp.targetObject = obj instanceof Staging_Alignment_gne__c ? 'STAGING_ALIGNMENT' :
                                obj instanceof TSF_vod__c ? 'TSF_vod__c' : obj instanceof ObjectTerritory2Association ? 'ObjectTerritory2Association' : 'UNDEFINE';
        
        if (metricType == MetricTypeName.ERROR) {
            metricTemp.errorsCount++;
        } else if (metricType == MetricTypeName.UNALIGN) {
            metricTemp.deleteCount++;
        } else if (metricType == MetricTypeName.REC_UPDATE) {
            metricTemp.updateCount++;
        } else {
            metricTemp.upsertCount++;
            metricTemp.upsertedRecords.add(obj);
        }
        mergeSubscribeMetrics(metricTemp, subscribeMetrics);
    }   
}