global with sharing class EMS_Subscribe_iHCP_Batch_Schedulable implements Schedulable {

    // Execute batch that changes closes/cancelles the events from the previous year
    global void execute(SchedulableContext SC) {
        EMS_Subscribe_iHCP_Batch subscribeIHCPBatch = new EMS_Subscribe_iHCP_Batch();
        Database.executeBatch(subscribeIHCPBatch);
    }
}