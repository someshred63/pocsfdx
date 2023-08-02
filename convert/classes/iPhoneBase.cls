public abstract class iPhoneBase{

	public static final List<String> NOTIFICATIONS_EMAIL;
	public static final String NOTIFICATION_EMAIL_CUSTOM_SETTING_NAME = 'iPhoneApexNotifications';
	public static final String CONFIG_ITEM_ORG_WIDE_EMAIL_ADDRESS = 'OrgWideEmailAddress';
	
	public static final String MANUAL_FIX_STATUS_FIXED = 'Fixed';
	private static Map<Id,String> requestStringsCache = new Map<Id,String>();
	private static Map<Id,System.Type> requestClassesCache = new Map<Id,System.Type>();
	private static Object manualFixResponse;
	private static List<Id> orgWideEmailAddressId;
	
	static{
   		NOTIFICATIONS_EMAIL = new List<String>();
    	for(GNE_SFA2_User_Notification_Email__c iPhoneApexNotification : GNE_SFA2_User_Notification_Email__c.getAll().values()) {
    		if(iPhoneApexNotification.Name.startsWith(NOTIFICATION_EMAIL_CUSTOM_SETTING_NAME) && String.isNotBlank(iPhoneApexNotification.Email__c)) {
    			NOTIFICATIONS_EMAIL.add(iPhoneApexNotification.Email__c);
    		}
    	}
	}
	
	public static String getServiceSettingValue(String key) {
        return getServiceSettingValue(key, null);
    }
    
    public static String getServiceSettingValue(String key, String defaultValue) {
        GNE_SFA2_OTR_Services_Settings__c serviceSetting = GNE_SFA2_OTR_Services_Settings__c.getValues(key);
        String result = serviceSetting!=null ? serviceSetting.Value_gne__c : null;
        return String.isNotBlank(result) ? result : defaultValue;
    }
    
    public static Id getOrgWideEmailAddressId() {
        if(orgWideEmailAddressId==null) {
            orgWideEmailAddressId = new List<Id>{null};
            String orgWideEmailAddress = getServiceSettingValue(CONFIG_ITEM_ORG_WIDE_EMAIL_ADDRESS);
            
            if(String.isNotBlank(orgWideEmailAddress)) {
                for(OrgWideEmailAddress owea : [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName= :orgWideEmailAddress LIMIT 1]) {
                    orgWideEmailAddressId[0] = owea.Id;
                }
            }
        }
        
        return orgWideEmailAddressId[0];
    }
    
    public static Boolean isNull(String value){
		if(value==null || value.trim().equals('')){
			return true;
		}
		return false;
	}
	
	public static Object getManualFixResponse() {
	    return manualFixResponse;
	}

	//Alter data 
	public static void handleLogging(iPhone_Commons_gne.RestResponse resp, String serviceName, String iPhoneRequestId){
		handleLogging(resp, false, null, serviceName, iPhoneRequestId);
	}

	//PFG
	public static void handleLogging(iPhone_Commons_gne.RestResponse resp, Boolean isDelta, String unixId, String serviceName){
		handleLogging(resp, isDelta, unixId, serviceName, null);
	}

	//Build resp
	public static void handleLogging(Object args, iPhone_Commons_gne.RestResponse resp, String serviceName){
		if (args != null && (args instanceOf iPhone_Commons_gne.BaseArgs)) {
            handleLogging(resp, serviceName, ((iPhone_Commons_gne.BaseArgs)args).getIPhoneRequestId());
        } else if(args != null && (args instanceOf iPhone_Commons_gne.DeltaArgs)){
        	iPhone_Commons_gne.DeltaArgs temp = (iPhone_Commons_gne.DeltaArgs)args;
        	handleLogging(resp, temp.lastSyncDate!=null, temp.unixId, serviceName);
		} else {
			handleLogging(resp, false, null, serviceName, null);
		}
	}

	public static void handleLogging(iPhone_Commons_gne.RestResponse resp, Boolean isDelta, String unixId, String serviceName, String iPhoneRequestId){
		Map<String, String> isl = new Map<String, String>();
		isl.put('Service_name__c', serviceName);
		isl.put('CPU_Time__c', resp.debugInfo.get('cpuTime'));
		isl.put('DML_Rows__c', resp.debugInfo.get('dmlRows'));
		isl.put('DML_Statements__c', resp.debugInfo.get('dmlStatements'));
		isl.put('Execution_Time__c', resp.debugInfo.get('execTime'));
		isl.put('Is_using_delta__c', String.valueOf(isDelta));
		isl.put('Query_Rows__c', resp.debugInfo.get('queryRows'));
		isl.put('Query_Statements__c', resp.debugInfo.get('queryStatements'));
		isl.put('Script_Statements__c', resp.debugInfo.get('scriptStatements'));
		isl.put('UnixId__c', unixId);
		isl.put('iPhone_Request_Id__c', iPhoneRequestId);
   		if(System.isBatch() || System.isFuture() || System.isScheduled()) {
    		createLog(isl);
    	} else {
    		futureCreateLog(isl);
    	}
	}

	public static void createLog(Map<String,String> islMap){
		Integer execTime = islMap.get('Execution_Time__c') != null ? Integer.valueOf(islMap.get('Execution_Time__c')) : null;
		Integer cpuTime = null;
		try{ 
			cpuTime = Integer.valueOf(islMap.get('CPU_Time__c').split('/')[0]);
		} catch(Exception ex){
		}
		Integer dmlRows = null;
		try{ 
			dmlRows = Integer.valueOf(islMap.get('DML_Rows__c').split('/')[0]);
		} catch(Exception ex){
		}
		Integer dmlStatements = null;
		try{ 
			dmlStatements = Integer.valueOf(islMap.get('DML_Statements__c').split('/')[0]);
		} catch(Exception ex){
		}
		Integer queryRows = null;
		try{ 
			queryRows = Integer.valueOf(islMap.get('Query_Rows__c').split('/')[0]);
		} catch(Exception ex){
		}
		Integer queryStatements = null;
		try{ 
			queryStatements = Integer.valueOf(islMap.get('Query_Statements__c').split('/')[0]);
		} catch(Exception ex){
		}
		Integer scriptStatements = null;
		try{ 
			scriptStatements = Integer.valueOf(islMap.get('Script_Statements__c').split('/')[0]);
		} catch(Exception ex){
		}
		Boolean isDelta = islMap.get('Is_using_delta__c') != null ? Boolean.valueOf(islMap.get('Is_using_delta__c')) : false;
		iPhone_Services_Log__c isl = new iPhone_Services_Log__c(
			Service_name__c			= islMap.get('Service_name__c'),
			CPU_Time__c 			= cpuTime,
			DML_Rows__c				= dmlRows,
			DML_Statements__c		= dmlStatements,
			Execution_Time__c		= execTime,
			Is_using_delta__c		= isDelta,
			Query_Rows__c			= queryRows,
			Query_Statements__c		= queryStatements,
			Script_Statements__c	= scriptStatements,
			UnixId__c				= islMap.get('UnixId__c'),
			iPhone_Request_Id__c	= islMap.get('iPhone_Request_Id__c')
		);
		insert isl;
	}

	@future
	public static void futureCreateLog(Map<String,String> islMap){
		Integer execTime = islMap.get('Execution_Time__c') != null ? Integer.valueOf(islMap.get('Execution_Time__c')) : null;
		Integer cpuTime = null;
		try{ 
			cpuTime = Integer.valueOf(islMap.get('CPU_Time__c').split('/')[0]);
		} catch(Exception ex){
		}
		Integer dmlRows = null;
		try{ 
			dmlRows = Integer.valueOf(islMap.get('DML_Rows__c').split('/')[0]);
		} catch(Exception ex){
		}
		Integer dmlStatements = null;
		try{ 
			dmlStatements = Integer.valueOf(islMap.get('DML_Statements__c').split('/')[0]);
		} catch(Exception ex){
		}
		Integer queryRows = null;
		try{ 
			queryRows = Integer.valueOf(islMap.get('Query_Rows__c').split('/')[0]);
		} catch(Exception ex){
		}
		Integer queryStatements = null;
		try{ 
			queryStatements = Integer.valueOf(islMap.get('Query_Statements__c').split('/')[0]);
		} catch(Exception ex){
		}
		Integer scriptStatements = null;
		try{ 
			scriptStatements = Integer.valueOf(islMap.get('Script_Statements__c').split('/')[0]);
		} catch(Exception ex){
		}
		Boolean isDelta = islMap.get('Is_using_delta__c') != null ? Boolean.valueOf(islMap.get('Is_using_delta__c')) : false;
		iPhone_Services_Log__c isl = new iPhone_Services_Log__c(
			Service_name__c			= islMap.get('Service_name__c'),
			CPU_Time__c 			= cpuTime,
			DML_Rows__c				= dmlRows,
			DML_Statements__c		= dmlStatements,
			Execution_Time__c		= execTime,
			Is_using_delta__c		= isDelta,
			Query_Rows__c			= queryRows,
			Query_Statements__c		= queryStatements,
			Script_Statements__c	= scriptStatements,
			UnixId__c				= islMap.get('UnixId__c'),
			iPhone_Request_Id__c	= islMap.get('iPhone_Request_Id__c')
		);
		insert isl;
	}
	
	public static void handleException(Exception e, String requestType, System.Type requestObjClass, Object requestObj, String mainSubject) {
		handleException(e, UserInfo.getUserId(), null, requestType, requestObjClass, null, requestObj, mainSubject);
	}
	
	public static void handleException(Exception e, String requestType, System.Type requestObjClass, String requestId, Object requestObj, String mainSubject) {
		handleException(e, UserInfo.getUserId(), null, requestType, requestObjClass, requestId, requestObj, mainSubject);
	}
	
	public static void handleException(Exception e, Id userId, String appName, String requestType, System.Type requestObjClass, Object requestObj, String mainSubject) {
		handleException(e, userId, appName, requestType, requestObjClass, null, requestObj, mainSubject);
	}
	
	public static void handleException(Exception e, Id userId, String appName, String requestType, System.Type requestObjClass, 
			String requestId, Object requestObj, String mainSubject) {
		Id errorLogId = createErrorLog(e, userId, appName, requestType, requestObjClass, requestId, requestObj);
		//kozminsl: email notification turn off
		/*
		String subject = mainSubject;
		String message = getUserInfoDescription(userId);
		String errorLogKeyPrefix = iPhone_API_Errors__c.sObjectType.getDescribe().getKeyPrefix();
		
		message += String.format('<b>Request Id:</b> {0}<br/><b>Application:</b> {1}<br/><b>Error Log:</b> {2}<br/><br/>' + 
				'<b>Exception:</b> {3}<br/><b>Message:</b> {4}<br/><b>StackTrace:</b><br/>{5}<br/>' +
				'<br/><i>To view List of All Errors, please click {6}</i><br/>', 
				new String[]{
						(String.isNotBlank(requestId) ? requestId : 'N/A'), (String.isNotBlank(appName) ? appName : 'Unknown'), getSalesforceLink(errorLogId, errorLogId), 
						getExceptionType(e), getExceptionMessage(e), e.getStackTraceString(),
						getSalesforceLink(errorLogKeyPrefix,'here')});
		
		sendEmailNotification(subject, message);
		*/
	}
	
	private static String getExceptionType(Exception e) {
		Exception exCause = e.getCause();
		return e.getTypeName() + (exCause!=null ? ' [' + exCause.getTypeName() + ']' : '');
	}
	
	private static String getExceptionMessage(Exception e) {
		Exception exCause = e.getCause();
		return e.getMessage() + ((exCause!=null && !e.getMessage().contains(exCause.getMessage())) ? '\nCaused By: ' + exCause.getMessage() : '');
	}
	
	private static Id createErrorLog(Exception e, Id userId, String appName, String requestType, System.Type requestObjClass, String requestId, Object requestObj) {
		List<iPhone_API_Errors__c> errorPartsToInsert = new List<iPhone_API_Errors__c>();
		iPhone_API_Errors__c mainError;
		Exception causeEx = e.getCause();
		
		Database.DMLOptions dmlOpt = new Database.DMLOptions();
        dmlOpt.allowFieldTruncation = true;
        dmlOpt.optAllOrNone = false;
		
		Integer maxPartSize = iPhone_API_Errors__c.Fields.Details__c.getDescribe().getLength();
		Integer maxExceptionSize = iPhone_API_Errors__c.Fields.Details_Exception__c.getDescribe().getLength();

		String exceptionMessage = getExceptionMessage(e).abbreviate(maxExceptionSize);
		String requestString = serializeRequest(requestObj);
		Integer size = requestString.length();
				
		for(Integer startIdx=0; startIdx<size; startIdx+=maxPartSize) {
			String body = requestString.substring(startIdx, Math.min(startIdx+maxPartSize, size));
			iPhone_API_Errors__c errorPart = new iPhone_API_Errors__c(
					Request_Class__c = (requestObjClass!=null ? requestObjClass.getName() : null),
					Request_Id__c = requestId,
					Details__c = body,
					OwnerId = userId,
					Exception_Type__c = getExceptionType(e),
					Details_Exception__c = exceptionMessage,
					Stack_Trace__c = e.getStackTraceString(),
					Request_Type__c = requestType,
					Application_Name__c = appName,
					User__c = userId,
					Last_Error_Date__c = System.now(),
					Part_No__c = (startIdx/maxPartSize+1),
					Hash_Code__c = string.valueof(System.hashCode(requestId + getExceptionMessage(e) + (startIdx/maxPartSize+1))));
			if(startIdx==0) {
				mainError = errorPart;
				
    			Database.UpsertResult upsertResult = Database.upsert(errorPart, iPhone_API_Errors__c.Hash_Code__c, false);
    			if(!upsertResult.isSuccess()) {
    				for(Database.Error err : upsertResult.getErrors()) {
    					System.debug('WriteErrorLog- Owner : ' + userId + ' requestString : ' + requestString + ' exception : ' + err.getMessage());
    				}
    				
    				break;
    			}
			} else {
				errorPart.Parent_Error__c = mainError.Id;
				errorPartsToInsert.add(errorPart);
			}
		}
		
		if(!errorPartsToInsert.isEmpty()) {
			Database.UpsertResult[] saveResults = Database.upsert(errorPartsToInsert, iPhone_API_Errors__c.Hash_Code__c, false);
			
			for(Database.UpsertResult saveResult : saveResults) {
				if(!saveResult.isSuccess()) {
    				for(Database.Error err : saveResult.getErrors()) {
    					System.debug('WriteErrorLog- Owner : ' + userId + ' requestString : ' + requestString + ' exception : ' + err.getMessage());
    				}
    			}
			}
		}
		
		// This is only additional task, if it fails, do nothing.
		if(mainError!=null) {
		    try {
                checkManualFix(mainError);
		    } catch(Exception ex) {} 
		}
		
		return mainError!=null ? mainError.Id : null;
	}
	
	private static void checkManualFix(iPhone_API_Errors__c mainError) {
	    List<iPhone_API_Errors__c> fixedErrs = [
            SELECT Id, Manual_Fix_Response_Class__c, Manual_Fix_Response__c
            FROM iPhone_API_Errors__c
            WHERE Id = :mainError.Id
                AND Manual_Fix_Status__c = :MANUAL_FIX_STATUS_FIXED
                AND Manual_Fix_Response_Class__c <> null
        ];
        
        for(iPhone_API_Errors__c fixedErr : fixedErrs) {
            System.Type responseClass = System.Type.forName(fixedErr.Manual_Fix_Response_Class__c);
            manualFixResponse = JSON.deserialize(fixedErr.Manual_Fix_Response__c, responseClass);
        }
	}
	
	public static void sendEmailNotification(String subject, String message){
		if(!NOTIFICATIONS_EMAIL.isEmpty()){
			sendEmailNotification(NOTIFICATIONS_EMAIL, subject, message);
		}else{
			System.debug('Email cannot be sent. iPhoneApexNotifications email is not set up.');
		}
	}
	
	public static void sendEmailNotification(List<String> emailAddresses, String subject, String message){
		if(!emailAddresses.isEmpty()) {
			//Create a new single email message object
	        Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();
	        
	        //From Address
	        Id orgWideAddressId = getOrgWideEmailAddressId();
	        
	        if(orgWideAddressId!=null) {
	            singleEmailMsg.setOrgWideEmailAddressId(orgWideAddressId);
	        }
	        //Address
	        singleEmailMsg.setToAddresses(emailAddresses);
	        // Subject
	        singleEmailMsg.setSubject(subject);
	        //Content
	        singleEmailMsg.setHtmlBody(message!=null ? message : '');
	        //Send
	        sendEmails(new Messaging.SingleEmailMessage[] {singleEmailMsg});
		}
	}
    
    public static Boolean validateCoordinates(Decimal lat, Decimal lon, System.Type requestClass, String actionName, String systemName, String rid) {
        Boolean result = true;
        if (!checkCoordinate(lat,-90,90, requestClass, actionName, systemName, rid) || 
            !checkCoordinate(lon, -180, 180, requestClass, actionName, systemName, rid)){
            result = false;
        }            
        return result;
    }
               
    private static Boolean checkCoordinate(Decimal coordinate, Integer leftRange, Integer rightRange, System.Type requestClass, String actionName, String systemName,String rid){
        Boolean result = true;
        if(leftRange > coordinate || coordinate > rightRange || coordinate == null) {
            result = false;
        }
        return result;
    }

	private static String getSalesforceURL(String objectId) {
		return URL.getSalesforceBaseUrl().toExternalForm() + '/' + objectId;
	}
	
	private static String getSalesforceLink(String objectId, String objectName) {
		return String.format('<a href="{0}">{1}</a>', new String[]{getSalesforceURL(objectId), objectName});
	}
	
	private static void sendEmails(List<Messaging.SingleEmailMessage> emails) {
		List<Messaging.Sendemailresult> results = Messaging.sendEmail(emails);
	    Integer idx = 0;
	    for(Messaging.Sendemailresult result : results) {
	    	Messaging.SingleEmailMessage email = emails[idx++];
	    	
		    if (!result.isSuccess()){
		    	for(Messaging.SendEmailError err : result.getErrors()) {
		       		System.debug('Couldn\'t send email. Reason: ' + err.getMessage());
		    	}
		    }	
	    }
	}
	
	private static String getUserInfoDescription(Id requestUserId) {
    	List<String> userInfos = new List<String>{
    			getSalesforceURL(UserInfo.getUserId()), UserInfo.getName(), UserInfo.getUserName(), 
    			getSalesforceURL(UserInfo.getOrganizationId()), UserInfo.getOrganizationName()};
    	
    	String userDesc = String.format('<b>User:</b> <a href="{0}">{1} ({2})</a><br/><b>Organization:</b> <a href="{3}">{4}</a><br/>', userInfos);
    	
    	if(String.isNotBlank(requestUserId) && requestUserId!=UserInfo.getUserId()) {
    		userDesc += '<b>Request User:</b> ' + getSalesforceLink(requestUserId, requestUserId) + '<br/>'; 
    	}
    	
    	return userDesc;
	}
	
	public static String getRequestStringFromErrorLog(Id errorLogId) {
		cacheRequestFromErrorLog(errorLogId);
		return requestStringsCache.get(errorLogId);
	}
	
	public static System.Type getRequestClassFromErrorLog(Id errorLogId) {
		cacheRequestFromErrorLog(errorLogId);
		return requestClassesCache.get(errorLogId);
	}
	
	private static void cacheRequestFromErrorLog(Id errorLogId) {
		String requestString = '';
		System.Type requestClass = null;
		
		for(iPhone_API_Errors__c errorLogPart : [
				SELECT Request_Class__c, Details__c FROM iPhone_API_Errors__c 
				WHERE Id = :errorLogId OR Parent_Error__c = :errorLogId ORDER BY Part_No__c asc]) {
			requestString += errorLogPart.Details__c;
			
			if(requestClass==null && errorLogPart.Request_Class__c!=null) {
				try {
					requestClass = System.Type.forName(errorLogPart.Request_Class__c);
				} catch (System.TypeException ex) {
					// Do nothing
				}
			}	
		}
		
		requestStringsCache.put(errorLogId, requestString);
		requestClassesCache.put(errorLogId, requestClass);
	}
	
	public static Object getRequestObjectFromErrorLog(Id errorLogId) {
		return getRequestObjectFromErrorLog(errorLogId, null);
	}
	
	public static Object getRequestObjectFromErrorLog(Id errorLogId, System.Type requestClass) {
		String requestString = getRequestStringFromErrorLog(errorLogId);
		requestClass = requestClass!=null ? requestClass : getRequestClassFromErrorLog(errorLogId);
		return deserializeRequest(requestString, requestClass);
	}
	
	public static String serializeRequest(Object requestObj) {
		if(requestObj!=null && requestObj instanceOf EnumSerializable) {
			((EnumSerializable)requestObj).serializeEnums();
		}
		
		return JSON.serialize(requestObj);
	}
	
	public static Object deserializeRequest(String requestString, System.Type requestClass) {
		Object requestObj = (String.isNotBlank(requestString) && requestClass!=null) ? JSON.deserialize(requestString, requestClass) : null;
		
		if(requestObj!=null && requestObj instanceOf EnumSerializable) {
			((EnumSerializable)requestObj).deserializeEnums();
		}
		
		return requestObj;
	}
	
	public static void testRequest(Id errorId, String newRequestString) {
		System.Type requestClass = getRequestClassFromErrorLog(errorId);
		newRequestString = newRequestString!=null ? newRequestString : getRequestStringFromErrorLog(errorId);
		testRequest(newRequestString, requestClass);
	}
	
	public static void testRequest(String newRequestString, System.Type requestClass) {
		if(requestClass!=null) {
			Object requestObj = null;
			
			try {
				requestObj = deserializeRequest(newRequestString, requestClass);
			} catch(JSONException ex) {
				throw new TestRequestException('Could not deserialize Request. Reason: ' + ex.getMessage());
			}
			
			if(requestObj instanceof RequestTestable) {
				System.SavePoint sp = Database.setSavePoint();
				try {
					((RequestTestable)requestObj).testRequest();
				} finally {
					Database.rollback(sp);
				}
			}
		} else {
			throw new TestRequestException('Missing Request Class');
		}
	}
	
	public class TestRequestException extends Exception {}
    public class iPhoneBaseException extends Exception {}
	
	public interface EnumSerializable {
		void serializeEnums();
		void deserializeEnums();
	}
	
	public interface RequestTestable {
		void testRequest();
	}
	
	public interface RequestTestable2 extends RequestTestable {
        System.Type getRequestType();
    }
    
    public without sharing class WithoutSharingQueryExecutor {
        public WithoutSharingQueryExecutor() {}
        public List<Product_vod__c> getProducts(Set<Id> prodIds) {
	        return prodIds.isEmpty() ? new List<Product_vod__c>() : [
	          SELECT Id, Name
	          FROM Product_vod__c
	          WHERE Id IN :prodIds
	        ];
	    }
	    
	    public Map<Id,Id> getWinnerIdsMap(Set<Id> ids) {
	        Map<Id,Id> result = new Map<Id,Id>();
	        
	        if(!ids.isEmpty()) {
                List<Merge_Type_Candidate_Stage_gne__c> oldMcs = [
                    SELECT Id_gne__c, ParentId_gne__c
                    FROM Merge_Type_Candidate_Stage_gne__c
                    WHERE   Id_gne__c IN :ids
                        AND DCH_Action_gne__c = :Merge_Type_Util.DCH_ACTION_LOSER
                ];
		        
		        for(Merge_Type_Candidate_Stage_gne__c mc : oldMcs) {
                    if(String.isNotBlank(mc.ParentId_gne__c) && mc.ParentId_gne__c instanceof Id) {
                        result.put(Id.valueOf(mc.Id_gne__c), Id.valueOf(mc.ParentId_gne__c));
                    }
                }
                
                if(result.isEmpty()) {
                    result.putAll(CORE_Merge_Util.getWinnerIdsMap(ids));
                }
	        }
	        
	        for(Id recId : ids) {
	            if(!result.containsKey(recId)) {
	                result.put(recId,recId);
	            }
	        }
	        
	        return result;
	        
	    }
	    
        // This method is deprecated. Use Map<Id,Id> getWinnerIdsMap(Set<Id> ids) instead.
        public List<Address_vod__c> getArchivedLoserAddresses(Set<Id> addrIds) {
	        return [
	            SELECT DCH_Parent_Id_gne__c, DCH_Previous_Id_gne__c
	            FROM Address_vod__c 
	            WHERE DCH_Parent_Id_gne__r.Id != null
	              AND DCH_Action_gne__c = :Merge_Type_Util.DCH_ACTION_CHECKMODE_LOSER
	              AND DCH_Previous_Id_gne__c IN :addrIds
	        ];
	    }
	    
	    // This method is deprecated. Use Map<Id,Id> getWinnerIdsMap(Set<Id> ids) instead.
	    public List<Account> getArchivedLoserAccounts(Set<Id> accIds) {
	        return [
	            SELECT DCH_Parent_Id_gne__c, DCH_Previous_Id_gne__c
	            FROM Account 
	            WHERE DCH_Parent_Id_gne__r.Id != null
	              AND DCH_Action_gne__c = :Merge_Type_Util.DCH_ACTION_CHECKMODE_LOSER
	              AND DCH_Previous_Id_gne__c IN :accIds
	        ];
	    }
    }
}