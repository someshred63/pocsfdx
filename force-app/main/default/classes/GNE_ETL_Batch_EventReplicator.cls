global class GNE_ETL_Batch_EventReplicator extends GNE_ETL_DataExchangeSupport
            implements Database.Batchable<SObject>, Database.Stateful  {


/* steps to run this in setup window:
   
   DateTime endTime = System.now();
   DateTime startTime = endTime.addDays(-5000);   
   GNE_ETL_Batch_EventReplicator etlBatch = new GNE_ETL_Batch_EventReplicator(startTime, endtime);
   Id batchInstanceId = database.executeBatch(etlBatch,2000);
    
*/              
    DateTime endTime   = System.Now(); 
    DateTime startTime = endTime.addDays(-7); 
        
    public GNE_ETL_Batch_EventReplicator (DateTime sTime, Datetime eTime) {
        startTime = sTime;
        endTime = eTime;
        objectName = 'Copy Event To Event Replica';
    }    
        
    global Database.QueryLocator start(Database.batchableContext bc) {
        init();       
        return Database.getQueryLocator ( 
            [select Id, Owner.Profile.Name, Owner.IsActive, RecordTypeId, WhoId, WhatId, Subject, Location, IsAllDayEvent, ActivityDateTime, ActivityDate, DurationInMinutes, StartDateTime, EndDateTime, Description, AccountId, OwnerId, Type, IsPrivate, ShowAs, IsDeleted, IsChild, IsGroupEvent, GroupEventType, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsArchived, RecurrenceActivityId, IsRecurrence, RecurrenceStartDateTime, RecurrenceEndDateOnly, RecurrenceTimeZoneSidKey, RecurrenceType, RecurrenceInterval, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, RecurrenceInstance, RecurrenceMonthOfYear, ReminderDateTime, IsReminderSet, Override_Lock_vod__c, Activity_Due_Date_gne__c, Activity_Type_gne__c, Congress_List_gne__c, Arrival_Date_gne__c, Departure_Date_gne__c, Willing_to_Interact_gne__c, Type_of_Interaction_gne__c, Followup_Activity_Type_vod__c, External_ID__c, Anticipated_Next_Step_gne__c, Appeal_ID_gne__c, CM_Case_Number_gne__c, CM_Case_Number_link_gne__c, Case_Id_gne__c, Closed_Date_gne__c, Counter_gne__c, Creator_Comments_gne__c, Due_Date_Category_gne__c, ICD9_1_gne__c, Legacy_SPOC_ID_gne__c, Process_Category_gne__c, Product_gne__c, Referral_Date_gne__c, Release_gne__c, Task_Create_Date_time_gne__c, Treating_Location_State_gne__c, Treating_MD_gne__c, gcal_entry_edit_url__c, gcal_ext_eid__c, gcalpoc_lastmodifiedsyncdifference__c, gcalsyncpoc_JustSynced__c, gcalsyncpoc_callid__c, gcalsyncpoc_synctime__c, Medical_Event_ID__c, Mobile_ID_vod__c, AGS_Case_Action_Number_gne__c, AGS_Case_Action_Value_gne__c, AGS_Case_Action_gne__c, AGS_isAGS_gne__c, Account_ID_gne__c, Account_Name_gne__c, Account_gne__c, Complete_Date_gne__c, Color_vod__c, CM_Case_AddressId_gne__c,CM_Case_Record_Type_Name_gne__c,CM_Queue_Case_AddressID_Changed_gne__c,CM_Queue_Group_Assignment_Number_gne__c,CM_Queue_Group_Due_Date_gne__c,CM_Queue_Name_gne__c,CM_Queue_TimeZone_Number_gne__c,Is_In_Restamping_Process_gne__c from Event where systemModstamp >= :startTime and systemModstamp <= :endTime ]
         );       
    }

    global void execute(Database.BatchableContext BC, List<SObject> eventList){        
        List<Event_Replica_gne__c>  newEventList = new List<Event_Replica_gne__c>();
        List<String> deleteIdList = new List<String>();
        List<Error_Log_gne__c> errorLogList = new List<Error_Log_gne__c>();
        
        try {
	        for (Event e : (List<Event>)eventList) {
                if ( e.owner.profile.name.contains('Canada') )
                  newEventList.add ( GNE_ETL_EventTaskReplicator_Utility.copyEvent(e, etlcaUser) );
                else
                  newEventList.add ( GNE_ETL_EventTaskReplicator_Utility.copyEvent(e, etladminUser) );
	        }
	        
	        // insert 
	        if (newEventList.size() > 0 ) {
	            List<Database.Upsertresult> upsertResultList = database.upsert (newEventList, Event_Replica_gne__c.Id_gne__c, false);
	            for (Database.Upsertresult result : upsertResultList ) {            	
	            	if (result.isSuccess()) {            	   
	            	   if ( result.isCreated()) 
	            	       recordInsertCount++;
	            	   else
	            	       recordUpdateCount++;             	   
	            	} else {
	            		recordFailCount++;
	            		Database.Error errorRecord = result.getErrors()[0];
                        errorLogList.add ( GNE_ETL_EventTaskReplicator_Utility.populateErrorLogRecord(objectName, 'UpsertFail', errorRecord.getMessage()) );	            		
	            	}
	            }
	        }                
	        recordReadCount += eventList.size();

	        if ( errorLogList.size() > 0 )
	           insert errorLogList;
	                           
        } catch (Exception e) {
        	runtimeErrorCount++;
            GNE_ETL_EventTaskReplicator_Utility.writeErrorLog(objectName,'executeBatch', e);        	
        }
    }
            
    global void finish(Database.BatchableContext BC){
        doFinish(BC);
    }
}