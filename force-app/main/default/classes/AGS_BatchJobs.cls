global class AGS_BatchJobs implements Schedulable {
  
  global void execute(SchedulableContext sc) {
    AGS_CaseUtility.abortCompletedJobs('AGS_BatchJobs');
    DateTime presentdate = system.now();
    Integer hour = presentdate.hour();
    if (hour < 19 || Test.IsRunningTest()) {
      String query = 'Select AGS_Case_gne__c,AGS_Case_ID_gne__c,Id,Name,CreatedDate,ownerId,Latency_Status_gne__c,Latency_Reminder_Check_gne__c from AGS_Case_Action_gne__c where Action_Status_gne__c =\'OPEN\' and Latency_Status_gne__c !=\'Escalated\' and Action_Type_gne__c =\'Compliance Task\' ';
      AGS_Latency_NotificationBatch Latency = new AGS_Latency_NotificationBatch(query);
      ID batchprocessid = Database.executeBatch(Latency, 1);
      AGS_CaseUtility.insertBatchStartedErrorLog(batchprocessid, 'AGS_BatchJobs', 'AGS Latency Notification Batch started; Batch id :');
    }
  }
}