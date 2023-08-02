/**********************************************************************************************************************
Purpose: ROBOCOPS-130
System shall change Processed record status to Expired at 24 months from Processed Date.   
=======================================================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0     Raju Manche  10/14/2020      INITIAL DEVELOPMENT

***********************************************************************************************************************/
global class SPLOA_UpdateStatusToExpiredBatchSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        SPLOA_UpdateStatusToExpiredBatch b = new SPLOA_UpdateStatusToExpiredBatch(); 
        database.executebatch(b);
    }
}