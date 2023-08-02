global class Merge_Type_Engine_Batch implements Database.Batchable<SObject>, Database.Stateful  {

    // Merge Type Engine Input Parameters
    Merge_Type_gne__c mergeType = null;
    boolean bCheckMode = false;
    Set<String> parentIdSet = null;
    
    // merge type controller, object fields/soql
    Merge_Type_Controller objController = null;
    
    // merge stats
    Integer TotalRecordCount = 0;
    Integer UniqueGroupCount  = 0;
    Integer RuntimeErrorCount = 0;
    
    // current duplicate set related data set
    String parentId  = null;
    set<String> objectIdList = new Set<String>();
    Merge_Type_Candidate_Stage_gne__c parentCandidate = null;
    List<Merge_Type_Candidate_Stage_gne__c> objectList = new List<Merge_Type_Candidate_Stage_gne__c>();
    
    Merge_Type_Apex_Job_gne__c apexJob = null;
    String archiveQuerySoql = null;
    
    Map<Id, String> approvalReqs = new Map<Id, String>();
    Integer approvalCommentMaxLength = null;
    Database.DMLOptions dmlOpt;
    
    private Merge_Type_Engine_Batch_Scheduler.MergeTypeWrapper [] orderedObjectsToExecute;

    private void init () {
        // merge type controller
            objController = new Merge_Type_Controller(mergeType, bCheckMode);

        // archive query
	        archiveQuerySoql = Merge_Type_Util.getMergeTypeArchiveQuery(mergeType.Id);
	        
	        dmlOpt = new Database.DMLOptions();
        	dmlOpt.allowFieldTruncation = true;
        	dmlOpt.optAllOrNone = true;
    }
    
    public Merge_Type_Engine_Batch (Merge_Type_Engine_Batch_Scheduler.MergeTypeWrapper [] orderedObjectsToExecute, Merge_Type_gne__c mergeType, Boolean mergeRunMode, Merge_Type_Apex_Job_gne__c job) {
        this.orderedObjectsToExecute = orderedObjectsToExecute;
        this.mergeType = mergeType;
        this.bCheckMode = mergeRunMode;
        this.apexJob = job;
        init ();
    }

    public Merge_Type_Engine_Batch (Merge_Type_gne__c mergeType, boolean MergeRunMode, Merge_Type_Apex_Job_gne__c job) {
        this.mergeType = mergeType;
        bCheckMode      = MergeRunMode;
        this.apexJob = job;
        init ();
    }

    public Merge_Type_Engine_Batch (Merge_Type_gne__c mergeType, boolean MergeRunMode, Set<String> parentIdSet, Merge_Type_Apex_Job_gne__c job) {
        this.mergeType = mergeType;
        bCheckMode      = MergeRunMode;
        this.parentIdSet = parentIdSet;
        this.apexJob = job;
        init ();
    }

	// JSON archive to Merge_Candidate_Archive_gne__c dec 05 2012: guru k
    private void keepJSONCopyBeforeMerge () {
       	system.debug('JSON Merge Candidates Archive.');
       	system.debug('ARCHIVE QUERY: ' + this.archiveQuerySoql );
       	if(String.isNotBlank(this.archiveQuerySoql))
       	{
	        String archiveQueryWithId = this.archiveQuerySoql + ' where id in : objectIdList';
	 		List<Merge_Type_Candidate_Archive_gne__c> archiveList = new List<Merge_Type_Candidate_Archive_gne__c>();
            Map<Id,SObject> m_id_record = new Map<Id,SObject>(Database.query(archiveQueryWithId));
	       	for(Merge_Type_Candidate_Stage_gne__c candidate: this.objectList)
	       	{
	       		Sobject record = m_id_record.get (candidate.id_gne__c);
	       		if (record != null) {
		       		String jsonArchiveData = JSON.serializePretty(record);
			    	Merge_Type_Candidate_Archive_gne__c mtcArchive =
			    	     new Merge_Type_Candidate_Archive_gne__c(
					    	JSON_data_gne__c = jsonArchiveData,
					    	MergeApexJob_ref_gne__c = (this.apexJob!=null ? this.apexJob.id : null),
					    	Merge_Type_ref_gne__c = candidate.Merge_Type_ref_gne__c,
					    	Merge_Type_Candidate_ref_gne__c = candidate.id);
					archiveList.add(mtcArchive);
	       		}
	       	}
	       	system.debug('JSON Merge Candidates Archive list: ' + archiveList);
	       	insert archiveList;
       	}
    }

    // Deployment Package 2 DEC 13 2012
    private List<SObject> keepDCHCopyBeforeMerge() {
        List<sobject> dchSourceTableRecordList;
        
        if (parentCandidate.DCH_Source_Record_Id_gne__c != null) {
        	List<String> dchSourceTableRecordIdList = new List<String>();
            
            for (Merge_Type_Candidate_Stage_gne__c mtc : objectList) {
            	dchSourceTableRecordIdList.add (mtc.DCH_Source_Record_Id_gne__c);
            }
            
            if (mergeType.Name == Merge_Type_Util.MERGE_TYPE_NAME_ACCOUNT || mergeType.Name == Merge_Type_Util.MERGE_TYPE_NAME_PERSON_ACCOUNT) {
	            dchSourceTableRecordList = [select Id, recordTypeId,DCH_Parent_Id_gne__c,DCH_Previous_Id_gne__c, 
	                                        DCH_Action_gne__c, DCH_Approval_Status_gne__c, DCH_Source_gne__c, ownerId
	                                        from Account where id in :dchSourceTableRecordIdList];
            } else if (mergeType.Name == Merge_Type_Util.MERGE_TYPE_NAME_ACCOUNT_ADDRESS || mergeType.Name == Merge_Type_Util.MERGE_TYPE_NAME_PERSON_ACCOUNT_ADDRESS) {
                dchSourceTableRecordList = [select Id, recordTypeId,DCH_Parent_Id_gne__c,DCH_Previous_Id_gne__c, 
                                            DCH_Action_gne__c, DCH_Approval_Status_gne__c, DCH_Source_gne__c
                                            from Address_vod__c where id in :dchSourceTableRecordIdList];
            }
            
            if(Merge_Type_Util.isCloneDCHFieldsEnabled(mergeType.Id)) {
            	cloneFieldsToDCHRecords(dchSourceTableRecordList);
            	Database.update(dchSourceTableRecordList);
            }
        } else{
	        if (mergeType.Name == Merge_Type_Util.MERGE_TYPE_NAME_ACCOUNT) {
	        	dchSourceTableRecordList = Merge_Type_Util.prepareAccountDCHRecords(parentId,objectIdList,mergeType);
	        } else if (mergeType.Name == Merge_Type_Util.MERGE_TYPE_NAME_PERSON_ACCOUNT) {
	            dchSourceTableRecordList = Merge_Type_Util.prepareAccountDCHRecords(parentId,objectIdList,mergeType);
	        } else if (mergeType.Name == Merge_Type_Util.MERGE_TYPE_NAME_ACCOUNT_ADDRESS) {
	            dchSourceTableRecordList =Merge_Type_Util.prepareAddressDCHRecords(parentId,objectIdList,mergeType);
	        } else if (mergeType.Name == Merge_Type_Util.MERGE_TYPE_NAME_PERSON_ACCOUNT_ADDRESS) {
	            dchSourceTableRecordList= Merge_Type_Util.prepareAddressDCHRecords(parentId,objectIdList,mergeType);
	        }
	        
	        if (dchSourceTableRecordList != null && dchSourceTableRecordList.size() > 0) {
	        	if(Merge_Type_Util.isCloneDCHFieldsEnabled(mergeType.Id)) {
            		cloneFieldsToDCHRecords(dchSourceTableRecordList);
	        	}
	        	
                database.insert(dchSourceTableRecordList);
                
                for (Merge_Type_Candidate_Stage_gne__c mtc : objectList) {
                	for (sobject record : dchSourceTableRecordList) {
                    	String dchPreviousId = (String)record.get('dch_previous_id_gne__c');
                        
                        if ( mtc.Id_gne__c == dchPreviousId) {
                        	mtc.dch_source_record_Id_gne__c = (String)record.get('Id');
                        	break;
                        }
                    }
                }
                
                update objectList;
            }
        }

        return dchSourceTableRecordList;
    }
    
    private void cloneFieldsToDCHRecords(List<SObject> dchRecordsList) {
    	Set<String> fieldSet = getFieldSet();
    	Map<Id,SObject> dchMap = new Map<Id,SObject>();
    	Set<Id> srcIds = new Set<Id>();
    	Set<Id> dchIds = new Set<Id>();
    	
    	for(Merge_Type_Candidate_Stage_gne__c mtc : objectList) {
    		srcIds.add(mtc.Id_gne__c);
    	}
    	
    	for(SObject dchRec : dchRecordsList) {
    		dchMap.put((Id)dchRec.get('dch_previous_id_gne__c'), dchRec);
    		
    		if(dchRec.Id!=null) {
    			dchIds.add(dchRec.Id);
    		}
    	}
    	
    	Map<Id,SObject> srcRecords = new Map<Id,SObject>(Database.query(String.format('SELECT RecordType.Name, {0} FROM {1} WHERE Id IN :srcIds', new String[]{
    			String.join(new List<String>(fieldSet),','), mergeType.Object_Name_gne__c
    	})));
    	
    	Map<Id,SObject> dchRecords = null;
    	
    	if(!dchIds.isEmpty()) {
    		dchRecords = new Map<Id,SObject>(Database.query(String.format('SELECT {0} FROM {1} WHERE Id IN :dchIds', new String[]{
    				String.join(new List<String>(fieldSet),','), mergeType.Object_Name_gne__c
    		})));
    	}
    	
    	
    	Set<String> excludedFields = new Set<String>{
    		'NAME', 'FIRSTNAME', 'LASTNAME', 'RECORDTYPEID',
			'AMS_ID_GNE__C', 'MDMID_GNE__C', 'MDM_UPDATE_DATE_GNE__C', 'STEWARDSHIP_SYSTEM_NAME_GNE__C',
			'MDM_PLAN_PRODUCT_ID_GNE__C', 'MDM_ADDRESS_ID_GNE__C', 'MDMID_STATUS_GNE__C', 'STATUS_GNE__C',
			'SCORECARD_ACCOUNT_ID_GNE__C', 'SAP_ID_GNE__C',	'RECORD_TYPE_TEXT_GNE__C',
			'PHYSICIAN_PORTAL_USERNAME_GNE__C', 'IPHONE_REQUEST_ID_GNE__C'
    	};
    	
    	for(Id srcId : dchMap.keySet()) {
    		SObject srcRec = srcRecords.get(srcId);
    		SObject dchRec = dchMap.get(srcId);
    		
    		if(srcRec!=null) {
	    		for(String fieldName : fieldSet) {
	    			if(!excludedFields.contains(fieldName)) {
	    				Object srcValue = srcRec.get(fieldName);
	    				Object dchPrevValue = dchRec.Id==null ? dchRec.get(fieldName) : dchRecords.get(dchRec.Id).get(fieldName);
	    				
	    				if(srcValue!=null || dchPrevValue!=null) { 
	    					dchRec.put(fieldName, srcValue);
	    				}
	    			}
	    		}
	    		
	    		if(fieldSet.contains('MDMID_GNE__C') && srcRec.get('MDMID_GNE__C')!=null) {
		        	dchRec.put('DCH_PREVIOUS_MDMID_GNE__C', srcRec.get('MDMID_GNE__C'));
	    		}
		                
		        if(fieldSet.contains('MDM_PLAN_PRODUCT_ID_GNE__C') && srcRec.get('MDM_PLAN_PRODUCT_ID_GNE__C')!=null) {
		        	dchRec.put('DCH_PREVIOUS_MDM_PLAN_PRODUCT_ID_GNE__C', srcRec.get('MDM_PLAN_PRODUCT_ID_GNE__C'));
		        }
		        
		        if(fieldSet.contains('MDM_ADDRESS_ID_GNE__C') && srcRec.get('MDM_ADDRESS_ID_GNE__C')!=null) {
		        	dchRec.put('DCH_PREVIOUS_MDM_ADDRESS_ID_GNE__C', srcRec.get('MDM_ADDRESS_ID_GNE__C'));
		        }
		
		        if(fieldSet.contains('RECORDTYPEID') && fieldSet.contains('DCH_PREVIOUS_RECORDTYPE_ID_GNE__C') && srcRec.get('RECORDTYPEID')!=null) {
		        	dchRec.put('DCH_PREVIOUS_RECORDTYPE_ID_GNE__C', srcRec.get('RECORDTYPEID'));
		        }
		        
		        SObject recordTypeObject = srcRec.getSObject('RecordType');
		        
		        if(recordTypeObject!=null) {
		            dchRec.put('DCH_PREVIOUS_RECORDTYPE_GNE__C', recordTypeObject.get('Name')); 
		        }
		    }
            
            dchRec.put('DCH_Clone_gne__c', true);	
    	}
    }
    
    private Set<String> getFieldSet() {
    	Set<String> fieldSet = new Set<String>();
    	Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(mergeType.Object_Name_gne__c).getDescribe().fields.getMap();
    	
    	for(String fieldName : fieldMap.keySet()) {
    		String fieldNameUC = fieldName.toUpperCase();
    		Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                        
            if(!fieldNameUC.startsWith('DCH') && (mergeType.Name!=Merge_Type_Util.MERGE_TYPE_NAME_ACCOUNT || !fieldNameUC.endsWith('_PC')) &&
               fieldDescribe.isCalculated() == false && fieldDescribe.isUpdateable() == true && fieldDescribe.isCreateable() == true && fieldDescribe.getReferenceTo().isEmpty()) {
            	fieldSet.add(fieldNameUC);
            }                       
        }
        
        fieldSet.add('RECORDTYPEID');
        return fieldSet;
    }

    private void captureDCHInfoToMergeTypeCandidate(Merge_Type_DuplicateSet duplicateSet) {
	    Set<String> allExceptionListSet = new Set<String>();
        Set<String> allExceptionDescSet = new Set<String>();
            
	    for ( Merge_Type_Candidate_Stage_gne__c candidate : objectList ){
	        List<String> exceptionCodeList = duplicateSet.LoserToExceptionCodeList.get( candidate.id_gne__c);
	        if ( exceptionCodeList == null ) {
	            candidate.dch_merge_type_exception_gne__c=Merge_Type_Util.DCH_ACTION_NO_EXCEPTION;
	            candidate.dch_merge_type_exception_desc_gne__c = null;
	            candidate.dch_clone_gne__c = true;
	        } else {
	            Set<String> exceptionListSet = new Set<String>();
                Set<String> exceptionDescSet = new Set<String>();
                
	            for (String exceptionCode : exceptionCodeList) {
	                if(String.isNotBlank(exceptionCode)) {
                    	exceptionListSet.add(exceptionCode);
                    }
	            }
	            
	            List<String> exceptionDescList = duplicateSet.LoserToErrorDescList.get(candidate.id_gne__c);
	            
	            for (String exceptionDesc : exceptionDescList) {
	                if (String.isNotBlank(exceptionDesc)) {
                    	exceptionDescSet.add(exceptionDesc);
                    }
	            }
	            
	            allExceptionListSet.addAll(exceptionListSet);
                allExceptionDescSet.addAll(exceptionDescSet);
                 
	            candidate.dch_merge_type_exception_gne__c=String.join(new List<String>(exceptionListSet), ';');
	            candidate.dch_merge_type_exception_desc_gne__c = String.join(new List<String>(exceptionDescSet), '\n');
	            candidate.dch_clone_gne__c = false;
	        }
	    }

        if(!allExceptionListSet.isEmpty()){
        	String allExceptionListString = String.join(new List<String>(allExceptionListSet), ';');
            String allExceptionDescString = String.join(new List<String>(allExceptionDescSet), '\n');
            
            parentCandidate.dch_merge_type_exception_gne__c =  allExceptionListString;
            parentCandidate.dch_merge_type_exception_desc_gne__c = allExceptionDescString;
            parentCandidate.dch_clone_gne__c = false;

            // approval processing
            if (bCheckMode == false && Merge_Type_Util.isApprovalProcessEnabled(mergeType.Id)){
                parentCandidate.DCH_Approval_Status_gne__c = 'Submitted';
                String approvalComment = 'Exceptions recorded for ' + mergeType.Object_Name_gne__c + ' Merge\n' +
                                         'Winner Record Id(' + parentId + ') - Please review exceptions \n' +
                		                 'Exception Code(s): ' + allExceptionListString + '\n' +
                           			     'Exception Desc(s): ' + allExceptionDescString.abbreviate(200) + '\n';
                SObject parentRec = ((Id)parentId).getSObjectType().newSObject(parentId);
                parentRec.put('dch_merge_exceptions_gne__c', parentCandidate.dch_merge_type_exception_gne__c);
                parentRec.put('dch_approval_status_gne__c', 'Submitted');
                Database.update(parentRec, dmlOpt);
                approvalReqs.put(parentId, approvalComment);
            }
        } else {
            System.debug (loggingLevel.INFO, 'Merge successfully. Update DCH Action in progress.');
            DateTime actionDate = DateTime.now();
            for ( Merge_Type_Candidate_Stage_gne__c candidate : objectList ){
                candidate.dch_action_date_gne__c = actionDate  ;
                candidate.dch_merge_type_exception_gne__c=Merge_Type_Util.DCH_ACTION_NO_EXCEPTION;
                candidate.dch_merge_type_exception_desc_gne__c = null;
                candidate.dch_clone_gne__c = true;
                if ( candidate == parentCandidate ) {
                   candidate.dch_action_gne__c = bCheckMode ? Merge_Type_Util.DCH_ACTION_CHECKMODE_WINNER : Merge_Type_Util.DCH_ACTION_WINNER;
                } else {
                	candidate.dch_action_gne__c= bcheckMode ? Merge_Type_Util.DCH_ACTION_CHECKMODE_LOSER : Merge_Type_Util.DCH_ACTION_LOSER;
                }
            }
        }
    }

    private void captureDCHInfoToAccountRecordMergeCandidate(List<SObject> dchSourceTableRecordList) {
    	// OTR integration
        for (Merge_Type_Candidate_Stage_gne__c mtc : objectList) {
            for (sobject record : dchSourceTableRecordList) {
                String dchPreviousId = (String)record.get('dch_previous_id_gne__c');
                if ( mtc.Id_gne__c == dchPreviousId) {
                    if ( mtc.dch_action_gne__c == Merge_Type_Util.DCH_ACTION_LOSER) {
                    	record.put('dch_action_gne__c', 'Merge (Loser)');
                    } else if ( mtc.dch_action_gne__c == Merge_Type_Util.DCH_ACTION_WINNER) {
                    	record.put('dch_action_gne__c', 'Merge (Winner)');
                    }
                    break;
                }
            }
        }
        update dchSourceTableRecordList;
    }
    
    private void executeApprovalProcess() {
    	try {
	    	List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
	            
	        for(ID parentId : this.approvalReqs.keySet()) {
	          	Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
	            approvalRequest.setObjectId(parentId);
	            String approvalComment = this.approvalReqs.get(parentId);
	            approvalComment = approvalComment!=null ? approvalComment.abbreviate(getApprovalCommentMaxLength()) : null;
	            approvalRequest.setComments(approvalComment);
	            approvalRequests.add(approvalRequest);
	        }
	        
	        if(!approvalRequests.isEmpty()) {
	        	// Disable merge process running mode. We want to call Merge_Type_Util.updateCandidatesApprovalStatus() trigger logic if needed
	        	Merge_Type_Util.setMergeProcessRunning(false);
	          	Approval.ProcessResult[] approvalResults = Approval.process(approvalRequests, false);
	          	Merge_Type_Util.setMergeProcessRunning(true);
	           	for(Approval.ProcessResult apr : approvalResults) {
	           		if(!apr.isSuccess()) {
	           			for(Database.Error err: apr.getErrors()) {
	           				if(err.getStatusCode() != StatusCode.ALREADY_IN_PROCESS) {
	           					throw new Merge_Type_Exception(err.getMessage());
	           				}
	           			}
	           		}
	           	}
	        }
    	} finally {
        	approvalReqs.clear();
    	}
    }
    
    private Integer getApprovalCommentMaxLength() {
    	if(approvalCommentMaxLength==null) {
    		approvalCommentMaxLength = Approval.RequestComment.getDescribe().getLength();
    	}
    	
    	return approvalCommentMaxLength;
    }
    
    private void callMerge() {
    	system.debug('MERGE.1');
    	System.Savepoint sp = Database.setSavepoint();
    	
    	try {
	    	approvalReqs.clear();

	        Merge_Type_DuplicateSet duplicateSet = new Merge_Type_DuplicateSet();
	        duplicateSet.initialize();
	        duplicateSet.LoserIdSet     = objectIdList;
	        duplicateSet.winnerRecordId = parentId;

            // JSON Archive
            keepJSONCopyBeforeMerge();

            // DCH archive for account, address merge types
            List<SObject> dchSourceTableRecordList ;
            if (mergeType.Object_Name_gne__c == Merge_Type_Util.MERGE_TYPE_OBJECT_ACCOUNT ||
                mergeType.Object_Name_gne__c == Merge_Type_Util.MERGE_TYPE_OBJECT_ADDRESS) {
            	dchSourceTableRecordList = keepDCHCopyBeforeMerge();
            }

            String returnObjectId = objController.doMerge ( objectIdList, parentId, duplicateSet);

            // Merge Type Candidate DCH/Processing Info
            captureDCHInfoToMergeTypeCandidate(duplicateSet);

            // OTR integration compatibility
            if (mergeType.Object_Name_gne__c == Merge_Type_Util.MERGE_TYPE_OBJECT_ACCOUNT ||
                mergeType.Object_Name_gne__c == Merge_Type_Util.MERGE_TYPE_OBJECT_ADDRESS) {
	            if (returnObjectId != null && bCheckMode == false) {
	               captureDCHInfoToAccountRecordMergeCandidate(dchSourceTableRecordList);
	            }
            }
            
            Database.update(objectList, dmlOpt);
			// Once Merge Type Candidates are updated ('DCH_Approval_Status_gne__c' is equal 'Submitted') we can sent approval requests:
            executeApprovalProcess();
        } catch (Exception e){
        	database.rollback(sp);
            System.debug (LoggingLevel.INFO, 'Exception occured -> ' + e.getMessage() );
            List<Merge_Type_Candidate_Stage_gne__c> rtExceptionCandidatesToUpdate = new List<Merge_Type_Candidate_Stage_gne__c>(); 
            for ( Merge_Type_Candidate_Stage_gne__c candidate : objectList ){
            	// create a copy of candidate to be sure that we will update only the fields that we want 
            	rtExceptionCandidatesToUpdate.add(
            		new Merge_Type_Candidate_Stage_gne__c(
	            		Id = candidate.Id,
	            		dch_merge_type_exception_gne__c = Merge_Type_Util.DCH_ACTION_RUNTIME_EXCEPTION,
	            		dch_merge_type_exception_desc_gne__c = (e.getMessage() + '\n' + e.getStackTraceString()),
	            		dch_clone_gne__c = false));
            }
            Database.update(rtExceptionCandidatesToUpdate, dmlOpt);
            sendErrorEmail ( e );
        }

        objectIdList.clear();
        objectList.clear();
    }

    // batch methods, outerloop
    global Database.QueryLocator start(Database.batchableContext bc) {
		system.debug('--- Batch Start ---');
    	system.debug('ParentIdSet: ' + parentIdSet);
    	system.debug('MergeType : ' + mergeType);
    	
    	Merge_Type_Util.setMergeProcessRunning(true);

        GNE_SFA2_Util.switchMergeMode(true);

        // query locator over merge type for account or address
        Database.QueryLocator queryLocator = null;
        if ( parentIdSet == null ) {
            queryLocator = Database.getQueryLocator([select Id, Id_gne__c, ParentId_gne__c, Merge_Type_ref_gne__c,
                                                            DCH_Action_Date_gne__c, DCH_Action_gne__c, DCH_Approval_Status_gne__c,
                                                            DCH_Clone_gne__c, DCH_Previous_Id_Link_gne__c,
                                                            DCH_Source_gne__c, DCH_User_gne__c,
                                                            DCH_Merge_Type_Exception_gne__c,DCH_Merge_Type_Exception_Desc_gne__c,
                                                            DCH_Source_Record_Id_gne__c
                                                            from Merge_Type_Candidate_Stage_gne__c
                                                            where DCH_Action_gne__c in (
                                                                    :Merge_Type_Util.DCH_ACTION_DEFAULT_LOGIC,
                                                                    :Merge_Type_Util.DCH_ACTION_CHECKMODE_WINNER,
                                                                    :Merge_Type_Util.DCH_ACTION_CHECKMODE_LOSER
                                                                    )
                                                                  and DCH_Approval_Status_gne__c in (:Merge_Type_Util.DCH_APPROVAL_APPROVED_STATUS, :Merge_Type_Util.DCH_APPROVAL_DEFAULT_STATUS)
                                                                  and Merge_Type_ref_gne__c = :mergeType.Id
                                                            order by ParentId_gne__c]);
        } else {
            queryLocator = Database.getQueryLocator([select Id, Id_gne__c, ParentId_gne__c, Merge_Type_ref_gne__c,
                                                            DCH_Action_Date_gne__c, DCH_Action_gne__c, DCH_Approval_Status_gne__c,
                                                            DCH_Clone_gne__c, DCH_Previous_Id_Link_gne__c,
                                                            DCH_Source_gne__c, DCH_User_gne__c,
                                                            DCH_Merge_Type_Exception_gne__c,DCH_Merge_Type_Exception_Desc_gne__c,
                                                            DCH_Source_Record_Id_gne__c
                                                            from Merge_Type_Candidate_Stage_gne__c
                                                            where DCH_Action_gne__c in (
                                                                    :Merge_Type_Util.DCH_ACTION_DEFAULT_LOGIC,
                                                                    :Merge_Type_Util.DCH_ACTION_CHECKMODE_WINNER,
                                                                    :Merge_Type_Util.DCH_ACTION_CHECKMODE_LOSER
                                                                    )
                                                                  and DCH_Approval_Status_gne__c in (:Merge_Type_Util.DCH_APPROVAL_APPROVED_STATUS, :Merge_Type_Util.DCH_APPROVAL_DEFAULT_STATUS)
                                                                  and Merge_Type_ref_gne__c = :mergeType.Id
                                                                  and ParentId_gne__c in :parentIdSet
                                                            order by ParentId_gne__c]);
        }
        return queryLocator;
    }

    global void execute(Database.BatchableContext BC, List<SObject> inputObjectList){
 		system.debug('--- Batch Execute ---');
 		system.debug('InputObjectList: ' + inputObjectList);
		Merge_Type_Util.setMergeProcessRunning(true);
		
        for ( Sobject record : inputObjectList ) {
            Merge_Type_Candidate_Stage_gne__c candidate = (Merge_Type_Candidate_Stage_gne__c) record;
            system.debug('Candidate: ' + candidate);
            TotalRecordCount++;
            try {
                System.debug (LoggingLevel.INFO, 'Id / ParentId_gne__c ' +
                              candidate.id_gne__c + '/' +  candidate.parentId_gne__c + '  processed. ');

				system.debug('ParentId: ' + parentId);
                if ( parentId == null ) {
                   parentId = candidate.parentId_gne__c;
                   //parentCandidate = candidate; // defect 18 jan 17 2013, qa/neha saxena
                }

                if ( parentId.equals(candidate.parentId_gne__c) == false )  { // new duplicate set
                    if (objectIdList.size() > 1 ){
                    	system.debug('ObjectIdList: ' + objectIdList);

                        UniqueGroupCount++;
                        // PENDING dec 08 2012
                        // fetch records(id objectIdList) from merge_type_gne__c.object_name_g__c
                        //  verify they do exists and build duplicate set using them.
                        if (parentCandidate != null && parentId != null){
                            callMerge();
                        }
                    }
                    objectIdList.clear();
                    objectList.clear();
                    parentId = candidate.parentId_gne__c;
                    //parentCandidate = candidate; // defect 18 jan 17 2013, qa/neha saxena
                    parentCandidate = null;
                }
                
                if (parentCandidate == null && candidate.Id_gne__c==candidate.parentid_gne__c) {
                   parentCandidate = candidate;  
                }

                objectIdList.add (candidate.id_gne__c) ;
                objectList.add ( candidate );
             } catch (Exception ex) {
                sendErrorEmail(ex);
                objectIdList.clear();
                objectList.clear();
                parentId = candidate.parentId_gne__c;
                //parentCandidate = candidate; // defect 18 jan 17 2013, qa/neha saxena
                parentCandidate = null;
	            
	            if(candidate.Id_gne__c==candidate.parentid_gne__c) {
	            	parentCandidate = candidate;  
	            }
	            
                objectIdList.add (candidate.id_gne__c) ;
                objectList.add ( candidate );
            }
        }
    }

    private void sendErrorEmail (Exception e) {
        RuntimeErrorCount++;
        Merge_Type_Util.writeErrorLog(parentId, parentCandidate, Merge_Type_Util.MERGE_JOB_BATCH_NAME, apexJob, mergeType, e);
    }

    global void finish(Database.BatchableContext BC){
    	system.debug('Merge finish.1');
    	Merge_Type_Util.setMergeProcessRunning(true);
    	
        //last merge batch
        try {
        	if(objectIdList.size()>1){
				UniqueGroupCount++;
            
                if (parentCandidate != null && parentId != null){
                	callMerge();
                }
            }
            
            parentId = null;
            objectIdList.clear();
            objectList.clear();
         } catch (Exception ex) {
            sendErrorEmail(ex);
        }

        system.debug('Merge finish.2');
        Merge_Type_Util.finalizeBatch(BC.getJobId(), mergeType, apexJob, TotalRecordCount, UniqueGroupCount, RuntimeErrorCount);
        
        if(orderedObjectsToExecute != null && !orderedObjectsToExecute.isEmpty()) {
            orderedObjectsToExecute.remove(0);
            if(!orderedObjectsToExecute.isEmpty()) {
                Merge_Type_Engine_Batch_Scheduler.MergeTypeWrapper  mtw = orderedObjectsToExecute[0];
                Merge_Type_gne__c mergeType = mtw.mergeType;
                Merge_Type_Apex_Job_gne__c job = new Merge_Type_Apex_Job_gne__c(Merge_Type_ref_gne__c = mergeType.Id, Apex_Job_Type_gne__c = mtw.apexJobType == Merge_Type_Util.APEX_JOB_TYPE_MERGE ?Merge_Type_Util.APEX_JOB_TYPE_MERGE : Merge_Type_Util.APEX_JOB_TYPE_INSERT_CANDIDATES);
                insert job;

                if(mtw.apexJobType == Merge_Type_Util.APEX_JOB_TYPE_MERGE){
                    Merge_Type_Engine_Batch asyncJob = new Merge_Type_Engine_Batch(orderedObjectsToExecute, mergeType, bCheckMode, job); 
                    Database.executeBatch (asyncJob, 10); 
                } else {
                    Merge_Type_Insert_Candidate_Batch asyncJob = new Merge_Type_Insert_Candidate_Batch(orderedObjectsToExecute, mergeType, job, bCheckMode);
                    Database.executeBatch (asyncJob, 2000); 
                }
            }                      
        }

        GNE_SFA2_Util.switchMergeMode(false);

    }
}