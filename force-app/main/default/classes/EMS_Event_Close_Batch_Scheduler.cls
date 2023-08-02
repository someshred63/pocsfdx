global with sharing class EMS_Event_Close_Batch_Scheduler implements Schedulable {

    // Execute batch that changes closes/cancelles the events from the previous year
    global void execute(SchedulableContext SC) {
        EMS_Event_Close_Batch cancelCloseEventsBatch = new EMS_Event_Close_Batch();
        Database.executeBatch(cancelCloseEventsBatch);
    }
}