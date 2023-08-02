global class GNE_ETL_Batch_EventReplicaArchiveRemoval extends GNE_ETL_DataExchangeSupport
    implements Database.Batchable<SObject>, Database.Stateful  {

	/* steps to run this in setup window:   
	   account is used as control loop support 
	   ( need to be changed to iterable based on delete run count )

	   DateTime endTime = System.now();
	   DateTime startTime = endTime.addDays(-5000);   
	   GNE_ETL_Batch_EventReplicaArchiveRemoval etlBatch = new GNE_ETL_Batch_EventReplicaArchiveRemoval(50, endtime);
	   Id batchInstanceId = database.executeBatch(etlBatch,1);    
	*/ 
             
    Integer deleteCleanupRunCount = 50;
    DateTime lastModifiedDateTime = null;
        
    public GNE_ETL_Batch_EventReplicaArchiveRemoval (Integer runCount, DateTime startDateTime) {
        deleteCleanupRunCount = runCount;    	
        lastModifiedDatetime = startDateTime;
        objectName = 'Event Replica Archive Removal';
    }    
        
    global Database.QueryLocator start(Database.batchableContext bc) {        
        return Database.getQueryLocator ( 
            [select Id from Account limit :deleteCleanupRunCount]
         );       
    }

    global void execute(Database.BatchableContext BC, List<SObject> objectList) {                        

        List<Event> eventList = [select id, systemModstamp, lastmodifieddate from event where systemModstamp >= : lastModifiedDateTime and  (isarchived = true or isdeleted = true) order by systemModstamp asc limit 5000 ALL ROWS];
        List<String> deleteIdList = new List<String>();
        
        try {
	        for (Event e : eventList) {
	        	deleteIdList.add ( e.Id);
	        	lastModifiedDatetime = e.lastmodifiedDate;
	        } 
	               
	        if ( deleteIdList.size() > 0 ) {
	        	List<Database.Deleteresult> deleteResultList = 
	        	   database.delete ( [ select id from event_replica_gne__c where Id_gne__c in :deleteIdList], false);
	        	recordReadCount += deleteResultList.size();
	        	for (Database.Deleteresult deleteResult : deleteResultList ) {
	        		if ( deleteResult.isSuccess() ) 
	        	       recordDeleteCount++; 
	        		else
	        		  recordFailCount++;
	        	}        	
	        }                                                        
        } catch (Exception e) {
            runtimeErrorCount++;
            GNE_ETL_EventTaskReplicator_Utility.writeErrorLog(objectName,'executeBatch', e);            
        }
    
    }
            
    global void finish(Database.BatchableContext BC){
        doFinish(BC);
    }
}