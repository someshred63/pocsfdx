global class AGS_LatencyBatchProcessignInvoke {
    
    
    
    global void AGS_LatencyBatchProcessignInvoke ()
    {
        
    }
    
    public static void start()
    {   
                        
            
      String query = 'Select AGS_Case_gne__c,AGS_Case_ID_gne__c,Action_Status_internal_gne__c,Id,Name,CreatedDate,ownerId,Latency_Status_gne__c,Latency_Reminder_Check_gne__c from AGS_Case_Action_gne__c where Action_Status_gne__c =\'OPEN\' and Latency_Status_gne__c !=\'Escalated\' and Action_Type_gne__c =\'Compliance Task\' ';
      system.debug(query);
      AGS_Latency_NotificationBatch Latency = new AGS_Latency_NotificationBatch(query);                
      ID batchprocessid = Database.executeBatch(Latency,1);
        
      System.debug('Watch out');    
    }
}