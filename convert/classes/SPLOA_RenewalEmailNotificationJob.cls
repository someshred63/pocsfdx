/**********************************************************************************************************************
Purpose: ROBOCOPS-178 
System shall send renewal email notification when Processed Date/Time on a processed request >= 21 Months.   
=======================================================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0     Raju Manche  10/14/2020      INITIAL DEVELOPMENT

***********************************************************************************************************************/
global class SPLOA_RenewalEmailNotificationJob implements Schedulable {
    global void execute(SchedulableContext sc) {      
        SPLOA_RenewalEmailRemainder_Batch b = new SPLOA_RenewalEmailRemainder_Batch();
        database.executebatch(b);
    }
}