/**
* @author GFRS Dev Team
* @date 05/08/2014
* @description gFRS_ClearHCComplianceSnapshotScheduler class - schedule of cleanup of old data in Snapshot table
*/
global with sharing class gFRS_ClearHCComplianceSnapshotScheduler implements Schedulable{
	
	global void execute(SchedulableContext sc){
        gFRS_ClearHCComplianceSnapshotBatch cleanupBatch = new gFRS_ClearHCComplianceSnapshotBatch();
        Database.executeBatch(cleanupBatch);     

    }
}