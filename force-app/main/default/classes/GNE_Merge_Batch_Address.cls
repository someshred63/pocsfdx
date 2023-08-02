global class GNE_Merge_Batch_Address extends GNE_Merge_DCHSupport 
     implements Database.Batchable<SObject>, Database.Stateful  {

/* steps to run this in setup window:
   Id batchInstanceId = database.executeBatch(new GNE_Merge_Batch_Address(true),1); 
*/

    Integer limitRows =0;
    Set<String> parentIdSet = null; 
      
    public GNE_Merge_Batch_Address (boolean MergeRunMode, Integer numOfRecordsToProcess) { 
        bCheckMode = MergeRunMode;
        objectName = 'Address_vod__c';
        objController = new GNE_ObjectMerge_Controller('Address_vod__c', '', MergeRunMode);
        limitRows = numOfRecordsToProcess;
        populateFieldSet();
    }    

    public GNE_Merge_Batch_Address (boolean MergeRunMode, Set<String> parentIdSet) { 
        bCheckMode = MergeRunMode;
        objectName = 'Address_vod__c';
        this.parentIdSet = parentIdSet; 
        objController = new GNE_ObjectMerge_Controller('Address_vod__c', '', MergeRunMode);
        populateFieldSet();
    }    
    
    void populateFieldSet () {          
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Address_vod__c.fields.getMap();     
        fieldSet = new Set<String>();
        
        for (String fieldName: fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = 
                fieldMap.get(fieldName).getDescribe();
                        
            if ( fieldDescribe.isCalculated() ||
                 fieldDescribe.isUnique() || 
                 (fieldDescribe.isUpdateable() == false) ||
                 (fieldDescribe.isCreateable() == false) ||
                 (fieldDescribe.getReferenceTo().size() > 0) 
            )
                continue; 
                                   
           fieldSet.add ( fieldName.toUpperCase() );
        }   
        fieldSet.add ('RECORDTYPEID');
        fieldSet.remove ('RECORD_TYPE_TEXT_GNE__c'); 
    }
    
    global Database.QueryLocator start(Database.batchableContext bc) {        
        String archivedRecordType = 'Archived%';
        String actionType         = 'Default Logic';
        String mergeType          = 'Address';
        String defaultApprovalStatus = 'Default Approval';
        String approvedStatus        = 'Approved';

        String mergeList = null;
        if ( parentIdSet != null ) {
            mergeList = 'select id, dch_merge_exceptions_gne__c,  ' + 
                           'dch_previous_id_gne__c, dch_parent_id_gne__c, ' + 
                           'dch_merge_type_gne__c ' + 
                           'from address_vod__c ' + 
                           'where dch_action_gne__c = :actionType and ' +
                           '(dch_parent_id_gne__r.dch_approval_status_gne__c = :approvedStatus or  ' +
                           ' dch_parent_id_gne__r.dch_approval_status_gne__c = :defaultApprovalStatus) and ' +  
                           'dch_merge_type_gne__c = :mergeType  and ' + 
                           'RecordType.Name like :archivedRecordType and ' + 
                           'dch_parent_id_gne__c != null and ' +
                           'dch_parent_id_gne__c in :parentIdSet  ' +  
                           'order by dch_parent_id_gne__c ' ;
        } else {                 
            mergeList = 'select id, dch_merge_exceptions_gne__c,  ' + 
                           'dch_previous_id_gne__c, dch_parent_id_gne__c, ' + 
                           'dch_merge_type_gne__c ' + 
                           'from address_vod__c ' + 
                           'where dch_action_gne__c = :actionType and ' +
                           '(dch_parent_id_gne__r.dch_approval_status_gne__c = :approvedStatus or  ' +
                           ' dch_parent_id_gne__r.dch_approval_status_gne__c = :defaultApprovalStatus) and ' +  
                           'dch_merge_type_gne__c = :mergeType  and ' + 
                           'RecordType.Name like :archivedRecordType and ' + 
                           'dch_parent_id_gne__c != null ' +  
                           'order by dch_parent_id_gne__c limit :limitRows' ;
        }
        
         System.debug (LoggingLevel.INFO, 'Address Query-> ' + mergeList);                                    
         return Database.getQueryLocator ( mergeList ); 
    }

    global void execute(Database.BatchableContext BC, List<SObject> objectList){        
        super.doExecute(BC,objectList);
    }
        
    global void finish(Database.BatchableContext BC){
        super.doFinish(BC);
    }
}