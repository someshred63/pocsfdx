public class CORE_Merge_Util {
    public static final String MERGE_JOB_TYPE_MERGE = 'Merge';
    public static final String MERGE_JOB_TYPE_MERGE_PERVIEW_MODE = 'MergePreviewMode';
    public static final String MERGE_JOB_TYPE_POPULATE_CANDIDATES = 'PopulateCandidates';
    public static final String MERGE_JOB_TYPE_MERGE_SINGLE_MODE = 'MergeSingleMode';
    public static final String MERGE_JOB_TYPE_MERGE_PREVIEW_SINGLE_MODE = 'MergePreviewSingleMode';
    public static final String MERGE_JOB_TYPE_UNMERGE = 'Unmerge';
    public static final String MERGE_JOB_TYPE_UNMERGE_PERVIEW_MODE = 'UnmergePreviewMode';
    public static final String MERGE_JOB_TYPE_UNMERGE_SINGLE_MODE = 'UnmergeSingleMode';
    public static final String MERGE_JOB_TYPE_UNMERGE_PREVIEW_SINGLE_MODE = 'UnmergePreviewSingleMode';
    
    public static final String ERROR_MESSAGE_CANNOT_DELETE_MERGE_RECORD = 'You cannot delete {0} record. Please contact System Administrator. This operation can be done only in Admin Mode.';
    public static final String ERROR_MESSAGE_CANNOT_CHANGE_STATUS = 'You cannot change {0} ({1}) status. It is already set to {2} and cannot be changed.';
    public static final String ERROR_MESSAGE_MERGE_OBJECT_CANNOT_BE_FOUND = 'Merge Object for given candidate could not be found. Candidate with given ID is not exist or there is no matching Merge Object. Please contact System Administrator for more details.';
    public static final String ERROR_MESSAGE_SOURCE_RECORD_IS_MISSING = 'Source Record {0} is missing';
    public static final String ERROR_MESSAGE_SOURCE_WINNER_RECORD_IS_MISSING = 'Source Record for Winner is missing';
    public static final String ERROR_MESSAGE_MISSING_WINNER_RECORD = 'Missing Winner Record';
    public static final String ERROR_MESSAGE_MISSING_LOSER_RECORD = 'Missing Loser Record';
    public static final String ERROR_MESSAGE_DUPLICATED_WINNER_RECORD = 'Duplicated Winner Record, only one is allowed';
    public static final String ERROR_MESSAGE_UPSERT_BLOCKED = 'Could not find existing {0} for given {1}: {2}';
    public static final String ERROR_EXPECTED_TOO_MANY_DML = 'Expected Too Many DML during update: ';
    
    public static final String ERROR_MESSAGE_FIELD_CONFLICT = 'Field Conflict {2} between {0} and {1}';
    public static final String ERROR_MESSAGE_RELATIONSHIP_CONFLICT = 'Relationship Conflict {1} on {0}';
    public static final String ERROR_MESSAGE_ARCHIVE_OWNER_DOES_NOT_EXIST = 'Owner does not exist or is not active';
    public static final String ERROR_MESSAGE_ARCHIVE_RECORD_TYPE_DOES_NOT_EXIST = 'Record Type does not exist or is not active';
    public static final String ERROR_MESSAGE_EXCLUDE_MATCHING_RECORD = 'Exclude matching record {0}, matching criteria: {1}';
    
    public static final String INFO_MESSAGE_BATCH_SCOPE_TRUNCATED = 'NOTE: Merge scope was truncated. There are still records to process and should be handled next time.';
    
    public static final String RUNTIME_EXCEPTION_CODE = 'RUNTIME_EXCEPTION';
    public static final String DEFAULT_MERGE_CANDIDATE_EXCEPTION_CODE = 'Merge Exception';
    public static final String DEFAULT_DATETIME_FORMAT = 'yyyy-MM-dd HH:mm:ss';
    
    public static final String CANDIDATE_SOURCE_AUTO_POPULATE = 'Auto-Populate';
    public static final String CANDIDATE_STATUS_LOADED = 'Loaded';
    public static final String CANDIDATE_STATUS_PROCESSED = 'Processed';
    public static final String CANDIDATE_STATUS_ERROR_PROCESSING = 'Error Processing';
    public static final String CANDIDATE_TYPE_MERGE = 'Merge';
    public static final String CANDIDATE_TYPE_UNMERGE = 'Unmerge';
    
    public static final String CANDIDATE_TYPE_WINNER = 'WINNER';
    public static final String CANDIDATE_TYPE_LOSER = 'LOSER';
    
    public static final String JOB_STATUS_NEW = 'New';
    public static final String JOB_STATUS_IN_PROGRESS = 'In Progress';
    public static final String JOB_STATUS_COMPLETED = 'Completed';
    
    private static final Map<String,String> HTML_REPORT_CSS_MAP = new Map<String,String>{
        'header' => 'margin-left:3px;',
        'report-table' => 'border:1px solid black;border-collapse:collapse;text-align:center;',
        'cell' => 'border:1px solid black;border-collapse:collapse;text-align:center;',
        'text-cell' => 'border:1px solid black;border-collapse:collapse;text-align:left;',
        'numeric-cell' => 'border:1px solid black;border-collapse:collapse;text-align:right;',
        'alert-row'=> 'background:red !important;',
        'object-type-cell' => 'font-weight:bold;',
        'auto-populated-cell' => 'background:#FAFAFA;',
        'processed-groups-cell' => 'background:#F0F0F0;',
        'processed-candidates-cell' => 'background:#FAFAFA;',//'background:#E6E6E6;',
        'errors-cell' => 'background:#F0F0F0;'//'background:#DCDCDC;'
    };
    
    private static Boolean isMergeProcessRunning;
    private static Map<SObjectType,Boolean> inTriggerMap;
    private static Map<SObjectType,Boolean> forceTriggerMap;
    private static Map<String,Integer> fieldLengthCache;
    
    public static void setMergeProcessRunning(Boolean isRunning) {
        isMergeProcessRunning = isRunning;
    }
    
    public static Boolean isMergeProcessRunning() {
        return isMergeProcessRunning==true;
    }
    
    public static Boolean isTriggerDisabled() {
        return isTriggerDisabled(null);
    }
    
    public static Boolean isTriggerDisabled(SObjectType sType) {
        return isForceTrigger(sType)!=true && (inTrigger(sType) || isAdminMode());
    }
    
    public static void setInTrigger(SObjectType sType, Boolean inOrOut) {
        if(inTriggerMap==null) {
            inTriggerMap = new Map<SObjectType,Boolean>();
        }
        
        inTriggerMap.put(sType, inOrOut);
    }
    
    public static Boolean inTrigger(SObjectType sType) {
        return inTriggerMap!=null && sType!=null && inTriggerMap.get(sType)==true;
    }
    
    public static void setForceTrigger(SObjectType sType, Boolean forceOrNot) {
        if(forceTriggerMap==null) {
            forceTriggerMap = new Map<SObjectType,Boolean>();
        }
        
        forceTriggerMap.put(sType, forceOrNot);
    }
    
    public static Boolean isForceTrigger(SObjectType sType) {
        return forceTriggerMap!=null && sType!=null && forceTriggerMap.get(sType)==true;
    }
    
    public static Boolean isAdminMode() {
        CORE_Merge_Interface.AdminModeManagerInterface adminModeManager = CORE_Merge_Configuration.getAdminModeManager();
        return adminModeManager!=null && adminModeManager.isAdminMode()==true;
    }
    
    public static Boolean switchAdminMode(Boolean turnOnOrOff) {
        Boolean prevAdminMode = false;
        CORE_Merge_Interface.AdminModeManagerInterface adminModeManager = CORE_Merge_Configuration.getAdminModeManager();
        
        if(adminModeManager!=null) {
            prevAdminMode = adminModeManager.switchAdminMode(turnOnOrOff);
        }
        
        return prevAdminMode==true;
    }
    
    public static List<SObject> setExternalId(List<SObject> triggerNew) {
        return setExternalId(triggerNew, String.valueOf(CORE_Merge_Candidate__c.External_Id_gne__c), String.valueOf(CORE_Merge_Candidate__c.External_Id_calc_gne__c));    
    }
    
    public static List<SObject> setExternalId(List<SObject> triggerNew, String extIdFieldName, String extIdFormulaFieldName) {
        List<SObject> changedRecs = new List<SObject>();
        
        for(SObject rec : triggerNew) {
            String oldValue = (String)rec.get(extIdFieldName);
            rec.put(extIdFieldName, rec.get(extIdFormulaFieldName));
            String newValue = (String)rec.get(extIdFieldName);
            
            if(!(String.isNotBlank(oldValue) ? oldValue : '').equals(String.isNotBlank(newValue) ? newValue : '')) {
                changedRecs.add(rec);
            }
        }
        
        return changedRecs;
    }
    
    public static void setMergeObject(List<CORE_Merge_Candidate__c> triggerNew) {
        Map<Id,List<CORE_Merge_Candidate__c>> masterIdToMergeCandidateMap = new Map<Id,List<CORE_Merge_Candidate__c>>();
        Map<String,Set<Id>> masterTypeToIds = new Map<String,Set<Id>>();
        
        for(CORE_Merge_Candidate__c recNew : triggerNew) {
            Id moid = recNew.Merge_Object_gne__c;
            String masterIdAsString = recNew.Master_Id_gne__c;
            
            if(moid==null && masterIdAsString!=null && masterIdAsString instanceof Id) {
                Id masterId = Id.valueOf(masterIdAsString);
                String sObjectTypeName = masterId.getSObjectType().getDescribe().getName().toUpperCase();
                
                if(!masterIdToMergeCandidateMap.containsKey(masterId)) {
                    masterIdToMergeCandidateMap.put(masterId, new List<SObject>());
                }
                
                masterIdToMergeCandidateMap.get(masterId).add(recNew);
                
                if(!masterTypeToIds.containsKey(sObjectTypeName)) {
                    masterTypeToIds.put(sObjectTypeName, new Set<Id>());
                }
                
                masterTypeToIds.get(sObjectTypeName).add(masterId);
            }
        }
        
        if(!masterTypeToIds.isEmpty()) {
            CORE_Merge_Util.intSetMergeObject(masterTypeToIds, masterIdToMergeCandidateMap);
        }
    }
    
    private static void intSetMergeObject(Map<String,Set<Id>> masterTypeToIds, Map<Id,List<CORE_Merge_Candidate__c>> masterIdToMergeCandidateMap) { 
        List<CORE_Merge_Object__c> mObjs = [
            SELECT Id, External_Id_gne__c, Object_Type_gne__c,
                (SELECT Value_json_gne__c FROM Merge_Configurations_gne__r WHERE Active_gne__c = true AND Key_gne__c = :CORE_Merge_Configuration.MergeProperty.MatchingRecord.name() LIMIT 1)
            FROM CORE_Merge_Object__c
            WHERE Object_Type_gne__c IN :masterTypeToIds.keySet()
            ORDER BY Order_gne__c
        ];
        
        Set<Id> alreadyMatchedMasterIds = new Set<Id>();
        
        for(CORE_Merge_Object__c mObj : mObjs) {
            String sObjecTypeName = mObj.Object_Type_gne__c;
            SObject matchingRecord = null;
            Set<String> fieldNames = null;
            
            for(CORE_Merge_Configuration__c mConfig : mObj.Merge_Configurations_gne__r) {
                if(String.isNotBlank(mConfig.Value_json_gne__c)) {
                    matchingRecord = (SObject)JSON.deserialize(mConfig.Value_json_gne__c, Type.forName(sObjecTypeName));
                    fieldNames = new Set<String>((((Map<String,Object>)JSON.deserializeUntyped(mConfig.Value_json_gne__c)).keySet()));
                }
            }
            
            Set<Id> masterIds = masterTypeToIds.get(sObjecTypeName.toUpperCase());
            masterIds.removeAll(alreadyMatchedMasterIds);
            
            if(matchingRecord!=null && fieldNames!=null && !fieldNames.isEmpty() && !masterIds.isEmpty()) {
                fieldNames.add('Id');
                List<SObject> masterRecs = Database.query(String.format('SELECT {0} FROM {1} WHERE Id IN :masterIds', new String[]{String.join(new List<String>(fieldNames), ','), sObjecTypeName}));
                fieldNames.remove('Id');
                
                for(SObject masterRec : masterRecs) {
                    Boolean isMatching = true;
                    
                    for(String fieldName : fieldNames) {
                        if(masterRec.get(fieldName)!=matchingRecord.get(fieldName)) {
                            isMatching = false;
                        }
                    }
                    
                    if(isMatching) {
                        alreadyMatchedMasterIds.add(masterRec.Id);
                        masterIds.remove(masterRec.Id);
                        
                        for(CORE_Merge_Candidate__c recNew : masterIdToMergeCandidateMap.get(masterRec.Id)) {
                            recNew.Merge_Object_gne__c = mObj.Id;
                        }
                    } 
                }
            }
            
            for(Id masterId : masterIds) {
                for(CORE_Merge_Candidate__c recNew : masterIdToMergeCandidateMap.get(masterId)) {
                    if(recNew.Merge_Object_gne__c==null) {
                        recNew.Merge_Object_gne__c = mObj.Id;
                    }
                }
            }
        }
    }
    
    public static void onMergeCandidatesUpsert(List<CORE_Merge_Candidate__c> triggerNew) {
        onMergeCandidatesUpsert(triggerNew, null);
        validateMergeObjectIsSet(triggerNew);
    }
    
    public static void onMergeCandidatesUpsert(List<CORE_Merge_Candidate__c> triggerNew, List<CORE_Merge_Candidate__c> triggerOld) {
        Integer idx = 0;
        String objLabel = null;
         
        for(CORE_Merge_Candidate__c mcNew : triggerNew) {
            CORE_Merge_Candidate__c mcOld = triggerOld==null ? null : triggerOld[idx];
            
            if(mcOld!=null && mcOld.Status_gne__c==CANDIDATE_STATUS_PROCESSED && mcNew.Status_gne__c!=mcOld.Status_gne__c) {
                objLabel = objLabel!=null ? objLabel : CORE_Merge_Candidate__c.sObjectType.getDescribe().getLabel();
                mcNew.Status_gne__c.addError(String.format(ERROR_MESSAGE_CANNOT_CHANGE_STATUS, new String[]{objLabel, mcNew.Name, mcOld.Status_gne__c}));
            } else if(mcNew.Status_gne__c=='Loaded' && (mcOld==null || mcOld.Status_gne__c!=mcNew.Status_gne__c)) {
                mcNew.Merge_Job_gne__c = null;
                mcNew.Error_Codes_gne__c = null;
                mcNew.Error_Details_gne__c = null;
                mcNew.Processed_Date_gne__c = null;
                mcNew.Loaded_Date_gne__c = mcNew.Loaded_Date_gne__c==null || (mcOld!=null && mcOld.Loaded_Date_gne__c==mcNew.Loaded_Date_gne__c) ? System.now() : mcNew.Loaded_Date_gne__c;
            }
            idx++;
        } 
        blockUpsertOnStaleCandidates(triggerNew);
    }
    
    public static void validateMergeObjectIsSet(List<CORE_Merge_Candidate__c> mcs) {
        for(CORE_Merge_Candidate__c mc : mcs) {
            if(mc.Merge_Object_gne__c==null) {
                mc.addError(ERROR_MESSAGE_MERGE_OBJECT_CANNOT_BE_FOUND);
            }
        }
    }

    private static void blockUpsertOnStaleCandidates(List<CORE_Merge_Candidate__c> candidates) {
        List<CORE_Merge_Candidate__c> aplicableCandidates = fetchAplicableCandidates(candidates);
        Set<Id> existingIds = initActionForBlockUpsertOnCandidate(aplicableCandidates);
        for(CORE_Merge_Candidate__c mc : aplicableCandidates){
            runValidationOnUpsertForCandidate(mc, existingIds);
        }
    }
    
    private static List<CORE_Merge_Candidate__c> fetchAplicableCandidates(List<CORE_Merge_Candidate__c> candidates) {
        List<CORE_Merge_Candidate__c> aplicableCandidates = new List<CORE_Merge_Candidate__c>();
        for(CORE_Merge_Candidate__c mc : candidates){
            if(isCandidateAplicable(mc)){
                aplicableCandidates.add(mc);
            }
        }
        return aplicableCandidates;
    }
    
    private static Boolean isCandidateAplicable(CORE_Merge_Candidate__c candidate){
        return candidate.Type_gne__c != MERGE_JOB_TYPE_UNMERGE 
            && candidate.Status_gne__c != CANDIDATE_STATUS_PROCESSED 
            && candidate.Status_gne__c != CANDIDATE_STATUS_ERROR_PROCESSING;
    }

    private static void runValidationOnUpsertForCandidate(CORE_Merge_Candidate__c mc, Set<Id> existingIds) {
        if(!(mc.Id_gne__c instanceof Id) || !existingIds.contains(mc.Id_gne__c)){
            mc.Id_gne__c.addError(formatMessageByObjectId(
                mc.Id_gne__c, 
                CORE_Merge_Candidate__c.Id_gne__c.getDescribe().getLabel()
            ));
        }
        if(!(mc.Master_Id_gne__c instanceof Id) || !existingIds.contains(mc.Master_Id_gne__c)){
            mc.Master_Id_gne__c.addError(formatMessageByObjectId(
                mc.Master_Id_gne__c, 
                CORE_Merge_Candidate__c.Master_Id_gne__c.getDescribe().getLabel()
            ));           
        }
    }

    private static String formatMessageByObjectId(String objectId, String field){
        return String.format(ERROR_MESSAGE_UPSERT_BLOCKED, new String[]{
            objectId instanceof Id && fetchObjectNameById(objectId) != null ? 
                ((Id)objectId).getSObjectType().getDescribe().getLabel() : 'Record', field, objectId
        });         
    }
    
    private static Set<Id> initActionForBlockUpsertOnCandidate(List<CORE_Merge_Candidate__c> candidates){
        Map<String, Set<Id>> objectName2Ids = fetchRecordsIds(candidates);
        return fetchRecordsFromDB(objectName2Ids);
    }

    private static Set<Id> fetchRecordsFromDB(Map<String, Set<Id>> objectName2Ids){
        Set<Id> existingIds = new Set<Id>();
        for(String objectName : objectName2Ids.keySet()){
            Set<Id> ids = objectName2Ids.get(objectName);
            String soql = 'SELECT Id FROM ' + objectName + ' WHERE Id IN :ids';
            for(sObject ob : Database.query(soql)){
                existingIds.add(ob.Id);
            }
        }
        return existingIds;
    }

    private static Map<String, Set<Id>> fetchRecordsIds(List<CORE_Merge_Candidate__c> candidates){
        Map<String, Set<Id>> objectName2Ids = new Map<String, Set<Id>>();
        for(CORE_Merge_Candidate__c mc : candidates){
            if(mc.Id_gne__c != null && mc.Id_gne__c instanceof Id){
                fillOutMap(mc.Id_gne__c, objectName2Ids);
            }
            if(mc.Master_Id_gne__c != null && mc.Master_Id_gne__c instanceof Id){
                fillOutMap(mc.Master_Id_gne__c, objectName2Ids);
            }
        }
        return objectName2Ids;
    }
    
    private static String fetchObjectNameById(Id objectId){
        String objectName = null;
        try{
            objectName = objectId.getSObjectType().getDescribe().getName();
        } catch (Exception ex){
            //do nothing
        } 
        return objectName;
    }
    
    private static void fillOutMap(Id objectId, Map<String, Set<Id>> objectName2Ids){
        String objectName = fetchObjectNameById(objectId);
        if(objectName != null){
            Set<Id> objectIds = objectName2Ids.get(objectName) != null ?
            objectName2Ids.get(objectName) : new Set<Id>();
            objectIds.add(objectId);
            objectName2Ids.put(objectName, objectIds);
        }        
    }

    public static void blockDelete(List<CORE_Merge_Candidate__c> mcs) {
        List<CORE_Merge_Candidate__c> recsToBlock = new List<CORE_Merge_Candidate__c>();
        
        for(CORE_Merge_Candidate__c mc : mcs) {
            if(mc.Status_gne__c==CANDIDATE_STATUS_PROCESSED) {
                recsToBlock.add(mc);
            }
        }
        
        blockDelete((List<SObject>)recsToBlock);
    }
    
    public static void blockDelete(List<SObject> recs) {
        String objLabel = recs.isEmpty() ? null : recs[0].getSObjectType().getDescribe().getLabel();
        
        for(SObject rec : recs) {
            rec.addError(String.format(ERROR_MESSAGE_CANNOT_DELETE_MERGE_RECORD, new String[]{objLabel}));
        }
    }
    
    public static void validateConfiguration(List<CORE_Merge_Configuration__c> triggerNew) {
        CORE_Merge_Configuration.ConfigManager configManager = new CORE_Merge_Configuration.ConfigManager();
        
        for(CORE_Merge_Configuration__c configRec : triggerNew) {
            try {
                configManager.readProperty(configRec);
            } catch(CORE_Merge_Configuration.MergeConfigurationException ex) {
                configRec.addError(ex.getMessage());
            } 
        }
    }
    
    private static Integer getFieldLength(SObjectType sObjType, SObjectField fld) {
        if(fieldLengthCache==null) {
            fieldLengthCache = new Map<String,Integer>();
        }

        String key = String.format('{0}_{1}', new String[]{String.valueOf(sObjType), String.valueOf(fld)});
        
        if(!fieldLengthCache.containsKey(key)) {
            fieldLengthCache.put(key, fld.getDescribe().getLength());
        }
        
        return fieldLengthCache.get(key);
    }
    
    public static Set<String> getFieldNamesFromSObject(SObject sObj) {
        Set<String> result = new Set<String>(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(sObj))).keySet());
        result.remove('attributes');
        return result;
    }
    
    public static MergeJobWrapper getCurrentJob() {
        List<CORE_Merge_Job__c> jobs = [
            SELECT Merge_Object_gne__c, Type_gne__c, Status_gne__c, CreatedDate, LastModifiedDate, 
                Metrics_json_gne__c, Apex_Limits_json_gne__c, Batch_Ids_json_gne__c,
                Summary_gne__c
            FROM CORE_Merge_Job__c
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ];
            
        CORE_Merge_Job__c job = !jobs.isEmpty() ? jobs[0] : null;
        return new MergeJobWrapper(job);
    }
    
    public static void handleStandAloneException(Exception ex, Id mergeObjectId) {
        if(mergeObjectId!=null) {
	        CORE_Merge_Configuration.readConfiguration(mergeObjectId);
	        CORE_Merge_Engine mergeEngine = new CORE_Merge_Engine();
	        mergeEngine.setMergeObjectRecord(CORE_Merge_Configuration.getMergeObject(mergeObjectId));
	        mergeEngine.handleException(ex);
	        mergeEngine.saveErrorRecords(mergeEngine.getErrorRecords(mergeEngine.getCache().getErrors()));
        }
    }
    
    public static String formatValue(Double value) {
        value = value!=null ? value : 0.0;
        value = (value*10.0).round()/10.0;
        String result = value.format().replaceAll(',', ' ').replaceAll(',', '.');
        result = result.contains('.') ? result : (result + '.0');
        return result; 
    }
        
    public static String formatValue(Integer value) {
        return value!=null ? value.format().replaceAll(',', ' ') : '0';
    }
    
    public static String getSalesforceURL(String objectId) {
        return URL.getSalesforceBaseUrl().toExternalForm() + '/' + objectId;
    }
        
    public static String getHtmlLink(String objectId, String objectDescription) {
        return String.format('<a href="{0}" title="{1}">{1}</a>', new String[]{getSalesforceURL(objectId), objectDescription, objectDescription});
    }
    
    public static Map<Id,Id> getWinnerIdsMap(Set<Id> ids) {
        return (new WithoutSharingQueryExecutor()).getWinnerIds(ids);
    }
    
    public virtual class MergeObjectWrapper implements Comparable, CORE_Merge_Interface.MergeObjectInterface {
        protected CORE_Merge_Object__c mergeObject;
        protected transient MergeObjectWrapper parentMergeObject;
        protected transient List<MergeObjectWrapper> childMergeObjects;
        protected transient List<MergeObjectWrapper> nextMergeObjects;
        protected transient Boolean isPopulateCandidatesEnabled;
        protected transient Boolean isPopulateCandidatesFromParentEnabled;
        protected transient Boolean isMergeFromParentEnabled;
        protected transient String populateCandidatesUniqueFieldName;
        protected transient List<String> populateCandidatesSortByColumns;
        protected transient String populateCandidatesWhereClause;
        protected transient String populateCandidatesBatchWhereClause;
        
        public MergeObjectWrapper(CORE_Merge_Object__c mergeObject) {
            this.mergeObject = mergeObject;
        }
        
        public Integer compareTo(Object compareTo) {
            Double thisOrder = getMergeObject().Order_gne__c;
            Double otherOrder = compareTo!=null ? ((MergeObjectWrapper)compareTo).getMergeObject().Order_gne__c : null;
            return thisOrder==otherOrder ? 0 : thisOrder>otherOrder ? 1 : -1;
        }
        
        public CORE_Merge_Object__c getMergeObject() {
            CORE_Merge_Configuration.readConfiguration(this.mergeObject);
            return CORE_Merge_Configuration.getMergeObject(this.mergeObject.Id);
        }
        
        public String getSObjectName() {
            return getMergeObject().Object_Type_gne__c;
        }
        
        public String getMergeObjectLabel() {
            return getMergeObject().Name;
        }
        
        public Double getOrder() {
            return getMergeObject().Order_gne__c;
        }
        
        public Object getPropertyValue(CORE_Merge_Configuration.MergeProperty prop) {
            return CORE_Merge_Configuration.getPropertyValue(getMergeObject(), prop);
        }

        public Object getPropertyValue(String propName) {
            return CORE_Merge_Configuration.getPropertyValue(getMergeObject(), propName);
        }

        public Object getPropertyValue(String propType, String propKey) {
            return CORE_Merge_Configuration.getPropertyValue(getMergeObject(), propType, propKey);
        }

        public Boolean getPropertyBooleanValue(CORE_Merge_Configuration.MergeProperty prop) {
            return CORE_Merge_Configuration.getPropertyBooleanValue(getMergeObject(), prop);
        }

        public Boolean getPropertyBooleanValue(String propName) {
            return CORE_Merge_Configuration.getPropertyBooleanValue(getMergeObject(), propName);
        }

        public String getPropertyStringValue(CORE_Merge_Configuration.MergeProperty prop) {
            return CORE_Merge_Configuration.getPropertyStringValue(getMergeObject(), prop);
        }

        public String getPropertyStringValue(String propName) {
            return CORE_Merge_Configuration.getPropertyStringValue(getMergeObject(), propName);
        }

        public List<String> getPropertyListValue(CORE_Merge_Configuration.MergeProperty prop) {
            return CORE_Merge_Configuration.getPropertyListValue(getMergeObject(), prop);
        }

        public List<String> getPropertyListValue(String propName) {
            return CORE_Merge_Configuration.getPropertyListValue(getMergeObject(), propName);
        }

        public Set<String> getPropertyKeysByType(CORE_Merge_Configuration.MergeProperty prop) {
            return CORE_Merge_Configuration.getPropertyKeysByType(getMergeObject(), prop);
        }

        public Set<String> getPropertyKeysByType(String propType) {
            return CORE_Merge_Configuration.getPropertyKeysByType(getMergeObject(), propType);
        }

        public Map<String,Object> getPropertiesByType(CORE_Merge_Configuration.MergeProperty prop) {
            return CORE_Merge_Configuration.getPropertiesByType(getMergeObject(), prop);
        }

        public Map<String,Object> getPropertiesByType(String propType) {
            return CORE_Merge_Configuration.getPropertiesByType(getMergeObject(), propType);
        }

        public Map<String,Map<String,Object>> getPropertiesByTypes(Set<String> propTypes) {
            return CORE_Merge_Configuration.getPropertiesByTypes(getMergeObject(), propTypes);
        }

        public Object getPropertyAttributes(CORE_Merge_Configuration.MergeProperty prop) {
            return CORE_Merge_Configuration.getPropertyAttributes(getMergeObject(), prop);
        }

        public Object getPropertyAttributes(String propName) {
            return CORE_Merge_Configuration.getPropertyAttributes(getMergeObject(), propName);
        }

        public Object getPropertyAttributes(String propType, String propKey) {
            return CORE_Merge_Configuration.getPropertyAttributes(getMergeObject(), propType, propKey);
        }

        public String getPropertyErrorCode(String propType, String propKey) {
            return CORE_Merge_Configuration.getPropertyErrorCode(getMergeObject(), propType, propKey);
        }
        
        public MergeObjectWrapper getParentMergeObject() {
            if(this.parentMergeObject==null && getMergeObject().Parent_Merge_Object_gne__c!=null) {
                this.parentMergeObject = new MergeObjectWrapper(CORE_Merge_Configuration.getMergeObject(getMergeObject().Parent_Merge_Object_gne__c));
            }
            
            return this.parentMergeObject;
        }
        
        public List<MergeObjectWrapper> getChildMergeObjects() {
            if(this.childMergeObjects==null) {
                this.childMergeObjects = new List<MergeObjectWrapper>();
                
                if(getMergeObject().Parent_Merge_Object_gne__c==null) {
                    for(CORE_Merge_Object__c mObj : CORE_Merge_Configuration.getMergeObjects()) {
                        if(mObj.Parent_Merge_Object_gne__c == getMergeObject().Id) {
                            this.childMergeObjects.add(new MergeObjectWrapper(mObj));
                        }
                    }
                }
                
                this.childMergeObjects.sort();
            }
            
            return this.childMergeObjects;
        }
        
        public List<MergeObjectWrapper> getNextMergeObjects() {
            if(this.nextMergeObjects==null) {
                this.nextMergeObjects = new List<MergeObjectWrapper>();
                
                if(getMergeObject().Parent_Merge_Object_gne__c!=null) {
                    for(MergeObjectWrapper mObjWrapper : getParentMergeObject().getChildMergeObjects()) {
                        if(mObjWrapper.getMergeObject().Order_gne__c > getMergeObject().Order_gne__c) {
                            this.nextMergeObjects.add(mObjWrapper);
                        }
                    }
                }
            }
            
            return this.nextMergeObjects;
        }
        
        private CORE_Merge_Configuration.PopulateCandidateConfig getPopulateConfig() {
            return (CORE_Merge_Configuration.PopulateCandidateConfig)getPropertyValue(CORE_Merge_Configuration.MergeProperty.PopulateCandidatesConfig);
        }
        
        public Boolean isPopulateCandidatesEnabled() {
            if(this.isPopulateCandidatesEnabled==null) {
                CORE_Merge_Configuration.PopulateCandidateConfig populateConfig = getPopulateConfig();
                this.isPopulateCandidatesEnabled = populateConfig!=null && populateConfig.isEnabled() && String.isNotBlank(populateConfig.getQueryUniqueField());
            }
            
            return this.isPopulateCandidatesEnabled;
        }
                       
        public Boolean isPopulateCandidatesFromParentEnabled() {
            if(this.isPopulateCandidatesFromParentEnabled==null) {
                this.isPopulateCandidatesFromParentEnabled = isPopulateCandidatesEnabled() && getPopulateConfig().isPopulateFromParentEnabled();
            }
            
            return this.isPopulateCandidatesFromParentEnabled;
        }
        
        public Boolean isMergeFromParentEnabled() {
            if(this.isMergeFromParentEnabled==null) {
                this.isMergeFromParentEnabled = isPopulateCandidatesFromParentEnabled() && getPopulateConfig().isMergeFromParentEnabled();
            }
            
            return this.isMergeFromParentEnabled;
        }
        
        public String getPopulateCandidatesUniqueFieldName() {
            if(this.populateCandidatesUniqueFieldName==null) {
                CORE_Merge_Configuration.PopulateCandidateConfig populateConfig = getPopulateConfig();
                this.populateCandidatesUniqueFieldName = populateConfig!=null ? populateConfig.getQueryUniqueField() : '';
            }
            
            return this.populateCandidatesUniqueFieldName;
        }
        
        public List<String> getPopulateCandidatesSortByColumns() {
            if(this.populateCandidatesSortByColumns==null) {
                CORE_Merge_Configuration.PopulateCandidateConfig populateConfig = getPopulateConfig();
                this.populateCandidatesSortByColumns = populateConfig!=null ? populateConfig.getQuerySortBy() : new List<String>();
            }
            
            return this.populateCandidatesSortByColumns;
        }
        
        public String getPopulateCandidatesWhereClause() {
            if(this.populateCandidatesWhereClause==null) {
                CORE_Merge_Configuration.PopulateCandidateConfig populateConfig = getPopulateConfig();
                this.populateCandidatesWhereClause = populateConfig!=null ? populateConfig.getQueryWhere() : '';
            }
            
            return this.populateCandidatesWhereClause;
        }
        
        public String getPopulateCandidatesBatchWhereClause() {
            if(this.populateCandidatesBatchWhereClause==null) {
                CORE_Merge_Configuration.PopulateCandidateConfig populateConfig = getPopulateConfig();
                this.populateCandidatesBatchWhereClause = populateConfig!=null ? populateConfig.getQueryBatchWhere() : populateConfig.getQueryWhere();
            }
            
            return this.populateCandidatesBatchWhereClause;
        }
        
        public CORE_Merge_Interface.MergeEngineBatchInterface getMergeBatch() {
            CORE_Merge_Interface.MergeEngineBatchInterface mergeBatch = (CORE_Merge_Interface.MergeEngineBatchInterface)getPropertyValue(CORE_Merge_Configuration.MergeProperty.MergeEngineBatch);
            return mergeBatch!=null ? mergeBatch : new CORE_Merge_Engine_Batch();
        }
        
        public CORE_Merge_Interface.MergeEngineBatchInterface getPreProcess() {
            CORE_Merge_Interface.MergeEngineBatchInterface mergeBatch = (CORE_Merge_Interface.MergeEngineBatchInterface)getPropertyValue(CORE_Merge_Configuration.MergeProperty.PreProcessBatch);
            return mergeBatch!=null ? mergeBatch : new CORE_Merge_Engine_Batch();
        }
        
        public CORE_Merge_Interface.PopulateCandidatesBatchInterface getPopulateCandidatesBatch() {
            CORE_Merge_Interface.PopulateCandidatesBatchInterface pcBatch = (CORE_Merge_Interface.PopulateCandidatesBatchInterface)getPropertyValue(CORE_Merge_Configuration.MergeProperty.PopulateCandidatesBatch);
            return pcBatch!=null ? pcBatch : new CORE_Merge_Populate_Candidates_Batch();
        }
        
        public Id executePreProcessJob(Boolean isPreviewMode, Set<String> winnerIds, Integer scopeLimit, Long durationLimit) {
            CORE_Merge_Interface.MergeEngineBatchInterface mergeBatch = getPreProcess();
            mergeBatch.initBatch(getMergeObject().Id, isPreviewMode, winnerIds, scopeLimit, durationLimit);
            return mergeBatch.executeBatch(getMergeObject().Id);
        }
        
        public Id executeMergeJob() {
            return executeMergeJob(false, null, null, null);
        }
        
        public Id executeMergeJob(Boolean isPreviewMode, Set<String> winnerIds, Integer scopeLimit, Long durationLimit) {
            CORE_Merge_Interface.MergeEngineBatchInterface mergeBatch = getMergeBatch();
            mergeBatch.initBatch(getMergeObject().Id, isPreviewMode, winnerIds, scopeLimit, durationLimit);
            return mergeBatch.executeBatch(getMergeObject().Id);
        }
        
        public Id executeMergeJob(CORE_Merge_Interface.MergeJobInterface mergeJob) {
            CORE_Merge_Interface.MergeEngineBatchInterface mergeBatch = getMergeBatch();
            mergeBatch.initBatch(getMergeObject().Id, mergeJob);
            return mergeBatch.executeBatch(getMergeObject().Id);
        }
        
        public Id executePopulateCandidatesJob() {
            CORE_Merge_Interface.PopulateCandidatesBatchInterface mergeBatch = getPopulateCandidatesBatch();
            mergeBatch.initBatch(getMergeObject().Id);
            return mergeBatch.executeBatch(getMergeObject().Id);
        }    
    }
    
    public class ApexLimitsInfo {
        protected Map<String,ApexLimitInfo> apexLimits;
        protected Integer scopeLimit;
        protected Long durationLimit;
        
        private Integer getScopeLimit() {
            return this.scopeLimit;
        }
        
        private void setScopeLimit(Integer scopeLimit) {
            this.scopeLimit = scopeLimit;
        }
        
        private Long getDurationLimit() {
            return this.durationLimit;
        }
        
        private void setDurationLimit(Long durationLimit) {
            this.durationLimit = durationLimit;
        }
        
        private ApexLimitsInfo() {
            this.apexLimits = new Map<String,ApexLimitInfo>{
                '01_CpuTime' => new ApexLimitInfo('CpuTime', Limits.getLimitCpuTime()),
                '02_Queries' => new ApexLimitInfo('Queries', Limits.getLimitQueries()),
                '03_QueryRows' => new ApexLimitInfo('QueryRows', Limits.getLimitQueryRows()),
                '04_DMLStatements' => new ApexLimitInfo('DMLStatements', Limits.getLimitDMLStatements()),
                '05_DMLRows' => new ApexLimitInfo('DMLRows', Limits.getLimitDMLRows()),
                '06_HeapSize' => new ApexLimitInfo('HeapSize', Limits.getLimitHeapSize()),
                '07_Savepoints' => new ApexLimitInfo('Savepoints', Limits.getLimitSavepoints()),
                '08_SavepointRollbacks' => new ApexLimitInfo('SavepointRollbacks', Limits.getLimitSavepointRollbacks()),
                '09_AggregateQueries' => new ApexLimitInfo('AggregateQueries', Limits.getLimitAggregateQueries()),
                '10_QueryLocatorRows' => new ApexLimitInfo('QueryLocatorRows', Limits.getLimitQueryLocatorRows())
            };
        }
        
        private void refresh() {
            this.apexLimits.get('01_CpuTime').refresh(Limits.getCpuTime());
            this.apexLimits.get('02_Queries').refresh(Limits.getQueries());
            this.apexLimits.get('03_QueryRows').refresh(Limits.getQueryRows());
            this.apexLimits.get('04_DMLStatements').refresh(Limits.getDMLStatements());
            this.apexLimits.get('05_DMLRows').refresh(Limits.getDMLRows());
            this.apexLimits.get('06_HeapSize').refresh(Limits.getHeapSize());
            this.apexLimits.get('07_Savepoints').refresh(Limits.getSavepoints());
            this.apexLimits.get('08_SavepointRollbacks').refresh(Limits.getSavepointRollbacks());
            this.apexLimits.get('09_AggregateQueries').refresh(Limits.getAggregateQueries());
            this.apexLimits.get('10_QueryLocatorRows').refresh(Limits.getQueryLocatorRows());
        }
        
        public String asHtmlTable() {
            List<String> columns = new List<String>{'LIMIT TYPE', 'LIMIT', 'MAX', 'AVG'};
            
            for(Integer i=0;i<columns.size();i++) {
                columns[i] = String.format('<th{0} style="{1}">{2}</th>', new String[]{
                    i>1 ? ' colspan="2"' : '',
                    HTML_REPORT_CSS_MAP.get('cell'),
                    columns[i]
                });
            }
            
            List<String> limitSortedKeys = new List<String>(this.apexLimits.keySet());
            limitSortedKeys.sort();
            
            List<String> rows = new List<String>();
            for(String key : limitSortedKeys) {
                rows.add(this.apexLimits.get(key).asHtmlRow());
            }
            
            return String.format('<table align="center" style="{0}"><thead><tr><th style="{1}" colspan="6">{2}</th></tr><tr>{3}</tr></thead><tbody>{4}</tbody></table>', new String[]{
                HTML_REPORT_CSS_MAP.get('report-table'),
                HTML_REPORT_CSS_MAP.get('cell'),
                'SALESFORCE LIMITS USAGE',
                String.join(columns, ''),
                String.join(rows, '')
            });
        }
        
        private String asJSON() {
            return JSON.serialize(this);
        }
    }
    
    private class ApexLimitInfo {
        private String name;
        private Integer apexLimit;
        private Integer maxValue;
        private Double avgValue;
        private Integer counter;
        
        private ApexLimitInfo(String name, Integer apexLimit) {
            this.name = name;
            this.apexLimit = apexLimit;
            this.maxValue = 0;
            this.avgValue = 0.0;
            this.counter = 0;
        }
        
        private void refresh(Integer limitValue) {
            this.maxValue = this.maxValue<limitValue ? limitValue : this.maxValue;
            this.avgValue = (this.avgValue*this.counter)/((Double)(this.counter+1)) + (Double)limitValue/((Double)(this.counter+1));
            this.counter++;
        }
        
        private String asHtmlRow() {
            Double maxPercent = this.apexLimit>0 ? (Double)this.maxValue*100/(Double)this.apexLimit : 0.0;
            Double avgPercent = this.apexLimit>0 ? (Double)this.avgValue*100/(Double)this.apexLimit : 0.0;
            List<String> values = new List<String>{
                formatValue(this.maxValue),
                formatValue(maxPercent) + '%',
                formatValue(this.avgValue),
                formatValue(avgPercent) + '%'
            };
            
            List<String> cells = new List<String>();
            
            for(String value : values) {
                cells.add(String.format('<td style="{0}">{1}</td>', new String[]{
                    HTML_REPORT_CSS_MAP.get('numeric-cell'),
                    value
                }));
            }
            Boolean isAlertRow = (maxPercent>50 || avgPercent>50);
            
            return String.format('<tr><td style="{1}{0}">{3}</td><td style="{2}{0}">{4}</td>{5}</tr>', new String[]{
                (maxPercent>50 || avgPercent>50) ? HTML_REPORT_CSS_MAP.get('alert-row') : '',
                HTML_REPORT_CSS_MAP.get('text-cell'),
                HTML_REPORT_CSS_MAP.get('numeric-cell'),
                this.name,
                formatValue(this.apexLimit),
                String.join(cells,'')
            });
        }
    }
    
    
    public virtual class MergeJobWrapper implements CORE_Merge_Interface.MergeJobInterface {
        protected CORE_Merge_Job__c mergeJob;
        protected String status;
        protected Map<String,JobMetrics> metrics;
        protected ApexLimitsInfo apexLimits;
        protected List<String> batchIds;
        protected String summary;
        protected String startedDate;
        protected String inProgressDate;
        protected String completedDate;
        protected String lastModifiedDate;
        protected Integer scopeLimit;
        protected Integer scopeSize;
        protected Long durationLimit;
        protected Long durationStart;
        protected Boolean stillSomethingToProcess;
        protected transient MergeObjectWrapper mergeObject;
        protected transient List<AsyncApexJob> batchJobs; 
        private Set<Id> visitedMergeObjectIds;
        private Boolean isPreviewMode;
        
        public MergeJobWrapper(CORE_Merge_Job__c mergeJob) {
            this.mergeJob = mergeJob;
            this.status = JOB_STATUS_NEW;
            this.metrics = new Map<String,JobMetrics>();
            this.batchIds = new List<String>();
            this.startedDate = this.lastModifiedDate = DateTime.now().formatGmt(DEFAULT_DATETIME_FORMAT);
            this.apexLimits = new ApexLimitsInfo();
            
            if(mergeJob!=null) {
                try {
                    this.status = String.isNotBlank(mergeJob.Status_gne__c) ? mergeJob.Status_gne__c : this.status;
                    this.startedDate = mergeJob.CreatedDate!=null ? mergeJob.CreatedDate.formatGmt(DEFAULT_DATETIME_FORMAT) : this.startedDate;
                    this.lastModifiedDate = mergeJob.LastModifiedDate!=null ? mergeJob.LastModifiedDate.formatGmt(DEFAULT_DATETIME_FORMAT) : this.lastModifiedDate;
                    this.batchIds = String.isNotBlank(mergeJob.Batch_Ids_json_gne__c) ? (List<String>)JSON.deserialize(mergeJob.Batch_Ids_json_gne__c, List<String>.class) : this.batchIds;
                    this.metrics = String.isNotBlank(mergeJob.Metrics_json_gne__c) ? (Map<String,JobMetrics>)JSON.deserialize(mergeJob.Metrics_json_gne__c, Map<String,JobMetrics>.class) : this.metrics;
                    this.summary = mergeJob.Summary_gne__c;
                    this.apexLimits = String.isNotBlank(mergeJob.Apex_Limits_json_gne__c) ? (ApexLimitsInfo)JSON.deserialize(mergeJob.Apex_Limits_json_gne__c, ApexLimitsInfo.class) : this.apexLimits;
                    this.scopeLimit = this.apexLimits.getScopeLimit();
                    this.durationLimit = this.apexLimits.getDurationLimit();
                } catch(Exception ex) {
                    // Do nothing - it must be safe operation
                }
            }
        }
        
        public Boolean isPreviewMode() {
            return this.isPreviewMode == true;
        }
        
        public void setPreviewMode(Boolean isPreviewMode) {
            this.isPreviewMode = isPreviewMode;
        }
        
        public Integer getScopeLimit() {
            return this.scopeLimit;
        }
        
        public void setScopeLimit(Integer scopeLimit) {
            this.scopeLimit = scopeLimit;
            
            if(getApexLimits()!=null) {
                getApexLimits().setScopeLimit(scopeLimit);
            }
        }
        
        public Integer getScopeSize() {
            if(this.scopeSize==null) {
                this.scopeSize = 0;
            }
            
            return this.scopeSize;
        }
        
        public void increaseScopeSize(Integer scopeSize) {
            if(this.scopeSize==null) {
                this.scopeSize = 0;
            }
            
            this.scopeSize+=scopeSize;
        }
        
        public Integer getRemainingScopeLimit() {
            return (getScopeLimit()!=null ? getScopeLimit() : 50000000) - getScopeSize();
        }
        
        public Boolean isScopeLimitExceeded() {
            return getRemainingScopeLimit()<=0;
        }
        
        public Long getDurationLimit() {
            return this.durationLimit;
        }
        
        public String getDurationLimitDescription() {
            return getDurationLimit()!=null ? getTimeDescription(this.durationLimit) : '';
        }
        
        public void setDurationLimit(Long durationLimit) {
            this.durationStart = DateTime.now().getTime();
            this.durationLimit = durationLimit;
            
            if(getApexLimits()!=null) {
                getApexLimits().setDurationLimit(durationLimit);
            }
        }
        
        public Boolean isDurationLimitExceeded() {
            return this.durationLimit!=null && this.durationStart!=null && (DateTime.now().getTime()-this.durationStart>this.durationLimit);
        }
        
        public String getStatus() {
            return this.status;
        }
        
        public String setStatus(String status) {
            String prevValue = this.status;
            this.status=status;
            return prevValue;
        }
        
        public DateTime getLastModifiedDate() {
            return DateTime.valueOfGmt(this.lastModifiedDate);
        }
        
        public List<String> getBatchIds() {
            return this.batchIds;
        }
        
        public void addBatchId(String batchId) {
            if(!new Set<String>(getBatchIds()).contains(batchId)) {
                getBatchIds().add(batchId);
            }
        }
        
        public Map<String,JobMetrics> getMetrics() {
            return this.metrics;
        }
        
        public void addMetrics(CORE_Merge_Interface.JobMetricsInterface jobMetrics) {
            if(!getMetrics().containsKey(jobMetrics.getMergeObjectId())) {
                getMetrics().put(jobMetrics.getMergeObjectId(), (JobMetrics)jobMetrics);
            } else {
                JobMetrics jMetrics = getMetrics().get(jobMetrics.getMergeObjectId());
                jMetrics.add(jobMetrics);
            }
        }
        
        public String getSummary() {
            return this.summary;
        }
        
        public void setSummary(String summary) {
            this.summary = summary;
        }
        
        public ApexLimitsInfo getApexLimits() {
            return this.apexLimits;
        }
        
        public CORE_Merge_Job__c getMergeJob() {
            return this.mergeJob;
        }
        
        public Boolean isBatchInProgress() {
            String batchStatus = getLastBatchStatus();
            return batchStatus!=null && new Set<String>{'QUEUED', 'PROCESSING', 'PREPARING', 'HOLDING'}.contains(batchStatus.toUpperCase());
        }
        
        public Boolean isInProgress() {
            String jobStatus = getStatus();
            String batchStatus = getLastBatchStatus();
            return (jobStatus==JOB_STATUS_NEW || jobStatus==JOB_STATUS_IN_PROGRESS) && isBatchInProgress() && getLastModifiedDate().addHours(1)>DateTime.now();
        }
        
        public MergeObjectWrapper getMergeObject() {
            if(this.mergeObject==null && getMergeJob()!=null) {
                this.mergeObject = new MergeObjectWrapper(new CORE_Merge_Object__c(Id = getMergeJob().Merge_Object_gne__c));
            }
            
            return this.mergeObject;
        }
        
        public String getMergeObjectLabel() {
            return getMergeObject()!=null ? getMergeObject().getMergeObjectLabel() : '';
        }
        
        public String getType() {
            return getMergeJob()!=null ? getMergeJob().Type_gne__c : null;
            
        }
        
        public String getTypeLabel() {
            String jobType = getType();
            return jobType==null ? '-' : 
                jobType==MERGE_JOB_TYPE_MERGE_PERVIEW_MODE ? 'Merge (Preview Mode)' :
                jobType==MERGE_JOB_TYPE_MERGE_SINGLE_MODE ? 'Single Merge' :
                jobType==MERGE_JOB_TYPE_MERGE_PREVIEW_SINGLE_MODE ? 'Single Merge (Preview Mode)' : 
                jobType==MERGE_JOB_TYPE_POPULATE_CANDIDATES ? 'Populate Candidates' :
                 
                jobType;
        }
        
        public String getStatusLabel() {
            String jobStatus = getStatus();
            return jobStatus==null ? '-' : jobStatus;
        }
        
        public Boolean isPopulateCandidates() {
            return getType()==MERGE_JOB_TYPE_POPULATE_CANDIDATES;
        }
        
        public List<AsyncApexJob> getBatchJobs() {
            if(this.batchJobs==null) {
                this.batchJobs = getBatchIds().isEmpty() ? new List<AsyncApexJob>() : [
                    SELECT Status, JobItemsProcessed, NumberOfErrors, TotalJobItems
                    FROM AsyncApexJob
                    WHERE ID IN :getBatchIds()
                    ORDER BY Id
                ];
            }
            
            return this.batchJobs;
        }
        
        public String getLastBatchStatus() {
            List<AsyncApexJob> jobs = getBatchJobs();
            return jobs.isEmpty() ? '-' : jobs[jobs.size()-1].Status;
        }
        
        public Integer getProcessedBatchesSize() {
            Integer result = 0;
            for(AsyncApexJob job : getBatchJobs()) {
                result += job.JobItemsProcessed!=null ? job.JobItemsProcessed : 0;
            }
            
            return result;
        }
        
        public Integer getAllBatchesSize() {
            Integer result = 0;
            for(AsyncApexJob job : getBatchJobs()) {
                result += job.TotalJobItems!=null ? job.TotalJobItems : 0;
            }
            
            return result;
        }
        
        public Integer getBatchFailuresSize() {
            Integer result = 0;
            for(AsyncApexJob job : getBatchJobs()) {
                result += job.NumberOfErrors!=null ? job.NumberOfErrors : 0;
            }
            
            return result;
        }
        
        public Integer getMergeGroupsSize() {
            Integer result = 0;
            
            for(JobMetrics jm : getMetrics().values()) {
                result += jm.getMergeGroupsSize();
            }
            
            return result;
        }
        
        public Integer getValidMergeGroupsSize() {
            Integer result = 0;
            
            for(JobMetrics jm : getMetrics().values()) {
                result += jm.getValidMergeGroupsSize();
            }
            
            return result;
        }
        
        public Integer getCandidatesSize() {
            Integer result = 0;
            
            for(JobMetrics jm : getMetrics().values()) {
                result += jm.getCandidatesSize();
            }
            
            return result;
        }
        
        public Integer getValidCandidatesSize() {
            Integer result = 0;
            
            for(JobMetrics jm : getMetrics().values()) {
                result += jm.getValidCandidatesSize();
            }
            
            return result;
        }
        
        public Integer getPopulatedMergeGroupsSize() {
            Integer result = 0;
            
            for(JobMetrics jm : getMetrics().values()) {
                result += jm.getPopulatedMergeGroupsSize();
            }
            
            return result;
        }
        
        public Integer getPopulatedCandidatesSize() {
            Integer result = 0;
            
            for(JobMetrics jm : getMetrics().values()) {
                result += jm.getPopulatedCandidatesSize();
            }
            
            return result;
        }
        
        public Integer getRuntimeErrorsSize() {
            Integer result = 0;
            
            for(JobMetrics jm : getMetrics().values()) {
                result += jm.getRuntimeErrorsSize();
            }
            
            return result;
        }
        
        public Integer getErrorsSize() {
            Integer result = 0;
            
            for(JobMetrics jm : getMetrics().values()) {
                result += jm.getErrorsSize();
            }
            
            return result;
        }
        
        public Map<String,Integer> getErrorCodesSize() {
            Map<String,Integer> result = new Map<String,Integer>();
            
            for(JobMetrics jm : getMetrics().values()) {
                for(String errCode : jm.getErrorCodesSize().keySet()) {
                    if(!result.containsKey(errCode)) {
                        result.put(errCode, 0);
                    }
            
                    result.put(errCode, result.get(errCode)+jm.getErrorCodesSize().get(errCode));
                }
            }
            
            return result;
        }
        
        public Set<Id> getVisitedMergeObjectIds() {
            if(this.visitedMergeObjectIds==null) {
                this.visitedMergeObjectIds = new Set<Id>();
            }
        
            return this.visitedMergeObjectIds;
        }
        
        public void saveJob() {
            CORE_Merge_Job__c mJobRec = getMergeJob();
            this.apexLimits.refresh();
            
            if(mJobRec!=null) {
                mJobRec.Batch_Ids_json_gne__c = JSON.serialize(getBatchIds());
                mJobRec.Metrics_json_gne__c = JSON.serialize(getMetrics());
                mJobRec.Status_gne__c = getStatus();
                mJobRec.Summary_gne__c = prepareSummary();
                mJobRec.Apex_Limits_json_gne__c = this.apexLimits.asJSON();
                
                Database.DmlOptions dmlOpt = new Database.DmlOptions();
                dmlOpt.allowFieldTruncation = true;
                mJobRec.setOptions(dmlOpt);
                Database.upsert(mJobRec, false);
            }
        }
        
        public String prepareSummary() {
            String summary = String.format('{0}\n\n{1}{2}', new String[]{prepareSummaryHeader(), String.join(getMetricsDescription(), '\n'), isStillSomethingToProcess() ? ('\n\n' + INFO_MESSAGE_BATCH_SCOPE_TRUNCATED) : ''});
            setSummary(summary);
            return summary;
        }
        
        public String prepareHtmlSummary() {
            List<List<String>> columnGroups = new List<List<String>>{
                new List<String>{'OBJECT TYPE'},
                new List<String>{'AUTO-POPULATED', 'GROUPS', 'CANDIDATES'},
                !isPopulateCandidates() ? new List<String>{'PROCESSED GROUPS', 'ERROR', 'VALID', 'ALL'} : null,
                !isPopulateCandidates() ? new List<String>{'PROCESSED CANDIDATES', 'ERROR', 'VALID', 'ALL'} : null,
                new List<String>{'ERRORS', 'RUNTIME', 'ALL'}
            };
            
            Integer colsCount = 0;
            List<String> firstRowHeaderCells = new List<String>();
            List<String> secondRowHeaderCells = new List<String>();
            for(List<String> columnGroup : columnGroups) {
                if(columnGroup!=null) {
                    Boolean withSubColumns = columnGroup.size()>1;
                    colsCount += withSubColumns ? columnGroup.size()-1 : columnGroup.size();
                    String groupName = columnGroup[0];
                    String groupCssClass = groupName.toLowerCase().replaceAll(' ', '-') + '-cell';
                    firstRowHeaderCells.add(String.format('<th {0} style="{1}{2}">{3}</th>', new String[]{
                        withSubColumns ? ('colspan="' + (columnGroup.size()-1) + '"') : 'rowspan="2"',
                        HTML_REPORT_CSS_MAP.get('cell'),
                        HTML_REPORT_CSS_MAP.get(groupCssClass),
                        groupName
                    }));
                    
                    for(Integer i=1;i<columnGroup.size();i++) {
                        secondRowHeaderCells.add(String.format('<th style="{0}{1}">{2}</th>', new String[]{
                            HTML_REPORT_CSS_MAP.get('cell'),
                            HTML_REPORT_CSS_MAP.get(groupCssClass),
                            columnGroup[i]
                        }));
                    }
                }
            }
            
            
            
            return String.format('{0}{9}\n\n<table align="center" style="{1}"><thead><tr><th style="{2}" colspan="{3}">{4}</th></tr><tr>{5}</tr><tr>{6}</tr></thead><tfoot><tr><td style="{2}" colspan="{3}">{8}</td></tr></tfoot><tbody>{7}</tbody></table>{10}', new String[]{
                prepareHtmlSummaryHeader(),
                HTML_REPORT_CSS_MAP.get('report-table'),
                HTML_REPORT_CSS_MAP.get('cell'),
                String.valueOf(colsCount),
                'JOB DETAILS',
                String.join(firstRowHeaderCells,''),
                String.join(secondRowHeaderCells,''),
                String.join(getMetricsDescription(true),''),
                'Job Report can be found ' + getHtmlLink(getMergeJob().Id, 'here'),
                isStillSomethingToProcess() ? ('\n' + INFO_MESSAGE_BATCH_SCOPE_TRUNCATED) : '',
                prepareErrorCodesHtmlTable()
            });
        }
        
        public String prepareHtmlSupportSummary() {
            return String.format('{0}\n\n{1}', new String[]{
                prepareHtmlSummary(),
                this.apexLimits.asHtmlTable()
            });
        }
        
        public String prepareSummaryHeader() {
            return String.format(
                'Merge Job {0} (Type: {1}) processed {2} batches with {3} failures.\n' +
                'Start Date: {4} GMT\n' +
                'End Date:   {5} GMT\n' +
                'Duration:   {6}',
                new String[]{
                    getMergeObjectLabel(), getTypeLabel(), formatValue(getAllBatchesSize()), formatValue(getBatchFailuresSize()),
                    this.startedDate, this.completedDate!=null ? this.completedDate : this.lastModifiedDate, this.getDurationDescription()
            });
        }
        
        public String prepareHtmlSummaryHeader() {
            return String.format(
                '<span style="{0}">Merge Job {1} (Type: {2}) processed {3} batches with {4} failures.</span>\n' +
                '<table><tbody><tr><td>Start Date:</td><td>{5} GMT</td></tr>' +
                '<tr><td>End Date:</td><td>{6} GMT</td></tr>' +
                '<tr><td>Duration:</td><td>{7}</td></tr></tbody></table>',
                new String[]{
                    HTML_REPORT_CSS_MAP.get('header'),
                    getMergeObjectLabel(), getTypeLabel(), formatValue(getAllBatchesSize()), formatValue(getBatchFailuresSize()),
                    this.startedDate, this.completedDate!=null ? this.completedDate : this.lastModifiedDate, this.getDurationDescription()
            });
        }
        
        public String prepareErrorCodesHtmlTable() {
            List<String> errorCodeRows = new List<String>();
            Map<String,Integer> errorCodesMap = getErrorCodesSize();
            
            List<String> sortedKeys = new List<String>();
            Map<String,String> errorCodesHelperMap = new Map<String,String>();
            
            for(String errCode : errorCodesMap.keySet()) {
                Integer val = errorCodesMap.get(errCode);
                String valAsString = String.valueOf(val);
                String key = String.format('{0}{1}_{2}', new String[]{'0'.repeat(Math.max(10-valAsString.length(),0)), valAsString, errCode});
                sortedKeys.add(key);
                errorCodesHelperMap.put(key, errCode);
            }
                
            sortedKeys.sort();
            
            for(Integer i=sortedKeys.size()-1;i>=0;i--) {
                String errCode = errorCodesHelperMap.get(sortedKeys[i]);
                Integer val = errorCodesMap.get(errCode);
                Boolean isAlertRow = errCode==RUNTIME_EXCEPTION_CODE;
                errorCodeRows.add(String.format('<tr><td style="{0}{2}">{3}</td><td style="{1}{2}">{4}</td></tr>', new String[]{
                    HTML_REPORT_CSS_MAP.get('text-cell'),
                    HTML_REPORT_CSS_MAP.get('numeric-cell'),
                    isAlertRow ? HTML_REPORT_CSS_MAP.get('alert-row') : '',
                    errCode,
                    formatValue(val)
                }));
            }
            
            List<String> columns = new List<String>{'CODE', 'SIZE'};
            
            for(Integer i=0;i<columns.size();i++) {
                columns[i] = String.format('<th style="{0}">{1}</th>', new String[]{
                    HTML_REPORT_CSS_MAP.get('cell'),
                    columns[i]
                });
            }
            
            return String.format(errorCodeRows.isEmpty() ? '' : '\n\n<table align="center" style="{0}"><thead><tr><th style="{1}" colspan="2">{2}</th></tr><tr>{3}</tr></thead><tbody>{4}</tbody></table>', new String[]{
                HTML_REPORT_CSS_MAP.get('report-table'),
                HTML_REPORT_CSS_MAP.get('cell'),
                'ERROR CODES',
                String.join(columns, ''),
                String.join(errorCodeRows, '')
            }); 
        }
        
        public String getDurationDescription() {
            return getDurationDescription(false);
        }
        
        public String getDurationDescription(Boolean actualProgressMode) {
            DateTime startDate = DateTime.valueOfGmt(this.startedDate);
            DateTime endDate = this.completedDate!=null ? DateTime.valueOfGmt(this.completedDate) : (actualProgressMode ? DateTime.now() : DateTime.valueOfGmt(this.lastModifiedDate));
            Long diffMillis = endDate.getTime() - startDate.getTime();
            return getTimeDescription(diffMillis);
        }
        
        protected String getTimeDescription(Long millis) {
            DateTime tDate = DateTime.newInstance(millis);
            List<String> listOfDateComponents = new List<String>{'day', 'hour', 'minute', 'second'};
            Map<String, Integer> componentValues = new Map<String,Integer>{
                'day' => tDate.dayGmt()-1,
                'hour' => tDate.hourGmt(),
                'minute' => tDate.minuteGmt(),
                'second' => tDate.secondGmt()
            };
            
            List<String> componentValuesList = new List<String>();
            Boolean isSomethingAdded = false;
            
            for(String componentType : listOfDateComponents) {
                Integer componentValue = componentValues.get(componentType);
                if(componentValue!=0 || (isSomethingAdded==false && componentType=='second')) {
                    isSomethingAdded = true;
                    componentValuesList.add(String.format('{0} {1}{2}', new String[]{String.valueOf(componentValue), componentType, componentValue>1 ? 's' : ''}));
                }
            }
            
            return String.join(componentValuesList, ' ');
        }
        
        public List<String> getMetricsDescription() {
            return getMetricsDescription(false);
        }
        
        public List<String> getMetricsDescription(Boolean isHtmlMode) {
            List<String> result = new List<String>();
            if(getMergeObject()!=null) {
                List<Id> mObjsIds = new List<Id>{getMergeObject().getMergeObject().Id};
                Map<Id,MergeObjectWrapper> mObjMap = new Map<Id,MergeObjectWrapper>();
                mObjMap.put(getMergeObject().getMergeObject().Id, getMergeObject());
                
                for(MergeObjectWrapper mObj : (getMergeObject().getParentMergeObject()==null ? getMergeObject().getChildMergeObjects() : getMergeObject().getNextMergeObjects())) {
                    mObjsIds.add(mObj.getMergeObject().Id);
                    mObjMap.put(mObj.getMergeObject().Id, mObj);
                }
                
                for(Id mObjId : mObjsIds) {
                    if(getMetrics().containsKey(mObjId)) {
                        JobMetrics jMetrics = getMetrics().get(mObjId);
                        result.add(isHtmlMode ? jMetrics.asHtml(mObjMap.get(mObjId), this) : jMetrics.asText(mObjMap.get(mObjId), this));
                    }
                }
            }
            
            return result;
        }
        
        public void markAsInProgress() {
            if(setStatus(JOB_STATUS_IN_PROGRESS)!=JOB_STATUS_IN_PROGRESS) {
                this.inProgressDate = DateTime.now().formatGmt(DEFAULT_DATETIME_FORMAT);
            }
            
            saveJob();
        }
        
        public void markAsCompleted() {
            markAsCompleted(false);
        }
        
        public void markAsCompleted(Boolean stillSomethingToProcess) {
            if(setStatus(JOB_STATUS_COMPLETED)!=JOB_STATUS_COMPLETED) {
                this.completedDate = DateTime.now().formatGmt(DEFAULT_DATETIME_FORMAT);
            }
            
            setStillSomethingToProcess(stillSomethingToProcess);
            saveJob();
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{prepareEmail(true), prepareEmail(false)}, false);
        }
        
        public void setStillSomethingToProcess(Boolean stillSomethingToProcess) {
            this.stillSomethingToProcess = stillSomethingToProcess;
        }
        
        public Boolean isStillSomethingToProcess() {
            return this.stillSomethingToProcess==true;
        }
        
        public String getProgressDescription() {
            return getProgressDescription(false);
        }
        
        public String getProgressDescription(Boolean actualProgressMode) {
            return String.format('Job : {0}, Type: {1} \nBatch/Overall Status: {2}/{3} \nAuto-Populated Groups/Candidates: {11}/{12} \n' + (!isPopulateCandidates() ? 'Duplicate Groups / Candidates (Processed/All): {7}/{8} / {9}/{10} \n' : '') + 'Errors (RUNTIME/All): {13}/{14}, Batch Failures: {15} \nDuration: {4} \nProgress: {5}/{6}{16}{17}', new String[] {
                getMergeObjectLabel(),
                getTypeLabel(),
                getLastBatchStatus(),
                getStatusLabel(),
                getDurationDescription(actualProgressMode),
                formatValue(getProcessedBatchesSize()),
                formatValue(getAllBatchesSize()),
                formatValue(getValidMergeGroupsSize()),
                formatValue(getMergeGroupsSize()),
                formatValue(getValidCandidatesSize()),
                formatValue(getCandidatesSize()),
                formatValue(getPopulatedMergeGroupsSize()),
                formatValue(getPopulatedCandidatesSize()),
                formatValue(getRuntimeErrorsSize()),
                formatValue(getErrorsSize()),
                formatValue(getBatchFailuresSize()),
                getScopeLimit()!=null ? ' \nScope Limit: ' + formatValue(getScopeLimit()) : '',
                getDurationLimit()!=null ? ' \nDuration Limit: ' + getDurationLimitDescription() : ''
            });
        }
        
        public Messaging.SingleEmailMessage prepareEmail(Boolean businnesOrSupportMode) {
            CORE_Merge_Configuration.MergeProperty emailProp = businnesOrSupportMode ? CORE_Merge_Configuration.MergeProperty.ReportEmail : CORE_Merge_Configuration.MergeProperty.SupportEmail;
            List<String> emails = (List<String>)getMergeObject().getPropertyListValue(emailProp);
            emails = emails!=null && !emails.isEmpty() ? new List<String>(emails) : new List<String>{UserInfo.getUserEmail()};
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(emails);
            
            Integer runtimeErrorsSize = getRuntimeErrorsSize();
            mail.setSubject(String.format('{0}Merge Job {1} (Type: {2}) completed{3}!', new String[]{
                businnesOrSupportMode ? '' : '[Merge Support] ',
                getMergeObjectLabel(),
                getTypeLabel(),
                businnesOrSupportMode || runtimeErrorsSize==0 ? '' : (' with ' + formatValue(runtimeErrorsSize)  + ' RUNTIME ERROR' + (runtimeErrorsSize==1 ? '' : 'S')) 
            }));
            
            mail.setHtmlBody((businnesOrSupportMode ? prepareHtmlSummary() : prepareHtmlSupportSummary()).replaceAll('\\n','<br/>'));
            return mail;
        }
    }
    
    public class JobMetrics implements CORE_Merge_Interface.JobMetricsInterface {
        private Id mergeObjectId;
        private Integer candidatesSize;
        private Integer validCandidatesSize;
        private Integer populatedMergeGroupsSize;
        private Integer populatedCandidatesSize;
        private Integer mergeGroupsSize;
        private Integer validMergeGroupsSize;
        private Integer errorsSize;
        private Map<String,Integer> errorCodesSize;
        
        public JobMetrics(Id mergeObjectId) {
            this.mergeObjectId = mergeObjectId;
            this.candidatesSize = 0;
            this.validCandidatesSize = 0;
            this.populatedMergeGroupsSize = 0;
            this.populatedCandidatesSize = 0;
            this.mergeGroupsSize = 0;
            this.validMergeGroupsSize = 0;
            this.errorsSize = 0;
            this.errorCodesSize = new Map<String,Integer>();
        }
        
        public Id getMergeObjectId() {
            return this.mergeObjectId;
        }
        
        public Integer getMergeGroupsSize() {
            return this.mergeGroupsSize;
        }
        
        public Integer getValidMergeGroupsSize() {
            return this.validMergeGroupsSize;
        }
        
        public Integer getCandidatesSize() {
            return this.candidatesSize;
        }
        
        public Integer getValidCandidatesSize() {
            return this.validCandidatesSize;
        }
        
        public Integer getPopulatedMergeGroupsSize() {
            return this.populatedMergeGroupsSize;
        }
        
        public Integer getPopulatedCandidatesSize() {
            return this.populatedCandidatesSize;
        }
        
        public Integer getErrorsSize() {
            return this.errorsSize;
        }
        
        public Integer getRuntimeErrorsSize() {
            return this.errorCodesSize.containsKey(RUNTIME_EXCEPTION_CODE) ? this.errorCodesSize.get(RUNTIME_EXCEPTION_CODE) : 0;
        }
        
        public Map<String,Integer> getErrorCodesSize() {
            return this.errorCodesSize;
        }
        
        public void add(CORE_Merge_Interface.JobMetricsInterface jobMetric) {
            increaseMergeGroupsSize(jobMetric.getMergeGroupsSize());
            increaseValidMergeGroupsSize(jobMetric.getValidMergeGroupsSize());
            increaseCandidatesSize(jobMetric.getCandidatesSize());
            increaseValidCandidatesSize(jobMetric.getValidCandidatesSize());
            increasePopulatedMergeGroupsSize(jobMetric.getPopulatedMergeGroupsSize());
            increasePopulatedCandidatesSize(jobMetric.getPopulatedCandidatesSize());
            increaseErrorsSize(jobMetric.getErrorsSize());
            
            for(String errCode : jobMetric.getErrorCodesSize().keySet()) {
                increaseErrorCodesSize(errCode, jobMetric.getErrorCodesSize().get(errCode));
            }
        }
        
        public void increaseMergeGroupsSize(Integer val) {
            this.mergeGroupsSize += val;
        }
        
        public void increaseValidMergeGroupsSize(Integer val) {
            this.validMergeGroupsSize += val;
        }
        
        public void increaseCandidatesSize(Integer val) {
            this.candidatesSize += val;
        }
        
        public void increaseValidCandidatesSize(Integer val) {
            this.validCandidatesSize += val;
        }
        
        public void increasePopulatedMergeGroupsSize(Integer val) {
            this.populatedMergeGroupsSize += val;
        }
        
        public void increasePopulatedCandidatesSize(Integer val) {
            this.populatedCandidatesSize += val;
        }
        
        public void increaseErrorsSize(Integer val) {
            this.errorsSize += val;
        }
        
        public void increaseErrorCodesSize(String errCode, Integer val) {
            if(!this.errorCodesSize.containsKey(errCode)) {
                this.errorCodesSize.put(errCode, 0);
            }
            
            this.errorCodesSize.put(errCode, this.errorCodesSize.get(errCode)+val);
        }
        
        public String asText(MergeObjectWrapper mergeObject, MergeJobWrapper mergeJob) {
            return String.format('{0}: \nAuto-Populated Groups/Candidates: {5}/{6}' + (!mergeJob.isPopulateCandidates() ? ', Duplicate Groups / Candidates (Processed/All): {1}/{2} / {3}/{4}' : '') + ', Errors (RUNTIME/All): {7}/{8}', new String[]{
                mergeObject.getMergeObjectLabel(),
                formatValue(getValidMergeGroupsSize()),
                formatValue(getMergeGroupsSize()),
                formatValue(getValidCandidatesSize()),
                formatValue(getCandidatesSize()),
                formatValue(getPopulatedMergeGroupsSize()),
                formatValue(getPopulatedCandidatesSize()),
                formatValue(getRuntimeErrorsSize()),
                formatValue(getErrorsSize())
            });
        }
        
        public String asHtml(MergeObjectWrapper mergeObject, MergeJobWrapper mergeJob) {
            List<String> valueCells = new List<String>{
                formatValue(getPopulatedMergeGroupsSize()),
                formatValue(getPopulatedCandidatesSize()),
                !mergeJob.isPopulateCandidates() ? formatValue(getMergeGroupsSize()-getValidMergeGroupsSize()) : null,
                !mergeJob.isPopulateCandidates() ? formatValue(getValidMergeGroupsSize()) : null,
                !mergeJob.isPopulateCandidates() ? formatValue(getMergeGroupsSize()) : null,
                !mergeJob.isPopulateCandidates() ? formatValue(getCandidatesSize()-getValidCandidatesSize()) : null,
                !mergeJob.isPopulateCandidates() ? formatValue(getValidCandidatesSize()) : null,
                !mergeJob.isPopulateCandidates() ? formatValue(getCandidatesSize()) : null,
                formatValue(getRuntimeErrorsSize()),
                formatValue(getErrorsSize())
            };
            Boolean isAlertRow = getRuntimeErrorsSize()>0;
            
            for(Integer i=0;i<valueCells.size();i++) {
                String columnGroupStyle = i<2 ? 'auto-populated-cell' : i<5 ? 'processed-groups-cell' : i<8 ? 'processed-candidates-cell' : 'errors-cell';
                if(valueCells[i]!=null) {
                    valueCells[i] = String.format('<td style="{0}{1}{2}">{3}</td>', new String[]{
                        HTML_REPORT_CSS_MAP.get('numeric-cell'),
                        HTML_REPORT_CSS_MAP.get(columnGroupStyle),
                        isAlertRow ? HTML_REPORT_CSS_MAP.get('alert-row') : '',
                        valueCells[i]
                    });
                }
            }
            
            return String.format('<tr><td style="{0}{1}{2}">{3}</td>{4}</tr>', new String[]{
                HTML_REPORT_CSS_MAP.get('text-cell'),
                HTML_REPORT_CSS_MAP.get('object-type-cell'),
                isAlertRow ? HTML_REPORT_CSS_MAP.get('alert-row') : '',
                mergeObject.getMergeObjectLabel(),
                String.join(valueCells,'')
            });
        }
    }
    
    public virtual class MergeGroupWrapper implements CORE_Merge_Interface.MergeGroupInterface {
        protected Id winnerId;
        protected List<Id> allIds;
        protected Boolean isValid;
        protected Boolean isInProgress;
        protected MergeCandidateWrapper winnerCandidate;
        protected List<MergeCandidateWrapper> allCandidates;
        protected List<MergeCandidateWrapper> loserCandidates;
        
        public MergeGroupWrapper(CORE_Merge_Candidate__c winnerCandidate, List<CORE_Merge_Candidate__c> allCandidates) {
            this.winnerCandidate = new MergeCandidateWrapper(winnerCandidate, this);
            this.allCandidates = new List<MergeCandidateWrapper>();
            
            for(CORE_Merge_Candidate__c mc : allCandidates) {
                this.allCandidates.add(new MergeCandidateWrapper(mc, this));
            }

            this.winnerId = winnerCandidate.Master_Id_gne__c!=null && winnerCandidate.Master_Id_gne__c instanceof Id ? Id.valueOf(winnerCandidate.Master_Id_gne__c) : null;
            this.allIds = new List<Id>();
             
            for(CORE_Merge_Candidate__c mc : allCandidates) {
                Id mcId = mc.Id_gne__c!=null && mc.Id_gne__c instanceof Id ? Id.valueOf(mc.Id_gne__c) : null;
                this.allIds.add(mcId);
            }
        }
        
        public Id getWinnerId() {
            return this.winnerId;
        }
        
        public List<Id> getAllIds() {
            return this.allIds;
        }
        
        public MergeCandidateWrapper getWinnerCandidate() {
	        return this.winnerCandidate;
	    }
	    
	    public List<MergeCandidateWrapper> getAllCandidates() {
	        return this.allCandidates;
	    }
	    
	    public List<MergeCandidateWrapper> getLoserCandidates() {
	        if(this.loserCandidates==null) {
	            this.loserCandidates = new List<MergeCandidateWrapper>(this.allCandidates);
	            
	            if(!this.loserCandidates.isEmpty()) {
	               this.loserCandidates.remove(0);
	            }
	        }
	        
	        return this.loserCandidates;
	    }
	    
	    public CORE_Merge_Object__c getMergeObject() {
	        Id mObjId = getWinnerCandidate().getCandidate().Merge_Object_gne__c;
            CORE_Merge_Configuration.readConfiguration(mObjId);
	        return CORE_Merge_Configuration.getMergeObject(mObjId);
	    }
	    
	    public String getSObjectName() {
	        return getMergeObject().Object_Type_gne__c;
	    }
	    
	    public void initCandidates() {
	        for(MergeCandidateWrapper mc : getAllCandidates()) {
                mc.getCandidate().Error_Codes_gne__c = null;
                mc.getCandidate().Error_Details_gne__c = null;
            }
	    }
	   
	    
	    public void setSourceRecords(Map<Id,SObject> sourceRecsMap) {
	        this.winnerCandidate.setSourceRecord(winnerId!=null ? sourceRecsMap.get(winnerId) : null);

	        Integer idx=0;
	        for(Id sId : allIds) {
	            this.allCandidates[idx++].setSourceRecord(sId!=null ? sourceRecsMap.get(sId) : null);
	        } 
	    }
	    
	    public void setSourceRecordsForValidate(Map<Id,SObject> sourceRecsMap) {
            this.winnerCandidate.setSourceRecordForValidate(winnerId!=null ? sourceRecsMap.get(winnerId) : null);

            Integer idx=0;
            for(Id sId : allIds) {
                this.allCandidates[idx++].setSourceRecordForValidate(sId!=null ? sourceRecsMap.get(sId) : null);
            } 
        }
        
        public void setSourceRecordsForArchive(Map<Id,SObject> sourceRecsMap) {
            this.winnerCandidate.setSourceRecordForArchive(winnerId!=null ? sourceRecsMap.get(winnerId) : null);

            Integer idx=0;
            for(Id sId : allIds) {
                this.allCandidates[idx++].setSourceRecordForArchive(sId!=null ? sourceRecsMap.get(sId) : null);
            } 
        }
        
        public void setIsValid(Boolean isValid) {
            this.isValid = isValid;
        }
        
        public void markAsCompleted() {
            Boolean isValid = isValid();
            
            for(MergeCandidateWrapper mc : getAllCandidates()) {
                mc.getCandidate().Status_gne__c = isValid ? CANDIDATE_STATUS_PROCESSED : CANDIDATE_STATUS_ERROR_PROCESSING;
                mc.getCandidate().Processed_Date_gne__c = DateTime.now();
            }
        }
        
        public Boolean isValid() {
            return this.isValid!=false;
        }
        
        public void setInProgress(Boolean isInProgress) {
            this.isInProgress=isInProgress;
        }
        
        public Boolean isInProgress() {
            return this.isInProgress==true;
        }
    }
    
    public virtual class MergeCandidateWrapper implements CORE_Merge_Interface.MergeCandidateInterface {
        protected CORE_Merge_Candidate__c candidate;
        protected MergeGroupWrapper mergeGroup;
        protected SObject sourceRecord;
        protected SObject sourceRecordForValidate;
        protected SObject sourceRecordForArchive;
        protected SObject sourceRecordToUpdate;
        protected SObject archiveClone;
        protected CORE_Merge_Archive_Record__c archiveRecord;
        protected List<SObject> archiveChildRecords;
        protected List<CORE_Merge_Archive_JSON_Part__c> archiveJsonParts;
        protected List<ErrorWrapper> errors;
        protected Boolean isChanged;
        
        public MergeCandidateWrapper(CORE_Merge_Candidate__c candidate, MergeGroupWrapper mergeGroup) {
            this.candidate = candidate;
            this.mergeGroup = mergeGroup;
        }
        
        public void markAsCompletedInPreviewMode() {
            getCandidate().Error_Details_gne__c = String.format('[Preview Mode]: Status: {0}{1}', new String[]{
                getCandidate().Status_gne__c,
                getCandidate().Error_Details_gne__c!=null ? (', Errors: ' + getCandidate().Error_Details_gne__c) : ''
            });
            
            getCandidate().Status_gne__c = CANDIDATE_STATUS_LOADED;
            getCandidate().Processed_Date_gne__c = null;
        }
        
        public CORE_Merge_Candidate__c getCandidate() {
            return this.candidate;
        }
        
        public MergeGroupWrapper getMergeGroup() {
            return this.mergeGroup;
        }
        
        public String print() {
            return this.candidate.Id_gne__c;
        }
        
        public void setSourceRecord(SObject sourceRecord) {
            this.sourceRecord = sourceRecord;
        }
        
        public SObject getSourceRecord() {
            return this.sourceRecord;
        }
        
        public void setSourceRecordForValidate(SObject sourceRecordForValidate) {
            this.sourceRecordForValidate = sourceRecordForValidate;
        }
        
        public SObject getSourceRecordForValidate() {
            return this.sourceRecordForValidate;
        }
        
        public void setSourceRecordForArchive(SObject sourceRecordForArchive) {
            this.sourceRecordForArchive = sourceRecordForArchive;
        }
        
        public SObject getSourceRecordForArchive() {
            return this.sourceRecordForArchive;
        }
        
        public SObject getSourceRecordToUpdate() {
            if(this.sourceRecordToUpdate==null) {
                this.sourceRecordToUpdate = this.getSourceRecord().getSObjectType().newSObject(this.getSourceRecord().Id);
            }
            
            return this.sourceRecordToUpdate;
        }
        
        public String getSourceId() {
            return this.candidate.Id_gne__c;
        }
        
        public String getMasterId() {
            return this.candidate.Master_Id_gne__c;
        }
        
        public Boolean isWinner() {
            return this.candidate.Id_gne__c==this.candidate.Master_Id_gne__c;
        }
        
        public Boolean isSourceValid() {
            return this.sourceRecord!=null;
        }
        
        public void setIsChanged(Boolean isChanged) {
            this.isChanged = isChanged() || isChanged;
        }
        
        public Boolean isChanged() {
            return this.isChanged==true;
        }
        
        public void setArchiveClone(SObject archiveClone) {
            this.archiveClone = archiveClone;
        }
        
        public SObject getArchiveClone() {
            return this.archiveClone;
        }
        
        public void createArchiveRecord(String systemTimeStamp) {
            this.archiveRecord = new CORE_Merge_Archive_Record__c(
                Id_gne__c = getSourceId(),
                Master_Id_gne__c = getMasterId(),
                Merge_Object_gne__c = getCandidate().Merge_Object_gne__c,
                Merge_Candidate_gne__c = getCandidate().Id
            );
            
            this.archiveRecord.External_Id_gne__c = String.format('{0}_{1}_{2}', new String[]{this.archiveRecord.Id_gne__c, this.archiveRecord.Master_Id_gne__c, systemTimeStamp});
            
            if(!isWinner()) {
                this.archiveRecord.Master_Archive_Record_gne__r = new CORE_Merge_Archive_Record__c(
                    External_Id_gne__c = String.format('{0}_{1}_{2}', new String[]{this.archiveRecord.Master_Id_gne__c, this.archiveRecord.Master_Id_gne__c, systemTimeStamp})
                );
            } 
        }
        
        public CORE_Merge_Archive_Record__c getArchiveRecord() {
            return this.archiveRecord;
        }
        
        public void setArchiveJsonFields(Map<String,Object> fieldValues) {
            String fieldValuesInJSON = !fieldValues.isEmpty() ? JSON.serialize(fieldValues) : null;
            saveArchiveJsonValue(getArchiveRecord(), null, fieldValuesInJSON);
        }
        
        public void addChildArchiveRecord(SObject childRec, SObjectField field, CORE_Merge_Configuration.RelationshipConfigWrapper rcw, String systemTimeStamp) {
            SObject archiveChildRec = rcw.getArchiveType()=='APP' ? (SObject)new CORE_Merge_Archive_App_Record__c() : (SObject)new CORE_Merge_Archive_Child_Record__c();
            CORE_Merge_Archive_Record__c parentRef = new CORE_Merge_Archive_Record__c(External_Id_gne__c = String.format('{0}_{1}_{2}', new String[]{getSourceId(), getMasterId(), systemTimeStamp}));
            
            archiveChildRec.put(String.valueOf(CORE_Merge_Archive_Child_Record__c.Id_gne__c), childRec.Id);
            archiveChildRec.put(String.valueOf(CORE_Merge_Archive_Child_Record__c.Relationship_Name_gne__c), rcw.getRelationshipName());
            archiveChildRec.put(String.valueOf(CORE_Merge_Archive_Child_Record__c.Field_Name_gne__c), String.valueOf(field));
            archiveChildRec.put(String.valueOf(CORE_Merge_Archive_Child_Record__c.Object_Type_gne__c), childRec.getSObjectType().getDescribe().getName());
            archiveChildRec.put(String.valueOf(CORE_Merge_Archive_Child_Record__c.External_Id_gne__c), String.format('{0}_{1}_{2}_{3}_{4}', new String[]{
                childRec.Id, getSourceId(), getMasterId(), rcw.getRelationshipName(), systemTimeStamp
            }));
            archiveChildRec.putSObject('Merge_Archive_Record_gne__r', parentRef);
            
            Map<String,Object> fieldValues = new Map<String,Object>();
            
            for(String fieldName : rcw.getQueryFields()) {
                fieldValues.put(fieldName, childRec.get(fieldName));    
            }
            
            String fieldValuesInJSON = !fieldValues.isEmpty() ? JSON.serialize(fieldValues) : null;
            saveArchiveJsonValue(parentRef, archiveChildRec, fieldValuesInJSON);
            
            if(this.archiveChildRecords==null) {
                this.archiveChildRecords = new List<SObject>(); 
            }
            
            this.archiveChildRecords.add(archiveChildRec);
        }
        
        private void saveArchiveJsonValue(CORE_Merge_Archive_Record__c archiveRec, SObject childArchiveRec, String fieldValuesInJSON) {
            if(fieldValuesInJSON!=null) {
                Integer maxJsonPartSize = getFieldLength(CORE_Merge_Archive_Record__c.sObjectType, CORE_Merge_Archive_Record__c.Value_json_gne__c);
	            Integer jsonSize = fieldValuesInJSON.length();
	            SObject mainArchiveRec = childArchiveRec!=null ? childArchiveRec : archiveRec;
	            if(jsonSize<=maxJsonPartSize) {
	                mainArchiveRec.put(String.valueOf(CORE_Merge_Archive_Record__c.Value_json_gne__c), fieldValuesInJSON); 
	            } else {
	                maxJsonPartSize-=2;
	                mainArchiveRec.put(String.valueOf(CORE_Merge_Archive_Record__c.Value_json_gne__c), '|' + fieldValuesInJSON.substring(0,maxJsonPartSize) + '|');
	                Integer partNo = 1;
	                CORE_Merge_Archive_Record__c parentRef = new CORE_Merge_Archive_Record__c(External_Id_gne__c = archiveRec.External_Id_gne__c);
	                SObject childRef = null;
	                
	                if(childArchiveRec!=null) {
	                    childRef = childArchiveRec.getSObjectType().newSObject();
	                    String extIdFieldName = String.valueOf(CORE_Merge_Archive_Child_Record__c.External_Id_gne__c);
	                    childRef.put(extIdFieldName, childArchiveRec.get(extIdFieldName));
	                }
	                
	                for(Integer startIdx=maxJsonPartSize; startIdx<jsonSize; startIdx+=maxJsonPartSize) {
	                    String jsonPart = fieldValuesInJSON.substring(startIdx, Math.min(startIdx+maxJsonPartSize, jsonSize));
	                    addArchiveJsonPart(partNo++, jsonPart, parentRef, childRef);
	                }
	            }
            }
        }
        
        private void addArchiveJsonPart(Integer partNo, String jsonValue, CORE_Merge_Archive_Record__c parentRef, SObject childRef) {
            CORE_Merge_Archive_JSON_Part__c partRec = new CORE_Merge_Archive_JSON_Part__c(
                Merge_Archive_Record_gne__r = parentRef,
                Merge_Archive_Child_Record_gne__r = childRef!=null && childRef instanceof CORE_Merge_Archive_Child_Record__c ? (CORE_Merge_Archive_Child_Record__c)childRef : null,
                Merge_Archive_App_Record_gne__r = childRef!=null && childRef instanceof CORE_Merge_Archive_App_Record__c ? (CORE_Merge_Archive_App_Record__c)childRef : null,
                Part_No_gne__c = partNo,
                Value_json_gne__c = '|' + jsonValue + '|' 
            );
            
            if(this.archiveJsonParts==null) {
                this.archiveJsonParts = new List<CORE_Merge_Archive_JSON_Part__c>(); 
            }
            
            this.archiveJsonParts.add(partRec);
        }
        
        public List<SObject> getArchiveChildRecords() {
            return this.archiveChildRecords!=null ? archiveChildRecords : new List<SObject>();
        }
        
        public List<CORE_Merge_Archive_JSON_Part__c> getArchiveJsonParts() {
            return this.archiveJsonParts!=null ? archiveJsonParts : new List<CORE_Merge_Archive_JSON_Part__c>();
        }
        
        public void addError(CORE_Merge_Object__c mObj, Exception ex) {
            addError(mObj, ex, true);
        }
        
        public void addError(CORE_Merge_Object__c mObj, Exception ex, Boolean isOwnError) {
            ErrorWrapper newErr = new ErrorWrapper(mObj, ex);
            addError(newErr, isOwnError);
        }
        
        public void addError(CORE_Merge_Object__c mObj, String code, String type, String description) {
            ErrorWrapper newErr = new ErrorWrapper(mObj, code, type, description);
            addError(newErr, true);
        }
        
        public void addError(ErrorWrapper newErr, Boolean isOwnError) {
            List<ErrorWrapper> errorsList = isOwnError==true ? this.getErrors() : new List<ErrorWrapper>(this.getErrors());
            errorsList.add(newErr);
            Set<String> errCodes = new Set<String>();
            Set<String> errDescs = new Set<String>();
            
            for(CORE_Merge_Interface.ErrorInterface err : errorsList) {
                if(String.isNotBlank(err.getCode())) {
                    errCodes.add(err.getCode());
                }
                
                errDescs.add(err.getDescription());
            }
            
            List<String> sortedErrCodes = new List<String>(errCodes);
            sortedErrCodes.sort();
            List<String> sortedErrDescs = new List<String>(errDescs);
            sortedErrDescs.sort();
            
            this.getCandidate().Error_Codes_gne__c = String.join(sortedErrCodes,';');
            this.getCandidate().Error_Details_gne__c = String.join(sortedErrDescs,';');
            
            if(isOwnError==true && !this.isWinner()) {
                this.getMergeGroup().getWinnerCandidate().addError(newErr, false);
            }
        }
        
        public List<ErrorWrapper> getErrors() {
            if(this.errors==null) {
                this.errors = new List<ErrorWrapper>();
            }
            
            return this.errors;
        }
    }
    
    public virtual class ErrorWrapper implements CORE_Merge_Interface.ErrorInterface {
        protected CORE_Merge_Object__c mergeObject;
        protected String code;
        protected String type;
        protected String stackTrace;
        protected String description;
        
        public ErrorWrapper(CORE_Merge_Object__c mergeObject, Exception ex) {
            this(mergeObject,
                 ex instanceof CORE_Merge_Interface.MergeCandidateExceptionInterface ? ((CORE_Merge_Interface.MergeCandidateExceptionInterface)ex).getErrorCode() : RUNTIME_EXCEPTION_CODE, 
                 ex instanceof CORE_Merge_Interface.MergeCandidateExceptionInterface ? ((CORE_Merge_Interface.MergeCandidateExceptionInterface)ex).getErrorType() : ex.getTypeName(),
                 ex.getMessage()
            );
            this.stackTrace = ex.getStackTraceString();
        }
        
        public ErrorWrapper(CORE_Merge_Object__c mergeObject, String code, String type, String description) {
            this.mergeObject = mergeObject;
            this.code = code;
            this.type = type;
            this.description = description;
        }
        
        public CORE_Merge_Object__c getMergeObject() {
            CORE_Merge_Configuration.readConfiguration(this.mergeObject);
            return CORE_Merge_Configuration.getMergeObject(this.mergeObject.Id);
        }
        
        public String getSObjectName() {
            return getMergeObject().Object_Type_gne__c;
        }
        
        public String getCode() {
            return this.code;
        }
        
        public String getType() {
            return this.type;
        }
        
        public String getShortDescription() {
            String result = getDescription();
            
            if(result!=null) {
                result = result.substringBefore('\n').left(255);
            }
            
            return result;
        }
        
        public String getDescription() {
            return this.description;
        }
        
        public String getStackTrace() {
            return this.stackTrace;
        }
        
        public CORE_Merge_Error__c asErrorRecord(CORE_Merge_Interface.MergeJobInterface job, CORE_Merge_Interface.MergeCandidateInterface mc) {
            CORE_Merge_Error__c errRec = new CORE_Merge_Error__c(
                Merge_Object_gne__c = getMergeObject().Id,
                Merge_Job_gne__c = job!=null ? job.getMergeJob().Id : null,
                Merge_Candidate_gne__c = mc!=null ? mc.getCandidate().Id : null,
                Object_Type_gne__c = getSObjectName(),
                Id_gne__c = mc!=null ? mc.getSourceId() : null,
                Master_Id_gne__c = mc!=null ? mc.getMasterId() : null,
                Error_Code_gne__c = getCode(),
                Type_gne__c = getType(),
                Level_gne__c = 'HIGH',
                Description_gne__c = getShortDescription(),
                Full_Description_gne__c = getDescription(),
                Stacktrace_gne__c = getStackTrace()
            );
            errRec.Hash_Code_gne__c = String.valueOf(System.hashCode(String.format('{0}_{1}_{2}_{3}_{4}', new String[]{errRec.Merge_Object_gne__c, errRec.Merge_Job_gne__c, errRec.Merge_Candidate_gne__c, errRec.Error_Code_gne__c, errRec.Description_gne__c})));
            return errRec;
        }
    }
    
    public virtual class DmlResult implements CORE_Merge_Interface.DmlResultInterface {
        protected Boolean isSuccess;
        protected List<Database.Error> errors;
        protected MergeCandidateWrapper candidate;
        
        public DmlResult(Database.SaveResult result) {
            this(result.isSuccess(), result.getErrors(), null);
        }
        
        public DmlResult(Database.SaveResult result, MergeCandidateWrapper candidate) {
            this(result.isSuccess(), result.getErrors(), candidate);
        }
        
        public DmlResult(Database.UpsertResult result) {
            this(result.isSuccess(), result.getErrors(), null);
        }
        
        public DmlResult(Database.UpsertResult result, MergeCandidateWrapper candidate) {
            this(result.isSuccess(), result.getErrors(), candidate);
        }
        
        public DmlResult(Database.DeleteResult result) {
            this(result.isSuccess(), result.getErrors(), null);
        }
        
        public DmlResult(Database.DeleteResult result, MergeCandidateWrapper candidate) {
            this(result.isSuccess(), result.getErrors(), candidate);
        }
        
        public DmlResult(Database.MergeResult result) {
            this(result.isSuccess(), result.getErrors(), null);
        }
        
        public DmlResult(Database.MergeResult result, MergeCandidateWrapper candidate) {
            this(result.isSuccess(), result.getErrors(), candidate);
        }
        
        public DmlResult(Boolean isSuccess, List<Database.Error> errors, MergeCandidateWrapper candidate) {
            this.isSuccess = isSuccess;
            this.errors = errors;
            this.candidate = candidate;
        }
        
        public Boolean isSuccess() {
            return this.isSuccess==true;
        }
        
        public List<Database.Error> getErrors() {
            return this.errors;
        }
        
        public MergeCandidateWrapper getCandidate() {
            return this.candidate;
        }
    }
    
    public virtual class MergeEngineCache implements CORE_Merge_Interface.MergeEnigneCacheInterface {
        protected List<MergeGroupWrapper> mergeGroups;
        protected Map<Id,List<MergeGroupWrapper>> childMergeGroupsToProcess;
        protected List<MergeGroupWrapper> childMergeGroupsToLoad;
        protected List<ErrorWrapper> errors;
        protected Map<String,CORE_Merge_Archive_Record__c> winnerArchiveRecs; 
        protected Map<String,CORE_Merge_Archive_Record__c> loserArchiveRecs;
        protected List<SObject> archiveChildRecords;
        protected List<CORE_Merge_Archive_JSON_Part__c> archiveJsonParts;
        protected Map<String,SObject> archiveClones;
        
        
        public MergeEngineCache() {}
        
        public List<MergeGroupWrapper> getMergeGroups() {
            if(this.mergeGroups==null) {
                this.mergeGroups = new List<MergeGroupWrapper>();
            }
            
            return this.mergeGroups;
        }
        
        public Map<Id,List<MergeGroupWrapper>> getChildMergeGroupsToProcess() {
            if(this.childMergeGroupsToProcess==null) {
                this.childMergeGroupsToProcess = new Map<Id,List<MergeGroupWrapper>>();
            }
            
            return this.childMergeGroupsToProcess;
        }
        
        public List<MergeGroupWrapper> getChildMergeGroupsToLoad() {
            if(this.childMergeGroupsToLoad==null) {
                this.childMergeGroupsToLoad = new List<MergeGroupWrapper>();
            }
            
            return this.childMergeGroupsToLoad;
        }
        
        public List<ErrorWrapper> getErrors() {
            if(this.errors==null) {
                this.errors = new List<ErrorWrapper>();
            }
            
            return this.errors;
        }
        
        public Integer getErrorsSize() {
            Integer result = getErrors().size();
            
            for(MergeGroupWrapper mGroup : getMergeGroups()) {
                for(MergeCandidateWrapper mc : mGroup.getAllCandidates()) {
                    result += mc.getErrors().size();
                }
            }
            
            return result;
        }
        
        public Integer getCandidatesSize() {
            Integer result = 0;
            
            for(MergeGroupWrapper mGroup : getMergeGroups()) {
                result += mGroup.getAllCandidates().size();
            }
            
            return result;
        }
        
        public Map<String,CORE_Merge_Archive_Record__c> getWinnerArchiveRecs() {
            if(this.winnerArchiveRecs==null) {
                this.winnerArchiveRecs = new Map<String,CORE_Merge_Archive_Record__c>();
            }
            
            return this.winnerArchiveRecs;
	    }
	    
	    public Map<String,CORE_Merge_Archive_Record__c> getLoserArchiveRecs() {
            if(this.loserArchiveRecs==null) {
                this.loserArchiveRecs = new Map<String,CORE_Merge_Archive_Record__c>();
            }
            
            return this.loserArchiveRecs;
        }
	    
        public List<SObject> getArchiveChildRecords() {
            if(this.archiveChildRecords==null) {
                this.archiveChildRecords = new List<SObject>();
            }
            
            return this.archiveChildRecords;
        }
        
        public List<CORE_Merge_Archive_JSON_Part__c> getArchiveJsonParts() {
            if(this.archiveJsonParts==null) {
                this.archiveJsonParts = new List<CORE_Merge_Archive_JSON_Part__c>();
            }
            
            return this.archiveJsonParts;
        }
        
        public Map<String,SObject> getArchiveClones() {
            if(this.archiveClones==null) {
                this.archiveClones = new Map<String,SObject>();
            }
            
            return this.archiveClones;
        }
    }
    
    private without sharing class WithoutSharingQueryExecutor {
        private WithoutSharingQueryExecutor() {}
        
        private Map<Id,Id> getWinnerIds(Set<Id> ids) {
            Map<Id,Id> result = new Map<Id,Id>();
            
            if(!ids.isEmpty()) {
               List<CORE_Merge_Candidate__c> mcs = [
                   SELECT Id_gne__c, Master_Id_gne__c
                   FROM CORE_Merge_Candidate__c
                   WHERE Id_gne__c IN :ids
                       AND Candidate_Type_calc_gne__c = :CANDIDATE_TYPE_LOSER
                       AND Status_gne__c = :CANDIDATE_STATUS_PROCESSED
               ];
               
               for(CORE_Merge_Candidate__c mc : mcs) {
                   if(String.isNotBlank(mc.Master_Id_gne__c) && String.isNotBlank(mc.Id_gne__c) && mc.Master_Id_gne__c instanceof Id && mc.Id_gne__c instanceof Id) {
                       result.put(Id.valueOf(mc.Id_gne__c), Id.valueOf(mc.Master_Id_gne__c));
                   }
               }
            }
            
            for(Id recId : ids) {
                if(!result.containsKey(recId)) {
                    result.put(recId,recId);
                }
            }
            
            return result;
        }
    }
    
    public virtual class MergeException extends Exception {}
    
    public class MergeCandidateException extends MergeException implements CORE_Merge_Interface.MergeCandidateExceptionInterface {
        private String errorCode;
        private String errorType;
        
        public MergeCandidateException(String errorCode, String text) {
            this(errorCode, null, text);
        }
        
        public MergeCandidateException(String errorCode, String text, MergeCandidateWrapper mc) {
            this(errorCode, null, String.format(text, new String[]{mc.print()}));
        }
        
        public MergeCandidateException(String errorCode, String errorType, String text, MergeCandidateWrapper mc) {
            this(errorCode, errorType, String.format(text, new String[]{mc.print()}));
        }
        
        public MergeCandidateException(String errorCode, String errorType, String text) {
            this(text);
            this.errorCode = errorCode;
            this.errorType = errorType;
        }
        
        public String getErrorCode() {
            return String.isNotBlank(this.errorCode) ? this.errorCode : DEFAULT_MERGE_CANDIDATE_EXCEPTION_CODE;
        }
        
        public String getErrorType() {
            return String.isNotBlank(this.errorType) ? this.errorType : 'MergeCandidateException';
        }
    }
    
    public class MergeDmlException extends MergeException {
        
        public MergeDmlException(Database.Error err) {
            this(err.getMessage());
        }
    }
}