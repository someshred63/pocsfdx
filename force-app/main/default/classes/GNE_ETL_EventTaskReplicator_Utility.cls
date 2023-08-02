public without sharing class GNE_ETL_EventTaskReplicator_Utility {

    static final String UNABLE_TO_LOG_ERROR  = 'Unable to log error';
    
    public static void deactiveUsers (Set<String> userNameSet, String objectName, String methodName) {
        try {
	        List<User> userList = [select id, isactive from user where isactive = true and  username in :userNameSet ];
	        for ( User userRecord : userList ) {
	            userRecord.isactive = false;
	        }
	        update userList;
        } catch (Exception e) {
             writeErrorLog(objectName, methodName, e);            
        }    	
    }
    
    public static Error_log_gne__c  populateErrorLogRecord (String objectName,
												String methodName, 
												String exceptionMsg) {
        return new Error_log_gne__c(
	               error_level_gne__c   = 'High',
	               object_name__c       = objectName,
	               code_type__c         = 'ETL Replicator',
	               snippet_name__c      = methodName,
	               error_description__c =  exceptionMsg );
    }
    
    public static void  writeErrorLog (String objectName,
                                       String methodName, 
                                       Exception exceptionRecord) {               
        try {
               Error_log_gne__c errorLog     = new Error_log_gne__c(
	               error_level_gne__c   = 'High',
	               object_name__c       = objectName,
	               code_type__c         = 'ETL Replicator',
	               snippet_name__c      = methodName,
	               error_description__c =  exceptionRecord.getMessage()  + ':' +  
	                                       exceptionRecord.getCause() + ':' +
	                                       exceptionRecord.getStackTraceString() );            
               insert errorLog;         
        } catch (Exception e) {
            System.debug (LoggingLevel.INFO, 
                          UNABLE_TO_LOG_ERROR + ' ( ' + 
                          exceptionRecord.getMessage() + '). ' + 
                          'writeErrorLog exception --> ' + e.getStackTraceString() );    
        }
    }

    public static void deleteTaskReplicaAfterTaskDelete (Set<Id> idSet){
        try {
        	database.delete ( [select id from Task_Replica_gne__c where Id_gne__c in :idSet], false);
        } catch (Exception e) {
            writeErrorLog('Task', 'deleteTaskReplicaAfterTaskDelete', e);        	
        }
    }
    
    public static void deletEventReplicaAfterEventDelete (Set<Id> idSet){
        try {
        	database.delete ( [select id from Event_Replica_gne__c where Id_gne__c in :idSet], false);
        } catch (Exception e) {
            writeErrorLog('Task', 'deletEventReplicaAfterEventDelete', e);           
        }
    }
    
    public static void runEventReplicaBatchSet (Datetime copystartTime, Datetime copyendTime, Integer copyBatchSize, 
                                                Integer archiveDeleteRunCount) {
       GNE_ETL_Batch_EventReplicator copyBatch = new GNE_ETL_Batch_EventReplicator(copystartTime, copyendTime);
       Id copyEventBatchId = database.executeBatch(copyBatch, copyBatchSize);

       GNE_ETL_Batch_EventReplicaArchiveRemoval archiveBatch = new GNE_ETL_Batch_EventReplicaArchiveRemoval(archiveDeleteRunCount, copystartTime);
       Id removeEventArchiveBatchId = database.executeBatch(archiveBatch,1); // batch is always 1
    }

    public static void runTaskReplicaBatchSet (Datetime copystartTime, Datetime copyendTime, Integer copyBatchSize, 
                                                Integer archiveDeleteRunCount) {
       GNE_ETL_Batch_TaskReplicator copyBatch = new GNE_ETL_Batch_TaskReplicator(copystartTime, copyendTime);
       Id copyEventBatchId = database.executeBatch(copyBatch, copyBatchSize);

       GNE_ETL_Batch_TaskReplicaArchiveRemoval archiveBatch = new GNE_ETL_Batch_TaskReplicaArchiveRemoval(archiveDeleteRunCount, copystartTime);
       Id removeEventArchiveBatchId = database.executeBatch(archiveBatch,1); // batch is always 1
    }
    
    public static Event_Replica_gne__c copyEvent (Event e, User ownerUser) {
            Event_Replica_gne__c newEventItem = new Event_Replica_gne__c (
                OwnerId = ownerUser.Id, 
                Id_gne__c = e.Id,
                RecordTypeId_gne__c = e.RecordTypeId,
                WhoId_gne__c = e.WhoId,
                WhatId_gne__c = e.WhatId,
                Subject_gne__c = e.Subject,
                Location_gne__c = e.Location,
                IsAllDayEvent_gne__c = e.IsAllDayEvent,
                ActivityDateTime_gne__c = e.ActivityDateTime,
                ActivityDate_gne__c = e.ActivityDate,
                DurationInMinutes_gne__c = e.DurationInMinutes,
                StartDateTime_gne__c = e.StartDateTime,
                EndDateTime_gne__c = e.EndDateTime,
                Description_gne__c = e.Description,
                AccountId_gne__c = e.AccountId,             
                OwnerId_gne__c = e.OwnerId,
                Type_gne__c = e.Type,
                IsPrivate_gne__c = e.IsPrivate,
                ShowAs_gne__c = e.ShowAs,
                IsDeleted_gne__c = e.IsDeleted,
                IsChild_gne__c = e.IsChild,
                IsGroupEvent_gne__c = e.IsGroupEvent,
                GroupEventType_gne__c = e.GroupEventType,
                CreatedDate_gne__c = e.CreatedDate,
                CreatedById_gne__c = e.CreatedById,
                LastModifiedDate_gne__c = e.LastModifiedDate,
                LastModifiedById_gne__c = e.LastModifiedById,
                SystemModstamp_gne__c = e.SystemModstamp,
                IsArchived_gne__c = e.IsArchived,
                RecurrenceActivityId_gne__c = e.RecurrenceActivityId,
                IsRecurrence_gne__c = e.IsRecurrence,
                RecurrenceStartDateTime_gne__c = e.RecurrenceStartDateTime,
                RecurrenceEndDateOnly_gne__c = e.RecurrenceEndDateOnly,
                RecurrenceTimeZoneSidKey_gne__c = e.RecurrenceTimeZoneSidKey,
                RecurrenceType_gne__c = e.RecurrenceType,
                RecurrenceInterval_gne__c = e.RecurrenceInterval,
                RecurrenceDayOfWeekMask_gne__c = e.RecurrenceDayOfWeekMask,
                RecurrenceDayOfMonth_gne__c = e.RecurrenceDayOfMonth,
//              RecurrenceInstance_gne__c = e.RecurrenceInstance,
                RecurrenceMonthOfYear_gne__c = e.RecurrenceMonthOfYear,
                ReminderDateTime_gne__c = e.ReminderDateTime,
                IsReminderSet_gne__c = e.IsReminderSet,
                Activity_Due_Date_gne__c = e.Activity_Due_Date_gne__c,
                Activity_Type_gne__c = e.Activity_Type_gne__c,
                Congress_List_gne__c = e.Congress_List_gne__c,
                Arrival_Date_gne__c = e.Arrival_Date_gne__c,
                Departure_Date_gne__c = e.Departure_Date_gne__c,
                Willing_to_Interact_gne__c = e.Willing_to_Interact_gne__c,
                Type_of_Interaction_gne__c = e.Type_of_Interaction_gne__c,
                Followup_Activity_Type_vod__c = e.Followup_Activity_Type_vod__c,
                External_ID__c = e.External_ID__c,
                Anticipated_Next_Step_gne__c = e.Anticipated_Next_Step_gne__c,
                Appeal_ID_gne__c = e.Appeal_ID_gne__c,
                CM_Case_Number_gne__c = e.CM_Case_Number_gne__c,
                Case_Id_gne__c = e.Case_Id_gne__c,
                Closed_Date_gne__c = e.Closed_Date_gne__c,
                Counter_gne__c = e.Counter_gne__c,
                Creator_Comments_gne__c = e.Creator_Comments_gne__c,
                Due_Date_Category_gne__c = e.Due_Date_Category_gne__c,
                ICD9_1_gne__c = e.ICD9_1_gne__c,
                Legacy_SPOC_ID_gne__c = e.Legacy_SPOC_ID_gne__c,
                Process_Category_gne__c = e.Process_Category_gne__c,
                Product_gne__c = e.Product_gne__c,
                Referral_Date_gne__c = e.Referral_Date_gne__c,
                Release_gne__c = e.Release_gne__c,
                Task_Create_Date_time_gne__c = e.Task_Create_Date_time_gne__c,
                Treating_Location_State_gne__c = e.Treating_Location_State_gne__c,
                Treating_MD_gne__c = e.Treating_MD_gne__c,
                gcal_entry_edit_url__c = e.gcal_entry_edit_url__c,
                gcal_ext_eid__c = e.gcal_ext_eid__c,
                gcalsyncpoc_JustSynced__c = e.gcalsyncpoc_JustSynced__c,
                gcalsyncpoc_callid__c = e.gcalsyncpoc_callid__c,
                gcalsyncpoc_synctime__c = e.gcalsyncpoc_synctime__c,
                Medical_Event_ID__c = e.Medical_Event_ID__c,
                Mobile_ID_vod__c = e.Mobile_ID_vod__c,
                AGS_Case_Action_Number_gne__c = e.AGS_Case_Action_Number_gne__c,
                AGS_Case_Action_gne__c = e.AGS_Case_Action_gne__c,
                AGS_isAGS_gne__c = e.AGS_isAGS_gne__c,
                Account_ID_gne__c = e.Account_ID_gne__c,
                Account_Name_gne__c = e.Account_Name_gne__c,
                Complete_Date_gne__c = e.Complete_Date_gne__c,
                Color_vod__c = e.Color_vod__c,
//              CM_Case_Number_link_gne__c = e.CM_Case_Number_link_gne__c,
//              AGS_Case_Action_Value_gne__c = e.AGS_Case_Action_Value_gne__c,
//              gcalpoc_lastmodifiedsyncdifference__c = e.gcalpoc_lastmodifiedsyncdifference__c,
//              Account_gne__c = e.Account_gne__c,
              CM_Case_AddressId_gne__c = e.CM_Case_AddressId_gne__c,
              CM_Case_Record_Type_Name_gne__c = e.CM_Case_Record_Type_Name_gne__c,
              CM_Queue_Case_AddressID_Changed_gne__c = e.CM_Queue_Case_AddressID_Changed_gne__c,
              CM_Queue_Group_Assignment_Number_gne__c = e.CM_Queue_Group_Assignment_Number_gne__c,
              CM_Queue_Group_Due_Date_gne__c = e.CM_Queue_Group_Due_Date_gne__c,
              CM_Queue_Name_gne__c = e.CM_Queue_Name_gne__c,
              CM_Queue_TimeZone_Number_gne__c = e.CM_Queue_TimeZone_Number_gne__c,
              Is_In_Restamping_Process_gne__c = e.Is_In_Restamping_Process_gne__c);
                          
        return newEventItem;      
    }
    
    public static Task_Replica_gne__c copyTask (Task t, User ownerUser) {
            Task_Replica_gne__c newTaskItem = new Task_Replica_gne__c (
                OwnerId = ownerUser.Id, 
                Id_gne__c = t.Id,
                RecordTypeId_gne__c = t.RecordTypeId,
                WhoId_gne__c = t.WhoId,
                WhatId_gne__c = t.WhatId,
                Subject_gne__c = t.Subject,
                ActivityDate_gne__c = t.ActivityDate,
                Status_gne__c = t.Status,
                Priority_gne__c = t.Priority,
                OwnerId_gne__c = t.OwnerId,
                Description_gne__c = t.Description,
                Type_gne__c = t.Type,
                IsDeleted_gne__c = t.IsDeleted,
                AccountId_gne__c = t.AccountId,
                IsClosed_gne__c = t.IsClosed,
                CreatedDate_gne__c = t.CreatedDate,
                CreatedById_gne__c = t.CreatedById,
                LastModifiedDate_gne__c = t.LastModifiedDate,
                LastModifiedById_gne__c = t.LastModifiedById,
                SystemModstamp_gne__c = t.SystemModstamp,
                IsArchived_gne__c = t.IsArchived,
                CallDurationInSeconds_gne__c = t.CallDurationInSeconds,
                CallType_gne__c = t.CallType,
                CallDisposition_gne__c = t.CallDisposition,
                CallObject_gne__c = t.CallObject,
                ReminderDateTime_gne__c = t.ReminderDateTime,
                IsReminderSet_gne__c = t.IsReminderSet,
                RecurrenceActivityId_gne__c = t.RecurrenceActivityId,
                IsRecurrence_gne__c = t.IsRecurrence,
                RecurrenceStartDateOnly_gne__c = t.RecurrenceStartDateOnly,
                RecurrenceEndDateOnly_gne__c = t.RecurrenceEndDateOnly,
                RecurrenceTimeZoneSidKey_gne__c = t.RecurrenceTimeZoneSidKey,
                RecurrenceType_gne__c = t.RecurrenceType,
                RecurrenceInterval_gne__c = t.RecurrenceInterval,
                RecurrenceDayOfWeekMask_gne__c = t.RecurrenceDayOfWeekMask,
                RecurrenceDayOfMonth_gne__c = t.RecurrenceDayOfMonth,
//              RecurrenceInstance_gne__c = t.RecurrenceInstance,
                RecurrenceMonthOfYear_gne__c = t.RecurrenceMonthOfYear,
                Override_Lock_vod__c = t.Override_Lock_vod__c,
                Activity_Due_Date_gne__c = t.Activity_Due_Date_gne__c,
                Activity_Type_gne__c = t.Activity_Type_gne__c,
                Congress_List_gne__c = t.Congress_List_gne__c,
                Arrival_Date_gne__c = t.Arrival_Date_gne__c,
                Departure_Date_gne__c = t.Departure_Date_gne__c,
                Willing_to_Interact_gne__c = t.Willing_to_Interact_gne__c,
                Type_of_Interaction_gne__c = t.Type_of_Interaction_gne__c,
                Followup_Activity_Type_vod__c = t.Followup_Activity_Type_vod__c,
                External_ID__c = t.External_ID__c,
                Anticipated_Next_Step_gne__c = t.Anticipated_Next_Step_gne__c,
                Appeal_ID_gne__c = t.Appeal_ID_gne__c,
                CM_Case_Number_gne__c = t.CM_Case_Number_gne__c,
                Case_Id_gne__c = t.Case_Id_gne__c,
                Closed_Date_gne__c = t.Closed_Date_gne__c,
                Counter_gne__c = t.Counter_gne__c,
                Creator_Comments_gne__c = t.Creator_Comments_gne__c,
                Due_Date_Category_gne__c = t.Due_Date_Category_gne__c,
                ICD9_1_gne__c = t.ICD9_1_gne__c,
                Legacy_SPOC_ID_gne__c = t.Legacy_SPOC_ID_gne__c,
                Process_Category_gne__c = t.Process_Category_gne__c,
                Product_gne__c = t.Product_gne__c,
                Referral_Date_gne__c = t.Referral_Date_gne__c,
                Release_gne__c = t.Release_gne__c,
                Task_Create_Date_time_gne__c = t.Task_Create_Date_time_gne__c,
                Treating_Location_State_gne__c = t.Treating_Location_State_gne__c,
                Treating_MD_gne__c = t.Treating_MD_gne__c,
                gcal_entry_edit_url__c = t.gcal_entry_edit_url__c,
                gcal_ext_eid__c = t.gcal_ext_eid__c,
                gcalsyncpoc_JustSynced__c = t.gcalsyncpoc_JustSynced__c,
                gcalsyncpoc_callid__c = t.gcalsyncpoc_callid__c,
                gcalsyncpoc_synctime__c = t.gcalsyncpoc_synctime__c,
                Medical_Event_ID__c = t.Medical_Event_ID__c,
                Mobile_ID_vod__c = t.Mobile_ID_vod__c,
                AGS_Case_Action_Number_gne__c = t.AGS_Case_Action_Number_gne__c,
                AGS_Case_Action_gne__c = t.AGS_Case_Action_gne__c,
                AGS_isAGS_gne__c = t.AGS_isAGS_gne__c,
                Account_ID_gne__c = t.Account_ID_gne__c,
                Account_Name_gne__c = t.Account_Name_gne__c,
//              Account_gne__c = t.Account_gne__c,
//              AGS_Case_Action_Value_gne__c = t.AGS_Case_Action_Value_gne__c,
//              gcalpoc_lastmodifiedsyncdifference__c = t.gcalpoc_lastmodifiedsyncdifference__c,
//              CM_Case_Number_link_gne__c = t.CM_Case_Number_link_gne__c,
                Complete_Date_gne__c = t.Complete_Date_gne__c,
                Color_vod__c = t.Color_vod__c,
              CM_Case_AddressId_gne__c = t.CM_Case_AddressId_gne__c,
              CM_Case_Record_Type_Name_gne__c = t.CM_Case_Record_Type_Name_gne__c,
              CM_Queue_Case_AddressID_Changed_gne__c = t.CM_Queue_Case_AddressID_Changed_gne__c,
              CM_Queue_Group_Assignment_Number_gne__c = t.CM_Queue_Group_Assignment_Number_gne__c,
              CM_Queue_Group_Due_Date_gne__c = t.CM_Queue_Group_Due_Date_gne__c,
              CM_Queue_Name_gne__c = t.CM_Queue_Name_gne__c,
              CM_Queue_TimeZone_Number_gne__c = t.CM_Queue_TimeZone_Number_gne__c,
              Is_In_Restamping_Process_gne__c = t.Is_In_Restamping_Process_gne__c)   ; 

        return newTaskItem;            
    }
    
}