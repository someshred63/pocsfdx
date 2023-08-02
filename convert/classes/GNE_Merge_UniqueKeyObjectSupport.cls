public virtual class GNE_Merge_UniqueKeyObjectSupport {

    protected String parentAccountId  = null;  
    protected String parentUniqueKey  = null;  
    protected set<String> objectIdList = new Set<String>();    

    protected GNE_ObjectMerge_Controller objController = null;
    protected String objectName = null;        
    protected boolean bCheckMode = false;

    protected Set<String> fieldSet = null;
    protected String sql           = null;
    
    protected Integer limitRows =0;
    protected Set<String> parentIdSet = null; 
    
    Integer UniqueGroupCount  = 0;
    Integer RuntimeErrorCount = 0;

    void init ( boolean MergeRunMode, SObject record ) {
         
        bCheckMode      = MergeRunMode;
        
        Schema.DescribeSObjectResult objectDescribeResult =
                    record.getSObjectType().getDescribe();
                            
        objectName = objectDescribeResult.getName();


        Map<String, Schema.SObjectField> fieldMap = 
                objectDescribeResult.fields.getMap();     

        fieldSet = new Set<String>();
        for (String fieldName: fieldMap.keySet()) {
           if ( fieldName.equalsIgnoreCase('id') )
               continue;            
           fieldSet.add ( fieldName.toUpperCase() );
        }   
        
        populateFieldSet();
        objController = new GNE_ObjectMerge_Controller(objectName, '', MergeRunMode);
    }
    
    protected GNE_Merge_UniqueKeyObjectSupport (boolean MergeRunMode, Integer numOfRecordsToProcess, SObject record) {
        limitRows = numOfRecordsToProcess;
        init (MergerunMode,record); 
    }    

    protected GNE_Merge_UniqueKeyObjectSupport (boolean MergeRunMode, Set<String> parentIdSet, SObject record) { 
        this.parentIdSet = parentIdSet; 
        init (MergerunMode,record); 
    }    
    
    protected void populateFieldSet () {                  
        sql = 'select id ' ;
        for (String fieldName: fieldSet) {
           sql = sql + ',' + fieldName ;
        }   
        sql = sql + ' from ' + objectName;  
    }
    
    protected Database.QueryLocator getQueryLocator () {        

        String mergeList = null;
        if ( parentIdSet != null ) {
            mergeList = 'select id, unique_key_calc_gne__c ' +  
                           'from ' + objectName + ' ' +   
                           'where unique_key_calc_gne__c in :parentIdSet ' +
                           'order by unique_key_calc_gne__c, createddate asc ' ; 
        } else {                 
            mergeList = 'select id, unique_key_calc_gne__c ' +  
                           ' from ' + objectName  +    
                           ' order by unique_key_calc_gne__c, createddate asc limit ' + limitRows ; 
        }
        
		System.debug (LoggingLevel.INFO, objectName + ' Query-> ' + mergeList);                                    
		return Database.getQueryLocator ( mergeList ); 
    }

    
    void keepCopyBeforeMerge () {
        Sobject[] objectList   = Database.query (sql + ' where id in :objectIdList ');
        List<Post_Merge_Data_gne__c> postMergeRecordList 
                = new List<Post_Merge_Data_gne__c>();
            
        for (Sobject record : objectList) {            
            String fieldValues = 'Id=' + record.get('Id') + '::';
            for ( String fieldName : fieldSet ) {
                fieldValues = fieldValues + 
                              fieldName + '=' +  record.get(fieldName) + '::';
            }
                
            Post_Merge_Data_gne__c postMergeRecord =
                    new Post_Merge_Data_gne__c();
            postMergeRecord.object_type_gne__c  = objectName;
            postMergeRecord.object_id_gne__c    = (String) record.get('Id');
            postMergeRecord.new_object_id_gne__c= parentAccountId;
            postMergeRecord.field_values_gne__c = fieldValues;
            postMergeRecord.external_id_gne__c  = objectName + '::' + 
                                                  parentAccountId + '::' + 
                                                  record.get('Id');

            System.debug (LoggingLevel.INFO, 'keepCopyBeforeMerge --> ' + 
                             postMergeRecord.external_id_gne__c + '/' + 
                             postMergeRecord.field_values_gne__c );
                                                                                  
            if ( parentAccountId == (String ) record.get('Id') ) {                                                      
                postMergeRecord.Action_Type_gne__c = 'Update';  
            } else {
                postMergeRecord.Action_Type_gne__c = 'Delete';  
            }                
            postMergeRecordList.add ( postMergeRecord );                       
        }                                    
        upsert postMergeRecordList  external_id_gne__c;            
    }

    void captureLog (GNE_Merge_DuplicateSet duplicateSet) {     

        List<Post_Merge_Data_gne__c> postMergeRecordList 
                = new List<Post_Merge_Data_gne__c>();
        
        for ( String  recordId : duplicateSet.LoserIdSet ){                                        
            List<String> exceptionDescList = 
                duplicateSet.LoserToErrorDescList.get(recordId);
            
            if ( exceptionDescList != null ) {
                Post_Merge_Data_gne__c postMergeRecord =
                          new Post_Merge_Data_gne__c();
                          
                postMergeRecord.external_id_gne__c = objectName + '::' + 
                                                     parentAccountId + '::' + 
                                                     recordId ;
                String exceptionDescString = '';
                for ( String exceptionDesc : exceptionDescList ) {
                    exceptionDescString    = exceptionDescString + exceptionDesc + '\n';
                }
                postMergeRecord.error_message_gne__c = exceptionDescString;                                                                            
                postMergeRecordList.add ( postMergeRecord );
            }
        }
        
        if ( postMergeRecordList.size() > 0 )
            upsert postMergeRecordList  external_id_gne__c;
                        
    }
    
    void callMerge () {
        try {        
            keepCopyBeforeMerge();
            GNE_Merge_DuplicateSet duplicateSet = new GNE_Merge_DuplicateSet();
            duplicateSet.initialize();
            duplicateSet.LoserIdSet     = objectIdList;
            duplicateSet.winnerRecordId = parentAccountId;
            
            String returnObjectId = objController.doMerge ( objectIdList, parentAccountId, duplicateSet);
            if ( returnObjectId == null ) 
                captureLog ( duplicateSet );
                                                                    
        } catch (Exception e){   
            sendErrorEmail(e);
        }
        objectIdList.clear();          
    }
    
    protected void doExecute(Database.BatchableContext BC, List<SObject> inputObjectList){
        
        for ( Sobject record : inputObjectList ) {      
            String recordKey  = (String ) record.get('unique_key_calc_gne__c');
            try {                       
                System.debug (LoggingLevel.INFO, 'Id / Unique_key_calc_gne__c ' +   
                              record.get('Id') + '/' +  recordKey  + '  processed. '); 

                if ( parentAccountId == null ) {
                   parentAccountId = (String ) record.get('Id');
                   parentUniqueKey = recordKey;
                }
                   
                if ( parentUniqueKey.equals(recordKey) == false )  {
                    if (objectIdList.size() > 1 ){
                    	UniqueGroupCount++;
                        callMerge();
                        objectIdList.clear();
                    }
                    objectIdList.clear();
                    parentUniqueKey = recordKey;                 
                    parentAccountId = (String) record.get('Id');
                }    
                objectIdList.add ( (String) record.get('Id') ) ;                            
             } catch (Exception ex) {                        
                sendErrorEmail(ex);
                objectIdList.clear();                
                parentUniqueKey = recordKey; 
                parentAccountId = (String) record.get('Id');
                objectIdList.add ( (String) record.get('Id') ) ;                            
            }
        }
    }
    
    protected void sendErrorEmail (Exception e) {       
    	RuntimeErrorCount++;
        String className  = 'GNE_Merge_Batch_UniqueKeyObject(' + objectName + ')';
        GNE_Merge_Utility_ErrorLog.writeErrorLog(parentAccountId,
                                                 objectName,className, e);
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
         } catch (Exception ex) {        
            sendErrorEmail(ex);
        }

        try {
            AsyncApexJob a = [Select Id, Status, NumberOfErrors, ApexClass.Name, 
                              JobItemsProcessed, TotalJobItems, CreatedBy.Email,
                              CreatedDate, CompletedDate
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
                            '(' + objectName + ') ' +  
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