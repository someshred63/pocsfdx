public abstract class  GNE_Merge_DCHSupport implements Database.Stateful {

    protected String parentAccountId  = null;    
    protected set<String> objectIdList = new Set<String>();
    protected Set<Id> mergePlacholdersIds = new Set<Id>();    

    protected GNE_ObjectMerge_Controller objController = null;
    protected String objectName = 'Account';        
    protected boolean bCheckMode = false;

    protected Set<String> fieldSet = null;
    abstract void populateFieldSet ();

    Integer UniqueGroupCount = 0;
    Integer RuntimeErrorCount = 0;
    
    void callMerge () {
    	        	
        String sql = 'select id, dch_parent_id_gne__c, dch_previous_id_gne__c,' + 
             'dch_merge_type_gne__c, dch_approval_status_gne__c, dch_action_gne__c,' + 
             'dch_merge_exceptions_gne__c, dch_merge_exception_desc_gne__c, ' +
             'dch_action_date_gne__c, dch_clone_gne__c ' + 
             ' from ' + objectName ;
        
        Sobject[] objectList   = Database.query (sql + ' where id in :mergePlacholdersIds ');
        SObject   parentRecord = Database.query (sql + ' where id = :parentAccountId ');
        System.Savepoint sp = Database.setSavepoint();
        
        Database.DMLOptions dmlOpt = new Database.DMLOptions();
        dmlOpt.allowFieldTruncation = true;
        dmlOpt.optAllOrNone = true;
                                                            
        try {
            GNE_Merge_DuplicateSet duplicateSet = new GNE_Merge_DuplicateSet();
            duplicateSet.initialize();
            duplicateSet.LoserIdSet     = objectIdList;
            duplicateSet.winnerRecordId = parentAccountId;
            
            Boolean bIsPersonAccount = false;
            String mergeType = (String ) parentRecord.get('dch_merge_type_gne__c');                    
            if ( mergeType.equals('Person Account') )
                bIsPersonAccount = true;
            
            Set<String> parentRecordIdSet = new Set<String>();
            Set<String> clonedRecordIdSet = new Set<String>();
            
            for (SObject objectRecord : objectList ) { 
                clonedRecordIdSet.add ( (String) objectRecord.get('id') );
                parentRecordIdSet.add ( (String) objectRecord.get('dch_previous_id_gne__c') );
            }                
            GNE_Merge_Utility_RecordClone.cloneRecordList (parentRecordIdSet, 
                                                           clonedRecordIdSet, 
	                                                       fieldSet,   
	                                                       objectName, 
	                                                       bIsPersonAccount) ;
               
            String returnObjectId = objController.doMerge ( objectIdList, parentAccountId, duplicateSet);
                    
            Set<String> allExceptionListSet = new Set<String>();
            Set<String> allExceptionDescSet = new Set<String>();
            
            for ( SObject objectRecord : objectList ){                                        
                List<String> exceptionCodeList = 
                    duplicateSet.LoserToExceptionCodeList.get((String)objectRecord.get('dch_previous_id_gne__c'));
                if ( exceptionCodeList == null ) {
                    objectRecord.put('dch_merge_exceptions_gne__c','No Exceptions Recorded');
                    objectRecord.put('dch_merge_exception_desc_gne__c', null);
                    objectRecord.put('dch_clone_gne__c', True);
                } else {
                    Set<String> exceptionListSet = new Set<String>();
                    Set<String> exceptionDescSet = new Set<String>();
                    
                    for ( String exceptionCode : exceptionCodeList ) {
                    	if(String.isNotBlank(exceptionCode)) {
                    		exceptionListSet.add(exceptionCode);
                    	}
                    }

                    List<String> exceptionDescList = 
                        duplicateSet.LoserToErrorDescList.get((String)objectRecord.get('dch_previous_id_gne__c'));

                    for ( String exceptionDesc : exceptionDescList ) {
                    	if (String.isNotBlank(exceptionDesc)) {
                    		exceptionDescSet.add(exceptionDesc);
                    	}
                    }
                    allExceptionListSet.addAll(exceptionListSet);
                    allExceptionDescSet.addAll(exceptionDescSet);                    
                    objectRecord.put('dch_merge_exceptions_gne__c', String.join(new List<String>(exceptionListSet), ';'));
                    objectRecord.put('dch_merge_exception_desc_gne__c', String.join(new List<String>(exceptionDescSet), '\n'));
                    objectRecord.put('dch_clone_gne__c', False);                                        
                }
            }
            
            String allExceptionListString = String.join(new List<String>(allExceptionListSet), ';');
            String allExceptionDescString = String.join(new List<String>(allExceptionDescSet), '\n'); 
            
            // rollup all exception to parent 
            if (allExceptionListString.length() > 0 ){
                parentRecord.put ('dch_merge_exceptions_gne__c', allExceptionListString); 
                parentRecord.put('dch_merge_exception_desc_gne__c', allExceptionDescString); 
                if ( bCheckMode == false ) 
                    parentRecord.put('dch_approval_status_gne__c', 'Submitted');       
                objectList.add ( parentRecord );
            } else { 
                parentRecord.put ('dch_merge_exceptions_gne__c', 'No Exceptions Recorded'); 
                parentRecord.put('dch_merge_exception_desc_gne__c', null); 
                objectList.add ( parentRecord );
            }
            
            Database.update(objectList, dmlOpt);                                                      
                    
            // approval processing
            if ( allExceptionListString.length() > 0 ){                    
                if ( System.Label.DCH_Send_Approval_Notification_gne.equalsIgnoreCase('TRUE') && 
                     (bCheckMode == false) ) {
	                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
	                   
	                approvalRequest.setComments('Exceptions recorded for ' + objectName + 
	                                             'Merge Parent Record Id(' + parentAccountId + ') - Please review exceptions \n' + 
	                                 'Exception Code(s): ' + allExceptionListString + '\n' + 
	                                 'Exception Desc(s): ' + allExceptionDescString + '\n' );
                    	                                 
	                approvalRequest.setObjectId(parentAccountId);
	                Approval.ProcessResult result = Approval.process(approvalRequest);
                } else {	                
                    System.debug (LoggingLevel.INFO, 'No Approval is sent. '+ 
                                  'Please verify System.Label.DCH_Send_Approval_Notification_gne.');	
                }
            } else if (bCheckMode == false) {
            	System.debug (loggingLevel.INFO, 'Merge successfully. Update DCH Action in progress.');
            	//update dch action 
            	DateTime actionDate = DateTime.now();
                parentRecord.put ('dch_action_date_gne__c', actionDate  );
                parentRecord.put('dch_merge_exceptions_gne__c','No Exceptions Recorded');
                parentRecord.put('dch_merge_exception_desc_gne__c', null);
	            for ( SObject objectRecord : objectList ){
	               if ( objectRecord == parentRecord ) 
	                   continue;
	               String dchPreviousId = (String) objectRecord.get('dch_previous_id_gne__c');
	               String dchParentId   = (String) objectRecord.get('dch_parent_id_gne__c');
	               if ( dchPreviousId.equalsIgnoreCase(dchParentId) ) {
	                   objectRecord.put('dch_action_gne__c', 'Merge (Winner)');	
	               } else {
	               	   objectRecord.put('dch_action_gne__c', 'Merge (Loser)');
	               }
                   objectRecord.put ('dch_action_date_gne__c', actionDate  );
                   objectRecord.put('dch_merge_exceptions_gne__c','No Exceptions Recorded');
                   objectRecord.put('dch_merge_exception_desc_gne__c', null);
                   objectRecord.put('dch_clone_gne__c', True);
	            }
	            
	            Database.update(objectList, dmlOpt);           
                System.debug (loggingLevel.INFO, 'Merge successfully. Update DCH Action complete.');
            }                               
        } catch (Exception e){
        	Database.rollback(sp);
        	RuntimeErrorCount++;   
        	System.debug (LoggingLevel.INFO, 'Exception occured -> ' + e.getMessage() );
        	List<SObject> objectRecordsToUpdate = objectList.clone();
        	objectRecordsToUpdate.clear();
        	
        	Map<Id,SObject> objectsMap = new Map<Id,SObject>(objectList);
        	objectsMap.put(parentRecord.Id, parentRecord);
        	
            for ( SObject objectRecord : objectsMap.values()){
            	SObject objectRecordToUpdate = objectRecord.getSObjectType().newSObject(objectRecord.Id);                                    
                objectRecordToUpdate.put ('dch_merge_exceptions_gne__c', 'RUNTIME EXCEPTION');
                objectRecordToUpdate.put ('dch_merge_exception_desc_gne__c', e.getMessage());
                objectRecordToUpdate.put ('dch_clone_gne__c', False);
                objectRecordsToUpdate.add(objectRecordToUpdate);
            }
            
            Database.update(objectRecordsToUpdate, dmlOpt);        
            sendErrorEmail ( e );                                
        }
        objectIdList.clear();
        mergePlacholdersIds.clear();         
    }
    
    protected void doExecute(Database.BatchableContext BC, List<SObject> inputObjectList){
    	for ( Sobject record : inputObjectList ) {      
            String dchParentId  = (String ) record.get('dch_parent_id_gne__c');
	        try {                   	
	
	            System.debug (LoggingLevel.INFO, 'Archived Id/DCH Parent Id/DCH Previous Id ' + 
	                          record.get('Id') + '/' + dchParentId  + '/' + 
	                          record.get('dch_previous_id_gne__c') + '  processed. '); 
	            
	            if ( parentAccountId == null ) {
	               parentAccountId = dchParentId;
	            }
	               
	            if ( parentAccountId.equals(dchParentId) == false )  {

	            	if (objectIdList.size() > 1 ){
	                   callMerge();
	                   UniqueGroupCount++;
	            	}   
	                objectIdList.clear();
	                mergePlacholdersIds.clear();
	            }
	            
	            parentAccountId = dchParentId; 
	            objectIdList.add ( (String) record.get('dch_previous_id_gne__c') ) ;
	            mergePlacholdersIds.add(record.Id);
	            
	         } catch (Exception ex) {        
	            sendErrorEmail(ex);
	            objectIdList.clear();
	            mergePlacholdersIds.clear();
	            parentAccountId = dchParentId; 
	            objectIdList.add ( (String) record.get('dch_previous_id_gne__c') ) ;
	            mergePlacholdersIds.add(record.Id); 
	        }
    	}
    }
    
    protected void sendErrorEmail (Exception e) {    	
    	String className  = 'GNE_Merge_Batch_OrgAccount';
    	String objectType = 'Account';    	 
    	if ( this instanceOf GNE_Merge_Batch_PersonAccount ) {
    	   className = 'GNE_Merge_Batch_PersonAccount';
    	   objectType = 'PersonAccount';	
    	} else if ( this instanceOf GNE_Merge_Batch_Address ) {
    	   className = 'GNE_Merge_Batch_Address';
    	   objectType = 'Address_vod__c';	
    	} else { 
    	   className  = 'Generic Batch Class';
    	   objectType = objectName;
    	}
		GNE_Merge_Utility_ErrorLog.writeErrorLog(parentAccountId,
		                                         objectType,className, e);
    }
    
    protected void doFinish(Database.BatchableContext BC){
        //last merge batch
        try {                       
            if ( parentAccountId != null && objectIdList.size() > 1 ){
                callMerge();
                UniqueGroupCount++;
            }
            parentAccountId = null;
            objectIdList.clear();
            mergePlacholdersIds.clear();           
         } catch (Exception ex) {        
            sendErrorEmail(ex);
        }

        try {
	        AsyncApexJob a = [Select Id, Status, NumberOfErrors, ApexClass.Name, 
	                          JobItemsProcessed, TotalJobItems, CreatedBy.Email,
	                          createdDate, completedDate 
	                          from AsyncApexJob 
	                          where Id =:BC.getJobId()
	                          ];
	        User createdUser = a.CreatedBy;
	        ApexClass batchApexClass = a.ApexClass;
	                                          
	        // Send an email to the Apex job's submitter notifying of job completion.
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        String[] toAddresses = System.Label.DCH_Support_Email_List_gne.split(',');
	        mail.setToAddresses(toAddresses);
	        mail.setSubject('Apex Job ' + + batchApexClass.Name + 
	                        ' status ' + a.Status);

            mail.setPlainTextBody
                            ('The batch Apex job ' + batchApexClass.Name + 
                            '(' + objectName + ') processed '    + a.TotalJobItems +
                            ' batches with ' + a.NumberOfErrors + ' failures.\n' + 
                            'Batch Job StartTime / CompletedTime ' + 
                            a.CreatedDate + '/' + a.CompletedDate +  '.\n\n' + 
                            'Total Unique Group Count(duplicate sets processed)/Runtime Error Count: ' + 
                            UniqueGroupCount + '/' + RuntimeErrorCount );
	                        	                        
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
            System.debug (LoggingLevel.INFO, 'Unable to send email ' + e.getMessage() );    
        }

    }
}