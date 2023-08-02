public without sharing class CORE_Merge_Configuration {
    
    public enum MergeProperty { 
        AdminModeManager,
        ApprovalProcessEnabled,
        ArchiveChildRelationship,
        ArchiveEnabled,
		ArchiveCloningEnabled,
		ArchiveCloneExcludedFields,
		ArchiveJsonEnabled,
		ArchiveJsonFields,
		ArchiveOwner,
		ArchiveRecordType,
		ArchiveMasterIdField,
		ArchiveIdField,
		ArchiveCloneFieldDefaults,
		ArchiveCloneLoserFieldDefaults,
		ArchiveCloneWinnerFieldDefaults,
        CustomConfigManager,
		CustomMergeEngineListner,
		CustomMergeValidation,
		CustomPostMergeAction,
		CustomPostUnmergeAction,
		CustomPreMergeAction,
		CustomPreUnmergeAction,
		CustomUnmergeValidation,
		DeferOnChildRelationship,
        DeferOnConflict,
		DeferOnConflictWithNulls,
		ExcludeMatching,
		FieldAvg,
		FieldBooleanAND,
		FieldBooleanOR,
		FieldConcatenate,
        FieldConcatenateUnique,
		FieldCustomTransfer,
		FieldNotNull,
		FieldPreferHigh,
		FieldPreferLow,
		FieldSum,
		FieldToQuery,
		MatchingRecord,
		PopulateCandidatesConfig,
		CustomPostPopulateAction,
		RelationshipToExclude,
		RelationshipToMove,
		RelationshipToQuery,
		ReportEmail,
		SupportEmail,
		ValidateSourceRecordDisabled,
		MergeEngine,
		MergeEngineBatch,
		PreProcessBatch,
		PopulateCandidatesBatch,
		SchedulerConfig,
		WikiPage
    }
    
    public static final Set<String> RELATIONSHIP_SETTINGS = new Set<String>{
        MergeProperty.ArchiveChildRelationship.name().toUpperCase(),
        MergeProperty.DeferOnChildRelationship.name().toUpperCase(),
        MergeProperty.RelationshipToExclude.name().toUpperCase(),
        MergeProperty.RelationshipToMove.name().toUpperCase(),
        MergeProperty.RelationshipToQuery.name().toUpperCase()
    };
    
    public static final Set<String> VALIDATION_SETTINGS = new Set<String>{
        MergeProperty.CustomMergeValidation.name().toUpperCase(),
        MergeProperty.DeferOnChildRelationship.name().toUpperCase(),
        MergeProperty.DeferOnConflict.name().toUpperCase(),
        MergeProperty.DeferOnConflictWithNulls.name().toUpperCase(),
        MergeProperty.ExcludeMatching.name().toUpperCase()
    };
    
    public static final Set<String> FIELD_SETTINGS = new Set<String>{
        MergeProperty.ArchiveMasterIdField.name().toUpperCase(),
        MergeProperty.ArchiveIdField.name().toUpperCase(),
        MergeProperty.DeferOnConflict.name().toUpperCase(),
        MergeProperty.DeferOnConflictWithNulls.name().toUpperCase(),
        MergeProperty.ExcludeMatching.name().toUpperCase(),
        MergeProperty.FieldAvg.name().toUpperCase(),
        MergeProperty.FieldBooleanAND.name().toUpperCase(),
        MergeProperty.FieldBooleanOR.name().toUpperCase(),
        MergeProperty.FieldConcatenate.name().toUpperCase(),
        MergeProperty.FieldConcatenateUnique.name().toUpperCase(),
        MergeProperty.FieldCustomTransfer.name().toUpperCase(),
        MergeProperty.FieldNotNull.name().toUpperCase(),
        MergeProperty.FieldPreferHigh.name().toUpperCase(),
        MergeProperty.FieldPreferLow.name().toUpperCase(),
        MergeProperty.FieldSum.name().toUpperCase(),
        MergeProperty.FieldToQuery.name().toUpperCase()
    };
    
    public static final Set<String> BOOLEAN_SETTINGS = new Set<String>{
        MergeProperty.ApprovalProcessEnabled.name().toUpperCase(),
        MergeProperty.ArchiveEnabled.name().toUpperCase(),
        MergeProperty.ArchiveCloningEnabled.name().toUpperCase(),
        MergeProperty.ArchiveJsonEnabled.name().toUpperCase(),
        MergeProperty.ValidateSourceRecordDisabled.name().toUpperCase()
    };
    
    public static final Map<String,System.Type> PROPERTY_VALUE_CUSTOM_TYPE_MAP = new Map<String,System.Type>{
        MergeProperty.AdminModeManager.name().toUpperCase() => CORE_Merge_Interface.AdminModeManagerInterface.class,
        MergeProperty.CustomMergeEngineListner.name().toUpperCase() => CORE_Merge_Interface.CustomMergeEngineListnerInterface.class,
        MergeProperty.CustomMergeValidation.name().toUpperCase() => CORE_Merge_Interface.CustomValidationInterface.class,
        MergeProperty.CustomPreMergeAction.name().toUpperCase() => CORE_Merge_Interface.CustomPreMergeActionInterface.class,
        MergeProperty.CustomPostMergeAction.name().toUpperCase() => CORE_Merge_Interface.CustomPostMergeActionInterface.class,
        MergeProperty.FieldCustomTransfer.name().toUpperCase() => CORE_Merge_Interface.CustomFieldTransferInterface.class,
        MergeProperty.CustomPostPopulateAction.name().toUpperCase() => CORE_Merge_Interface.CustomPostPopulateActionInterface.class,
        MergeProperty.MergeEngine.name().toUpperCase() => CORE_Merge_Interface.MergeEngineInterface.class,
        MergeProperty.MergeEngineBatch.name().toUpperCase() => CORE_Merge_Interface.MergeEngineBatchInterface.class,
        MergeProperty.PopulateCandidatesBatch.name().toUpperCase() => CORE_Merge_Interface.PopulateCandidatesBatchInterface.class,
        MergeProperty.PreProcessBatch.name().toUpperCase() => CORE_Merge_Interface.MergeEngineBatchInterface.class
    };
    
    public static final Map<String,System.Type> PROPERTY_JSON_VALUE_CUSTOM_TYPE_MAP = new Map<String,System.Type>{
        MergeProperty.MatchingRecord.name().toUpperCase() => SObject.class,
        MergeProperty.ArchiveCloneFieldDefaults.name().toUpperCase() => SObject.class,
        MergeProperty.ArchiveCloneLoserFieldDefaults.name().toUpperCase() => SObject.class,
        MergeProperty.ArchiveCloneWinnerFieldDefaults.name().toUpperCase() => SObject.class,
        MergeProperty.ArchiveChildRelationship.name().toUpperCase() => RelationshipConfigWrapper.class,
        MergeProperty.DeferOnChildRelationship.name().toUpperCase() => RelationshipConfigWrapper.class,
        MergeProperty.ExcludeMatching.name().toUpperCase() => SObject.class,
        MergeProperty.RelationshipToExclude.name().toUpperCase() => RelationshipConfigWrapper.class,
        MergeProperty.RelationshipToMove.name().toUpperCase() => RelationshipConfigWrapper.class,
        MergeProperty.RelationshipToQuery.name().toUpperCase() => RelationshipConfigWrapper.class,
        MergeProperty.ArchiveCloneExcludedFields.name().toUpperCase() => List<String>.class,
        MergeProperty.ArchiveJsonFields.name().toUpperCase() => List<String>.class,
        MergeProperty.PopulateCandidatesConfig.name().toUpperCase() => PopulateCandidateConfig.class,
        MergeProperty.SchedulerConfig.name().toUpperCase() => List<SchedulerConfig>.class
    };
    
    public static final String ATTRIBUTE_SCOPE_SIZE = 'scopeSize';
    public static final String ATTRIBUTE_LIMIT_QUERY_SIZE = 'limitSize';
    
    private static final String ERROR_MESSAGE_CANNOT_READ_PROPERTY = 'Could not read property. Please contact System Administrator.';
    private static final String ERROR_MESSAGE_CONFIGURATION_ERROR = '[Merge Configuration Error] Property: {0}, Message: {1}';
    private static final String PROPERTY_LIST_SEPARATOR = ';';
    
    private static final String CRON_COLUMN_SEPARATOR = ' ';
    private static final String CRON_ALL_VALUES_CHAR = '*';
    private static final String CRON_NO_SPECIFIC_VALUE_CHAR = '?';
    private static final String CRON_LIST_SEPARATOR = ',';
    private static final String CRON_RANGE_SEPARATOR = '-';
    private static final String CRON_ORDERED_DAY_NAMES = 'SUN,MON,TUE,WED,THU,FRI,SAT';
    private static final String CRON_ORDERED_MONTH_NAMES = 'JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC';
        
    
    private static Map<Id,CORE_Merge_Interface.ConfigManagerInterface> configManagersCache;
    private static Map<String,CORE_Merge_Object__c> mergeObjectsCache;
    private static Map<String,Object> customClassInstances;
    @TestVisible private static List<CORE_Merge_Interface.AdminModeManagerInterface> adminModeManager;
    private static Map<String,Id> ownerIdCache;
    private static Map<String,Id> recordTypeIdCache;
    private static Map<String,Schema.DescribeSObjectResult> sObjectDescribe;
    private static Map<String,Map<String,Schema.ChildRelationship>> childRelationshipMap;
    
    public static CORE_Merge_Object__c getMergeObject(String key) {
        return mergeObjectsCache!=null ? mergeObjectsCache.get(key) : null;
    }
    
    public static List<CORE_Merge_Object__c> getMergeObjects() {
        List<CORE_Merge_Object__c> result = new List<CORE_Merge_Object__c>();
        
        if(mergeObjectsCache!=null) {
            Set<Id> visitedIds = new Set<Id>();
            
            for(CORE_Merge_Object__c mObj : mergeObjectsCache.values()) {
                if(!visitedIds.contains(mObj.Id)) {
                    result.add(mObj);
                }
                
                visitedIds.add(mObj.Id);
            }    
        }
        
        return result;
    }
    
    public static Object getPropertyValue(CORE_Merge_Object__c mObj, MergeProperty prop) {
        return getPropertyValue(mObj, prop.name());
    }
    
    public static Object getPropertyValue(CORE_Merge_Object__c mObj, String propName) {
        return getConfigManager(mObj).getPropertyValue(propName);
    }
    
    public static Object getPropertyValue(CORE_Merge_Object__c mObj, String propType, String propKey) {
        return getConfigManager(mObj).getPropertyValue(propType, propKey);
    }
    
    public static Boolean getPropertyBooleanValue(CORE_Merge_Object__c mObj, MergeProperty prop) {
        return getPropertyBooleanValue(mObj, prop.name());
    }
    
    public static Boolean getPropertyBooleanValue(CORE_Merge_Object__c mObj, String propName) {
        Object propVal = getPropertyValue(mObj, propName);
        return (Boolean)propVal;
    }
    
    public static String getPropertyStringValue(CORE_Merge_Object__c mObj, MergeProperty prop) {
        return getPropertyStringValue(mObj, prop.name());
    }
        
    public static String getPropertyStringValue(CORE_Merge_Object__c mObj, String propName) {
        Object propVal = getPropertyValue(mObj, propName);
        return (String)propVal;
    }
    
    public static List<String> getPropertyListValue(CORE_Merge_Object__c mObj, MergeProperty prop) {
        return getPropertyListValue(mObj, prop.name());
    }
        
    public static List<String> getPropertyListValue(CORE_Merge_Object__c mObj, String propName) {
        Object propVal = getPropertyValue(mObj, propName);
        return (List<String>)propVal;
    }
    
    public static Set<String> getPropertyKeysByType(CORE_Merge_Object__c mObj, MergeProperty prop) {
        return getPropertyKeysByType(mObj, prop.name());
    }
    
    public static Set<String> getPropertyKeysByType(CORE_Merge_Object__c mObj, String propType) {
        return getConfigManager(mObj).getPropertyKeysByType(propType);
    }
    
    public static Map<String,Object> getPropertiesByType(CORE_Merge_Object__c mObj, MergeProperty prop) {
        return getPropertiesByType(mObj, prop.name());
    }
       
    public static Map<String,Object> getPropertiesByType(CORE_Merge_Object__c mObj, String propType) {
        return getConfigManager(mObj).getPropertiesByType(propType);
    }
    
    public static Map<String,Map<String,Object>> getPropertiesByTypes(CORE_Merge_Object__c mObj, Set<String> propTypes) {
        return getConfigManager(mObj).getPropertiesByTypes(propTypes);
    }
    
    public static Object getPropertyAttributes(CORE_Merge_Object__c mObj, MergeProperty prop) {
        return getPropertyAttributes(mObj, prop.name());
    }
    
    public static Object getPropertyAttributes(CORE_Merge_Object__c mObj, String propName) {
        return getConfigManager(mObj).getPropertyAttributes(propName);
    }
    
    public static Object getPropertyAttributes(CORE_Merge_Object__c mObj, String propType, String propKey) {
        return getConfigManager(mObj).getPropertyAttributes(propType, propKey);
    }
    
    public static String getPropertyErrorCode(CORE_Merge_Object__c mObj, String propType, String propKey) {
        return getConfigManager(mObj).getPropertyErrorCode(propType, propKey);
    }
    
    public static Boolean isPropertyType(String propType, MergeProperty prop) {
        return propType!=null && propType==prop.name();
    }
    
    public static void readConfiguration(CORE_Merge_Object__c mo) {
        readConfiguration(mo.Id);
    }
    
    public static void readConfiguration(CORE_Merge_Job__c mj) {
        readConfiguration(mj.Merge_Object_gne__c);
    }
    
    public static void readConfiguration(CORE_Merge_Candidate__c mc) {
        readConfiguration(mc.Merge_Object_gne__c);
    }
    
    public static void readConfiguration(Id mergeObjId) {
        if(configManagersCache==null) {
            configManagersCache = new Map<Id,CORE_Merge_Interface.ConfigManagerInterface>();
            Set<Id> parentMObjIds = new Set<Id>();
            List<CORE_Merge_Object__c> parentMergeObjs = [SELECT Parent_Merge_Object_gne__c FROM CORE_Merge_Object__c WHERE ID = :mergeObjId];
            
            for(CORE_Merge_Object__c mObj : parentMergeObjs) {
                parentMObjIds.add(String.isNotBlank(mObj.Parent_Merge_Object_gne__c) ? mObj.Parent_Merge_Object_gne__c : mObj.Id);
            }
            
            List<CORE_Merge_Object__c> mergeObjs = [
                SELECT Id, Name, External_Id_gne__c, Parent_Merge_Object_gne__c, Object_Name_gne__c, Object_Type_gne__c, Order_gne__c,
                    (SELECT Type_gne__c, CreatedDate
                     FROM Merge_Jobs_gne__r
                     WHERE Status_gne__c IN ('Completed') AND Type_gne__c IN ('Merge', 'PopulateCandidates')
                     ORDER BY CreatedDate DESC
                     LIMIT 10)
                FROM CORE_Merge_Object__c
                WHERE Id IN :parentMObjIds OR Parent_Merge_Object_gne__c IN :parentMObjIds 
                ORDER BY Parent_Merge_Object_gne__c, Order_gne__c
            ];
            
            List<CORE_Merge_Configuration__c> mergeConfigRecs = [
                SELECT Merge_Object_gne__c, Merge_Object_gne__r.Id, Merge_Object_gne__r.External_Id_gne__c, Merge_Object_gne__r.Parent_Merge_Object_gne__c,
                    Type_gne__c, Key_gne__c, Value_gne__c, Value_json_gne__c, Error_Code_gne__c, Object_Type_calc_gne__c, Type_Key_calc_gne__c
                FROM CORE_Merge_Configuration__c
                WHERE Merge_Object_gne__c IN :mergeObjs AND Active_gne__c = true AND Type_gne__c <> null AND Key_gne__c <> null
            ];
            
            Map<Id,List<CORE_Merge_Configuration__c>> mergeConfigRecsMap = new Map<Id,List<CORE_Merge_Configuration__c>>();
            
            for(CORE_Merge_Configuration__c configRec : mergeConfigRecs) {
                if(!mergeConfigRecsMap.containsKey(configRec.Merge_Object_gne__c)) {
                    mergeConfigRecsMap.put(configRec.Merge_Object_gne__c, new List<CORE_Merge_Configuration__c>());
                }
                
                mergeConfigRecsMap.get(configRec.Merge_Object_gne__c).add(configRec);
            }
            
            Map<String,CORE_Merge_Configuration__c> parentConfigRecsMap = null;
            ConfigManager cManager = new ConfigManager();
            
            for(CORE_Merge_Object__c mObj : mergeObjs) {
                Map<String,CORE_Merge_Configuration__c> configRecsMap = new Map<String,CORE_Merge_Configuration__c>();
                
                if(parentConfigRecsMap!=null && mObj.Parent_Merge_Object_gne__c!=null) {
                    configRecsMap.putAll(parentConfigRecsMap);
                }
                
                if(mergeConfigRecsMap.containsKey(mObj.Id)) {
                    for(CORE_Merge_Configuration__c configRec : mergeConfigRecsMap.get(mObj.Id)) {
                        configRecsMap.put(cManager.getPropertyKey(configRec), configRec);
                    }
                }
                
	            intReadConfiguration(mObj, configRecsMap);
	            
	            if(mObj.Parent_Merge_Object_gne__c==null) {
	                parentConfigRecsMap = configRecsMap;
	            }
            }
        }
    }
    
    public static CORE_Merge_Interface.AdminModeManagerInterface getAdminModeManager() {
        if(adminModeManager==null) {
            adminModeManager = new List<CORE_Merge_Interface.AdminModeManagerInterface>();
            
            List<CORE_Merge_Configuration__c> adminManagerConfigs = [
                SELECT Value_gne__c
                FROM CORE_Merge_Configuration__c
                WHERE Active_gne__c = true
                    AND Type_gne__c = :MergeProperty.AdminModeManager.name()
                LIMIT 1
            ];
            
            for(CORE_Merge_Configuration__c configRec : adminManagerConfigs) {
                adminModeManager.add((CORE_Merge_Interface.AdminModeManagerInterface)getCustomClassInstance(configRec.Value_gne__c));
            }
        }
        
        return adminModeManager.isEmpty() ? null : adminModeManager[0];
    }
    
    private static void intReadConfiguration(CORE_Merge_Object__c mObj, Map<String,CORE_Merge_Configuration__c> configRecsMap) {
        cacheMergeObject(mObj);
        CORE_Merge_Interface.ConfigManagerInterface configManager = createConfigManagerInstance(configRecsMap);
        cacheConfigManager(mObj, configManager);
        
        for(CORE_Merge_Configuration__c propRec : configRecsMap.values()) {
            configManager.readProperty(propRec);
        }
    }
    
    private static void cacheMergeObject(CORE_Merge_Object__c mObj) {
        if(mergeObjectsCache==null) {
            mergeObjectsCache = new Map<String,CORE_Merge_Object__c>();
        }
        
        mergeObjectsCache.put(mObj.External_Id_gne__c, mObj);
        mergeObjectsCache.put(mObj.Id, mObj);
    }
    
    private static CORE_Merge_Configuration__c getConfigRecord(Map<String,CORE_Merge_Configuration__c> configRecsMap, MergeProperty propName) {
        return configRecsMap.get(propName.name().toUpperCase());
    }
    
    private static CORE_Merge_Interface.ConfigManagerInterface createConfigManagerInstance(Map<String,CORE_Merge_Configuration__c> configRecsMap) {
        CORE_Merge_Interface.ConfigManagerInterface configManager = new ConfigManager();
        CORE_Merge_Configuration__c configRec = getConfigRecord(configRecsMap, MergeProperty.CustomConfigManager);

        if(configRec!=null && String.isNotBlank(configRec.Value_gne__c)) {
	        try {
	            configManager = (CORE_Merge_Interface.ConfigManagerInterface)Type.forName(configRec.Value_gne__c).newInstance();
	        } catch(Exception ex) {
	            throw new MergeConfigurationException(ERROR_MESSAGE_CANNOT_READ_PROPERTY, configRec.Type_Key_calc_gne__c); 
	        }
        }
        
        return configManager;
    }
    
    private static void cacheConfigManager(CORE_Merge_Object__c mObj, CORE_Merge_Interface.ConfigManagerInterface cManager) {
        configManagersCache.put(mObj.Id, cManager);
    }
    
    private static CORE_Merge_Interface.ConfigManagerInterface getConfigManager(CORE_Merge_Object__c mObj) {
        readConfiguration(mObj.Id);
        return configManagersCache.containsKey(mObj.Id) ? configManagersCache.get(mObj.Id) : new ConfigManager();
    }
    
    @TestVisible private static Object getCustomClassInstance(String className) {
        if(customClassInstances==null) {
            customClassInstances = new Map<String,Object>();
        }
        
        String classNameUpperCase = className.toUpperCase();
        
        if(!customClassInstances.containsKey(classNameUpperCase)) {
            customClassInstances.put(classNameUpperCase, Type.forName(className).newInstance());
        }
            
        return customClassInstances.get(classNameUpperCase);
    }
    
    private static Id getOwnerId(String ownerName) {
        if(ownerIdCache==null) {
            ownerIdCache = new Map<String,Id>();
        }
        
        String ownerNameUpperCase = ownerName.toUpperCase();
        
        if(!ownerIdCache.containsKey(ownerNameUpperCase)) {
            Id ownerId = null;
            
            for(User u : [SELECT Id FROM User WHERE IsActive = true AND Name = :ownerName LIMIT 1]) {
               ownerId = u.Id;
            }
            
            if(ownerId==null) {
                ownerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :ownerName LIMIT 1].Id;
            }
            
            ownerIdCache.put(ownerNameUpperCase, ownerId);
        }
        
        return ownerIdCache.get(ownerNameUpperCase);
    }

    private static Id getRecordTypeId(String sObjectName, String recordTypeDevName) {
        if(recordTypeIdCache==null) {
            recordTypeIdCache = new Map<String,Id>();
        }
        
        String rtUpperCase = recordTypeDevName.toUpperCase();
        
        if(!recordTypeIdCache.containsKey(rtUpperCase)) {
            Id rtId = [SELECT Id FROM RecordType WHERE SObjectType = :sObjectName AND DeveloperName = :recordTypeDevName LIMIT 1].Id;
            
            recordTypeIdCache.put(rtUpperCase, rtId);
        }
        
        return recordTypeIdCache.get(rtUpperCase);
    }
    
    public static Schema.DescribeSObjectResult getSObjectDescribe(String sObjectName) {
        if(sObjectDescribe==null) {
            sObjectDescribe = new Map<String,Schema.DescribeSObjectResult>();
        }
        
        String sObjNameUC = sObjectName.toUpperCase();
        
        if(!sObjectDescribe.containsKey(sObjNameUC)) {
            sObjectDescribe.put(sObjNameUC, Schema.getGlobalDescribe().get(sObjNameUC).getDescribe());
        }
        
        return sObjectDescribe.get(sObjNameUC);
    }
    
    public static Map<String,Schema.ChildRelationship> getChildRelationshipMap(String sObjectName) {
        if(childRelationshipMap==null) {
            childRelationshipMap = new Map<String,Map<String,Schema.ChildRelationship>>();
        }
        
        String sObjNameUC = sObjectName.toUpperCase();
        
        if(!childRelationshipMap.containsKey(sObjNameUC)) {
            childRelationshipMap.put(sObjNameUC, new Map<String,Schema.ChildRelationship>());
            
            List<Schema.ChildRelationship> childRelationship = getSObjectDescribe(sObjectName).getChildRelationships();
            
            for (Schema.ChildRelationship child : childRelationship) {
                // Workaround for Salesforce Case #10482798 - Some Schema Child Relationship Names are not set
                if(String.isNotBlank(child.getRelationshipName())) {
                    childRelationshipMap.get(sObjNameUC).put(getRelationshipName(child.getRelationshipName()), child);
                }
            }
        }
        
        return childRelationshipMap.get(sObjNameUC);
    }
    
    private static String getRelationshipName(String rName) {
        return Pattern.matches('^R00[^_]+(?!__r)$', rName) ? rName : rName.toUpperCase();
    }
    
    public virtual class ConfigManager implements CORE_Merge_Interface.ConfigManagerInterface {
        protected Map<String,Object> propertyCache;
        protected Map<String,Set<String>> propertyByTypeCache;
        protected Map<String,Object> propertyAttributes;
        protected Map<String,String> propertyErrorCodesCache;
        
        public ConfigManager() {}
    
        public virtual void readProperty(CORE_Merge_Configuration__c propRec) {
            if(propertyCache==null) {
                propertyCache = new Map<String,Object>();
                propertyByTypeCache = new Map<String,Set<String>>();
            }
            
            Object propValue = null;
            
            try {
                propValue = intReadProperty(propRec);
                readPropertyAttributes(propRec);
                readErrorCode(propRec);
            } catch(Exception ex) {
                handleReadPropertyException(ex, propRec);
            }
            
            propertyCache.put(getPropertyKey(propRec), propValue);
            
            String propKey = propRec.Key_gne__c.toUpperCase();
            String propType = getPropertyType(propRec);
            
            if(!propertyByTypeCache.containsKey(propType)) {
                propertyByTypeCache.put(propType, new Set<String>());
            }
            
            propertyByTypeCache.get(propType).add(propKey);
        }
        
        protected virtual Object intReadProperty(CORE_Merge_Configuration__c propRec) {
            Object result = null;
            Object propAttributes = null;
            String propValue = propRec.Value_gne__c;
            String propJsonValue = propRec.Value_json_gne__c;
            String propType = getPropertyType(propRec);
            String key = getPropertyKey(propRec);
            
            if((propType==MergeProperty.SupportEmail.name() || propType==MergeProperty.ReportEmail.name()) && (String.isNotBlank(propValue) || String.isNotBlank(propJsonValue))) {
                List<String> resultAsList = String.isNotBlank(propValue) ? propValue.split(PROPERTY_LIST_SEPARATOR) : new List<String>();
                resultAsList.addAll(String.isNotBlank(propJsonValue) ? (List<String>)JSON.deserialize(propJsonValue, List<String>.class) : new List<String>());
                result = resultAsList;
            } else if(propType==MergeProperty.ArchiveOwner.name()) {
                result = getOwnerId(propValue);
            } else if(propType==MergeProperty.ArchiveRecordType.name()) {
                result = getRecordTypeId(propRec.Object_Type_calc_gne__c, propValue);
            } else if(BOOLEAN_SETTINGS.contains(propType)) {
                result = String.isNotBlank(propValue) && Boolean.valueOf(propValue)==true; 
            } else if(PROPERTY_VALUE_CUSTOM_TYPE_MAP.containsKey(propType)) {
                result = getCustomClassInstance(propValue);
            } else if(PROPERTY_JSON_VALUE_CUSTOM_TYPE_MAP.containsKey(propType)) {
                System.Type jsonType = PROPERTY_JSON_VALUE_CUSTOM_TYPE_MAP.get(propType);
                
                if(jsonType==SObject.class && String.isNotBlank(propJsonValue)) {
                    jsonType = Type.forName(propRec.Object_Type_calc_gne__c);
                }
                
                propJsonValue = replaceBuildInVariables(propJsonValue, propRec);
                result = String.isNotBlank(propJsonValue) ? JSON.deserialize(propJsonValue, jsonType) : null;
                
                if(jsonType==RelationshipConfigWrapper.class && result==null) {
                    result = new RelationshipConfigWrapper();
                } else if(jsonType==PopulateCandidateConfig.class && result==null) {
                    result = new PopulateCandidateConfig();
                } else if(jsonType==List<SchedulerConfig>.class && result==null) {
                    result = new List<SchedulerConfig>();
                }
                
                if(result!=null && result instanceof CORE_Merge_Interface.RelationshipConfigInterface) {
                    CORE_Merge_Interface.RelationshipConfigInterface rcw = (CORE_Merge_Interface.RelationshipConfigInterface)result;
                    String relName = getRelationshipName(propRec.Key_gne__c);
                    rcw.setRelationshipName(getRelationshipName(propRec.Key_gne__c));
                    getChildRelationshipMap(propRec.Object_Type_calc_gne__c).get(relName).getField();
                } else if(result!=null && result instanceof List<SchedulerConfig>) {
                    List<SchedulerConfig> sConfigs = (List<SchedulerConfig>)result;
                    
                    for(SchedulerConfig sConfig : sConfigs) {
                        sConfig.validateJobType();
                        sConfig.parseCronExpression();
                    }
                }
            } else {
                result = propValue;
            }
            
            if(propType==MergeProperty.AdminModeManager.name()) {
                adminModeManager = null;
            }
            
            return result;
        }
        
        private String replaceBuildInVariables(String jsonValue, CORE_Merge_Configuration__c propRec) {
            if(String.isNotBlank(jsonValue)) {
                jsonValue = jsonValue.replaceAll('\\{\\{UserInfo\\.getUserId\\(\\)\\}\\}',UserInfo.getUserId());
                
                if(Pattern.matches('.*\\{\\{LAST_MERGE_JOB_DATETIME\\}\\}.*', jsonValue)) {
                    CORE_Merge_Object__c mObj = getMergeObject(propRec.Merge_Object_gne__c);
                    DateTime lastMergeJobDate = getLastMergeJobData(mObj, 'Merge');
                    jsonValue = jsonValue.replaceAll('\\{\\{LAST_MERGE_JOB_DATETIME\\}\\}', lastMergeJobDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
                }
                
                if(Pattern.matches('.*\\{\\{LAST_POPULATE_JOB_DATETIME\\}\\}.*', jsonValue)) {
                    CORE_Merge_Object__c mObj = getMergeObject(propRec.Merge_Object_gne__c);
                    DateTime lastMergeJobDate = getLastMergeJobData(mObj, 'PopulateCandidates');
                    jsonValue = jsonValue.replaceAll('\\{\\{LAST_POPULATE_JOB_DATETIME\\}\\}', lastMergeJobDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
                }
            }
            
            return jsonValue;
        }
        
        protected virtual DateTime getLastMergeJobData(CORE_Merge_Object__c mObj, String jobType) {
            DateTime lastMergeJobDate = null;
            
            if(mObj!=null && mObj.Merge_Jobs_gne__r!=null && !mObj.Merge_Jobs_gne__r.isEmpty()) {
                for(CORE_Merge_Job__c mJob : mObj.Merge_Jobs_gne__r) {
                    if(mJob.Type_gne__c==jobType) {
                        lastMergeJobDate = mJob.CreatedDate;
                        break;
                    }
                }
            }
            
            return lastMergeJobDate!=null ? lastMergeJobDate : DateTime.now().addDays(-30);
        }
        
        protected virtual void readPropertyAttributes(CORE_Merge_Configuration__c propRec) {
            String propType = getPropertyType(propRec);
            String propJsonValue = propRec.Value_json_gne__c;
            
            if(String.isNotBlank(propJsonValue) && !PROPERTY_JSON_VALUE_CUSTOM_TYPE_MAP.containsKey(propType)) {
                Object propAttributes = JSON.deserializeUntyped(propJsonValue);
                
                if(propAttributes!=null) {
                    if(propertyAttributes==null) {
                        propertyAttributes = new Map<String,Object>();
                    }
                    
                    propertyAttributes.put(getPropertyKey(propRec), propAttributes);
                }
            }
        }
        
        protected virtual void readErrorCode(CORE_Merge_Configuration__c propRec) {
            String propType = getPropertyType(propRec);
            
            if(propType!=null && VALIDATION_SETTINGS.contains(propType)) {
                if(propertyErrorCodesCache==null) {
                    propertyErrorCodesCache = new Map<String,String>();
                }
                
                propertyErrorCodesCache.put(getPropertyKey(propRec), propRec.Error_Code_gne__c);
            }
        }
        
        public virtual Object getPropertyValue(String propKey) {
            return propertyCache!=null && propertyCache.containsKey(propKey.toUpperCase()) ?  propertyCache.get(propKey.toUpperCase()) : null;
        }
        
        public virtual Object getPropertyValue(String propType, String propKey) {
            String key = getPropertyKey(propType, propKey);
            return getPropertyValue(key);
        }
        
        public Object getPropertyAttributes(String propKey) {
            return propertyAttributes!=null ? propertyAttributes.get(propKey.toUpperCase()) : null;
        }
        
        public Object getPropertyAttributes(String propType, String propKey) {
            String key = getPropertyKey(propType, propKey);
            return getPropertyAttributes(key);
        }
        
        public virtual String getPropertyKey(CORE_Merge_Configuration__c propRec) {
            return getPropertyKey(propRec.Type_gne__c, propRec.Key_gne__c);
        }
        
        public virtual String getPropertyKey(String pType, String pKey) {
            return pType==pKey ? pType.toUpperCase() : String.format('{0}_{1}', new String[]{pType, pKey}).toUpperCase();
        }
        
        public virtual String getPropertyType(CORE_Merge_Configuration__c propRec) {
            return propRec.Type_gne__c.toUpperCase();
        }
        
        public virtual Set<String> getPropertyKeysByType(String pType) {
            return propertyByTypeCache!=null && propertyByTypeCache.containsKey(pType.toUpperCase()) ? propertyByTypeCache.get(pType.toUpperCase()) : new Set<String>();
        }
        
        public virtual Map<String,Object> getPropertiesByType(String pType) {
            Map<String,Object> propsMap = new Map<String,Object>();
            
            for(String pKey : getPropertyKeysByType(pType)) {
                propsMap.put(pKey,getPropertyValue(pType, pKey));
            }
            
            return propsMap;
        }
        
        public virtual Map<String,Map<String,Object>> getPropertiesByTypes(Set<String> propTypes) {
            Map<String,Map<String,Object>> propsMap = new Map<String,Map<String,Object>>();
            
            if(propertyByTypeCache!=null) {
                for(String pType : propTypes) {
                    String pTypeUpper = pType.toUpperCase();
                    if(propertyByTypeCache.containsKey(pTypeUpper)) {
                        Map<String,Object> propWithValues = new Map<String,Object>();
                        propsMap.put(pTypeUpper, propWithValues);
                        
                        for(String pKey : propertyByTypeCache.get(pTypeUpper)) {
                            propWithValues.put(pKey,getPropertyValue(pType, pKey));
                        }
                    }
                }
            }
            
            return propsMap;
        }
        
        public virtual String getPropertyErrorCode(String pType, String pKey) {
            return propertyErrorCodesCache!=null ? propertyErrorCodesCache.get(getPropertyKey(pType, pKey)) : null;
        }
        
        protected virtual void handleReadPropertyException(Exception ex, CORE_Merge_Configuration__c propRec) {
            throw new MergeConfigurationException(ERROR_MESSAGE_CANNOT_READ_PROPERTY, propRec.Type_Key_calc_gne__c);
        }
    }
    
    public virtual class RelationshipConfigWrapper implements CORE_Merge_Interface.RelationshipConfigInterface {
        protected String relationshipName;
        protected Set<String> queryFields;
        protected String queryWhere;
        protected String queryOrderBy;
        protected Integer queryLimit;
        protected String archiveType;
        
        public RelationshipConfigWrapper() {}
        
        public RelationshipConfigWrapper(String relationshipName, Set<String> queryFields, String queryWhere, String queryOrderBy) {
            this.relationshipName = relationshipName;
            this.queryFields = queryFields;
            this.queryWhere = queryWhere;
            this.queryOrderBy = queryOrderBy;
        }
        
        public Set<String> getQueryFields() {
            return this.queryFields==null ? new Set<String>() : this.queryFields;
        }
        
        public String getQueryWhere() {
            return this.queryWhere;
        }
        
        public String getQueryOrderBy() {
            return this.queryOrderBy;
        }
        
        public Integer getQueryLimit() {
            return this.queryLimit;
        }
        
        public String getRelationshipName() {
            return this.relationshipName;
        }
        
        public void setRelationshipName(String relationshipName) {
            this.relationshipName = relationshipName;
        }
        
        public String getArchiveType() {
            return this.archiveType;
        }
    }
    
    public class PopulateCandidateConfig implements CORE_Merge_Interface.PopulateCandidateConfigInterface {
        private Boolean enabled;
        private Boolean populateFromParentEnabled;
        private Boolean mergeFromParentEnabled;
        private List<String> querySortBy;
        private String queryUniqueField;
        private String queryWhere;
        private String queryBatchWhere;
        
        public PopulateCandidateConfig() {}
        
        public Boolean isEnabled() {
            return this.enabled==true;
        }
        
        public Boolean isPopulateFromParentEnabled() {
            return this.populateFromParentEnabled==true;
        }
        
        public Boolean isMergeFromParentEnabled() {
            return this.mergeFromParentEnabled==true;
        }
        
        public List<String> getQuerySortBy() {
            return this.querySortBy!=null ? this.querySortBy : new List<String>();
        }
        
        public String getQueryUniqueField() {
            return this.queryUniqueField;
        }
        
        public String getQueryWhere() {
            return this.queryWhere;
        }
        
        public String getQueryBatchWhere() {
            return this.queryBatchWhere;
        } 
    }
    
    public class SchedulerConfig implements CORE_Merge_Interface.SchedulerConfigInterface {
        private String cronExpression;
        private String jobType;
        private Integer scopeLimit;
        private Long durationLimit;
        private Map<String,String> jobArguments;
        
        private transient Set<Integer> validDaysOfMonth;
        private transient Set<Integer> validMonths;
        private transient Set<Integer> validDaysOfWeek;
        
        public SchedulerConfig() {}
        
        public String getCronExpression() {
            return this.cronExpression;
        }
        
        public String getJobType() {
            return this.jobType;
        }
        
        public Integer getScopeLimit() {
            return this.scopeLimit;
        }
        
        public Long getDurationLimit() {
            return this.durationLimit;
        }
        
        public Map<String,String> getJobArguments() {
            return this.jobArguments!=null ? this.jobArguments : new Map<String,String>();
        }
        
        public void validateJobType() {
            if(!new Set<String>{'MERGE', 'POPULATECANDIDATES'}.contains(getJobType().toUpperCase())) {
                throw new MergeConfigurationException('Wrong Job Type');
            }
        }
        
        public void parseCronExpression() {
            String[] columns = getCronExpression().split(CRON_COLUMN_SEPARATOR);
            String dayOfMonthData = columns[0];
            String monthData = columns[1];
            String dayOfWeekData = columns[2];
                
            validDaysOfMonth = getAvailableValues(dayOfMonthData, 1,31, null);
            validMonths = getAvailableValues(monthData, 1,12, CRON_ORDERED_MONTH_NAMES);
            validDaysOfWeek = getAvailableValues(dayOfWeekData, 1,7, CRON_ORDERED_DAY_NAMES);
        }
        
        public Boolean matches(DateTime dTime) {
            Integer dayOfMonth = dTime.day();
            Integer month = dTime.month();
            Integer dayOfWeek = CRON_ORDERED_DAY_NAMES.indexOf(dTime.format('E').toUpperCase())/4 + 1;
            
            Boolean isLastDayOfMonth = dTime.addDays(1).day() < dayOfMonth;
            
            Boolean dayOfMothMatches = validDaysOfMonth.isEmpty() || validDaysOfMonth.contains(dayOfMonth) || (isLastDayOfMonth && isLastDayOfMonthAvailable(dayOfMonth));
            Boolean mothMatches = validMonths.isEmpty() || validMonths.contains(month);
            Boolean dayOfWeekMatches = validDaysOfWeek.isEmpty() || validDaysOfWeek.contains(dayOfWeek);
            
            return dayOfMothMatches && mothMatches && dayOfWeekMatches;
        }
        
        private Set<Integer> getAvailableValues(String inputData, Integer startIdx, Integer endIdx, String orderedTextValues) {
            // Empty set means that all values are available
            Set<Integer> availableValues = new Set<Integer>();
            
            if(!inputData.equals(CRON_ALL_VALUES_CHAR) && !inputData.equals(CRON_NO_SPECIFIC_VALUE_CHAR)) {
                for(String listElement : inputData.split(CRON_LIST_SEPARATOR)) {
                    String ulistElement = listElement.toUpperCase();
                    String rangeStartElement = ulistElement;
                    String rangeEndElement = ulistElement;
                    
                    if(ulistElement.contains(CRON_RANGE_SEPARATOR)) {
                        String[] range = ulistElement.split(CRON_RANGE_SEPARATOR);
                        rangeStartElement = range[0];
                        rangeEndElement = range[1];
                    }
                    
                    Integer elementStartIdx = null, elementEndIdx = null;
                    
                    elementStartIdx = (orderedTextValues!=null && rangeStartElement.length()==3 && orderedTextValues.indexOf(rangeStartElement)!=-1) 
                        ? (orderedTextValues.indexOf(rangeStartElement)/4+1)
                        : Integer.valueOf(rangeStartElement);
                            
                    elementEndIdx = (orderedTextValues!=null && rangeStartElement.length()==3 && orderedTextValues.indexOf(rangeEndElement)!=-1) 
                        ? (orderedTextValues.indexOf(rangeEndElement)/4+1)
                        : Integer.valueOf(rangeEndElement);
                            
                    for(Integer i = elementStartIdx; i<=elementEndIdx; i++) {
                        availableValues.add(i);
                    }
                }
            } 
            
            return availableValues;
            
        }
        
        private Boolean isLastDayOfMonthAvailable(Integer lastDayOfMonth) {
            List<Integer> validDays = new List<Integer>(validDaysOfMonth);
            validDays.sort();
            return lastDayOfMonth < validDays[validDays.size()-1];
        }
    }
    
    public class MergeConfigurationException extends Exception {
        public MergeConfigurationException(String text, String propType) {
            this(String.format('[Merge Configuration Error] Property: {0}, Message: {1}', new String[]{propType, text}));
        }
    }
}