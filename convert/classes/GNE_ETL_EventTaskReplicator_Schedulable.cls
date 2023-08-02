global class GNE_ETL_EventTaskReplicator_Schedulable implements Schedulable {
    
    global void execute(SchedulableContext sc) {        
        try {           
            
            DateTime endTime = System.now();
            DateTime startTime = endTime.addDays(-2);               
            
            Event_Replica_gne__c eventReplica = null;
            try {
                eventReplica = [select id, systemmodstamp_gne__c from Event_Replica_gne__c order by systemmodstamp_gne__c desc limit 1];
                startTime = eventReplica.systemmodstamp_gne__c;
            } catch (Exception e){
            	System.debug ('use default days');
            }            
            GNE_ETL_EventTaskReplicator_Utility.runEventReplicaBatchSet (startTime, endtime, 200, 50);          


            Task_Replica_gne__c taskReplica = null;
            try {
                taskReplica = [select id, systemmodstamp_gne__c from Task_Replica_gne__c order by systemmodstamp_gne__c desc limit 1];
                startTime = taskReplica.systemmodstamp_gne__c;
            } catch (Exception e){
                System.debug ('use default days');
            }            
            GNE_ETL_EventTaskReplicator_Utility.runTaskReplicaBatchSet (startTime, endtime, 200, 50);

        } catch ( Exception e ) {
            System.debug (LoggingLevel.INFO, 'Error occured. Error Desc -> ' + e.getMessage() );
        }
    }   

}