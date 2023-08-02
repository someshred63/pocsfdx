global without sharing class gFRS_MassReassignUserPermission implements Schedulable {
	
	global void execute(SchedulableContext sc){
		system.debug('KS:Start execution gFRS_MassReassignUserPermission');
		gFRS_MassReassignUserPermissionBatchable attBatch=new gFRS_MassReassignUserPermissionBatchable();
		Database.executeBatch(attBatch, 200);
		gFRS_LOAUserPermissionBatchable attBatch1=new gFRS_LOAUserPermissionBatchable();
		Database.executeBatch(attBatch1, 200);
		System.debug('KS:gFRS_MassReassignUserPermission : end'); 
	}
}