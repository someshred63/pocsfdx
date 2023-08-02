global without sharing class GNE_Subscribe_Account_Exclusion implements Database.Batchable<SObject>, Database.Stateful {
	
	private final String STATUS_LOADED = 'Loaded';
	private final String STATUS_PROCESSED = 'Processed';
	private final String STATUS_ERROR_PROCESSING = 'Error Processing';
	private final String PREV_MODE_PREFIX = '[previewMode]';
	private final String MESSAGE_SEPARATOR = ';';
	private final String CHECK_COMMENTS = 'Automatically updated per MedPro data';
	private final STRING USER_CONTEXT_NAME = 'SFA US OPS JOBS';	
	private final ID USER_CONTEXT_ID;
	
	private Boolean isPrevMode;
	private Map<String, Id> winnerAccountsToStagingId;
	
	global GNE_Subscribe_Account_Exclusion(Boolean prevMode){
		this.isPrevMode = prevMode;
		this.winnerAccountsToStagingId = new Map<String, Id>();
		this.USER_CONTEXT_ID = getUserContextId();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		Datetime lastProcessTimeStamp = null;// this.getLastProcessExecutionTime(BC);
		Set<String> scopeStatuses = new Set<String>{STATUS_LOADED};
		
		String queryStr = String.format('SELECT ID, {0}, {1}, {2}, {3}, {4} ',
			new String[]{
				String.valueOf(Staging_Account_Exclusion_gne__c.Account_ID_gne__c),					// 0
				String.valueOf(Staging_Account_Exclusion_gne__c.Comments_gne__c),					// 1
				String.valueOf(Staging_Account_Exclusion_gne__c.Exclusion_Date_Checked_gne__c),		// 2
				String.valueOf(Staging_Account_Exclusion_gne__c.Exclusion_Status_gne__c),			// 3
				String.valueOf(Staging_Account_Exclusion_gne__c.Status_gne__c)						// 4
			}
		);
		
		String whereExpr = String.format('WHERE {0} IN :scopeStatuses ',
			new String[]{
				String.valueOf(Staging_Account_Exclusion_gne__c.Status_gne__c)						// 0
			}
		);
		
		if (lastProcessTimeStamp != null){
			whereExpr += 'AND CreatedDate >= :lastProcessTimeStamp ';
		}
		
		String orderBy = 'Order By CreatedDate desc';
		
		String fQuery = String.format('{0} FROM Staging_Account_Exclusion_gne__c {1} {2}',
			new String[]{
				queryStr,		// 0
				whereExpr,		// 1
				orderBy			// 2
			}
		);
		
		return Database.getQueryLocator(fQuery);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		try {
			doExecute(BC, scope);
		} catch(Exception ex){
			sendErrorNotificationEmail(ex.getMessage(), ex.getStackTraceString());
		}
	}
	
	private void doExecute(Database.BatchableContext BC, List<sObject> scope){
		BatchContext batchContext = validateAndCreateBatchContext(scope);
		
		Account account = null;
		Staging_Account_Exclusion_gne__c stagingRecord = null;
		for (Id accId : batchContext.accountsMap.keyset()){
			account = batchContext.accountsMap.get(accId);
			stagingRecord = batchContext.getProcessedStagingRecordByAccId(accId);
			account.AGS_EX_Exclusion_Status_base_gne__c = stagingRecord.Exclusion_Status_gne__c;
			account.AGS_EX_Date_Checked_Exclusion_gne__c = stagingRecord.Exclusion_Date_Checked_gne__c;
		}
						
		Boolean errorOccured = false;
		Savepoint sp = Database.setSavepoint();
		try {
			Database.SaveResult[] sResults = null;
			if (batchContext.accountsMap.size() > 0){
				// Save Accounts
				List<Account> accountsToUpdate = batchContext.accountsMap.values();
				sResults = Database.update(accountsToUpdate, false);
				if (sResults != null){
					Integer idx = 0;
					account = null;
					stagingRecord = null;
					AGS_EX_Exclusion_Request_gne__c excRecord = null;
					for (Database.SaveResult sResult : sResults){
						account = accountsToUpdate[idx];
						stagingRecord = batchContext.getProcessedStagingRecordByAccId(account.Id);
						if (!sResult.isSuccess()){
							setStagingObjectStatus(stagingRecord, STATUS_ERROR_PROCESSING, getErrMessage(sResult.getErrors()));
							batchContext.accountsMap.remove(account.Id);
						} else {
							setStagingObjectStatus(stagingRecord, STATUS_PROCESSED, '');
						}
						idx++;
					}
					if (batchContext.accountsMap.size() > 0){
						List<AGS_EX_Exclusion_Request_gne__c> excRequestsToInsert = getExclusionRequests(batchContext.accountsMap);
						if (excRequestsToInsert.size() > 0){
							// Save AGS_EX_Exclusion_Request_gne__c
							sResults = Database.insert(excRequestsToInsert, false);
							if (sResults != null){
								idx = 0;
								Map<Id, AGS_EX_Exclusion_Request_gne__c> excRequestsInsertedMap = new Map<Id, AGS_EX_Exclusion_Request_gne__c>();
								for (Database.SaveResult sResult : sResults){
									excRecord = excRequestsToInsert[idx];
									if (!sResult.isSuccess()){
										stagingRecord = batchContext.getProcessedStagingRecordByAccId(excRecord.AGS_EX_Account_Name_gne__c);
										updateStagingObjectComments(stagingRecord, 'WARNING-The AGS_EX_Exclusion_Request_gne__c and AGS_EX_Exclusion_Check_gne__c records were not created');
									} else {
										excRequestsInsertedMap.put(excRecord.Id, excRecord);
									}
									idx++;
								}
								if (excRequestsInsertedMap.size() > 0){
									List<AGS_EX_Exclusion_Check_gne__c> excChecksToInsert = getExclusionChecks(excRequestsInsertedMap.values(), batchContext.processedAccIdToStagingRecordsMap);
									if (excChecksToInsert.size() > 0){
										// Save AGS_EX_Exclusion_Check_gne__c
										sResults = Database.insert(excChecksToInsert, false);
										if (sResults != null){
											idx = 0;
											AGS_EX_Exclusion_Check_gne__c excChekRecord = null;
											for (Database.SaveResult sResult : sResults){
												if (!sResult.isSuccess()){
													excChekRecord = excChecksToInsert[idx];
													excRecord = excRequestsInsertedMap.get(excChekRecord.AGS_EX_Exclusion_Request_gne__c);
													stagingRecord = batchContext.getProcessedStagingRecordByAccId(excRecord.AGS_EX_Account_Name_gne__c);
													updateStagingObjectComments(stagingRecord, 'WARNING-The AGS_EX_Exclusion_Check_gne__c record was not created');
												}
												idx++;
											}
										}
									}
								}
							}
						}
					}
				}
			}
		} catch (Exception ex){
			errorOccured = true;
			Database.Rollback(sp);
			throw ex;
		} finally {
			if (!errorOccured){
				if (this.isPrevMode){
					Database.Rollback(sp);
				}
				commitStagingRecords(batchContext);
			}
		}
	}
	
	private void commitStagingRecords(BatchContext batchContext){
		List<Staging_Account_Exclusion_gne__c> records = batchContext.getAllStagingRecords();
		if (records.size() > 0){
		 	Database.SaveResult[] sResults = Database.update(records, false);
		}
	}
		
	private String getErrMessage(Database.Error[] errors){
		List<String> errorMsgs = new List<String>();
		for (Database.Error err : errors){
			errorMsgs.add(err.getMessage());
		}
		return String.join(errorMsgs, MESSAGE_SEPARATOR);
	}
	
	private List<AGS_EX_Exclusion_Request_gne__c> getExclusionRequests(Map<Id, Account> accountsMap){
		List<AGS_EX_Exclusion_Request_gne__c> result = new List<AGS_EX_Exclusion_Request_gne__c>();
		Account account = null;
		AGS_EX_Exclusion_Request_gne__c newExRequest = null;
		String addr = null;
		for (Id accId : accountsMap.keyset()){
			account = accountsMap.get(accId);
			newExRequest = new AGS_EX_Exclusion_Request_gne__c();
			newExRequest.AGS_EX_Account_Name_gne__c = accId;
			newExRequest.AGS_EX_Request_Status_gne__c = 'Completed';
			addr = getAddress(account.Address_vod__r);
			newExRequest.AGS_EX_Account_Primary_Address_gne__c = (addr == null ? 'No address available' : addr);
			result.add(newExRequest);
		}
		return result;
	}
	
	private List<AGS_EX_Exclusion_Check_gne__c> getExclusionChecks(List<AGS_EX_Exclusion_Request_gne__c> excRequests, Map<Id, Staging_Account_Exclusion_gne__c> processedAccIdToStagingRecordsMap){
		List<AGS_EX_Exclusion_Check_gne__c> result = new List<AGS_EX_Exclusion_Check_gne__c>();
		Staging_Account_Exclusion_gne__c stagingRecord = null;
		AGS_EX_Exclusion_Check_gne__c newExCheck = null;
		for (AGS_EX_Exclusion_Request_gne__c excRequest : excRequests){
			stagingRecord = processedAccIdToStagingRecordsMap.get(excRequest.AGS_EX_Account_Name_gne__c);
			newExCheck = new AGS_EX_Exclusion_Check_gne__c();
			newExCheck.AGS_EX_Exclusion_Request_gne__c = excRequest.Id;
			newExCheck.AGS_EX_Status_gne__c = stagingRecord.Exclusion_Status_gne__c;
			newExCheck.AGS_EX_Check_Date_gne__c = stagingRecord.Exclusion_Date_Checked_gne__c;
			newExCheck.AGS_EX_Reviewer_Name_gne__c = USER_CONTEXT_ID;
			newExCheck.AGS_EX_Comments_gne__c = CHECK_COMMENTS;
			result.add(newExCheck);
		}
		return result;
	}
	
	private BatchContext validateAndCreateBatchContext(List<SObject> scope){
		BatchContext batchContext = new BatchContext();
		List<String> recErrors = new List<String>();
		for (Staging_Account_Exclusion_gne__c stagingExcl : (List<Staging_Account_Exclusion_gne__c>)scope){
			recErrors.clear();
			stagingExcl.Comments_gne__c = '';
			if (String.isBlank(stagingExcl.Account_ID_gne__c)){
				recErrors.add('Account_ID_gne__c is blank');
			}
			if (stagingExcl.Exclusion_Date_Checked_gne__c == null){
				recErrors.add('Exclusion_Date_Checked_gne__c is blank');
			}
			if (String.isBlank(stagingExcl.Exclusion_Status_gne__c)){
				recErrors.add('Exclusion_Status_gne__c is blank');
			}
			if (String.isNotBlank(stagingExcl.Account_ID_gne__c) && winnerAccountsToStagingId.containsKey(stagingExcl.Account_ID_gne__c)){
				recErrors.add('Duplicated Account_ID_gne__c with the record with ID: ' + winnerAccountsToStagingId.get(stagingExcl.Account_ID_gne__c));
			}
			if (recErrors.size() > 0){
				setStagingObjectStatus(stagingExcl, STATUS_ERROR_PROCESSING, String.join(recErrors, MESSAGE_SEPARATOR));
				batchContext.rejectedStagingRecords.add(stagingExcl);
				continue;
			}
			batchContext.processedAccIdToStagingRecordsMap.put(stagingExcl.Account_ID_gne__c, stagingExcl);
			winnerAccountsToStagingId.put(stagingExcl.Account_ID_gne__c, stagingExcl.Id);
		}
		
		batchContext.accountsMap = new Map<Id, Account>([
			SELECT Id, AGS_EX_Exclusion_Status_base_gne__c, AGS_EX_Date_Checked_Exclusion_gne__c,
				(SELECT Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r ORDER BY Primary_vod__c DESC, GOLD_RECORD_gne__c DESC, LastModifiedDate DESC LIMIT 1)
			FROM Account 
			WHERE Id IN :batchContext.processedAccIdToStagingRecordsMap.keyset()]);
		Map<Id, String> accIdNotValidList = new Map<Id, String>();
		for (Id accId : batchContext.processedAccIdToStagingRecordsMap.keyset()){
			if (!batchContext.accountsMap.containsKey(accId)){
				accIdNotValidList.put(accId, 'There is no account for given Account_ID_gne__c: ' + accId);
				continue;
			}			
			Staging_Account_Exclusion_gne__c stagingRec = batchContext.processedAccIdToStagingRecordsMap.get(accId);
			if (stagingRec.Exclusion_Date_Checked_gne__c > Date.today()){
				accIdNotValidList.put(accId, 'The Exclusion_Date_Checked_gne__c value cannot be from the future: ' + String.valueOf(stagingRec.Exclusion_Date_Checked_gne__c));
				continue;
			}
			if (stagingRec.Exclusion_Date_Checked_gne__c < Date.today() && stagingRec.Exclusion_Date_Checked_gne__c.daysBetween(Date.today()) > 365){
				accIdNotValidList.put(accId, 'The Exclusion_Date_Checked_gne__c value is older than 365 days and is expired: ' + String.valueOf(stagingRec.Exclusion_Date_Checked_gne__c));
				continue;
			}
			Account cAccount = batchContext.accountsMap.get(accId);
			if (cAccount.AGS_EX_Date_Checked_Exclusion_gne__c != null && cAccount.AGS_EX_Date_Checked_Exclusion_gne__c > stagingRec.Exclusion_Date_Checked_gne__c){
				accIdNotValidList.put(accId, 'Current Account AGS_EX_Date_Checked_Exclusion_gne__c is greater than given value: ' + String.valueOf(stagingRec.Exclusion_Date_Checked_gne__c));
				continue;
			}
			if (cAccount.AGS_EX_Date_Checked_Exclusion_gne__c != null && cAccount.AGS_EX_Date_Checked_Exclusion_gne__c >= stagingRec.Exclusion_Date_Checked_gne__c && cAccount.AGS_EX_Exclusion_Status_base_gne__c == stagingRec.Exclusion_Status_gne__c){
				accIdNotValidList.put(accId, 'Current Account AGS_EX_Date_Checked_Exclusion_gne__c is greater or equal than given value and status is the same: ' + String.valueOf(stagingRec.Exclusion_Date_Checked_gne__c));
				continue;
			}
		}
		for (Id accId : accIdNotValidList.keyset()){
			Staging_Account_Exclusion_gne__c stagingExcl = batchContext.processedAccIdToStagingRecordsMap.remove(accId);
			setStagingObjectStatus(stagingExcl, STATUS_ERROR_PROCESSING, accIdNotValidList.get(accId));
			batchContext.rejectedStagingRecords.add(stagingExcl);
			if (batchContext.accountsMap.containsKey(accId)){
				batchContext.accountsMap.remove(accId);
			}
		}
		return batchContext;
	}
	
	private void setStagingObjectStatus(Staging_Account_Exclusion_gne__c stagingRec, String PROCESS_STATUS, String message){
		if (this.isPrevMode){
			stagingRec.Comments_gne__c = PREV_MODE_PREFIX + PROCESS_STATUS + MESSAGE_SEPARATOR + message;
		} else {
			stagingRec.Comments_gne__c = message;
			stagingRec.Status_gne__c = PROCESS_STATUS;
		}
	}
	
	private void updateStagingObjectComments(Staging_Account_Exclusion_gne__c stagingRec, String message){
		if (String.isNotBlank(stagingRec.Comments_gne__c)){
			stagingRec.Comments_gne__c += MESSAGE_SEPARATOR + message;
		} else {
			stagingRec.Comments_gne__c = message;
		}
	}
	
	private String getAddress(List<Address_vod__c> addresses){
		if (addresses == null || addresses.size() == 0){
			return null;
		}
		Address_vod__c address = addresses[0];
		return (String.isNotBlank(address.Name) ? address.Name : '') +
			(String.isNotBlank(address.City_vod__c) ? ', ' + address.City_vod__c : '') +
			(String.isNotBlank(address.State_vod__c) ? ', ' + address.State_vod__c : '') +
			(String.isNotBlank(address.Zip_vod__c) ? ' ' + address.Zip_vod__c : '');
	}
	
	private class BatchContext {
		public List<Staging_Account_Exclusion_gne__c> rejectedStagingRecords { get; set; }
		public Map<Id, Staging_Account_Exclusion_gne__c> processedAccIdToStagingRecordsMap { get; set; }
		public Map<Id, Account> accountsMap { get; set; }
		
		public BatchContext(){
			this.rejectedStagingRecords = new List<Staging_Account_Exclusion_gne__c>();
			this.processedAccIdToStagingRecordsMap = new Map<Id, Staging_Account_Exclusion_gne__c>();
			this.accountsMap = new Map<Id, Account>();
		}
		
		public Staging_Account_Exclusion_gne__c getProcessedStagingRecordByAccId(Id accountId){
			return this.processedAccIdToStagingRecordsMap.get(accountId);
		}
		
		public List<Staging_Account_Exclusion_gne__c> getAllStagingRecords(){
			List<Staging_Account_Exclusion_gne__c> result = new List<Staging_Account_Exclusion_gne__c>();
			result.addAll(this.rejectedStagingRecords);
			result.addAll(this.processedAccIdToStagingRecordsMap.values());
			return result;
		}
	}
	
	private DateTime getLastProcessExecutionTime(Database.BatchableContext BC) {
    	DateTime lastProcessExecutionTime = null;
    	for(AsyncApexJob job : [
    		SELECT CreatedDate 
    		FROM AsyncApexJob 
    		WHERE ApexClass.Name = :GNE_Subscribe_Account_Exclusion_WS.class.getName() 
    			AND Id <> :BC.getJobId() 
    			AND ParentJobId = null 
    			AND JobType = 'BatchApex' 
    			AND Status = 'Completed' 
    		ORDER BY CreatedDate DESC 
    		LIMIT 1]) {
			lastProcessExecutionTime = job.CreatedDate;
		}
        return lastProcessExecutionTime;
    }
    
    private ID getUserContextID(){
    	return [SELECT ID FROM User WHERE Name = :USER_CONTEXT_NAME].ID;
    }
    
    global void finish(Database.BatchableContext BC){
		sendConfirmationEmail();
	}
	
	private void sendConfirmationEmail(){
    	String emailSubject = (this.isPrevMode) ? PREV_MODE_PREFIX + ' ' : '';
    	emailSubject += 'The Subscribe Account Exclusion Batch process is completed.';
		String emailBody = 'Subscribe Account Exclusion Batch process is completed.';
		sendEmail(emailSubject, emailBody);
    }
    
    private void sendErrorNotificationEmail(String excMessage, String stackTraceMessage){
    	String emailSubject = 'The Subscribe Account Exclusion Batch process has errors.';
    	String emailBody = 'Please review following errors.<br/><br/> ';
    	emailBody += '<b>Error Message:</b><br/>' + excMessage + '<br/><br/>';
    	emailBody += '<b>Stack trace:</b><br/>' + stackTraceMessage + '<br/><br/>';
    	sendEmail(emailSubject, emailBody);
    }
    
    private void sendEmail(String emailSubject, String emailBody){
    	try{			
			String userEmail = UserInfo.getUserEmail();
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();			
			mail.setToAddresses(new List<String>{userEmail});
	    	mail.setBccSender(false);
	    	mail.setSubject(emailSubject);
			mail.setHtmlBody(emailBody);
			List<Messaging.Sendemailresult> emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
			if(emailResult != null && !emailResult[0].isSuccess()) {
				List<Messaging.SendEmailError> emailError = emailResult[0].getErrors();
				if(emailError!=null) {
					System.debug('email error : ' + emailError[0].getMessage());
				}
			}
		} catch(Exception ex) {
			throw ex;
		}	
    }
    
}