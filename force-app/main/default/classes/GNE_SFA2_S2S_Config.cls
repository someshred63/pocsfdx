public with sharing class GNE_SFA2_S2S_Config {
    public Enum ConfigItem {S2SEnabled, S2SConnection, S2SConnectionUser, DisabledFeatures, S2SConnectedObjectsNeedCleanup, SupportEmail, OrgWideEmailAddress, NamedCredentials, S2SLogLevel, S2SLogDuplicateDatePrecision, DebugEnabled, FeatureServiceNames, FeatureServiceProperties, Error}
    public Enum LogLevel {ALL, ERROR}
    
    public static final String RECORD_TYPE_HCP = 'Professional_vod';
    public static final String RECORD_TYPE_ADDR_REP = 'RepMaintained';
    public static final String RECORD_TYPE_ADDR_COMPANY = 'CompanyMaintained';
    
    private static Boolean isS2SEnabled;
    private static Set<String> disabledFeatures;
    private static Set<String> logLevels;
    private static Boolean isDebugEnabled;
    private static Map<String,String> configItemValues;
    private static List<Id> orgWideEmailAddressId;
    private static Id accountOwnerId;
    private static Id accountRecordTypeId;
    private static Map<String,Id> connectionIdsMap;
    
    public static Boolean isFeatureEnabled(String feature) {
        return isS2SEnabled() && (feature==null || !getDisabledFeatures().contains(feature.toUpperCase()));
    }
    
    public static Boolean isS2SEnabled() {
        if(isS2SEnabled==null) {
            isS2SEnabled = getConfigItemBooleanValue(ConfigItem.S2SEnabled);
        }
        
        return isS2SEnabled;
    }
    
    public static Set<String> getDisabledFeatures() {
        if(disabledFeatures==null) {
            disabledFeatures = new Set<String>();
            
            Set<String> dFeaturesSet = (Set<String>)getConfigItemJSONValue(ConfigItem.DisabledFeatures, Set<String>.class);
            
            for(String feature : (dFeaturesSet!=null ? dFeaturesSet : new Set<String>())) {
                if(feature!=null) {
                    disabledFeatures.add(feature.toUpperCase());
                }
            }
        }
        
        return disabledFeatures;
    }
    
    public static Boolean isLogLevelEnabled(LogLevel level) {
        return isLogLevelEnabled(level, null);
    }
    
    public static Boolean isLogLevelEnabled(LogLevel level, String featureName) {
        if(logLevels==null) {
            logLevels = new Set<String>();
            Set<String> s2sLogLevels = (Set<String>)getConfigItemJSONValue(ConfigItem.S2SLogLevel, Set<String>.class);
            
            for(String ll : (s2sLogLevels!=null ? s2sLogLevels : new Set<String>())) {
                if(ll!=null) {
                    logLevels.add(ll.toUpperCase());
                }
            }
        }
        
        return logLevels.contains(level.name().toUpperCase()) 
            || (featureName!=null && logLevels.contains((featureName + level.name()).toUpperCase()))
            || (level!=LogLevel.ALL ? isLogLevelEnabled(LogLevel.ALL, featureName) : false);
    }
    
    public static Boolean isDebugEnabled() {
        if(isDebugEnabled==null) {
            isDebugEnabled = getConfigItemBooleanValue(ConfigItem.DebugEnabled);
        }
        
        return isDebugEnabled;
    }
    
    public static String getNamedCredential(String extSystem, String featureName) {
        Map<String,String> namedCredentials = (Map<String,String>)getConfigItemJSONValue(ConfigItem.NamedCredentials, Map<String,String>.class);
        return namedCredentials!=null ? (String.isNotBlank(featureName) && namedCredentials.containsKey(extSystem + featureName) ? namedCredentials.get(extSystem + featureName) : namedCredentials.get(extSystem)) : null;
    }
    
    public static String getServiceName(String featureName) {
        Map<String,String> serviceNames = (Map<String,String>)getConfigItemJSONValue(ConfigItem.FeatureServiceNames, Map<String,String>.class);
        return serviceNames!=null ? serviceNames.get(featureName) : null;
    }
    
    public static Map<String,String> getServiceProperties(String extSystem, String featureName, String serviceName) {
        String key1 = extSystem + featureName + serviceName;
        String key2 = featureName + serviceName;
        String key3 = extSystem + featureName;
        String key4 = featureName;
        
        Map<String,Map<String,String>> serviceProps = (Map<String,Map<String,String>>)getConfigItemJSONValue(ConfigItem.FeatureServiceProperties, Map<String,Map<String,String>>.class);
        Map<String,String> result = serviceProps!=null ? serviceProps.get(key1) : null;
        result = serviceProps!=null && result==null ? serviceProps.get(key2) : result;
        result = serviceProps!=null && result==null ? serviceProps.get(key3) : result;
        result = serviceProps!=null && result==null ? serviceProps.get(key4) : result;
        return result!=null ? result : new Map<String,String>();
    }
    
    public static List<String> getSupportEmails(String featureName) {
        List<String> result = new List<String>();
        Set<String> visitedEmails = new Set<String>();
        Map<String,List<String>> supportEmails = (Map<String,List<String>>)getConfigItemJSONValue(ConfigItem.SupportEmail, Map<String,List<String>>.class);
        
        if(supportEmails!=null) {
	        for(String mask : supportEmails.keySet()) {
	            List<String> emails = supportEmails.get(mask);
	
	            if(emails!=null && (mask == 'ALL' || (String.isNotBlank(featureName) && Pattern.matches('(?i).*' + mask + '.*', featureName)))) {
	                for(String email : emails) {
	                    if(String.isNotBlank(email) && visitedEmails.add(email.toUpperCase())) {
	                        result.add(email);
	                    }
	                }
	            }
	        }
        }
        
        return result;
    }
    
    public static Id getOrgWideEmailAddressId() {
        if(orgWideEmailAddressId==null) {
            orgWideEmailAddressId = new List<Id>{null};
            String orgWideEmailAddress = getConfigItemValue(ConfigItem.OrgWideEmailAddress);
            
            if(String.isNotBlank(orgWideEmailAddress)) {
                for(OrgWideEmailAddress owea : [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName= :orgWideEmailAddress LIMIT 1]) {
                    orgWideEmailAddressId[0] = owea.Id;
                }
            }
        }
        
        return orgWideEmailAddressId[0];
    }
    
    public static Map<String,Id> getConnectionIdsMap() {
        if(connectionIdsMap==null) {
            connectionIdsMap = new Map<String,Id>();
            Map<String,String> connectionNamesMap = (Map<String,String>)getConfigItemJSONValue(ConfigItem.S2SConnection, Map<String,String>.class);
            Set<String> connectionNames = connectionNamesMap!=null ? new Set<String>(connectionNamesMap.values()) : new Set<String>();
            
            if(!connectionNames.isEmpty()) {
                List<PartnerNetworkConnection> connections = [SELECT Id, ConnectionName FROM PartnerNetworkConnection WHERE ConnectionStatus = 'Accepted' AND ConnectionName IN :connectionNames ORDER BY Id DESC];
                
                for(PartnerNetworkConnection connection : connections) {
                    for(String extSystem : connectionNamesMap.keySet()) {
                        if(connection.ConnectionName==connectionNamesMap.get(extSystem)) {
                            connectionIdsMap.put(extSystem.toUpperCase(), connection.Id);
                        }
                    }
                }
            }
        }
        
        return connectionIdsMap;
    }
    
    public static Set<Id> getConnectionIds() {
        return new Set<Id>(getConnectionIdsMap().values());
    }
    
    public static String getConnectionId(String extSystem) {
        return getConnectionIdsMap().get(extSystem.toUpperCase());
    }
    
    public static Set<String> getConnectedObjectsNeedCleanup() {
        Set<String> result = new Set<String>();
        List<String> cleanupObjectsList = (List<String>)getConfigItemJSONValue(ConfigItem.S2SConnectedObjectsNeedCleanup, List<String>.class);
        
        for(String sObjName : (cleanupObjectsList!=null ? cleanupObjectsList : new List<String>())) {
            if(String.isNotBlank(sObjName)) {
                result.add(sObjName.toUpperCase());
            }
        }
        
        return result;
    }
    
    public static Boolean isS2SConnectionUser(String name) {
        return name==getConfigItemValue(ConfigItem.S2SConnectionUser);
    }
    
    public static Boolean getConfigItemBooleanValue(ConfigItem cItem) {
        Boolean result = false;
        String valueAsString = getConfigItemValue(cItem);
        result = String.isNotBlank(valueAsString) && new Set<String>{'1', 'TRUE', 'YES'}.contains(valueAsString.toUpperCase());
        return result;
    }
    
    public static List<String> getConfigItemListValue(ConfigItem cItem) {
        List<String> result = new List<String>();
        String valueAsString = getConfigItemValue(cItem);
        result = String.isNotBlank(valueAsString) ? valueAsString.split(';') : result;
        return result;
    }
    
    public static Object getConfigItemJSONValue(ConfigItem cItem) {
        return getConfigItemJSONValue(cItem.name(), null);
    }
    
    public static Object getConfigItemJSONValue(String cItemName) {
        return getConfigItemJSONValue(cItemName, null);
    }
    
    public static Object getConfigItemJSONValue(ConfigItem cItem, System.Type classType) {
        return getConfigItemJSONValue(cItem.name(), classType);
    }
    
    public static Object getConfigItemJSONValue(String cItemName, System.Type classType) {
        Object result;
        String valueAsString = getConfigItemValue(cItemName);
        
        if(String.isNotBlank(valueAsString)) {
            try {
                result = classType==null ? JSON.deserializeUntyped(valueAsString) : JSON.deserialize(valueAsString, classType);    
            } catch(Exception ex) {}
        }
        
        return result;
    }
    
    public static String getConfigItemValue(ConfigItem cItem) {
        return getConfigItemValue(cItem.name());
    }
    
    public static String getConfigItemValue(String cItemName) {
        if(configItemValues==null) {
            configItemValues = new Map<String,String>();
            
            Map<String,GNE_SFA2_S2S_Config_Items_gne__c> configRecs = GNE_SFA2_S2S_Config_Items_gne__c.getAll();
            List<String> cNames = new List<String>(configRecs.keySet());
            cNames.sort();
            
            for(String cName : cNames) {
                GNE_SFA2_S2S_Config_Items_gne__c cRec = configRecs.get(cName);
                
                if(cRec.Is_Active_gne__c==true) {
                    String cKey = cRec.Key_gne__c.toUpperCase();
                    configItemValues.put(cKey, (configItemValues.get(cKey)!=null ? configItemValues.get(cKey) : '') + cRec.Value_gne__c);    
                }
            } 
        }
        
        String result = configItemValues.get(cItemName.toUpperCase());
        return String.isNotBlank(result) ? result : null;
    }
    
    public static void setConfigItemValue(String key, String value) {
        GNE_SFA2_S2S_Config_Items_gne__c configItem = GNE_SFA2_S2S_Config_Items_gne__c.getAll().get(key);

        if(configItem==null) {
            configItem = new GNE_SFA2_S2S_Config_Items_gne__c(Name = key);
        }
        
        configItem.Key_gne__c = key;    
        configItem.Value_gne__c = value;
        configItem.Is_Active_gne__c = true;
        
        if(configItemValues!=null) {
             configItemValues.put(configItem.Key_gne__c.toUpperCase(), configItem.Value_gne__c);
        }
        
        Database.upsert(configItem, false);
    }
    
    public static String getErrorMessage(String errorCode) {
        String result = getConfigItemValue(ConfigItem.Error.name() + errorCode);
        
        if(result!=null && result.containsIgnoreCase('LABEL.')) {
            String labelName = result.toUpperCase().substringAfter('LABEL.');
            List<ExternalString> labels = [SELECT Value FROM ExternalString WHERE Name = :labelName LIMIT 1];
            result = !labels.isEmpty() ? labels[0].Value : result;
        }
        
        return String.isNotBlank(result) ? result : errorCode;  
    }
    
    public static Id getAccountOwnerId() {
        if(accountOwnerId==null) {
            String ownerExtId = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.DefaultRecordOwner);
            
                
            if(ownerExtId!=null) {
                List<User> users = GNE_SFA2_SBC_DAO.getUserByExternalId(ownerExtId);
                accountOwnerId = !users.isEmpty() ? users[0].Id : null;
            }
            
            accountOwnerId = accountOwnerId!=null ? accountOwnerId : UserInfo.getUserId();
        }
        
        return accountOwnerId;     
    }
    
    public static Id getAccountRecordTypeId() {
        if(accountRecordTypeId==null) {
            List<RecordType> rts = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = :RECORD_TYPE_HCP LIMIT 1];
            for(RecordType rt : rts) {
                accountRecordTypeId = rt.Id;
            }
        }
        
        return accountRecordTypeId;
    }
}