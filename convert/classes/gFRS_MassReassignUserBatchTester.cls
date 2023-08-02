@isTest
private  class gFRS_MassReassignUserBatchTester {
	
	@isTest(SeeAllData=true)
	static void testStart() {	
		gFRS_MassReassignUserPermissionBatchable batchObject = new gFRS_MassReassignUserPermissionBatchable();
		Database.Querylocator result = batchObject.start(null);
		
		System.assertNotEquals(result, null);	
	}
	
	@isTest(SeeAllData=true)
	static void testExecute() {	
		gFRS_MassReassignUserPermissionBatchable batchObject = new gFRS_MassReassignUserPermissionBatchable();
		List<sObject> listOfProcessInstances = [select ActorId, OriginalActorId,ProcessInstance.TargetObjectId from ProcessInstanceWorkItem where ProcessInstanceWorkItem.ProcessInstance.TargetObject.Type = 'GFRS_Funding_Request__c' and ProcessInstanceWorkItem.ProcessInstance.status='Pending'];
		
		batchObject.execute(null, listOfProcessInstances);	
	}
	
	@isTest(SeeAllData=true)
	static  void sendMassPermissionUnitTest() {		
		gFRS_MassReassignUserPermission reminderObject = new gFRS_MassReassignUserPermission();
		reminderObject.execute(null);
    }
}