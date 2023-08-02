global class GNE_Merge_Batch_AccountExternal extends GNE_Merge_UniqueKeyObjectSupport 
            implements Database.Batchable<SObject>, Database.Stateful  {

/* steps to run this in setup window:
   Id batchInstanceId = database.executeBatch(new GNE_Merge_Batch_AccountExternal(true,10),1); 
*/
    
    public GNE_Merge_Batch_AccountExternal (boolean MergeRunMode, Integer numOfRecordsToProcess, SObject record) {
        super(MergeRunMode, numOfRecordsToProcess, record);
    }    

    public GNE_Merge_Batch_AccountExternal (boolean MergeRunMode, Set<String> parentIdSet, SObject record) {
    	super(MergeRunMode, parentIdSet, record); 
    }    
    
    
    global Database.QueryLocator start(Database.batchableContext bc) {        
        String mergeList = null;
        if ( parentIdSet != null ) {
            mergeList = 'select id, unique_key_calc_gne__c ' +  
                           ' from ' + objectName + ' ' +   
                           ' where third_party_gne__c != null and third_party_id_gne__c != null  ' + 
                           ' unique_key_calc_gne__c in :parentIdSet ' +
                           ' order by unique_key_calc_gne__c, createddate asc ' ; 
        } else {                 
            mergeList = 'select id, unique_key_calc_gne__c ' +  
                           ' from ' + objectName  + ' ' +    
                           ' where third_party_gne__c != null and third_party_id_gne__c != null  ' + 
                           ' order by unique_key_calc_gne__c, createddate asc limit ' + limitRows ; 
        }
        
        System.debug (LoggingLevel.INFO, objectName + ' Query-> ' + mergeList);                                    
        return Database.getQueryLocator ( mergeList );      
        //return super.getQueryLocator();
    }

    global void execute(Database.BatchableContext BC, List<SObject> objectList){        
        super.doExecute(BC,objectList);
    }
        
    global void finish(Database.BatchableContext BC){
        super.doFinish(BC);
    }    
}