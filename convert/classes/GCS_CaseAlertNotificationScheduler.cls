/**********************************************************************************************************************
Purpose: GCS_CaseAlertNotificationScheduler class is schdule At 12noon, for GCS cases with category of "Order" that are not in 
status of "Closed" or "Peer Review," the case status will change to "Alert"
=======================================================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0     Raheem       29/07/2020      INITIAL DEVELOPMENT

***********************************************************************************************************************/
public class GCS_CaseAlertNotificationScheduler implements Schedulable{

    public static String DAILY_CRON_EXP = '0 0 12 * * ?';
    public static String DAILY_JOB_NAME = 'Daily GCS Case Alert Job';

    public void execute(SchedulableContext sc){
        GCS_CaseAlertNotificationsBatch caseAlertNotificationBatch = new GCS_CaseAlertNotificationsBatch();
         Database.executeBatch(caseAlertNotificationBatch);
    }
}