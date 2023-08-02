public with sharing class Merge_Type_Util {

    public static final string DCH_APPROVAL_DEFAULT_STATUS = 'Default Approval'; // initial approval state
    public static final string DCH_APPROVAL_APPROVED_STATUS = 'Approved'; // Approved.

    public static final string DCH_SOURCE_OTHER = 'Other'; // canada source
    public static final string STEWARDSHIP_SYSTEM_ARCHIVED_ACCOUNT = 'ArchivedAccount';
    public static final string STATUS_INACTIVE = 'Inactive';

    public static final string DCH_ACTION_DEFAULT_LOGIC = 'Default Logic'; // initial stage status
    public static final string DCH_ACTION_RELATED_LIST_LOGIC = 'Related List Logic'; // parent account for address merge
    public static final string DCH_ACTION_CHECKMODE_WINNER = 'Merge (Winner)';
    public static final string DCH_ACTION_CHECKMODE_LOSER = 'Merge (Loser)';

    public static final string DCH_ACTION_WINNER = 'Winner'; // after merge winner status
    public static final string DCH_ACTION_LOSER = 'Loser';   // after merge loser status

    public static final string DCH_ACTION_NO_EXCEPTION = 'No Exceptions Recorded';
    public static final string DCH_ACTION_RUNTIME_EXCEPTION = 'RUNTIME EXCEPTION';
	
	public static final string MERGE_TYPE_OBJECT_NAME = 'Object Name';
	public static final string MERGE_TYPE_REGION_CODE = 'Region Code';
	public static final string MERGE_TYPE_APPROVAL_PROCESS_ENABLED = 'Approval Process Enabled';
	public static final string MERGE_TYPE_DCH_CLONE_FIELDS_ENABLED = 'DCH Clone Fields Enabled';
	public static final string MERGE_TYPE_ARCHIVE_QUERY = 'Archive Query';
    public static final string MERGE_TYPE_ARCHIVE_OWNER = 'Archive Owner';
    public static final string MERGE_TYPE_ARCHIVE_FIELD_DEFAULTS = 'Archive Field Defaults';
    public static final string MERGE_TYPE_ADDRESS_ARCHIVE_FIELD_DEFAULTS = 'Address Archive Field Defaults';
    public static final string MERGE_TYPE_UNIQUE_FIELD_NAME = 'Unique Set Field Name';
    public static final string MERGE_TYPE_SORT_COLUMNS = 'Sort By Columns';
    public static final string MERGE_TYPE_WHERE_CLAUSE = 'Where Clause';
    public static final string MERGE_TYPE_SUPPORT_EMAIL_ADDRESS = 'Support Email';
    public static final string MERGE_TYPE_OBJECT_ACCOUNT = 'Account';
    public static final string MERGE_TYPE_OBJECT_ADDRESS = 'Address_vod__c';

    public static final string APEX_JOB_TYPE_MERGE = 'Merge';
    public static final string APEX_JOB_TYPE_MERGE_CHECKMODE = 'Merge Checkmode';
    public static final string APEX_JOB_TYPE_INSERT_CANDIDATES = 'Insert Candidates';

    public static final string MERGE_TYPE_NAME_ACCOUNT = 'Account';
    public static final string MERGE_TYPE_NAME_PERSON_ACCOUNT = 'Person Account';
    public static final string MERGE_TYPE_NAME_ACCOUNT_ADDRESS = 'Account Address';
    public static final string MERGE_TYPE_NAME_PERSON_ACCOUNT_ADDRESS = 'Person Account Address';

    public static final string ARCHIVE_RECORDTYPE_ACCOUNT = 'Archived Account';
    public static final string ARCHIVE_RECORDTYPE_PERSON_ACCOUNT = 'Archived Person Account';
    public static final string ARCHIVE_RECORDTYPE_ADDRESS = 'Archived Address';

    public static final string LAST_JOB_DATETIME_REGEXP = '\\[LAST_JOB_DATETIME\\]';
    public static final string LAST_ACCOUNT_JOB_DATETIME_REGEXP = '\\[LAST_ACCOUNT_JOB_DATETIME\\]';
    
    public static final string MERGE_JOB_BATCH_NAME = 'Merge_Type_Engine_Batch';
    public static final string INSERT_CANDIDATE_JOB_BATCH_NAME = 'Merge_Type_Insert_Candidate_Batch';
    
    private static Map<String,DateTime> lastApexJobDateTimeCache;
    private static Map<String,Object> mergeTypeCache;
    private static Map<Id,List<String>> supportEmailAddresses;
    private static Boolean isMergeProcessRunning;
	
	// PENDING implementation Populate Accunt DCH Record guru k dec 08/2012
    public static List<Account> prepareAccountDCHRecords (String winnerId, Set<String> loserIdSet, Merge_Type_gne__c mergeType) {
    	List<Account> dchAccountList = new List<Account>();
    	// return initialize account dch model
        // this method does not insert address record. caller context.
        String archiveUserName = getMergeTypeArchiveOwner(mergeType.Id);
        User archiveUser = [select Id from User where name = :archiveUserName and Isactive=true limit 1];
        Decimal regionCode = getMergeTypeRegionCode(mergeType.Id);
        Map<String,RecordType> accountAddressRecordTypeInfo = getMergeTypeArchiveRecordTypes();
        Map<Id,Account> m_id_account = new Map<Id,Account>([select Id, Name, FirstName, LastName, recordtype.name, isPersonAccount from account where id in :loserIdSet]);
        Account winnerAccount = m_id_account.get(winnerId);
        
        if(winnerAccount!=null) {
	        RecordType recordTypeInfo = winnerAccount.IsPersonAccount ? accountAddressRecordTypeInfo.get(ARCHIVE_RECORDTYPE_PERSON_ACCOUNT) : accountAddressRecordTypeInfo.get(ARCHIVE_RECORDTYPE_ACCOUNT);
			Map<String,Object> dchDefaults = getMergeTypeArchiveFieldDefaults(mergeType.Id);
				
			for (String loserId : loserIdSet){
	        	Account acct = m_id_account.get(loserId);
	        	if(acct!=null) {
		        	Account dchAccount = null;
		        	if (winnerAccount.isPersonAccount) {
			        	dchAccount = new Account (FirstName = acct.FirstName,
		    	                                  LastName = acct.LastName,
		    	                                  recordTypeId = recordTypeInfo.Id,
		    	                                  DCH_Parent_Id_gne__c = winnerAccount.Id,
		    	                                  DCH_Previous_Id_gne__c = acct.Id,
		    	                                  DCH_Action_gne__c = DCH_ACTION_DEFAULT_LOGIC,
		    	                                  DCH_Approval_Status_gne__c = DCH_APPROVAL_DEFAULT_STATUS,
		    	                                  DCH_Source_gne__c = DCH_SOURCE_OTHER,
		    	                                  DCH_User_gne__c = UserInfo.getUserId(),
		    	                                  Stewardship_System_Name_gne__c = STEWARDSHIP_SYSTEM_ARCHIVED_ACCOUNT,
		    	                                  Status_gne__c = STATUS_INACTIVE,
		    	                                  OwnerId = archiveUser.Id,
		    	                                  Region_Code_gne__c = regionCode);
		        	} else {
			            dchAccount = new Account (Name = acct.Name,
		                                          recordTypeId = recordTypeInfo.Id,
		                                          DCH_Parent_Id_gne__c = winnerAccount.Id,
		                                          DCH_Previous_Id_gne__c = acct.Id,
		                                          DCH_Action_gne__c = DCH_ACTION_DEFAULT_LOGIC,
		                                          DCH_Approval_Status_gne__c = DCH_APPROVAL_DEFAULT_STATUS,
		                                          DCH_Source_gne__c = DCH_SOURCE_OTHER,
		                                          DCH_User_gne__c = UserInfo.getUserId(),
		                                          Stewardship_System_Name_gne__c = STEWARDSHIP_SYSTEM_ARCHIVED_ACCOUNT,
		                                          Status_gne__c = STATUS_INACTIVE, 
		    	                                  OwnerId = archiveUser.Id,
		    	                                  Region_Code_gne__c = regionCode);
		        	}
		        	
		        	for(String dchField : dchDefaults.keySet()) {
		        		dchAccount.put(dchField, dchDefaults.get(dchField));
		        	}
	        		
	        		dchAccountList.add (dchAccount);
	        	}
	        }
        }
            
    	return dchAccountList;
    }

    // PENDING implementation Populate Accunt DCH Record guru k dec 08/2012
    public static List<Address_vod__c> prepareAddressDCHRecords (String winnerId, Set<String> loserIdSet, Merge_Type_gne__c mergeType) {
        // return initialize address dch model
        // this method does not insert address record. caller context.
        List<Address_vod__c> dchAddressList = new List<Address_vod__c>();
        String archiveUserName = getMergeTypeArchiveOwner(mergeType.Id);
        User archiveUser = [select Id from User where name = :archiveUserName and Isactive=true limit 1];
        Decimal regionCode = getMergeTypeRegionCode(mergeType.Id);
        Map<String,RecordType> accountAddressRecordTypeInfo = getMergeTypeArchiveRecordTypes();
        Map<Id,Address_vod__c> m_id_address = new Map<Id,Address_vod__c>([select Id, Name, account_vod__c,account_vod__r.isPersonAccount, account_vod__r.Name, account_vod__r.FirstName, account_vod__r.LastName, recordtype.name from Address_vod__c where id in :loserIdSet]);
        Address_vod__c winnerAddress = m_id_address.get(winnerId);
        
        if(winnerAddress!=null) {
	        RecordType accountRecordTypeInfo = winnerAddress.account_vod__r.IsPersonAccount ? accountAddressRecordTypeInfo.get(ARCHIVE_RECORDTYPE_PERSON_ACCOUNT) : accountAddressRecordTypeInfo.get(ARCHIVE_RECORDTYPE_ACCOUNT);
	        RecordType recordTypeInfo = accountAddressRecordTypeInfo.get(ARCHIVE_RECORDTYPE_ADDRESS);
			Map<String,Object> dchDefaults = getMergeTypeArchiveFieldDefaults(mergeType.Id);
			Map<String,Object> dchAddressDefaults = getMergeTypeAddressArchiveFieldDefaults(mergeType.Id);
			Account dchAccount = null;
	
	        if (winnerAddress.account_vod__r.IsPersonAccount) {
	        	dchAccount = new Account (FirstName = winnerAddress.account_vod__r.FirstName,
	    	                              LastName = winnerAddress.account_vod__r.LastName,
	                                      recordTypeId = accountRecordTypeInfo.Id,
	                                      DCH_Parent_Id_gne__c = winnerAddress.account_vod__c,
	                                      DCH_Previous_Id_gne__c = winnerAddress.account_vod__c,
	                                      DCH_Action_gne__c = DCH_ACTION_RELATED_LIST_LOGIC,
	                                      DCH_Approval_Status_gne__c = DCH_APPROVAL_DEFAULT_STATUS,
	                                      DCH_Source_gne__c = DCH_SOURCE_OTHER,
	                                      DCH_User_gne__c = UserInfo.getUserId(),
	                                      Stewardship_System_Name_gne__c = STEWARDSHIP_SYSTEM_ARCHIVED_ACCOUNT,
	                                      Status_gne__c = STATUS_INACTIVE,
	                                      OwnerId = archiveUser.Id,
	                                      Region_Code_gne__c = regionCode);
	        } else {
	            dchAccount = new Account (Name = winnerAddress.account_vod__r.Name,
	                                      recordTypeId = accountRecordTypeInfo.Id,
	                                      DCH_Parent_Id_gne__c = winnerAddress.account_vod__c,
	                                      DCH_Previous_Id_gne__c = winnerAddress.account_vod__c,
	                                      DCH_Action_gne__c = DCH_ACTION_RELATED_LIST_LOGIC,
	                                      DCH_Approval_Status_gne__c = DCH_APPROVAL_DEFAULT_STATUS,
	                                      DCH_Source_gne__c = DCH_SOURCE_OTHER,
	                                      DCH_User_gne__c = UserInfo.getUserId(),
	                                      Stewardship_System_Name_gne__c = STEWARDSHIP_SYSTEM_ARCHIVED_ACCOUNT,
	                                      Status_gne__c = STATUS_INACTIVE,
	                                      OwnerId = archiveUser.Id,
	                                      Region_Code_gne__c = regionCode);
	        }
	        
	        for(String dchField : dchDefaults.keySet()) {
	        	dchAccount.put(dchField, dchDefaults.get(dchField));
	        }
	
	    	insert dchAccount;
	
	        for (String loserId : loserIdSet){
	            Address_vod__c address = m_id_address.get(loserId);
	            
	            if(address!=null) {
		            Address_vod__c dchAddress = new Address_vod__c (
		                                              Name = address.Name,
		                                              recordTypeId = recordTypeInfo.Id,
		                                              DCH_Parent_Id_gne__c = winnerAddress.Id,
		                                              DCH_Previous_Id_gne__c = address.Id,
		                                              DCH_Action_gne__c = DCH_ACTION_DEFAULT_LOGIC,
		                                              DCH_Approval_Status_gne__c = DCH_APPROVAL_DEFAULT_STATUS,
		                                              DCH_Source_gne__c = DCH_SOURCE_OTHER,
		                                              DCH_User_gne__c = UserInfo.getUserId(),
		                                              Status_gne__c = STATUS_INACTIVE,
		                                              account_vod__c = dchAccount.Id);
		            
		            for(String dchField : dchAddressDefaults.keySet()) {
		        		dchAddress.put(dchField, dchAddressDefaults.get(dchField));
		        	}
		        	
		            dchAddressList.add (dchAddress);
	            }
	        }
        }
        
        return dchAddressList;
    }

    public static List<Merge_Type_Candidate_Stage_gne__c> prepareMergeTypeCandidates (Id winnerId, List<Id> loserIdList, Id mergeTypeId) {
    	List<Merge_Type_Candidate_Stage_gne__c> candidates = new List<Merge_Type_Candidate_Stage_gne__c>();
    	for(Id looserId: loserIdList)
    	{
    		Merge_Type_Candidate_Stage_gne__c candidate = new Merge_Type_Candidate_Stage_gne__c(
	    		ParentId_gne__c = winnerId,
	    		Id_gne__c = looserId,
	    		Merge_Type_ref_gne__c = mergeTypeId,
	    		DCH_Action_gne__c = Merge_Type_Util.DCH_ACTION_DEFAULT_LOGIC,
	    		external_id_gne__c = looserId + ':' + winnerId + ':' + Merge_Type_Util.DCH_ACTION_DEFAULT_LOGIC);
    		candidates.add(candidate);
    	}
        // return initialize merge type candidates
        // this method does not insert records. caller context.
    	return candidates;
    }

    public static String getMergeTypeCandidateFindQueryString (Id mergeTypeId, Merge_Type_Apex_Job_gne__c currentApexJob) {
        String uniqueSetFieldName = getMergeTypeUniqueSetFieldName(mergeTypeId);
        String sortByColumns = getMergeTypeSortColumns(mergeTypeId);
        String whereClause = getMergeTypeWhereClause(mergeTypeId);
        String mergeTypeTableName = getMergeTypeObjectName(mergeTypeId);
        String query = null;
		
        if (String.isNotBlank(uniqueSetFieldName) && String.isNotBlank(sortByColumns) && String.isNotBlank(whereClause)) {
	        if(Pattern.matches('.*' + LAST_JOB_DATETIME_REGEXP + '.*', whereClause)) {
	        	whereClause = whereClause.replaceAll(LAST_JOB_DATETIME_REGEXP, ':lastExecutionDateTime');
	        }
	        
	        if(Pattern.matches('.*' + LAST_ACCOUNT_JOB_DATETIME_REGEXP + '.*', whereClause)) {
	        	whereClause = whereClause.replaceAll(LAST_ACCOUNT_JOB_DATETIME_REGEXP, ':lastAccountExecutionDateTime');
	        }
	        
	        query = 'select id, ' + uniqueSetFieldName + ' from ' + mergeTypeTableName
	        				+  ' where ' +  whereClause
	                        + ' order by ' + uniqueSetFieldName + ', ' + sortByColumns;
        }
        
    	return query;
    }
    
    public static DateTime getLastApexJobDateTime(Id mergeTypeId, Merge_Type_Apex_Job_gne__c currentApexJob) {
    	DateTime result = null;
    	
    	if(lastApexJobDateTimeCache == null) {
    		lastApexJobDateTimeCache = new Map<String,DateTime>();
    	}
    	
    	String key = mergeTypeId + '_' + currentApexJob.Id;
    	
    	if(LastApexJobDateTimeCache.containsKey(key)) {
    		result = lastApexJobDateTimeCache.get(key);
    	} else {
	    	for(Merge_Type_Apex_Job_gne__c apexJob : [
	    			SELECT CreatedDate
	    			FROM Merge_Type_Apex_Job_gne__c
	    			WHERE Merge_Type_ref_gne__c = :mergeTypeId
	    				AND Apex_Job_Type_gne__c = :currentApexJob.Apex_Job_Type_gne__c
	    				AND Id <> :currentApexJob.Id
	    				AND Completed_gne__c = true
	    			ORDER BY CreatedDate desc
	    			LIMIT 1]) {
	    		result = apexJob.CreatedDate;	
	    	}
    		
    		result = result!=null ? result : System.now().addYears(-1);
    		lastApexJobDateTimeCache.put(key, result);
    	}
    	
    	return result;
    }
    
    public static DateTime getLastAccountApexJobDateTime(Id mergeTypeId) {
    	DateTime result = null;
    	
    	if(lastApexJobDateTimeCache == null) {
    		lastApexJobDateTimeCache = new Map<String,DateTime>();
    	}
    	
    	String key = 'ACCOUNT';
    	
    	if(lastApexJobDateTimeCache.containsKey(key)) {
    		result = lastApexJobDateTimeCache.get(key);
    	} else {
    		Decimal regionCode = [SELECT Region_Code_gne__c FROM Merge_Type_gne__c WHERE Id = :mergeTypeId].Region_Code_gne__c;
	    	for(Merge_Type_Apex_Job_gne__c apexJob : [
	    			SELECT CreatedDate
	    			FROM Merge_Type_Apex_Job_gne__c
	    			WHERE Merge_Type_ref_gne__r.Name = :MERGE_TYPE_NAME_ACCOUNT
	    				AND Apex_Job_Type_gne__c = :APEX_JOB_TYPE_MERGE
	    				AND Merge_Type_ref_gne__r.Region_Code_gne__c = :regionCode
	    				AND Completed_gne__c = true
	    			ORDER BY CreatedDate desc
	    			LIMIT 1]) {
	    		result = apexJob.CreatedDate;	
	    	}
	    	
	    	for(Merge_Type_Apex_Job_gne__c apexJob : [
	    			SELECT CreatedDate
	    			FROM Merge_Type_Apex_Job_gne__c
	    			WHERE Merge_Type_ref_gne__r.Name = :MERGE_TYPE_NAME_PERSON_ACCOUNT
	    				AND Apex_Job_Type_gne__c = :APEX_JOB_TYPE_MERGE
	    				AND Merge_Type_ref_gne__r.Region_Code_gne__c = :regionCode
	    				AND Completed_gne__c = true
	    			ORDER BY CreatedDate desc
	    			LIMIT 1]) {
	    		
	    		result = (result!=null && result<apexJob.CreatedDate) ? result : apexJob.CreatedDate;	
	    	}
	    	
	    	result = result!=null ? result : System.now().addYears(-1);
    		lastApexJobDateTimeCache.put(key, result);
    	}
    	
    	return result;
    }
    
    public static String getMergeTypeArchiveQuery(Id mergeTypeId) {
    	cacheMergeType(mergeTypeId);
    	return (String)mergeTypeCache.get(getCacheKeyPrefix(mergeTypeId) + MERGE_TYPE_ARCHIVE_QUERY.toUpperCase());
    }
    
    public static String getMergeTypeArchiveOwner(Id mergeTypeId) {
    	cacheMergeType(mergeTypeId);
    	return (String)mergeTypeCache.get(getCacheKeyPrefix(mergeTypeId) + MERGE_TYPE_ARCHIVE_OWNER.toUpperCase());
    }
    
    public static Map<String, Object> getMergeTypeArchiveFieldDefaults(Id mergeTypeId) {
    	cacheMergeType(mergeTypeId);
    	String defaultsJSON = (String)mergeTypeCache.get(getCacheKeyPrefix(mergeTypeId) + MERGE_TYPE_ARCHIVE_FIELD_DEFAULTS.toUpperCase());
    	return String.isNotBlank(defaultsJSON) ? (Map<String, Object>)JSON.deserializeUntyped(defaultsJSON) : new Map<String,Object>();
    }
    
    public static Map<String, Object> getMergeTypeAddressArchiveFieldDefaults(Id mergeTypeId) {
    	cacheMergeType(mergeTypeId);
    	String defaultsJSON = (String)mergeTypeCache.get(getCacheKeyPrefix(mergeTypeId) + MERGE_TYPE_ADDRESS_ARCHIVE_FIELD_DEFAULTS.toUpperCase());
    	return String.isNotBlank(defaultsJSON) ? (Map<String, Object>)JSON.deserializeUntyped(defaultsJSON) : new Map<String,Object>();
    }

    public static String getMergeTypeUniqueSetFieldName(Id mergeTypeId) {
    	cacheMergeType(mergeTypeId);
    	return (String)mergeTypeCache.get(getCacheKeyPrefix(mergeTypeId) + MERGE_TYPE_UNIQUE_FIELD_NAME.toUpperCase());
    }

    public static String getMergeTypeSortColumns(Id mergeTypeId) {
    	cacheMergeType(mergeTypeId);
    	return (String)mergeTypeCache.get(getCacheKeyPrefix(mergeTypeId) + MERGE_TYPE_SORT_COLUMNS.toUpperCase());
    }
    
    public static String getMergeTypeWhereClause(Id mergeTypeId) {
    	cacheMergeType(mergeTypeId);
    	return (String)mergeTypeCache.get(getCacheKeyPrefix(mergeTypeId) + MERGE_TYPE_WHERE_CLAUSE.toUpperCase());
    }
    
    public static String getMergeTypeObjectName(Id mergeTypeId) {
    	cacheMergeType(mergeTypeId);
    	return (String)mergeTypeCache.get(getCacheKeyPrefix(mergeTypeId) + MERGE_TYPE_OBJECT_NAME.toUpperCase());
    }
    
    public static Decimal getMergeTypeRegionCode(Id mergeTypeId) {
    	cacheMergeType(mergeTypeId);
    	return (Decimal)mergeTypeCache.get(getCacheKeyPrefix(mergeTypeId) + MERGE_TYPE_REGION_CODE.toUpperCase());
    }
    
    public static Boolean isApprovalProcessEnabled(Id mergeTypeId) {
    	cacheMergeType(mergeTypeId);
    	return ((Boolean)mergeTypeCache.get(getCacheKeyPrefix(mergeTypeId) + MERGE_TYPE_APPROVAL_PROCESS_ENABLED.toUpperCase()))==true;
    }
    
    public static List<String> getSupportEmailAddresses(Id mergeTypeId) {
    	cacheMergeType(mergeTypeId);
    	return supportEmailAddresses.get(mergeTypeId);
    }
    
    public static Boolean isCloneDCHFieldsEnabled(Id mergeTypeId) {
    	cacheMergeType(mergeTypeId);
    	return ((Boolean)mergeTypeCache.get(getCacheKeyPrefix(mergeTypeId) + MERGE_TYPE_DCH_CLONE_FIELDS_ENABLED.toUpperCase()))==true;
    }
    
    private static String getCacheKeyPrefix(Id mergeTypeId) {
    	return mergeTypeId + '_';
    }
    
    private static void cacheMergeType(Id mergeTypeId) {
		if(mergeTypeCache == null)  {
			mergeTypeCache = new Map<String,Object>();
			supportEmailAddresses = new Map<Id,List<String>>();
		}
		
		String keyPrefix = getCacheKeyPrefix(mergeTypeId);
		
		if(!mergeTypeCache.containsKey(keyPrefix + MERGE_TYPE_OBJECT_NAME.toUpperCase())) {
			supportEmailAddresses.put(mergeTypeId, new List<String>());
			Set<String> mbrNames = new Set<String>{
				MERGE_TYPE_ARCHIVE_QUERY,
				MERGE_TYPE_ARCHIVE_OWNER,
				MERGE_TYPE_ARCHIVE_FIELD_DEFAULTS,
				MERGE_TYPE_ADDRESS_ARCHIVE_FIELD_DEFAULTS,
				MERGE_TYPE_UNIQUE_FIELD_NAME,
				MERGE_TYPE_SORT_COLUMNS,
				MERGE_TYPE_WHERE_CLAUSE,
				MERGE_TYPE_SUPPORT_EMAIL_ADDRESS
			};
			
			for(Merge_Type_gne__c mergeType : [SELECT Object_Name_gne__c, Region_Code_gne__c, Approval_Process_Enabled_gne__c, DCH_Clone_Fields_Enabled_gne__c,
													(SELECT Field_Name_gne__c,Field_Type_gne__c,RelatedList_Query_Text_gne__c
													 FROM Merge_Business_Rule_gne__r
													 WHERE Active_gne__c = true
													 	AND Field_Type_gne__c in :mbrNames)
											  FROM Merge_Type_gne__c
											  WHERE Id = :mergeTypeId]) {
				mergeTypeCache.put(keyPrefix + MERGE_TYPE_OBJECT_NAME.toUpperCase(), mergeType.Object_Name_gne__c);
            	mergeTypeCache.put(keyPrefix + MERGE_TYPE_REGION_CODE.toUpperCase(), mergeType.Region_Code_gne__c);
            	mergeTypeCache.put(keyPrefix + MERGE_TYPE_APPROVAL_PROCESS_ENABLED.toUpperCase(), mergeType.Approval_Process_Enabled_gne__c);
            	mergeTypeCache.put(keyPrefix + MERGE_TYPE_DCH_CLONE_FIELDS_ENABLED.toUpperCase(), mergeType.DCH_Clone_Fields_Enabled_gne__c);
            	
            	for(Merge_Type_Business_Rule_gne__c mbr : mergeType.Merge_Business_Rule_gne__r) {
            		if(mbr.Field_Type_gne__c == MERGE_TYPE_SUPPORT_EMAIL_ADDRESS) {
            			supportEmailAddresses.get(mergeTypeId).add(mbr.Field_Name_gne__c);
            		} else {
            			mergeTypeCache.put(keyPrefix + mbr.Field_Type_gne__c.toUpperCase(), 
            					(mbr.Field_Type_gne__c == MERGE_TYPE_ARCHIVE_QUERY || mbr.Field_Type_gne__c == MERGE_TYPE_ARCHIVE_FIELD_DEFAULTS || mbr.Field_Type_gne__c == MERGE_TYPE_ADDRESS_ARCHIVE_FIELD_DEFAULTS)
            						? mbr.RelatedList_Query_Text_gne__c
            						: mbr.Field_Name_gne__c
            			);
            		}
            	}
			}
		}
	}

    public static Map<String,RecordType> getMergeTypeArchiveRecordTypes() {
    	Map<String,RecordType> m_name_rt = new Map<String,RecordType>();
    	List<RecordType> rtList = [select id, name, sobjecttype, developername from recordtype where name like '%archived%'];
    	for (RecordType rt : rtList) {
    		m_name_rt.put(rt.name, rt);
    	}
    	return m_name_rt;
    }
    
    public static AsyncApexJob getCurrentMergeJob() {
    	return getCurrentJob(MERGE_JOB_BATCH_NAME);
    }
    
    public static AsyncApexJob getCurrentInsertCandidateJob() {
    	return getCurrentJob(INSERT_CANDIDATE_JOB_BATCH_NAME);
    }
    
    private static AsyncApexJob getCurrentJob(String batchClassName) {
		AsyncApexJob result = null;
		
		for(AsyncApexJob job : [SELECT ApexClass.Name, Status, CreatedDate, CompletedDate, TotalJobItems, JobItemsProcessed, NumberOfErrors from AsyncApexJob
	           					WHERE ApexClass.Name = :batchClassName
	           						AND JobType = 'BatchApex'
	           					ORDER BY CreatedDate desc LIMIT 1]) {
			result = job;	            							            					
	    }
		
		return result;
	}
	
	public static Boolean isJobRunning(AsyncApexJob job) {
		return job!=null && job.Status!=null && new Set<String>{'QUEUED', 'PROCESSING', 'PREPARING', 'HOLDING'}.contains(job.Status.toUpperCase());
	}
	
	public static Boolean isJobCompleted(AsyncApexJob job) {
		return job!=null && job.Status == 'Completed';
	}
	
	public static String getStatusMessageForJob(AsyncApexJob job){
		String msg = String.format('Merge Type {0} is {1}{2}{3}', new String[]{
				(job.ApexClass.Name == MERGE_JOB_BATCH_NAME ? 'Batch' : 'Insert Candidates Batch'),
				(job.Status!=null ? job.Status.toLowerCase() : '-'),
				(job.Status=='Completed' ? ('. Total Batches: ' + job.TotalJobItems + ', Failures: ' + job.NumberOfErrors) : ''),
				(job.Status=='Processing' ? ('. Progress: ' + job.JobItemsProcessed + '/' + job.TotalJobItems + ', Failures: ' + job.NumberOfErrors) : '')
		});
		return msg;
	}
	
	public static void finalizeBatch(Id asyncApexJobId, Merge_Type_gne__c mergeType, Merge_Type_Apex_Job_gne__c apexJob, Integer totalRecordCount, Integer uniqueGroupCount, Integer runtimeErrorCount) {
		AsyncApexJob a = [
			SELECT Id, Status, NumberOfErrors, ApexClass.Name,
                   JobItemsProcessed, TotalJobItems, CreatedBy.Email,
                   CreatedDate, CompletedDate
            FROM AsyncApexJob
            WHERE Id =:asyncApexJobId
        ];
        
        User createdUser = a.CreatedBy;
        ApexClass batchApexClass = a.ApexClass;
        String log = String.format(
        	'The batch Apex job {0} ({1} : {2}) processed {3} batches with {4} failures.\n' +
        	'Batch Job StartTime / CompletedTime {5}/{6}.\n\n' +
        	'Total Records / Unique Group Count(duplicate sets processed)/Runtime Error Count: {7}/{8}/{9}.\n\n',
        	new String[]{
        		batchApexClass.Name, mergeType.Name, mergeType.Object_Name_gne__c, String.valueOf(a.TotalJobItems), String.valueOf(a.NumberOfErrors),
        		a.CreatedDate.format('yyyy-MM-dd HH:mm:ss', 'PST'), a.CompletedDate.format('yyyy-MM-dd HH:mm:ss (zzzz)', 'PST'),
        		String.valueOf(totalRecordCount), String.valueOf(uniqueGroupCount), String.valueOf(runtimeErrorCount)
        });
        
        if(apexJob!=null) {
	    	apexJob = [select Id, log_gne__c from Merge_Type_Apex_Job_gne__c where id = :apexJob.Id];
	        apexJob.log_gne__c = log;
	        apexJob.Completed_gne__c = true;
	        update apexJob;
        }
            
        try {
            String[] toAddresses = Merge_Type_Util.getSupportEmailAddresses(mergeType.Id);
            
            if(!toAddresses.isEmpty()) {                
	            // Send an email to the Apex job's submitter notifying of job completion.
	            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	            mail.setToAddresses(toAddresses);
	            mail.setSubject(String.format('Apex Job {0}({1} : {2}) status {3}', new String[]{
	            	batchApexClass.Name, mergeType.Name, mergeType.Object_Name_gne__c, a.Status
	            }));
	            mail.setPlainTextBody (log);
	            //Set attachment
	            GNE_CAN_Csv_Helper csvHelper = new GNE_CAN_Csv_Helper('Merge_Type_Error_Log_gne__c', String.valueOf(apexJob.Id));
	            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {csvHelper.getAttachment()});
	            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            
        } catch (Exception e) {
            System.debug (LoggingLevel.INFO, 'Unable to send email ' + e.getMessage() );
        }
	}
	
	public static void writeErrorLog(String batchName, Merge_Type_Apex_Job_gne__c apexJob, Merge_Type_gne__c mergeType, Exception ex) {
		writeErrorLog(null, null, batchName, apexJob, mergeType, ex);
	}
	
	public static void writeErrorLog(String parentRecordId, Merge_Type_Candidate_Stage_gne__c parentCandidate, String batchName, Merge_Type_Apex_Job_gne__c apexJob, Merge_Type_gne__c mergeType, Exception ex) {               
    	try {
        	Merge_Type_Error_Log_gne__c errorLog = new Merge_Type_Error_Log_gne__c(
        		Merge_Type_ref_gne__c = mergeType.Id,
        		Merge_Type_Apex_Job_ref_gne__c = (apexJob!=null ? apexJob.Id : null),
        		Merge_Type_Candidate_Stage_ref_gne__c = (parentCandidate!=null ? parentCandidate.Id : null),
        		Parent_Id_gne__c = parentRecordId,
        		Batch_Name_gne__c = batchName,
        		Level_gne__c = 'High',
        		Description_gne__c = ex.getMessage(),
        		Stacktrace_gne__c = ex.getStackTraceString()
        	);
        	Database.DMLOptions dmlOpt = new Database.DMLOptions();
        	dmlOpt.allowFieldTruncation = true;
        	Database.insert(errorLog, dmlOpt);        	
        } catch (Exception e) {
        	System.debug (LoggingLevel.INFO, 'Unable to log error ( ' + ex.getMessage() + '). writeErrorLog exception --> ' + e.getMessage());	
        }
    }
    
    public static void updateCandidatesApprovalStatus(Map<Id,String> approvalStatuses) {
    	if(!isMergeProcessRunning()) {
	    	List<Merge_Type_Candidate_Stage_gne__c> mergeCandidates = [
	    		SELECT Id_gne__c, DCH_Approval_Status_gne__c
	    		FROM Merge_Type_Candidate_Stage_gne__c
	    		WHERE Id_gne__c IN :approvalStatuses.keySet()
	    			AND DCH_Action_gne__c <> :DCH_ACTION_WINNER
	    	];
	    	
	    	for(Merge_Type_Candidate_Stage_gne__c mc : mergeCandidates) {
	    		mc.DCH_Approval_Status_gne__c = approvalStatuses.get((Id)mc.Id_gne__c);
	    	}
	    	
	    	Database.update(mergeCandidates);
    	}
    }
    
    public static Boolean isMergeProcessRunning() {
    	return isMergeProcessRunning==true;
    }
    
    public static void setMergeProcessRunning(Boolean value) {
    	isMergeProcessRunning = value;
    }
}