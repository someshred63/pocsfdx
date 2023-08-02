public virtual without sharing class CORE_Subscribe_Base {
	
	public static final String PARTY_TYPE_INDIVIDUAL_CODE           = 'IND';
    public static final String PARTY_TYPE_ORGANIZATION_CODE         = 'ORG';  
    public static final String SFDC_CTRB_SOURCE_CODE                = 'SFDC';
    public static final String MDM_CTRB_SOURCE_CODE                 = 'MDM';
    public static final String AMS_CTRB_SOURCE_CODE                 = 'AMS';
    public static final String NPI_CTRB_SOURCE_CODE                 = 'NPI';
    public static final String CONFIG_ITEM_NAME_CREATE_ACCOUNT_EXT = 'CreateAccountExternalXREFList';
    public static final String CONFIG_ITEM_NAME_CREATE_ACCOUNT_XREF= 'CreateAccountXREFList';
    public static final String CONFIG_ITEM_NAME_CREATE_ADDRESS_EXT = 'CreateAddressExternalXREFList';
    public static final String CONFIG_ITEM_NAME_CREATE_ADDRESS_XREF= 'CreateAddressXREFList';
    public static final String CONFIG_ITEM_NAME_DEFAULT_INDV_ROLE  = 'DefaultIndividualRoleCode';
    public static final String CONFIG_ITEM_NAME_DEFAULT_INDV_CREDENTIAL  = 'DefaultIndividualCredentialCode';
    public static final String CONFIG_ITEM_NAME_UPDATE_ON_MDM_ID	= 'EnableUpdateOnMDMId';
    public static final String CONFIG_ITEM_LOGGING_LEVEL           = 'LoggingLevel';      

    public static final String CONFIG_ITEM_NOTIFICATION_EMAIL       = 'SubscribeNotifyEmail';  
    public static final String CONFIG_ITEM_NAME_VALID_SOURCES 		= 'ValidSourcesXREFList';
	
	public static final Set<String> CREATE_ACCOUNT_XREF;            // Valid contributor sources for account to be upserted (as defined in the CONFIG_ITEM_NAME_CREATE_ACCOUNT_XREF custom setting)  
    public static final Set<String> CREATE_ACCOUNT_EXT;             // Valid sources for account external import (as defined in the CONFIG_ITEM_NAME_CREATE_ACCOUNT_EXT custom setting)
    public static final Set<String> CREATE_ADDRESS_XREF;            // Valid contributor sources for address to be upserted (as defined in the CONFIG_ITEM_NAME_CREATE_ADDRESS_XREF custom setting)
    public static final Set<String> CREATE_ADDRESS_EXT;             // Valid sources for address external import (as defined in the CONFIG_ITEM_NAME_CREATE_ADDRESS_EXT custom setting)
    public static final String DEFAULT_INDIVIDUAL_ROLE_CODE;        // Default individual role code (as defined in the CONFIG_ITEM_NAME_DEFAULT_INDV_ROLE custom setting)
    public static final Boolean UPDATE_ON_MDM_ID;					// If set to 'TRUE' or 'Y' performs update based on MDM ID at Account, Address Level 
    public static final String LOGGING_LEVEL;                       // Logging Level from the CONFIG_ITEM_LOGGING_LEVEL custom setting (valid values are ERROR, WARN, INFO, DEBUG, FINE, FINER, FINEST);
    public static final Set<String> VALID_SOURCES;          	   // Valid contributor sources for a party to be processed (as defined in the CONFIG_ITEM_NAME_VALID_SOURCES custom setting)
    
    public static final String CNNCL_PARTY = 'PTY';
    public static final String CNNCL_PARTY_LOC = 'PTYLOC';
    
    public static final String STATUS_SUCCESS = 'Success';
	public static final String STATUS_ERROR = 'Error';
	
	public enum SubscribeMode {ASI, NORMAL}
	
	private static String plainTextLineBreak = '\n';
	
	 /**
    * Retrieve configuration items from 'CORE FOUN Misc Config Items' custom setting  
    */
    static {        
        // Account Create
        Map<String, CORE_Found_Misc_Config__c> configItemsMap = CORE_Found_Misc_Config__c.getAll();     

       	CREATE_ACCOUNT_XREF = new Set<String>();
        if ((configItemsMap.containsKey(CONFIG_ITEM_NAME_CREATE_ACCOUNT_XREF)) && (configItemsMap.get(CONFIG_ITEM_NAME_CREATE_ACCOUNT_XREF).Configuration_Value_gne__c.length() > 0)) {                 
            for (String item : configItemsMap.get(CONFIG_ITEM_NAME_CREATE_ACCOUNT_XREF).Configuration_Value_gne__c.split(',')){
	            CREATE_ACCOUNT_XREF.add(item.trim());
            }                                 
        }
            
        // Account External     
       	CREATE_ACCOUNT_EXT = new Set<String>();
        if ((configItemsMap.containsKey(CONFIG_ITEM_NAME_CREATE_ACCOUNT_EXT)) && (configItemsMap.get(CONFIG_ITEM_NAME_CREATE_ACCOUNT_EXT).Configuration_Value_gne__c.length() > 0)) {               
            for (String item : configItemsMap.get(CONFIG_ITEM_NAME_CREATE_ACCOUNT_EXT).Configuration_Value_gne__c.split(',')){
	            CREATE_ACCOUNT_EXT.add(item.trim());
            }
        }

        // Create Address   
    	CREATE_ADDRESS_XREF = new Set<String>();
        if ((configItemsMap.containsKey(CONFIG_ITEM_NAME_CREATE_ADDRESS_XREF)) && (configItemsMap.get(CONFIG_ITEM_NAME_CREATE_ADDRESS_XREF).Configuration_Value_gne__c.length() > 0)) {                 
            for (String item : configItemsMap.get(CONFIG_ITEM_NAME_CREATE_ADDRESS_XREF).Configuration_Value_gne__c.split(',')){
	            CREATE_ADDRESS_XREF.add(item.trim());
            }
        }
        
        // Address External     
    	CREATE_ADDRESS_EXT = new Set<String>();
        if ((configItemsMap.containsKey(CONFIG_ITEM_NAME_CREATE_ADDRESS_EXT)) && (configItemsMap.get(CONFIG_ITEM_NAME_CREATE_ADDRESS_EXT).Configuration_Value_gne__c.length() > 0)) {               
            for (String item: configItemsMap.get(CONFIG_ITEM_NAME_CREATE_ADDRESS_EXT).Configuration_Value_gne__c.split(',')){
            	CREATE_ADDRESS_EXT.add(item.trim());
        	}
        }       
        
        // Default Individual Role Code     
        if ((configItemsMap.containsKey(CONFIG_ITEM_NAME_DEFAULT_INDV_ROLE)) && (configItemsMap.get(CONFIG_ITEM_NAME_DEFAULT_INDV_ROLE).Configuration_Value_gne__c.length() > 0)) {                 
            DEFAULT_INDIVIDUAL_ROLE_CODE = configItemsMap.get(CONFIG_ITEM_NAME_DEFAULT_INDV_ROLE).Configuration_Value_gne__c.trim();
        } else{
        	DEFAULT_INDIVIDUAL_ROLE_CODE = 'HCPNPSCR';
        }       
 
        // Enable update based on MDM Id?  
        if ((configItemsMap.containsKey(CONFIG_ITEM_NAME_UPDATE_ON_MDM_ID)) && (configItemsMap.get(CONFIG_ITEM_NAME_UPDATE_ON_MDM_ID).Configuration_Value_gne__c.length() > 0)) {               
        	UPDATE_ON_MDM_ID = (configItemsMap.get(CONFIG_ITEM_NAME_UPDATE_ON_MDM_ID).Configuration_Value_gne__c == 'TRUE' ||  configItemsMap.get(CONFIG_ITEM_NAME_UPDATE_ON_MDM_ID).Configuration_Value_gne__c == 'Y');
        }else{
	        UPDATE_ON_MDM_ID = false;
        }
 
        // Default Logging Level    
        if ((configItemsMap.containsKey(CONFIG_ITEM_LOGGING_LEVEL)) && (configItemsMap.get(CONFIG_ITEM_LOGGING_LEVEL).Configuration_Value_gne__c.length() > 0)) {               
            LOGGING_LEVEL = configItemsMap.get(CONFIG_ITEM_LOGGING_LEVEL).Configuration_Value_gne__c.trim();
        } else{
        	LOGGING_LEVEL = '';
        } 
        
        // Valid Sources
        VALID_SOURCES = new Set<String>();
        if ((configItemsMap.containsKey(CONFIG_ITEM_NAME_VALID_SOURCES)) && (configItemsMap.get(CONFIG_ITEM_NAME_VALID_SOURCES).Configuration_Value_gne__c.length() > 0)) {                 
            for (String item: configItemsMap.get(CONFIG_ITEM_NAME_VALID_SOURCES).Configuration_Value_gne__c.split(',')){
                VALID_SOURCES.add(item.trim());  
            }  
        }           
    }
	
	public static void sendSummaryMail(Core_Subscribe_Job__c sJob, CORE_Subscribe_Metrics metrics) {
        //Create a new single email message object
        Map<String, CORE_Found_Misc_Config__c> configItemsMap = CORE_Found_Misc_Config__c.getAll();
        List<String> addresses = configItemsMap.get('SubscribeNotifyEmail').Configuration_Value_gne__c.split(',');
        sendSummaryMail(sJob, addresses, metrics);
	}
	
	public static void sendSummaryMail(Core_Subscribe_Job__c sJob, List<String> emailAddresses, CORE_Subscribe_Metrics metrics) {
		sendSummaryMail(sJob, emailAddresses, metrics, null);
	}
	
	public static void sendSummaryMail(Core_Subscribe_Job__c sJob, List<String> emailAddresses, CORE_Subscribe_Metrics metrics, String msg) {
		sendSummaryMail(sJob, emailAddresses, metrics, msg, false);
	}
	
	public static String sendSummaryMail(Core_Subscribe_Job__c sJob, List<String> emailAddresses, CORE_Subscribe_Metrics metrics, String msg, Boolean isHtmlFormat) {
		String lineBreak = isHtmlFormat ? '<br/>' : plainTextLineBreak;	
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        //Address
        email.setToAddresses(emailAddresses);
        email.setSubject(sJob.Name + ' finished');

        String summary = isHtmlFormat ? '<head><style>table, th, td {border: 1px solid black;}table {width : 600px;border-collapse: collapse;}th, td {padding: 15px;text-align: center;}tr:nth-child(even) {background-color: #f2f2f2}</style></head>' : '';
        summary += sJob.Name + ' finished' + lineBreak + lineBreak;
        if (String.isNotBlank(msg)) {
        	summary += msg;
        }
        if(sJob.Status_gne__c != 'Error'){
        	summary += printMetrics(metrics, lineBreak);
        } else {
        	summary += 'Process failed. Reason:' + lineBreak + lineBreak;
        	summary += sJob.Summary_gne__c;
        }
        //Content
        if (isHtmlFormat) {
        	email.setHtmlBody(summary);
        } else {
        	email.setPlainTextBody(summary);
        }
        //Send
        try{
        	List<Messaging.Sendemailresult> result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
	        if (!result[0].isSuccess()){
	            System.debug('Couldn\'t send metrics summary email!');
	        }
        }catch(Exception e){
        	System.debug('Couldn\'t send metrics summary email!');
        }
        return summary;
    }
    
    public static void sendSummaryMail(String jobName, CORE_Subscribe_Metrics metrics) {
    	Map<String, CORE_Found_Misc_Config__c> configItemsMap = CORE_Found_Misc_Config__c.getAll();
        List<String> emailAddresses = configItemsMap.get('SubscribeNotifyEmail').Configuration_Value_gne__c.split(',');
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        //Address
        email.setToAddresses(emailAddresses);
        email.setSubject(jobName + ' finished');

        String summary = jobName + ' finished' + plainTextLineBreak + plainTextLineBreak;
       	summary += printMetrics(metrics, plainTextLineBreak);
        //Content
        email.setPlainTextBody(summary);
        //Send
        try{
        	List<Messaging.Sendemailresult> result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
	        if (!result[0].isSuccess()){
	            System.debug('Couldn\'t send metrics summary email!');
	        }
        }catch(Exception e){
        	System.debug('Couldn\'t send metrics summary email!');
        }
    }
    
    public static String printMetrics(CORE_Subscribe_Metrics metrics) {
    	return printMetrics(metrics, plainTextLineBreak);
    }
    
    public static String printMetrics(CORE_Subscribe_Metrics metrics, String lineBreak) {
    	if(metrics.endTime == null){
    		metrics.endTime = System.now();
    	}
    	String result = ''; 
    	if(metrics.mType == CORE_Subscribe_Metrics.MetricType.TOTAL){
    		result += 'Process start time: '+ metrics.startTime + lineBreak;
    		result += 'Process end time: '+ metrics.endTime + lineBreak;
    		if(metrics.startTime != null && metrics.endTime != null){
	    		result += 'Running time: '+ CORE_Subscribe_Util.getDurationDescription(metrics.startTime, metrics.endTime) +lineBreak;
    		}
    		
    		result += lineBreak + 'Total number of parties processed: '+ metrics.partiesNumber +lineBreak;
    		result += 'Validation errors: '+ metrics.validationErrors +lineBreak;
    	}else{
	    	result = lineBreak + 'Metrics for: ' + metrics.targetObject + lineBreak;
	    	if (metrics.upsertCount == 0 || metrics.insertCount > 0) {
	    		result += '-inserted: ' + metrics.insertCount + lineBreak;
	    	}
	    	if (metrics.upsertCount == 0 || metrics.updateCount > 0) {
		    	result += '-updated: ' + metrics.updateCount + lineBreak;
	    	}
	    	if (metrics.upsertCount > 0) {
		    	result += '-upserted: ' + metrics.upsertCount + lineBreak;
	    	}
	    	if (metrics.deleteCount > 0) {
		    	result += '-deleted: ' + metrics.deleteCount + lineBreak;
	    	}
	    	result += '-errors: ' + metrics.errorsCount + lineBreak;
	    	
	    	if (String.isNotBlank(metrics.summary)) {
		    	result += 'Details:' + lineBreak + metrics.summary + lineBreak;
	    	}
    	}
    	if(metrics.relatedMetrics != null){
    		for(CORE_Subscribe_Metrics metric: metrics.relatedMetrics){
    			result += printMetrics(metric, lineBreak);
    		}
    	}
    	return result;
    }
    
    protected CORE_Subscribe_Error__c createError(String objectName, Id recordId, String description, String level){
    	return createError(objectName, (String)recordId, description, level);
    }
    
    protected CORE_Subscribe_Error__c createError(String objectName, String recordId, String description, String level){
    	String title = '';
    	if(description != null){
    		title = description.abbreviate(255);
    	} 
    	return createError(objectName, (String)recordId, title, description, level);
	}
	
    protected CORE_Subscribe_Error__c createError(String objectName, String recordId, String title, String description, String level){
		return new CORE_Subscribe_Error__c(Object_Name_gne__c= objectName, Description_gne__c = description, Level_gne__c=level, Record_Id_gne__c = recordId, Title_gne__c = title);
	}
	
	/**
    * Adds custom debug message to execution log
    */
    protected void debug(String sMessage) {
        if (LOGGING_LEVEL == 'ERROR'){
            system.debug(Logginglevel.ERROR, '-----------------------------------> ' + sMessage);
        }else if (LOGGING_LEVEL == 'WARN'){
            system.debug(Logginglevel.WARN,  '-----------------------------------> ' + sMessage);
        }else if (LOGGING_LEVEL == 'INFO'){
            system.debug(Logginglevel.INFO,  '-----------------------------------> ' + sMessage);
        }else if (LOGGING_LEVEL == 'DEBUG'){
            system.debug(Logginglevel.DEBUG, '-----------------------------------> ' + sMessage);
        }else if (LOGGING_LEVEL == 'FINE'){
            system.debug(Logginglevel.FINE,  '-----------------------------------> ' + sMessage);
        }else if (LOGGING_LEVEL == 'FINER'){
            system.debug(Logginglevel.FINER, '-----------------------------------> ' + sMessage);
        }else if (LOGGING_LEVEL == 'FINEST'){
            system.debug(Logginglevel.FINEST,'-----------------------------------> ' + sMessage);
        }              
    }
    
    /*Set fields values base on communication chanel field and refence custom setting. Only null fields are overwritten.*/
   	protected virtual void processCommunicationChannel(String communicationChannel, sObject targetObject, String prefix) {
       	Set<String>alreadyProcessedCodes = new Set<String>();
		List<CommunicationChannelJson>commChannels = (List<CommunicationChannelJson>)JSON.deserialize(communicationChannel, List<CommunicationChannelJson>.class);
		for(CommunicationChannelJson channel: commChannels){
		    CORE_Comm_Chnl_Typ__c setting = CORE_Comm_Chnl_Typ__c.getValues(channel.code);
		    if(setting != null && setting.value_gne__c != null){
		        List<String> fieldsToSet =  setting.value_gne__c.split(';');
		        for(String fieldToSet: fieldsToSet){
		            if(fieldToSet.startsWithIgnoreCase(prefix)){
		                fieldToSet = fieldToSet.substring(prefix.length());
		                if(fieldToSet.contains('(if > 1)')){
		                	if(alreadyProcessedCodes.contains(channel.code)){
		                		fieldToSet = fieldToSet.substring(0, fieldToSet.length() - 8).trim();
		                		if(targetObject.get(fieldToSet) == null){
				                	targetObject.put(fieldToSet, channel.value);
		                		}
		                	}
		                }else if (!alreadyProcessedCodes.contains(channel.code)){
		                	if(targetObject.get(fieldToSet) == null){
		                		targetObject.put(fieldToSet, channel.value);
		                	}
		                }
		            }
		        }
		    }
		    alreadyProcessedCodes.add(channel.code);
		}
	 }
    
    public virtual class JsonList {
    	public String code;
    }
    
    public virtual class JsonCodeValueList extends JsonList {
        public String value;
    }
    
   public class CommunicationChannelJson extends JsonCodeValueList {
        public String Extension;
    }
}