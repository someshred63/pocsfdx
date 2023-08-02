global class GNE_Merge_Batch_OrgAccount extends GNE_Merge_DCHSupport 
     implements Database.Batchable<SObject>, Database.Stateful  {

/* steps to run this in setup window:
   Id batchInstanceId = database.executeBatch(new GNE_Merge_Batch_OrgAccount(true),1); 
*/
    Integer limitRows =0;
    Set<String> parentIdSet = null; 
    private Boolean executeNextBatchMode = false;
    
    public GNE_Merge_Batch_OrgAccount (boolean MergeRunMode, Integer numOfRecordsToProcess) { 
        this(MergeRunMode, numOfRecordsToProcess, false);
    }
    
    public GNE_Merge_Batch_OrgAccount (boolean MergeRunMode, Integer numOfRecordsToProcess, Boolean executeNextBatch) {
    	limitRows = numOfRecordsToProcess;
    	init(MergeRunMode, executeNextBatch);
    	populateFieldSet();
    }    

    public GNE_Merge_Batch_OrgAccount (boolean MergeRunMode, Set<String> parentIdSet) { 
        this.parentIdSet = parentIdSet;
        init(MergeRunMode, false);
    }
    
    private void init(Boolean MergeRunMode, Boolean executeNextBatch) {
    	bCheckMode = MergeRunMode;
    	executeNextBatchMode = executeNextBatch == true;
        objController = new GNE_ObjectMerge_Controller('Account', 'Account', MergeRunMode);
        populateFieldSet();
    }
    
    void populateFieldSet () {     	    
	    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();    	
    	fieldSet = new Set<String>();
    	
        for (String fieldName: fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = 
                fieldMap.get(fieldName).getDescribe();
        	            
            if ( fieldDescribe.isCalculated() ||
                 (fieldDescribe.isUpdateable() == false) ||
                 (fieldDescribe.isCreateable() == false) ||
                 (fieldDescribe.getReferenceTo().size() > 0) 
            )
                continue; 
    	
    	   String fieldNameUpperCase = fieldName.toUpperCase();
    	   if ( fieldNameUpperCase.endsWith('_PC') )
    	       continue;
    	       
    	   fieldSet.add ( fieldNameUpperCase );
        }	
        fieldSet.add ('RECORDTYPEID');
        fieldSet.remove ('RECORD_TYPE_TEXT_GNE__c'); 
    }
    
    global Database.QueryLocator start(Database.batchableContext bc) {
        
        String archivedRecordType    = 'Archived%';
        String actionType            = 'Default Logic';
        String mergeType             = 'Account';
        String defaultApprovalStatus = 'Default Approval';
        String approvedStatus        = 'Approved';
        //datetime for last job 
         
         String mergeList = null;
         
         if ( parentIdSet != null ) {
              mergeList = 'select id, dch_merge_exceptions_gne__c,  ' + 
                               'dch_previous_id_gne__c, dch_parent_id_gne__c, ' + 
                               'dch_merge_type_gne__c ' + 
                               'from account ' + 
                               'where dch_action_gne__c = :actionType and ' +
                               '(dch_parent_id_gne__r.dch_approval_status_gne__c = :approvedStatus or  ' +
                               ' dch_parent_id_gne__r.dch_approval_status_gne__c = :defaultApprovalStatus) and ' +  
                               'dch_merge_type_gne__c = :mergeType  and ' + 
                               'dch_parent_id_gne__c != null and ' +  
                               'ispersonaccount = false and ' + 
                               'RecordType.Name like :archivedRecordType and ' +
                               'dch_parent_id_gne__c in :parentIdSet  ' +  
                               'order by dch_parent_id_gne__c ' ;
         } else {       
	          mergeList = 'select id, dch_merge_exceptions_gne__c,  ' + 
	                           'dch_previous_id_gne__c, dch_parent_id_gne__c, ' + 
	                           'dch_merge_type_gne__c ' + 
	                           'from account ' + 
	                           'where dch_action_gne__c = :actionType and ' +
	                           '(dch_parent_id_gne__r.dch_approval_status_gne__c = :approvedStatus or  ' +
	                           ' dch_parent_id_gne__r.dch_approval_status_gne__c = :defaultApprovalStatus) and ' +  
	                           'dch_merge_type_gne__c = :mergeType  and ' + 
	                           'dch_parent_id_gne__c != null and ' +  
	                           'ispersonaccount = false and ' + 
	                           'RecordType.Name like :archivedRecordType ' +
	                           'order by dch_parent_id_gne__c limit :limitRows' ;
         }
 
         System.debug (LoggingLevel.INFO, 'OrgAccount Query-> ' + mergeList);                                    
         return Database.getQueryLocator ( mergeList ); 
    }

    global void execute(Database.BatchableContext BC, List<SObject> objectList){        
        super.doExecute(BC,objectList);
    }
        
    global void finish(Database.BatchableContext BC){
    	try {
        	super.doFinish(BC);
        } finally {
            if(executeNextBatchMode == true) {
	        	Database.executeBatch(new GNE_Merge_Batch_Address(bCheckMode, limitRows),1);
	        }
        }
    }
}