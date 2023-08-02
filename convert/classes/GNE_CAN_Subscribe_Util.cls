public without sharing class GNE_CAN_Subscribe_Util {
    
    public class ExceptionInfo {
        public String   stackTrace;
        public String   typeName;
        public String   cause; 
        public Integer  lineNumber;
        public String   message;
        public Boolean	isKnownException;
        public String	codeLevel;
        
        public ExceptionInfo(Exception ex) {
        	isKnownException = false;
            Exception cEx = ex.getCause();
            
            stackTrace  = ex.getStackTraceString();
            typeName    = ex.getTypeName();
            cause       = cEx!=null ? cEx.getMessage() : '';
            lineNumber  = ex.getLineNumber();
            message     = ex.getMessage();
            codeLevel	= GNE_CAN_Subscribe_Util.RUNTIME_ERROR_APEX_CLASS_CODE; 
        }
        
        public ExceptionInfo(KnownException exType) {
        	isKnownException = true;
        	typeName    = exType.name();
        	message		= GNE_CAN_Subscribe_Util.knownExceptionDescriptions.get(exType);
        	codeLevel	= GNE_CAN_Subscribe_Util.SUBSCRIBE_ERROR_CODE;
        }
        
        public ExceptionInfo(Database.Error err) {
        	isKnownException = false;
            Exception ex = new SubscribeException(null);
            stackTrace  = ex.getStackTraceString();
            typeName    = err.getStatusCode().name();
            cause       = '';
            lineNumber  = ex.getLineNumber();
            message     = err.getMessage();
            codeLevel	= GNE_CAN_Subscribe_Util.RUNTIME_ERROR_APEX_TRIGGER_CODE;
        }
        
        public String print() {
            String out = '';
            out += 'TypeName: ' + typeName + '\n';
            out += 'LineNumber: ' + (lineNumber!=null ? String.valueOf(lineNumber) : '') + '\n';
            out += 'Message: ' + message + '\n';
            out += 'Cause: ' + cause + '\n';
            out += 'StackTrace: ' + stackTrace + '\n';
            
            return out;
        }
        
        public void fillApexJobError(Stg_SFA_Subscribe_Apex_Job_Error__c err) {
            err.Error_Description_can__c = isKnownException ? message : print();
            err.Error_Level_can__c = isKnownException ? 'Medium' : 'High';
            err.Error_Type_can__c = typeName;
            err.Code_Type_can__c = codeLevel;
            
        }
    }
    
    public class SubscribeException extends Exception {
    	public List<KnownException> errors;
    	
    	public SubscribeException(List<KnownException> a_errors) {
    		errors = a_errors;
    	}
    }
    
    public Enum FieldMappingUpdateMode {ALWAYS, TARGET_FIELD_NULL, SOURCE_FIELD_NOT_NULL}
    
    public static final String CONFIG_ITEM_NAME_SFDC_DEBUG_LOGGING_LEVEL = 'SFDC_DEBUG_LOGGING_LEVEL';
        
    public static final String CONFIG_ITEM_NAME_HCO_CUSTOMER_CLASS_NAME = 'HCO_CUSTOMER_CLASS_NAME';
    public static final String CONFIG_ITEM_NAME_HCP_CUSTOMER_CLASS_NAME = 'HCP_CUSTOMER_CLASS_NAME';
    public static final String CONFIG_ITEM_NAME_DEPARTMENT_ACCOUNT_TYPE = 'DEPARTMENT_ACCOUNT_TYPE';
    public static final String CONFIG_ITEM_NAME_RECORD_TYPE_HCP = 'RECORD_TYPE_HCP';
    public static final String CONFIG_ITEM_NAME_RECORD_TYPE_HCO = 'RECORD_TYPE_HCO';
    public static final String CONFIG_ITEM_NAME_RECORD_TYPE_HCO_DEPARTMENT = 'RECORD_TYPE_HCO_DEPARTMENT';
    public static final String CONFIG_ITEM_NAME_RECORD_TYPE_ADDRESS_HCP = 'RECORD_TYPE_ADDRESS_HCP';
    public static final String CONFIG_ITEM_NAME_RECORD_TYPE_ADDRESS_HCO = 'RECORD_TYPE_ADDRESS_HCO';
    public static final String CONFIG_ITEM_NAME_ACOUNT_DEFAULT_REGION_CODE = 'ACOUNT_DEFAULT_REGION_CODE';
    public static final String CONFIG_ITEM_NAME_BATCH_SIZE = 'BATCH_SIZE';
    public static final String CONFIG_ITEM_NAME_NOTIFICATION_EMAIL = 'NOTIFICATION_EMAIL';
    public static final String CONFIG_ITEM_NAME_ACCOUNT_INSERT_MODE = 'ACCOUNT_INSERT_MODE';
    public static final String CONFIG_ITEM_NAME_ADDRESS_INSERT_MODE = 'ADDRESS_INSERT_MODE';
    public static final String CONFIG_ITEM_NAME_OWNER_USER_NAME = 'ACCOUNT_OWNER_USER_NAME';
    
    public static final LoggingLevel SFDC_DEBUG_LOGGING_LEVEL;
    public static final String HCO_CUSTOMER_CLASS_NAME;
    public static final String HCP_CUSTOMER_CLASS_NAME;
    public static final String DEPARTMENT_ACCOUNT_TYPE;
    public static final String RECORD_TYPE_HCP;
    public static final String RECORD_TYPE_HCO;
    public static final String RECORD_TYPE_HCO_DEPARTMENT;
    public static final String RECORD_TYPE_ADDRESS_HCP;
    public static final String RECORD_TYPE_ADDRESS_HCO;
    public static final Integer ACOUNT_DEFAULT_REGION_CODE;
    public static final Integer BATCH_SIZE;
    public static final String NOTIFICATION_EMAIL;
    public static final Boolean ACCOUNT_INSERT_MODE;
    public static final Boolean ADDRESS_INSERT_MODE;
    public static final String ACCOUNT_OWNER_USER_NAME;
    public static final Id RECORD_OWNER_ID;
    
    public static final String SUBSCRIBE_STATUS_SUCCESS = 'Success';
    public static final String SUBSCRIBE_STATUS_FAILED = 'Failed';
    public static final String SUBSCRIBE_STATUS_FAILED_ON_ADDRESS = 'Failed on Address';
    public static final String ADDRESS_UAD_INDICATOR_INACTIVE = 'D';
    public static final String UAD_INDICATOR_INSERT = 'I';
    public static final String UAD_INDICATOR_UPDATE = 'U';
    public static final String ADDRESS_INACTIVATE_REASON = 'Deactivated as part of CR XXXXX';
    public static final String ADDRESS_POSTAL_CODE_REG_EXP = '[A-Z]\\d[A-Z]\\s\\d[A-Z]\\d';
    
    public static final String RUNTIME_ERROR_APEX_CLASS_CODE = 'RUNTIME_ERROR';
    public static final String RUNTIME_ERROR_APEX_TRIGGER_CODE = 'RUNTIME_TRIGGER_ERROR';
    public static final String SUBSCRIBE_ERROR_CODE = 'SUBSCRIBE_EXCEPTION';
    
    
    public enum KnownException {
    	ACCOUNT_HAS_NO_ADDRESS, 
    	HCP_CUSTOMER_FIRST_NAME_IS_NULL, 
    	HCP_CUSTOMER_LAST_NAME_IS_NULL,
    	HCO_CUSTOMER_NAME_IS_NULL,
    	CUSTOMER_TYPE_IS_NULL,
    	CANNOT_CHANGE_RECORD_TYPE,
    	ADDRESS_ASSIGNED_TO_DIFFERENT_ACCOUNT,
    	ADDRESS_NAME_IS_NULL,
    	ADDRESS_CITY_IS_NULL,
    	ADDRESS_PROVINCE_IS_NULL,
    	ADDRESS_PROVINCE_WRONG_VALUE,
    	ACCOUNT_OWNER_NOT_SET,
    	TARGET_ACCOUNT_FOR_UPDATE_NOT_FOUND,
    	TARGET_ACCOUNT_WITH_GIVEN_ROCHE_ID_ALREADY_EXISTS,
    	ACCOUNT_UAD_INDICATOR_NOT_VALID,
    	TARGET_ADDRESS_FOR_UPDATE_NOT_FOUND,
    	TARGET_ADDRESS_WITH_GIVEN_ROCHE_ID_ALREADY_EXISTS,
    	ADDRESS_UAD_INDICATOR_NOT_VALID,
    	ADDRESS_POSTAL_CODE_WRONG_VALUE,
    	ADDRESS_POSTAL_CODE_IS_NULL,
    	ACCOUNT_HAS_NO_VALID_ADDRESS
    }
    
    public static final Map<KnownException, String> knownExceptionDescriptions = new Map<KnownException, String> {
    	KnownException.ACCOUNT_HAS_NO_ADDRESS => 'Source Account has no address.', 
    	KnownException.HCP_CUSTOMER_FIRST_NAME_IS_NULL => 'Source HCP Account First Name is not set.', 
    	KnownException.HCP_CUSTOMER_LAST_NAME_IS_NULL => 'Source HCP Account Last Name is not set.',
    	KnownException.HCO_CUSTOMER_NAME_IS_NULL => 'Source HCO Account Name is not set.',
    	KnownException.CUSTOMER_TYPE_IS_NULL => 'Source Account Type is not set.',
    	KnownException.CANNOT_CHANGE_RECORD_TYPE => 'Existing Target Account has different Record Type than Source Account.',
    	KnownException.ADDRESS_ASSIGNED_TO_DIFFERENT_ACCOUNT => 'Target Address is assigned to different Account than Source Record.',
    	KnownException.ADDRESS_NAME_IS_NULL => 'Source Address Name is not set.',
    	KnownException.ADDRESS_CITY_IS_NULL => 'Source Address City is not set.',
    	KnownException.ADDRESS_PROVINCE_IS_NULL => 'Source Address Province is not set.',
    	KnownException.ADDRESS_PROVINCE_WRONG_VALUE => 'Source Address Province is set, but has wrong value.',
    	KnownException.ACCOUNT_OWNER_NOT_SET => 'Account Owner not set in GNE_CAN_Config_Items_List_can__c setting.',
    	KnownException.TARGET_ACCOUNT_FOR_UPDATE_NOT_FOUND => 'Target Account Update Candidate not found for given SFDC ID.',
    	KnownException.TARGET_ACCOUNT_WITH_GIVEN_ROCHE_ID_ALREADY_EXISTS => 'Cannot insert Account, because Account with given Roche Id already exists.',
    	KnownException.ACCOUNT_UAD_INDICATOR_NOT_VALID => 'Account UAD Indicator is null or has wrong value (valid values: \'I\' or \'U\').',
    	KnownException.TARGET_ADDRESS_FOR_UPDATE_NOT_FOUND => 'Target Address Update Candidate not found for given SFDC ID.',
    	KnownException.TARGET_ADDRESS_WITH_GIVEN_ROCHE_ID_ALREADY_EXISTS => 'Cannot insert Address, because Address with given Roche Id and Roche Address Id already exists.',
    	KnownException.ADDRESS_UAD_INDICATOR_NOT_VALID => 'Address UAD Indicator is null or has wrong value (valid values: \'I\', \'U\' or \'D\').',
    	KnownException.ADDRESS_POSTAL_CODE_WRONG_VALUE => 'Source Address Postal Code is set, but has wrong format. Pattern is \'[A-Z][0-9][A-Z] [0-9][A-Z][0-9]\' i.e. A0A 1B1.',
    	KnownException.ADDRESS_POSTAL_CODE_IS_NULL => 'Source Address Postal Code is not set.',
    	KnownException.ACCOUNT_HAS_NO_VALID_ADDRESS => 'Source Account has an address, but it is not valid.'
    };
    
    private static Map<String, Set<String>> fieldSetsForObjects;
    private static Map<String, Map<String,String>> fieldMappings;
    private static Map<String, FieldMappingUpdateMode> fieldUpdateModes;
    private static Map<String, Boolean> fieldCaseSensitiveModes;
    
    
    static{
        Map<String, GNE_CAN_Config_Items_List_can__c> configItemsMap = GNE_CAN_Config_Items_List_can__c.getAll();  
        
        if((configItemsMap.containsKey(CONFIG_ITEM_NAME_SFDC_DEBUG_LOGGING_LEVEL)) && (configItemsMap.get(CONFIG_ITEM_NAME_SFDC_DEBUG_LOGGING_LEVEL).Value_can__c!=NULL) && (configItemsMap.get(CONFIG_ITEM_NAME_SFDC_DEBUG_LOGGING_LEVEL).Value_can__c.length()>0)){
            String logLevel = configItemsMap.get(CONFIG_ITEM_NAME_SFDC_DEBUG_LOGGING_LEVEL).Value_can__c.toUpperCase();
            for(LoggingLevel lLevel : LoggingLevel.values()) {
                if(logLevel == lLevel.name()) {
                    SFDC_DEBUG_LOGGING_LEVEL = lLevel;
                    break;
                }
            }
        }
        
        if((configItemsMap.containsKey(CONFIG_ITEM_NAME_HCO_CUSTOMER_CLASS_NAME)) && (configItemsMap.get(CONFIG_ITEM_NAME_HCO_CUSTOMER_CLASS_NAME).Value_can__c!=NULL) && (configItemsMap.get(CONFIG_ITEM_NAME_HCO_CUSTOMER_CLASS_NAME).Value_can__c.length()>0)){
            HCO_CUSTOMER_CLASS_NAME = configItemsMap.get(CONFIG_ITEM_NAME_HCO_CUSTOMER_CLASS_NAME).Value_can__c;
        }
        
        if((configItemsMap.containsKey(CONFIG_ITEM_NAME_HCP_CUSTOMER_CLASS_NAME)) && (configItemsMap.get(CONFIG_ITEM_NAME_HCP_CUSTOMER_CLASS_NAME).Value_can__c!=NULL) && (configItemsMap.get(CONFIG_ITEM_NAME_HCP_CUSTOMER_CLASS_NAME).Value_can__c.length()>0)){
            HCP_CUSTOMER_CLASS_NAME = configItemsMap.get(CONFIG_ITEM_NAME_HCP_CUSTOMER_CLASS_NAME).Value_can__c;
        }
        
        if((configItemsMap.containsKey(CONFIG_ITEM_NAME_DEPARTMENT_ACCOUNT_TYPE)) && (configItemsMap.get(CONFIG_ITEM_NAME_DEPARTMENT_ACCOUNT_TYPE).Value_can__c!=NULL) && (configItemsMap.get(CONFIG_ITEM_NAME_DEPARTMENT_ACCOUNT_TYPE).Value_can__c.length()>0)){
            DEPARTMENT_ACCOUNT_TYPE = configItemsMap.get(CONFIG_ITEM_NAME_DEPARTMENT_ACCOUNT_TYPE).Value_can__c;
        }
        
        if((configItemsMap.containsKey(CONFIG_ITEM_NAME_RECORD_TYPE_HCP)) && (configItemsMap.get(CONFIG_ITEM_NAME_RECORD_TYPE_HCP).Value_can__c!=NULL) && (configItemsMap.get(CONFIG_ITEM_NAME_RECORD_TYPE_HCP).Value_can__c.length()>0)){
            RECORD_TYPE_HCP = configItemsMap.get(CONFIG_ITEM_NAME_RECORD_TYPE_HCP).Value_can__c;
        }

        if((configItemsMap.containsKey(CONFIG_ITEM_NAME_RECORD_TYPE_HCO)) && (configItemsMap.get(CONFIG_ITEM_NAME_RECORD_TYPE_HCO).Value_can__c!=NULL) && (configItemsMap.get(CONFIG_ITEM_NAME_RECORD_TYPE_HCO).Value_can__c.length()>0)){
            RECORD_TYPE_HCO = configItemsMap.get(CONFIG_ITEM_NAME_RECORD_TYPE_HCO).Value_can__c;
        }
        
        if((configItemsMap.containsKey(CONFIG_ITEM_NAME_RECORD_TYPE_HCO_DEPARTMENT)) && (configItemsMap.get(CONFIG_ITEM_NAME_RECORD_TYPE_HCO_DEPARTMENT).Value_can__c!=NULL) && (configItemsMap.get(CONFIG_ITEM_NAME_RECORD_TYPE_HCO_DEPARTMENT).Value_can__c.length()>0)){
            RECORD_TYPE_HCO_DEPARTMENT  = configItemsMap.get(CONFIG_ITEM_NAME_RECORD_TYPE_HCO_DEPARTMENT).Value_can__c;
        }
        
        if((configItemsMap.containsKey(CONFIG_ITEM_NAME_RECORD_TYPE_ADDRESS_HCP)) && (configItemsMap.get(CONFIG_ITEM_NAME_RECORD_TYPE_ADDRESS_HCP).Value_can__c!=NULL) && (configItemsMap.get(CONFIG_ITEM_NAME_RECORD_TYPE_ADDRESS_HCP).Value_can__c.length()>0)){
            RECORD_TYPE_ADDRESS_HCP = configItemsMap.get(CONFIG_ITEM_NAME_RECORD_TYPE_ADDRESS_HCP).Value_can__c;
        }
        
        if((configItemsMap.containsKey(CONFIG_ITEM_NAME_RECORD_TYPE_ADDRESS_HCO)) && (configItemsMap.get(CONFIG_ITEM_NAME_RECORD_TYPE_ADDRESS_HCO).Value_can__c!=NULL) && (configItemsMap.get(CONFIG_ITEM_NAME_RECORD_TYPE_ADDRESS_HCO).Value_can__c.length()>0)){
            RECORD_TYPE_ADDRESS_HCO = configItemsMap.get(CONFIG_ITEM_NAME_RECORD_TYPE_ADDRESS_HCO).Value_can__c;
        }
        
        if((configItemsMap.containsKey(CONFIG_ITEM_NAME_ACOUNT_DEFAULT_REGION_CODE)) && (configItemsMap.get(CONFIG_ITEM_NAME_ACOUNT_DEFAULT_REGION_CODE).Value_can__c!=NULL) && (configItemsMap.get(CONFIG_ITEM_NAME_ACOUNT_DEFAULT_REGION_CODE).Value_can__c.length()>0)){
            ACOUNT_DEFAULT_REGION_CODE  = Integer.valueOf(configItemsMap.get(CONFIG_ITEM_NAME_ACOUNT_DEFAULT_REGION_CODE).Value_can__c);
        }
        
        if((configItemsMap.containsKey(CONFIG_ITEM_NAME_BATCH_SIZE)) && (configItemsMap.get(CONFIG_ITEM_NAME_BATCH_SIZE).Value_can__c!=NULL) && (configItemsMap.get(CONFIG_ITEM_NAME_BATCH_SIZE).Value_can__c.length()>0)){
            BATCH_SIZE = Integer.valueOf(configItemsMap.get(CONFIG_ITEM_NAME_BATCH_SIZE).Value_can__c);
        } else {
            BATCH_SIZE = 10;
        }
        
        if((configItemsMap.containsKey(CONFIG_ITEM_NAME_NOTIFICATION_EMAIL)) && (configItemsMap.get(CONFIG_ITEM_NAME_NOTIFICATION_EMAIL).Value_can__c!=NULL) && (configItemsMap.get(CONFIG_ITEM_NAME_NOTIFICATION_EMAIL).Value_can__c.length()>0)){
            NOTIFICATION_EMAIL = configItemsMap.get(CONFIG_ITEM_NAME_NOTIFICATION_EMAIL).Value_can__c;
        } else {
        	NOTIFICATION_EMAIL = 'no-email-defined@roche.com';
        }
        
        Set<String> trueValues = new Set<String>{'1', 'true', 'yes'};
        
        if((configItemsMap.containsKey(CONFIG_ITEM_NAME_ACCOUNT_INSERT_MODE)) && (configItemsMap.get(CONFIG_ITEM_NAME_ACCOUNT_INSERT_MODE).Value_can__c!=NULL) && (configItemsMap.get(CONFIG_ITEM_NAME_ACCOUNT_INSERT_MODE).Value_can__c.length()>0)){
            ACCOUNT_INSERT_MODE = trueValues.contains(configItemsMap.get(CONFIG_ITEM_NAME_ACCOUNT_INSERT_MODE).Value_can__c.toLowerCase());
        } else {
            ACCOUNT_INSERT_MODE = true;
        }
        
        if((configItemsMap.containsKey(CONFIG_ITEM_NAME_ADDRESS_INSERT_MODE)) && (configItemsMap.get(CONFIG_ITEM_NAME_ADDRESS_INSERT_MODE).Value_can__c!=NULL) && (configItemsMap.get(CONFIG_ITEM_NAME_ADDRESS_INSERT_MODE).Value_can__c.length()>0)){
            ADDRESS_INSERT_MODE = trueValues.contains(configItemsMap.get(CONFIG_ITEM_NAME_ADDRESS_INSERT_MODE).Value_can__c.toLowerCase());
        } else {
            ADDRESS_INSERT_MODE = true;
        }
        
        if((configItemsMap.containsKey(CONFIG_ITEM_NAME_OWNER_USER_NAME)) && (configItemsMap.get(CONFIG_ITEM_NAME_OWNER_USER_NAME).Value_can__c!=NULL) && (configItemsMap.get(CONFIG_ITEM_NAME_OWNER_USER_NAME).Value_can__c.length()>0)){
            ACCOUNT_OWNER_USER_NAME = configItemsMap.get(CONFIG_ITEM_NAME_OWNER_USER_NAME).Value_can__c;
            String userName = ACCOUNT_OWNER_USER_NAME + '%';
            for(User u : [SELECT Id FROM User WHERE UserName like :userName limit 1]) {
                RECORD_OWNER_ID = u.Id; 
            }
            
        }
    }
    /**
    Retrieves String representation of Ids contained in given Set.
    */
    public static String getStringIdSet(Set<String> ids){
        return '\'' + String.join(new List<String>(ids),'\',\'') + '\''; 
    }
    
    
    /**
    Retrieves String representation od field names contained in given Set.
    */
    public static String getStringFieldNames(Set<String> fieldNames){
        return String.join(new List<String>(fieldNames),',');
    }
    
    public static Set<String> getFieldSetForObject(String sObjectName){
        if(fieldSetsForObjects==null) {
            readFieldMappingsConfiguration();
        }
        
        Set<String> result = fieldSetsForObjects.get(sObjectName.toUpperCase());
        if(result==null) {
            result = new Set<String>();
        }
        
        return result;
    }
    
    public static Map<String,String> getFieldMappings(String stgSObjectName, String targetSObjectName) {
        if(fieldMappings==null) {
            readFieldMappingsConfiguration();
        }
        
        Map<String,String> result = fieldMappings.get(stgSObjectName.toUpperCase() + '.' + targetSObjectName.toUpperCase());
        if(result==null) {
            result = new Map<String,String>();
        }
        
        return result;
    }
    
    public static FieldMappingUpdateMode getFieldUpdateMode(String stgSObjectName, String stgFieldName) {
        if(fieldUpdateModes==null) {
            readFieldMappingsConfiguration();
        }
        
        FieldMappingUpdateMode result = fieldUpdateModes.get(stgSObjectName.toUpperCase() + '.' + stgFieldName);
        // it can return null value
        return result;
    }
    
    public static Boolean isFieldCaseSensitiveMode(String stgSObjectName, String stgFieldName) {
        if(fieldCaseSensitiveModes==null) {
            readFieldMappingsConfiguration();
        }
        
        return fieldCaseSensitiveModes.get(stgSObjectName.toUpperCase() + '.' + stgFieldName) == true;
    }
    
    private static void readFieldMappingsConfiguration() {
        fieldSetsForObjects = new Map<String, Set<String>>();
        fieldMappings = new Map<String, Map<String,String>>();
        fieldUpdateModes = new Map<String, FieldMappingUpdateMode>();
        fieldCaseSensitiveModes = new Map<String,Boolean>();
        
        Map<String, FieldMappingUpdateMode> availableModes = new Map<String, FieldMappingUpdateMode>(); 
        for(FieldMappingUpdateMode mode : FieldMappingUpdateMode.values()) {
            availableModes.put(mode.name(), mode);
        }
        
        List<GNE_CAN_PS_Fields_Mapping_can__c> fieldMappingsSetting = GNE_CAN_PS_Fields_Mapping_can__c.getAll().values();
        
        for(GNE_CAN_PS_Fields_Mapping_can__c mapConfigRec : fieldMappingsSetting) {
            if(!mapConfigRec.Active_can__c) {
                continue;
            }
            
            fieldUpdateModes.put(mapConfigRec.Staging_Object_can__c.toUpperCase() + '.' + mapConfigRec.Staging_Field_can__c,
                mapConfigRec.Update_mode_gne__c!=null ? availableModes.get(mapConfigRec.Update_mode_gne__c) : FieldMappingUpdateMode.ALWAYS);
            
            String mappingObjectsKey = mapConfigRec.Staging_Object_can__c.toUpperCase() + '.' + mapConfigRec.Target_Object_can__c.toUpperCase();
            
            if(!fieldMappings.containsKey(mappingObjectsKey)) {
                fieldMappings.put(mappingObjectsKey, new Map<String,String>());
            }
            
            fieldMappings.get(mappingObjectsKey).put(mapConfigRec.Staging_Field_can__c, mapConfigRec.Target_Field_can__c);
            
            if(!fieldSetsForObjects.containsKey(mapConfigRec.Staging_Object_can__c.toUpperCase())) {
                fieldSetsForObjects.put(mapConfigRec.Staging_Object_can__c.toUpperCase(), new Set<String>());
            }
            
            fieldSetsForObjects.get(mapConfigRec.Staging_Object_can__c.toUpperCase()).add(mapConfigRec.Staging_Field_can__c);
            
            if(!fieldSetsForObjects.containsKey(mapConfigRec.Target_Object_can__c.toUpperCase())) {
                fieldSetsForObjects.put(mapConfigRec.Target_Object_can__c.toUpperCase(), new Set<String>());
            }
            
            fieldSetsForObjects.get(mapConfigRec.Target_Object_can__c.toUpperCase()).add(mapConfigRec.Target_Field_can__c);
            
            fieldCaseSensitiveModes.put(mapConfigRec.Staging_Object_can__c.toUpperCase() + '.' + mapConfigRec.Staging_Field_can__c, mapConfigRec.Case_Sensitive_can__c==true);
        }
    }
    
    public static void addDebugMessage(String sMessage) {
        addDebugMessage(SFDC_DEBUG_LOGGING_LEVEL, sMessage);
    }
    
    public static void addDebugMessage(Logginglevel logLevel, String sMessage) {
        if(logLevel!=null) {
            system.debug(logLevel, '\n\n-----------------------------------> ' + sMessage + '\n\n');
        }
    }
}