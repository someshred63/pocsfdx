/************************************************************
*  @author: Bartosz Osowiecki, Roche
*  Date: 2013-12-06
*  Description: 
*  Batch Runner can be used to execute any Batch Process. 
*  Batch Runner checks if given batch is not executed already or if there is a free slot to execute the process.
*  Usage: call GNE_Batch_Runner.executeBatch(yourBatchInstance, yourBatchClassType)
*         or   GNE_Batch_Runner.executeBatch(yourBatchInstance, yourBatchClassType, scope)
*         or   GNE_Batch_Runner.executeBatch(yourBatchInstance, yourBatchClassType, 
*                 emailWhenStarted, emailWhenAlreadyRunning, emailWhenBusy, scheduleWhenBusy)
*         or   GNE_Batch_Runner.executeBatch(yourBatchInstance, yourBatchClassType, scope,
*                 emailWhenStarted, emailWhenAlreadyRunning, emailWhenBusy, scheduleWhenBusy)
*         or   GNE_Batch_Runner.executeBatch(yourBatchInstance, yourBatchClassType, Set<GNE_Batch_Runner.ExecuteProperty> props)
*         or   GNE_Batch_Runner.executeBatch(yourBatchInstance, yourBatchClassType, scope, Set<GNE_Batch_Runner.ExecuteProperty> props)
*
*         If yourBatchInstance implements GNE_Batch_Runner.BatchableBase, you can omit second argument - yourBatchClassType
*************************************************************/
public without sharing virtual class GNE_Batch_Runner {
	
	public enum DMLType {INSERT_DML, UPDATE_DML, UPSERT_DML, DELETE_DML}
	public enum LogErrorType {TRIGGER_ERROR, APEX_ERROR}
	public enum ExecuteStatus {PROCESSING, STARTED, TOO_BUSY}
	public enum ExecuteProperty {EMAIL_WHEN_STARTED, EMAIL_WHEN_ALREADY_RUNNING, EMAIL_WHEN_BUSY, SCHEDULE_WHEN_BUSY}
	
	private static Integer maxBatches;
	private static Integer scheduleAfterMinutes;
	private static List<Batch_Runner_Error_Log_gne__c> logErrorsCache = new List<Batch_Runner_Error_Log_gne__c>();
	private static List<Messaging.SingleEmailMessage> emailsCache = new List<Messaging.SingleEmailMessage>();
	private static Map<String,AsyncApexJob> activeBatchJobsCache;
	private static Boolean isStoreErrorsAndEmailsMode = false;
	private static Boolean isExceptionsInOneEmailMode = true;
	private static Messaging.SingleEmailMessage exceptionsEmailMessage;
	private static Integer exceptionCounter;
	
	public static final Set<String> excludedJobStatuses = 
		new Set<String>{'Aborted', 'Completed', 'Failed'};
		
	public static Boolean getIsStoreErrorsAndEmailsMode() {
		return isStoreErrorsAndEmailsMode == true;
	}
	
	public static void setIsStoreErrorsAndEmailsMode(Boolean newMode) {
		isStoreErrorsAndEmailsMode = newMode;
	}
	
	public static Boolean getIsExceptionsInOneEmailMode() {
		return isExceptionsInOneEmailMode == true;
	}
	
	public static void setIsExceptionsInOneEmailMode(Boolean newMode) {
		isExceptionsInOneEmailMode = newMode;
	}
	
	public static Integer getMaxBatches() {
		return maxBatches!=null ? maxBatches : GNE_Batch_Runner_Config.getActiveBatchesMaxSize();
	}
	
	public static void setMaxBatches(Integer newMaxBatches) {
		maxBatches = newMaxBatches;
	}
	
	public static Integer getScheduleAfterMinutes() {
		return scheduleAfterMinutes!=null ? scheduleAfterMinutes : 1;
	}
	
	public static void setScheduleAfterMinutes(Integer newScheduleAfterMinutes) {
		scheduleAfterMinutes = newScheduleAfterMinutes;
	}

    public static void scheduleBatchBasedOnSettings(Schedulable schedulable, String scheduleName, String jobName) {
		Integer scheduleIndex = 0;
		List<CronTrigger> currentlyScheduledJobs = [
				SELECT Id, CronJobDetail.Name
				FROM CronTrigger
				WHERE CronJobDetail.Name LIKE :jobName + '%'];

		if(currentlyScheduledJobs.size() > 0) {
			try {
				scheduleIndex = Integer.valueOf(currentlyScheduledJobs[0].CronJobDetail.Name.right(1));
			} catch (Exception e) {
				throw new JobNameMalformedException('Job Name does not end with index number so cannot fetch next schedule for this job.');
			}
			scheduleIndex += 1;

			system.abortJob(currentlyScheduledJobs[0].id);
		}

		scheduleJobBasedOnConfig(scheduleName, scheduleIndex, jobName, schedulable);
    }

	private static void scheduleJobBasedOnConfig(String scheduleName, Integer scheduleIndex, String jobName, Schedulable schedulable) {
		String scheduleNameFull = scheduleName + ':' + scheduleIndex;
		List<String> scheduleForBatch = GNE_Batch_Runner_Config.getScheduleForBatch(scheduleNameFull);
		if (scheduleForBatch.size() > 0) {
			System.schedule(jobName + ':' + scheduleIndex, scheduleForBatch[0], schedulable);
		} else if(scheduleIndex == 1 && scheduleForBatch.size() == 0) {
			throw new ScheduleNotFoundException('Could not find schedule with name: ' + scheduleNameFull);
		} else {
			scheduleJobBasedOnConfig(scheduleName, 1, jobName, schedulable);
		}
	}

	public static ExecuteResult exeuteBatch(BatchableBase batch) {
		return executeBatch((Database.Batchable<SObject>)batch, batch.getBatchClass(), null, new Set<ExecuteProperty>(),  new ExecuteResult());
	}
	
	public static ExecuteResult exeuteBatch(Database.Batchable<SObject> batch, System.Type batchClass) {
		return executeBatch(batch, batchClass, null, new Set<ExecuteProperty>(),  new ExecuteResult());
	}
	
	public static ExecuteResult executeBatch(BatchableBase batch, 
			Boolean emailWhenStarted, Boolean emailWhenAlreadyRunning, Boolean emailWhenBusy, Boolean scheduleWhenBusy) {
		
		return executeBatch((Database.Batchable<SObject>)batch, batch.getBatchClass(), null, emailWhenStarted, emailWhenAlreadyRunning, emailWhenBusy, scheduleWhenBusy);
	}
	
	
	public static ExecuteResult executeBatch(Database.Batchable<SObject> batch, System.Type batchClass, 
			Boolean emailWhenStarted, Boolean emailWhenAlreadyRunning, Boolean emailWhenBusy, Boolean scheduleWhenBusy) {
		
		return executeBatch(batch, batchClass, null, emailWhenStarted, emailWhenAlreadyRunning, emailWhenBusy, scheduleWhenBusy);
	}
	
	public static ExecuteResult executeBatch(BatchableBase batch, Set<ExecuteProperty> props) {
		return executeBatch((Database.Batchable<SObject>)batch, batch.getBatchClass(), null, props,  new ExecuteResult());
	}
	
	public static ExecuteResult executeBatch(Database.Batchable<SObject> batch, System.Type batchClass, Set<ExecuteProperty> props) {
		return executeBatch(batch, batchClass, null, props,  new ExecuteResult());
	}
	
	public static ExecuteResult executeBatch(BatchableBase batch, Integer scope) {
		return executeBatch((Database.Batchable<SObject>)batch, batch.getBatchClass(), scope,  new Set<ExecuteProperty>(), new ExecuteResult());
	}
	
	public static ExecuteResult executeBatch(Database.Batchable<SObject> batch, System.Type batchClass, Integer scope) {
		return executeBatch(batch, batchClass, scope,  new Set<ExecuteProperty>(), new ExecuteResult());
	}
	
	public static ExecuteResult executeBatch(BatchableBase batch, Integer scope, 
			Boolean emailWhenStarted, Boolean emailWhenAlreadyRunning, Boolean emailWhenBusy, Boolean scheduleWhenBusy) {
		return executeBatch((Database.Batchable<SObject>)batch, batch.getBatchClass(), scope, 
			emailWhenStarted, emailWhenAlreadyRunning, emailWhenBusy, scheduleWhenBusy);		
	}
	
	public static ExecuteResult executeBatch(Database.Batchable<SObject> batch, System.Type batchClass, Integer scope, 
			Boolean emailWhenStarted, Boolean emailWhenAlreadyRunning, Boolean emailWhenBusy, Boolean scheduleWhenBusy) {
		
		Set<ExecuteProperty> props = new Set<ExecuteProperty>();
		if (emailWhenStarted==true) { props.add(ExecuteProperty.EMAIL_WHEN_STARTED); }
		if (emailWhenAlreadyRunning==true) { props.add(ExecuteProperty.EMAIL_WHEN_ALREADY_RUNNING); }
		if (emailWhenBusy==true) { props.add(ExecuteProperty.EMAIL_WHEN_BUSY); }
		if (scheduleWhenBusy==true) { props.add(ExecuteProperty.SCHEDULE_WHEN_BUSY); }
		
		return executeBatch(batch, batchClass, scope,  props, new ExecuteResult());
	}
	
	public static ExecuteResult executeBatch(BatchableBase batch, Integer scope, Set<ExecuteProperty> props) {
		return executeBatch((Database.Batchable<SObject>)batch, batch.getBatchClass(), scope,  props, new ExecuteResult());
	}
	
	public static ExecuteResult executeBatch(Database.Batchable<SObject> batch, System.Type batchClass, Integer scope, Set<ExecuteProperty> props) {
		return executeBatch(batch,batchClass, scope,  props, new ExecuteResult());
	}
	
	public static ExecuteResult executeBatch(BatchableBase batch, Integer scope, Set<ExecuteProperty> props, ExecuteResult result) {
		return executeBatch((Database.Batchable<SObject>)batch, batch.getBatchClass(), scope, props, result);
	}
	
	public static ExecuteResult executeBatch(Database.Batchable<SObject> batch, System.Type batchClass, Integer scope, Set<ExecuteProperty> props, ExecuteResult result) {
		String batchClassName = batchClass.getName();
		Set<String> activeBatchJobClassNames = getActiveBatchJobClassNames();
        
        if (activeBatchJobClassNames.contains(batchClassName)) {
        	result.setStatus(ExecuteStatus.PROCESSING);
        	actionOnAlreadyRunning(batch, batchClass, scope, props, result);
        } else if (activeBatchJobClassNames.size() >= getMaxBatches()) {
        	result.setStatus(ExecuteStatus.TOO_BUSY);
            actionOnBusy(batch, batchClass, scope, props, result);
        } else {
            if(scope!=null) {
            	result.setJobId(Database.executeBatch(batch,scope));
            } else {
            	result.setJobId(Database.executeBatch(batch));
            }
            
            // Clear cache. It need to be recalculated, because new job was created
            activeBatchJobsCache = null;
            
            result.setStatus(ExecuteStatus.STARTED);
            actionOnStarted(batch, batchClass, scope, props, result);
        }
        		
		return result;
	}
	
	private static void actionOnStarted(Database.Batchable<SObject> batch, System.Type batchClass, Integer scope, Set<ExecuteProperty> props, ExecuteResult result) {
		if(props.contains(ExecuteProperty.EMAIL_WHEN_STARTED)) {
			if(batch instanceof Batchable) {
				sendEmailNotification((Batchable)batch, System.Label.GNE_BATCH_RUNNER_BATCH_PROCESS_STARTED);
			} else {
				sendEmailNotification(batchClass, System.Label.GNE_BATCH_RUNNER_BATCH_PROCESS_STARTED);
			}
		}
	}
	
	private static void actionOnAlreadyRunning(Database.Batchable<SObject> batch, System.Type batchClass, Integer scope, Set<ExecuteProperty> props, ExecuteResult result) {
		if(props.contains(ExecuteProperty.EMAIL_WHEN_ALREADY_RUNNING)) {
			if(batch instanceof Batchable) {
				sendEmailNotification((Batchable)batch, System.Label.GNE_BATCH_RUNNER_BATCH_PROCESS_ALREADY_RUNNING);
			} else {
				sendEmailNotification(batchClass, System.Label.GNE_BATCH_RUNNER_BATCH_PROCESS_ALREADY_RUNNING);
			}
		}
	}
	
	private static void actionOnBusy(Database.Batchable<SObject> batch, System.Type batchClass, Integer scope, Set<ExecuteProperty> props, ExecuteResult result) {
		String className = batchClass.getName();
		
		if(props.contains(ExecuteProperty.SCHEDULE_WHEN_BUSY)) {
			if(scope!=null) {
            	result.setJobId(System.scheduleBatch(batch, className, getScheduleAfterMinutes(), scope));
            } else {
            	result.setJobId(System.scheduleBatch(batch, className, getScheduleAfterMinutes()));
            }
			
			result.setStatus(ExecuteStatus.STARTED);
		} else if(props.contains(ExecuteProperty.EMAIL_WHEN_BUSY)) {
			String message = String.format(System.Label.GNE_BATCH_RUNNER_BATCH_TOO_MANY_RUNNING_JOBS, new String[]{String.valueOf(getMaxBatches())});
			if(batch instanceof Batchable) {
				sendEmailNotification((Batchable)batch, message);
			} else {
				sendEmailNotification(batchClass, message);
			}
		}
	}
	
	public static List<String> getEmailsForBatch(System.Type batchClass) {
		return GNE_Batch_Runner_Config.getEmailsForBatchWithDefault(batchClass.getName());
	}
	
	public static List<String> getEmailsForBatch(BatchableBase batch) {
		return getEmailsForBatch(batch.getBatchClass());
	}
	
	public static void handleException(Exception ex) {
		handleException(null, null, GNE_Batch_Runner_Config.getEmailsFromStackTrace(), ex, null);
	}
	
	public static void handleException(Exception ex, List<String> emails) {
		handleException(null, null, emails, ex, null);
	}
	
	public static void handleException(System.Type batchClass, Exception ex) {
		handleException(null, batchClass, GNE_Batch_Runner_Config.getEmailsForBatchWithDefault(batchClass.getName()), ex, null);
	}
	
	public static void handleException(BatchableBase batch, Exception ex) {
		System.Type batchClass = batch.getBatchClass();
		handleException(batch, batchClass, GNE_Batch_Runner_Config.getEmailsForBatchWithDefault(batchClass.getName()), ex, null);
	}
	
	public static void handleException(BatchableBase batch, Exception ex, SObject sObj) {
		System.Type batchClass = batch.getBatchClass();
		handleException(batch, batchClass, GNE_Batch_Runner_Config.getEmailsForBatchWithDefault(batchClass.getName()), ex, sObj);
	}
	
	public static void handleException(System.Type batchClass, List<String> emails, Exception ex) {
		handleException(null, batchClass, GNE_Batch_Runner_Config.getEmailsForBatchWithDefault(batchClass.getName()), ex, null);
	}
	
	public static void handleException(BatchableBase batch, System.Type batchClass, List<String> emails, Exception ex, SObject sObj) {
		String emailBody = (getIsExceptionsInOneEmailMode() ? '' : ('Type: ' + ex.getTypeName() + '\n')) + 'StackTrace:\n' + ex.getStackTraceString();
		
		if(batch!=null) {
			if(sObj!=null) {
				emailBody = String.format('Record: {0}\n{1}', new String[]{batch.getRecordDescription(sObj), emailBody});	
			}
			
			if(getIsStoreErrorsAndEmailsMode()) {
				logErrorsCache.add(createErrorLog(batch, sObj, ex));
			} else {
				insertLogErrors(batch, new List<Batch_Runner_Error_Log_gne__c>{createErrorLog(batch, sObj, ex)});
			}
		}
		
		if(getIsStoreErrorsAndEmailsMode() && getIsExceptionsInOneEmailMode()) {
			exceptionCounter = exceptionCounter==null ? 1 : exceptionCounter+1;
			emailBody = String.format('{0}. {1}: {2}\n[{3}]\n', new String[]{String.valueOf(exceptionCounter), ex.getTypeName(), ex.getMessage(), emailBody});
			
			String subjectPrefix = 'Raised Exceptions';
			String subject = subjectPrefix + ' (' + exceptionCounter + ')';
			
			if(exceptionsEmailMessage==null) {
				exceptionsEmailMessage = sendEmailNotification(batch, batchClass, emails, subject, 'List of Exceptions:\n' + emailBody);
			} else {
				exceptionsEmailMessage.setPlainTextBody(exceptionsEmailMessage.getPlainTextBody() + '\n' + emailBody);
				String prevSubject = exceptionsEmailMessage.getSubject();
				exceptionsEmailMessage.setSubject(prevSubject.left(prevSubject.lastIndexOf(subjectPrefix)) + subject);
			}
		} else {
			sendEmailNotification(batch, batchClass, emails, '[Exception] ' + ex.getMessage(), emailBody);
		}
	}
		
	public static Messaging.SingleEmailMessage sendErrorEmailNotification(String errorMessage) {
		return sendErrorEmailNotification(null, null, GNE_Batch_Runner_Config.getEmailsFromStackTrace(),errorMessage);
	}
	
	public static Messaging.SingleEmailMessage sendErrorEmailNotification(System.Type batchClass, String errorMessage) {
		return sendErrorEmailNotification(null, batchClass, GNE_Batch_Runner_Config.getEmailsForBatchWithDefault(batchClass.getName()), errorMessage);
	}
	
	public static Messaging.SingleEmailMessage sendErrorEmailNotification(BatchableBase batch, String errorMessage) {
		System.Type batchClass = batch.getBatchClass();
		return sendErrorEmailNotification(batch, batchClass, GNE_Batch_Runner_Config.getEmailsForBatchWithDefault(batchClass.getName()), errorMessage);
	}
	
	public static Messaging.SingleEmailMessage sendErrorEmailNotification(System.Type batchClass, List<String> emails, String errorMessage) {
		return sendErrorEmailNotification(null, batchClass, GNE_Batch_Runner_Config.getEmailsForBatchWithDefault(batchClass.getName()), errorMessage);
	}
	
	public static Messaging.SingleEmailMessage sendErrorEmailNotification(Batchable batch, List<String> emails, String errorMessage) {
		System.Type batchClass = batch.getBatchClass();
		return sendErrorEmailNotification(batch, batchClass, emails, errorMessage);
	}
	
	public static Messaging.SingleEmailMessage sendErrorEmailNotification(BatchableBase batch, System.Type batchClass, List<String> emails, String errorMessage) {
		errorMessage = '[Batch Error] ' + errorMessage;
		return sendEmailNotification(batch, batchClass, emails, errorMessage, null);
	}
	
	public static Messaging.SingleEmailMessage sendEmailNotification(String subject) {
		return sendEmailNotification(null, null, GNE_Batch_Runner_Config.getEmailsFromStackTrace(), subject, null);
	}
	
	public static Messaging.SingleEmailMessage sendEmailNotification(String subject, String message) {
		return sendEmailNotification(null, null, GNE_Batch_Runner_Config.getEmailsFromStackTrace(), subject, message);
	}
	
	public static Messaging.SingleEmailMessage sendEmailNotification(System.Type batchClass, String subject) {
		return sendEmailNotification(null, batchClass, GNE_Batch_Runner_Config.getEmailsForBatchWithDefault(batchClass.getName()), subject, null);
	}
	
	public static Messaging.SingleEmailMessage sendEmailNotification(BatchableBase batch, String subject) {
		System.Type batchClass = batch.getBatchClass();
		return sendEmailNotification(batch, batchClass, GNE_Batch_Runner_Config.getEmailsForBatchWithDefault(batchClass.getName()), subject, null);
	}
	
	public static Messaging.SingleEmailMessage sendEmailNotification(System.Type batchClass, String subject, String message) {
		return sendEmailNotification(null, batchClass, GNE_Batch_Runner_Config.getEmailsForBatchWithDefault(batchClass.getName()), subject, message);
	}
	
	public static Messaging.SingleEmailMessage sendEmailNotification(BatchableBase batch, String subject, String message) {
		System.Type batchClass = batch.getBatchClass();
		return sendEmailNotification(batch, batchClass, GNE_Batch_Runner_Config.getEmailsForBatchWithDefault(batchClass.getName()), subject, message);
	}
	
	public static Messaging.SingleEmailMessage sendEmailNotification(System.Type batchClass, List<String> emails, String subject) {
		return sendEmailNotification(null, batchClass, emails, subject, null);
	}
	
	public static Messaging.SingleEmailMessage sendEmailNotification(BatchableBase batch, List<String> emails, String subject) {
		return sendEmailNotification(batch, batch.getBatchClass(), emails, subject, null);
	}
	
	public static Messaging.SingleEmailMessage sendEmailNotification(System.Type batchClass, List<String> emails, String subject, String message) {
		return sendEmailNotification(null, batchClass, emails, subject, message);
	}
	
	public static Messaging.SingleEmailMessage sendEmailNotification(BatchableBase batch, List<String> emails, String subject, String message) {
		return sendEmailNotification(batch, batch.getBatchClass(), emails, subject, message);
	}
	
	public static Messaging.SingleEmailMessage sendEmailNotification(BatchableBase batch, System.Type batchClass, List<String> emails, String subject, String message) {
		Messaging.SingleEmailMessage emailMsg = null;
		
		if(batch!=null) {
			String batchName = batch.getBatchName();
			
			if(batchName!=null) {
				subject = '[' + batchName + '] ' + subject;
			}
		} else if (batchClass != null) {
			String className = batchClass.getName();
			subject = '[' + className + '] ' + subject;
		}
		
		String uInfo = getUserInfoDescription();
		
		message = uInfo + getBatchJobDescription(batch) + (message!=null ? '\n' + message : '');
		
		if(!emails.isEmpty()) {
			//Create a new single email message object
	        emailMsg = new Messaging.SingleEmailMessage();
	        Id orgWideAddressId = GNE_Batch_Runner_Config.getOrgWideEmailAddressId();
        
            if(orgWideAddressId!=null) {
                emailMsg.setOrgWideEmailAddressId(orgWideAddressId);
            }
            
	        //Address
	        emailMsg.setToAddresses(emails);
	        // Subject
	        emailMsg.setSubject(subject);
	        //Content
	        emailMsg.setPlainTextBody(message!=null ? message : '');
	        //Send
	        if(getIsStoreErrorsAndEmailsMode()) {
	        	emailsCache.add(emailMsg);
	        } else {
	        	sendEmails(batch, new Messaging.SingleEmailMessage[] {emailMsg});
	        }
		}
		
		return emailMsg;
	}
	
	private static String getUserInfoDescription() {
		return String.format('User: {0} ({1}, {2})\nOrganization: {3} ({4}, {5})\n', new String[]{
				UserInfo.getName(), UserInfo.getUserId(), UserInfo.getUserName(), UserInfo.getOrganizationName(), UserInfo.getOrganizationId(), getSalesforceBaseUrl()});
	}
	
	private static String getBatchJobDescription(BatchableBase batch) {
		String result = '';
		AsyncApexJob job = null;
		if(batch!=null && (job = getBatchJob(batch))!=null) {
			result = String.format('Batch Start Time: {0}\nBatch Id: {1}\nBatch Progress: {2}/{3}\nBatch Class: {4} ({5})\n',
					new String[] {
						job.CreatedDate.format('yyyy-MM-dd HH:mm:ss.S (z, XXX)'),
						job.Id,
						String.valueOf(job.JobItemsProcessed + Math.min(1,job.TotalJobItems)),
						String.valueOf(job.TotalJobItems),
						job.ApexClass.Name,
						getSalesforceURL(job.ApexClassId)});
		}
		
		return result;
	}
	
	private static String getSalesforceBaseUrl() {
	    return URL.getSalesforceBaseUrl().toExternalForm();
	}
	
	private static String getSalesforceURL(String internalUrl) {
		return getSalesforceBaseUrl() + (internalUrl.startsWith('/') ? '' : '/') + internalUrl;
	}
	
	public static void sendEmails(BatchableBase batch) {
		sendEmails(batch, emailsCache);
	}
	
	public static void sendEmails(BatchableBase batch, List<Messaging.SingleEmailMessage> emails) {
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
	
	public static void executeDML(Batchable batch, List<SObject> sObjs, DMLType dType, String actionId, String actionDescription) {
		executeDML(batch, sObjs, dType, actionId, actionDescription, true, true);
	}
	
	public static void executeDML(Batchable batch, List<SObject> sObjs, DMLType dType, String actionId, String actionDescription,
			Boolean sendEmailNotification, Boolean logErrors) {
    	if(!sObjs.isEmpty()) {
    		Database.SaveResult[] saveResults = null;
	    	Database.UpsertResult[] upsertResults = null;
	    	Database.DeleteResult[] deleteResults = null;
	    	if(dType == DMLType.INSERT_DML) {
	    		saveResults = Database.Insert(sObjs, false);
	    	} else if(dType == DMLType.UPDATE_DML) {
	    		saveResults = Database.Update(sObjs, false); 
	    	} else if(dType == DMLType.UPSERT_DML) {
	    		upsertResults = Database.Upsert(sObjs, false); 
	    	} else if(dType == DMLType.DELETE_DML) {
	    		deleteResults = Database.Delete(sObjs, false);
	    	}
	    	
	    	Map<String,List<Database.Error>> recToErrorsMap = getErrorsFromDmlResults(batch, sObjs, saveResults, upsertResults, deleteResults);
	    	batch.processDatabaseErrors(sObjs, recToErrorsMap, actionId, actionDescription);
	    	processDatabaseErrors(batch, sObjs, recToErrorsMap, actionId, actionDescription, sendEmailNotification, logErrors);
    	}
	}
	
	public static Map<String, List<Database.Error>> getErrorsFromDmlResults(Batchable batch, List<SObject> sObjs, Database.SaveResult[] saveResults) {
		return getErrorsFromDmlResults(batch, sObjs, saveResults, null, null);
	}
	
	public static Map<String, List<Database.Error>> getErrorsFromDmlResults(Batchable batch, List<SObject> sObjs, Database.UpsertResult[] upsertResults) {
		return getErrorsFromDmlResults(batch, sObjs, null, upsertResults, null);
	}
	
	public static Map<String, List<Database.Error>> getErrorsFromDmlResults(Batchable batch, List<SObject> sObjs, Database.DeleteResult[] deleteResults) {
		return getErrorsFromDmlResults(batch, sObjs, null, null, deleteResults);
	}
	
	private static Map<String, List<Database.Error>> getErrorsFromDmlResults(Batchable batch, List<SObject> sObjs, 
    		Database.SaveResult[] saveResults, Database.UpsertResult[] upsertResults, Database.DeleteResult[] deleteResults) {
    	
    	Map<String, List<Database.Error>> recToErrorsMap = new Map<String, List<Database.Error>>();
    		
		if(saveResults!=null) {
	    	Integer idx = 0;
	    	for(Database.SaveResult result : saveResults) {
	    		cacheDmlErrors(batch, sObjs[idx++], result.isSuccess(), result.getErrors(), recToErrorsMap);
	    	}
		} else if(upsertResults!=null) {
	    	Integer idx = 0;
	    	for(Database.UpsertResult result : upsertResults) {
	    		cacheDmlErrors(batch, sObjs[idx++], result.isSuccess(), result.getErrors(), recToErrorsMap);
	    	}
	    } else if(deleteResults!=null) {
	    	Integer idx = 0;
	    	for(Database.DeleteResult result : deleteResults) {
	    		cacheDmlErrors(batch, sObjs[idx++], result.isSuccess(), result.getErrors(), recToErrorsMap);
	    	}
	    }
	    
	    return recToErrorsMap;
    }
    
    private static void cacheDmlErrors(Batchable batch, SObject sObj, Boolean isSuccess, Database.Error[] errors, Map<String, List<Database.Error>> recToErrorsMap) {
    	if(!isSuccess) {
    		String sObjKey = batch.getKeyForRecord(sObj);
	    	
	    	if(!recToErrorsMap.containsKey(sObjKey)) {
	    		recToErrorsMap.put(sObjKey,new List<Database.Error>());
	    	}
	    		
	    	recToErrorsMap.get(sObjKey).addAll(errors);
		}
    }
    	
    public static void processDatabaseErrors(Batchable batch, List<SObject> sObjs, Map<String,List<Database.Error>> recToErrorsMap, 
    		String actionId, String actionDescription, Boolean sendEmailNotification, Boolean logErrors) {
    		
	   	if(sendEmailNotification == true || logErrors == true) {
	    	List<String> errorMsgs = new List<String>();
	    	List<Batch_Runner_Error_Log_gne__c> errorLogs = new List<Batch_Runner_Error_Log_gne__c>();
	    	
	    	for(SObject sObj : sObjs) {
	    		String sObjKey = batch.getKeyForRecord(sObj);
	    		List<Database.Error> errors;
	    		
	    		if(recToErrorsMap.containsKey(sObjKey) && !(errors = recToErrorsMap.get(sObjKey)).isEmpty()) {
	    			for(Database.Error err : errors) {
	    				if(sendEmailNotification == true) {
	    					errorMsgs.add((errorMsgs.size()+1) + '. ' + batch.getErrorEmailDescription(actionId, sObj, err));
	    				}
	    				
	    				if(logErrors == true) {
	    					errorLogs.add(createErrorLog(batch, sObj, err));
	    				}
	    			}
	    		}
	    	}
	    	
	    	if(!errorMsgs.isEmpty()) {
	   			sendDatabaseErrorsEmailNotification(batch, actionId, actionDescription, errorMsgs);
	   		}
	   		
	   		if(!errorLogs.isEmpty()) {
	   			if(getIsStoreErrorsAndEmailsMode()) {
	   				logErrorsCache.addAll(errorLogs);
	   			} else {
	   				insertLogErrors(batch, errorLogs);	
	   			}
	   		}
	   	}
    }
    
    public static void sendDatabaseErrorsEmailNotification(Batchable batch, String actionId, String actionDescription, List<String> errorMsgs) {
    	
    	GNE_Batch_Runner.sendEmailNotification(batch, 
    			'[' + actionDescription + '] Database Errors (' + errorMsgs.size()  + ')',
    			'List of Errors:\n' + String.join(errorMsgs,'\n'));
    }
    
    public static Batch_Runner_Error_Log_gne__c createErrorLog(BatchableBase batch, SObject sObj, Database.Error err) {
    	return createErrorLog(batch, sObj, LogErrorType.TRIGGER_ERROR, String.valueOf(err.getStatusCode()), err.getMessage(), err.getMessage());	
    }
    
    public static Batch_Runner_Error_Log_gne__c createErrorLog(BatchableBase batch, SObject sObj, Exception ex) {
    	return createErrorLog(batch, sObj, LogErrorType.APEX_ERROR, ex.getTypeName(), ex.getMessage(), ex.getMessage() + '\nStackTrace:\n['+ ex.getStackTraceString() +']');	
    }
    
    public static Batch_Runner_Error_Log_gne__c createErrorLog(BatchableBase batch, SObject sObj, String errorMessage) {
    	return createErrorLog(batch, sObj, LogErrorType.APEX_ERROR, null, errorMessage, errorMessage);
    }
    
    public static Batch_Runner_Error_Log_gne__c createErrorLog(BatchableBase batch, SObject sObj, LogErrorType errorType, String errorSubtype, 
    		String errorShortMessage, String errorMessage) {
    	Batch_Runner_Error_Log_gne__c logError = new Batch_Runner_Error_Log_gne__c(
    			Record_Id_gne__c = (sObj!=null ? sObj.Id : null),
    			Record_Key_gne__c = (sObj!=null ? batch.getKeyForRecord(sObj) : null),
    			Record_Description_gne__c = (sObj!=null ? batch.getRecordDescription(sObj) : null),
    			Batch_Name_gne__c = batch.getBatchName(),
    			Batch_Class_gne__c = batch.getBatchClass().getName(),
    			Batch_Job_Id_gne__c = getBatchJobId(batch),
    			Batch_Start_Date_gne__c = getBatchJobCreatedDate(batch),
    			Error_Type_gne__c = errorType.name(),
    			Error_Subtype_gne__c = errorSubtype,
    			Error_Short_Description_gne__c = errorShortMessage,
    			Error_Description_gne__c = errorMessage);
    	return logError;
    }
    
    public static void insertLogsAndSendEmails(BatchableBase batch) {
    	insertLogErrors(batch);
    	sendEmails(batch);
    }
    
    public static void insertLogErrors(BatchableBase batch) {
    	insertLogErrors(batch,logErrorsCache);
    }
    
    public static void insertLogErrors(BatchableBase batch, List<Batch_Runner_Error_Log_gne__c> logErrorsToInsert) {
    	if(!logErrorsToInsert.isEmpty()) {
    		Database.DMLOptions dml = new Database.DMLOptions();
        	dml.allowFieldTruncation = true;
        	dml.optAllOrNone = false;
    		Database.Saveresult[] saveResults = Database.insert(logErrorsToInsert, dml);
    		
    		for(Database.Saveresult result : saveResults) {
    			if(!result.isSuccess()) {
    				for(Database.Error err : result.getErrors()) {
    					System.debug('Error while inserting Error in Batch Runner Log: ' + err.getMessage());
    				}
    			}
    		}
    	}
    }
    
    private static void cacheActiveBatchJobs() {
		if(activeBatchJobsCache==null) {
			activeBatchJobsCache = new Map<String,AsyncApexJob>();
			
			for(AsyncApexJob job : [SELECT Id, ApexClass.Name, CreatedDate, JobItemsProcessed, TotalJobItems, ApexClassId
         			FROM AsyncApexJob 
         			WHERE Status NOT IN :excludedJobStatuses 
         			AND JobType = 'BatchApex']) {
         		activeBatchJobsCache.put(job.ApexClass.Name, job);		
         	}
		}
	}
	
	private static Set<String> getActiveBatchJobClassNames() {
		if(activeBatchJobsCache==null) {
			cacheActiveBatchJobs();
		}
		
		return activeBatchJobsCache.keySet();
	}
	
	public static AsyncApexJob getBatchJob(BatchableBase batch) {
		if(activeBatchJobsCache==null) {
			cacheActiveBatchJobs();
		}
		
		return activeBatchJobsCache.get(batch.getBatchClass().getName());
	}
	
	public static Id getBatchJobId(BatchableBase batch) {
		AsyncApexJob job = getBatchJob(batch);
		return job!=null ? job.id : null;
	}
	
	public static DateTime getBatchJobCreatedDate(BatchableBase batch) {
		AsyncApexJob job = getBatchJob(batch);
		return job!=null ? job.CreatedDate : null;
	}
	
	public static Integer getBatchJobItemsProcessed(BatchableBase batch) {
		AsyncApexJob job = getBatchJob(batch);
		return job!=null ? job.JobItemsProcessed : null;
	}
	
	public static Integer getBatchJobTotalItems(BatchableBase batch) {
		AsyncApexJob job = getBatchJob(batch);
		return job!=null ? job.TotalJobItems : null;
	}
	
	public static Id getBatchJobClassId(BatchableBase batch) {
		AsyncApexJob job = getBatchJob(batch);
		return job!=null ? job.ApexClassId : null;
	}
	
	public static String getBatchJobClassName(BatchableBase batch) {
		AsyncApexJob job = getBatchJob(batch);
		return job!=null ? job.ApexClass.Name : null;
	}
	
	public static Database.QueryLocator doStart(BatchableBase batch, Database.BatchableContext BC) {
		Database.QueryLocator result = null;
		setIsStoreErrorsAndEmailsMode(true);
    	System.Savepoint sp = Database.setSavepoint();
        
        try {
        	result = batch.intStart(BC);
        } catch(Exception ex) {
        	Database.rollback(sp);
        	handleException(batch, ex);
        } finally {
        	insertLogsAndSendEmails(batch);
        }
        
        return result;
	}
	
	public static void doExecute(BatchableBase batch, Database.BatchableContext BC, List<sObject> scope) {
		Database.QueryLocator result = null;
		setIsStoreErrorsAndEmailsMode(true);
    	System.Savepoint sp = Database.setSavepoint();
    	
        try {
        	batch.intExecute(BC, scope);
        } catch(Exception ex) {
        	Database.rollback(sp);
        	handleException(batch, ex);
        } finally {
        	insertLogsAndSendEmails(batch);
        }
	}
	
	public static void doFinish(BatchableBase batch, Database.BatchableContext BC) {
		Database.QueryLocator result = null;
		setIsStoreErrorsAndEmailsMode(true);
		System.Savepoint sp = Database.setSavepoint();
    	
        try {
        	batch.intFinish(BC);
        } catch(Exception ex) {
        	Database.rollback(sp);
        	handleException(batch, ex);
        } finally {
        	insertLogsAndSendEmails(batch);
        }
	}
	
	public virtual class ExecuteResult {
		private ExecuteStatus status;
		private Id jobId;
		
		public ExecuteResult() {}
		
		public virtual String getStatus() {
			return status!=null ? status.name() : null;
		}
		
		public virtual void setStatus(ExecuteStatus newStatus) {
			status = newStatus;
		}
		
		public virtual Id getJobId() {
			return jobId;
		}
		
		public virtual void setJobId(Id newJobId) {
			jobId = newJobId;
		}
	}
	
	public interface BatchableBase {
		System.Type getBatchClass();
		String getBatchName();
		String getKeyForRecord(SObject sObj);
		String getRecordDescription(SObject sObj);
		
		Database.QueryLocator intStart(Database.BatchableContext BC);
		void intExecute(Database.BatchableContext BC, List<sObject> scope);
		void intFinish(Database.BatchableContext BC);
	}
	
	public interface Batchable extends BatchableBase {
		void processDatabaseErrors(List<SObject> sObjs, Map<String,List<Database.Error>> recToErrorsMap, String actionId, String actionDescription);
		String getErrorEmailDescription(String actionId, SObject sObj, Database.Error err);
	}

	public class JobNameMalformedException extends Exception {
		String message {get; set;}
	}

	public class ScheduleNotFoundException extends Exception {
		String message {get; set;}
	}
}