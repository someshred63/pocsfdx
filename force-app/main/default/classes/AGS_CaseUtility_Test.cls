/** @date 12/28/2016
* @Author Gabriel Juriewicz
* @description Test class for AGS_CaseUtility
*/
@isTest
private class AGS_CaseUtility_Test {

	@isTest
	static void insertFailedToDeleteErrorLog_shouldInsertErrorLog() {
		// GIVEN
		String expectedCustomErrorMessage = 'There was and error deleting completed jobs';
		String expectedSystemErrorMessage = 'System error message.';
		String expectedBatchId = '7075400000JUKVaAAP';

		// WHEN
		AGS_CaseUtility.insertFailedToDeleteErrorLog(expectedBatchId, 'AGS_CaseUtility_Test', expectedSystemErrorMessage);

		// THEN
		AGS_Error_Log__c newErrorLog = [SELECT Custom_Error_Message__c, System_Error_Message__c, Batch_Id__c FROM AGS_Error_Log__c WHERE Class_Name__c = 'AGS_CaseUtility_Test'];
		System.assertEquals(expectedCustomErrorMessage, newErrorLog.Custom_Error_Message__c);
		System.assertEquals(expectedSystemErrorMessage, newErrorLog.System_Error_Message__c);
		System.assertEquals(expectedBatchId, newErrorLog.Batch_Id__c);
	}

	@isTest
	static void insertBatchStartedErrorLog_shouldInsertErrorLog() {
		// GIVEN
		String expectedCustomErrorMessage = 'Custom error message:';
		String expectedBatchId = '7075400000JUKVaAAP';

		// WHEN
		AGS_CaseUtility.insertBatchStartedErrorLog(expectedBatchId, 'AGS_CaseUtility_Test', expectedCustomErrorMessage);

		// THEN
		AGS_Error_Log__c newErrorLog = [SELECT Custom_Error_Message__c, Batch_Id__c FROM AGS_Error_Log__c WHERE Class_Name__c = 'AGS_CaseUtility_Test'];
		System.assertEquals(expectedCustomErrorMessage + expectedBatchId, newErrorLog.Custom_Error_Message__c);
		System.assertEquals(expectedBatchId, newErrorLog.Batch_Id__c);
	}


	@isTest
	static void addClosedAGSActivityToAGSCase_shouldReturnTask_ActionIsRequiredReminder() {
		// GIVEN
		AGS_Case_gne__c agsCase = AGS_TestUtil.createAgsCase();
		AGS_Case_Action_gne__c latencyCaseAction = AGS_TestUtil.createActionCase(agsCase, AGS_TestUtil.AGS_CASEACTION_SACTION_ACTION_REQUIRED_REMINDER, AGS_TestUtil.AGS_CASEACTION_RT_CLOSE_CASE);
		RecordType rt = [select Id from RecordType where Name = : AGS_TestUtil.AGS_CASEACTION_RT_CLOSE_CASE];

		AGS_Case_Action_gne__c newCaseAction = new AGS_Case_Action_gne__c(
		    ownerId = agsCase.OwnerId,
		    AGS_Case_gne__c = agsCase.Id,
		    Action_gne__c =  AGS_TestUtil.AGS_CASEACTION_SACTION_ACTION_REQUIRED_REMINDER,
		    Action_Status_internal_gne__c = 'Open',
		    AGS_Case_Action_Latency__c = latencyCaseAction.Id,
		    recordtypeid = rt.Id);
		insert newCaseAction;

		newCaseAction = [SELECT AGS_Case_Action_Latency__r.Name, AGS_Case_Action_Latency__c, Action_gne__c,AGS_Case_gne__c FROM AGS_Case_Action_gne__c WHERE Id = :newCaseAction.Id];
		// WHEN
		AGS_Case_Activity_History__c newTask = AGS_CaseUtility.addClosedAGSActivityToAGSCase(newCaseAction, String.valueOf(UserInfo.getUserId()), 'test subject');

		// THEN
		latencyCaseAction = [SELECT Name FROM AGS_Case_Action_gne__c WHERE Id = : latencyCaseAction.Id];
		System.assertEquals('Completed', newTask.Status__c, 'addClosedAGSActivityToAGSCase function should return 1 AGS_Case_Activity_History__c record of status \'Complete\'.');
		System.assertEquals('test subject', newTask.Subject__c, 'addClosedAGSActivityToAGSCase function should return 1 AGS_Case_Activity_History__c record with subject sent as function\'s param');
		System.assertEquals(UserInfo.getUserId(), newTask.ownerId, 'addClosedAGSActivityToAGSCase function should return 1 AGS_Case_Activity_History__c record with ownerId pointing to id sent as function\'s param');
		System.assertEquals(AGS_TestUtil.AGS_CASEACTION_SACTION_ACTION_REQUIRED_REMINDER + ' for Case action #' + latencyCaseAction.Name, newTask.AGS_Case_Action__c);
	}

	@isTest
	static void addClosedAGSActivityToAGSCase_shouldReturnTask() {
		// GIVEN
		AGS_Case_gne__c agsCase = AGS_TestUtil.createAgsCase();
		AGS_Case_Action_gne__c newCaseAction = AGS_TestUtil.createActionCase(agsCase, AGS_TestUtil.AGS_CASEACTION_SACTION_SYSTEM_REOPEN, AGS_TestUtil.AGS_CASEACTION_RT_CLOSE_CASE);
		newCaseAction = [SELECT Name, Action_gne__c, AGS_Case_gne__c FROM AGS_Case_Action_gne__c WHERE Id = : newCaseAction.Id];

		// WHEN
		AGS_Case_Activity_History__c newTask = AGS_CaseUtility.addClosedAGSActivityToAGSCase(newCaseAction, String.valueOf(UserInfo.getUserId()), 'test subject');

		// THEN
		System.assertEquals('Completed', newTask.Status__c, 'addClosedAGSActivityToAGSCase function should return 1 AGS_Case_Activity_History__c record of status \'Complete\'.');
		System.assertEquals('test subject', newTask.Subject__c, 'addClosedAGSActivityToAGSCase function should return 1 AGS_Case_Activity_History__c record with subject sent as function\'s param');
		System.assertEquals(UserInfo.getUserId(), newTask.ownerId, 'addClosedAGSActivityToAGSCase function should return 1 AGS_Case_Activity_History__c record with ownerId pointing to id sent as function\'s param');
		System.assertEquals(newCaseAction.Action_gne__c + ' #' + newCaseAction.Name, newTask.AGS_Case_Action__c);
	}

	@isTest
	static void addNewCaseActionToCase_owner_shouldReturnCaseAction() {
		// GIVEN
		AGS_Case_gne__c agsCase = AGS_TestUtil.createAgsCase();
		User actionOwner = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];

		// WHEN
		AGS_Case_Action_gne__c newCaseAction = AGS_CaseUtility.addNewCaseActionToCase_owner(agsCase, AGS_TestUtil.AGS_CASEACTION_SACTION_SYSTEM_REOPEN, actionOwner);

		// THEN
		System.assertEquals(UserInfo.getUserId(), newCaseAction.ownerId, 'Function should return new AGS Case action with ownerId pointing to User sent in param.');
		System.assertEquals(AGS_TestUtil.AGS_CASEACTION_SACTION_SYSTEM_REOPEN, newCaseAction.Action_gne__c, 'Function should return new AGS Case Action and assign value sent in param to Action_gne__c field.');
		System.assertEquals(agsCase.Id, newCaseAction.AGS_Case_gne__c, 'Function should return new AGS Case Action with AGS_Case_gne__c field pointing to AGS Case sent in function\'s param.');
		System.assertEquals('Open', newCaseAction.Action_Status_internal_gne__c, 'Function should return new AGS Case Action with Action_Status_internal_gne__c field set to \'Open\'');
	}

	@isTest
	static void addNewCaseActionToCase_shouldReturnCaseAction() {
		// GIVEN
		AGS_Case_gne__c agsCase = AGS_TestUtil.createAgsCase();

		// WHEN
		AGS_Case_Action_gne__c newCaseAction = AGS_CaseUtility.addNewCaseActionToCase(agsCase, AGS_TestUtil.AGS_CASEACTION_SACTION_SYSTEM_REOPEN);

		// THEN
		System.assertEquals(AGS_TestUtil.AGS_CASEACTION_SACTION_SYSTEM_REOPEN, newCaseAction.Action_gne__c, 'Should return AGS Case Action with value from param assigned to Action_gne__c field');
		System.assertEquals(agsCase.Id, newCaseAction.AGS_Case_gne__c, 'Should return AGS Case Action with AGS_Case_gne__c field pointing to AGS Case sent in param.' );
		System.assertEquals('Open', newCaseAction.Action_Status_internal_gne__c, 'Should return AGS Case Action with status Open.');
	}

	@isTest
	static void addClosedTaskToAGSCase_shouldReturnTask() {
		// GIVEN
		AGS_Case_gne__c agsCase = AGS_TestUtil.createAgsCase();
		AGS_Case_Action_gne__c newCaseAction = AGS_TestUtil.createActionCase(agsCase, AGS_TestUtil.AGS_CASEACTION_SACTION_SYSTEM_REOPEN, AGS_TestUtil.AGS_CASEACTION_RT_CLOSE_CASE);
		RecordType randomTaskRt = [SELECT Id FROM RecordType WHERE sObjectType = 'Task' LIMIT 1];

		// WHEN
		Task returnedTask = AGS_CaseUtility.addClosedTaskToAGSCase(newCaseAction, UserInfo.getUserId(), 'test subject', randomTaskRt.Id);

		// THEN
		System.assertEquals(true, returnedTask.AGS_isAGS_gne__c, 'Should return Task with value True assigned to AGS_isAGS_gne__c field.');
		System.assertEquals(UserInfo.getUserId(), returnedTask.ownerId, 'Should return Task with ownerId field pointing to User sent in param.');
		System.assertEquals('test subject', returnedTask.subject, 'Should return Task with value sent in param assigned to subject field.');
		System.assertEquals(newCaseAction.Action_gne__c, returnedTask.AGS_Case_Action_gne__c, 'Should return Task with Action type of related Case Action assigned to AGS_Case_Action_gne__c field');
		System.assertEquals(agsCase.Id, returnedTask.whatid, 'Should return Task with whatid field pointing to ags Case sent in param.');
		System.assertEquals('Please confirm AGS Case Action #' + newCaseAction.Name + ' Action: ' + newCaseAction.Action_gne__c, returnedTask.description, 'Should return Taks with a propper value in description field.');
		System.assertEquals(date.today(), returnedTask.ActivityDate, 'Should return Task with today date in ActivityDate field.');
		System.assertEquals(datetime.now(), returnedTask.Closed_Date_gne__c, 'Should return Task with current time in Closed_Date_gne__c field.');
		System.assertEquals(randomTaskRt.Id, returnedTask.RecordTypeId, 'Should return Task with record type sent in param.');
	}

	@isTest
	static void addPleaseValidateData_shouldReturnCaseAction() {
		// GIVEN
		AGS_Case_gne__c agsCase = AGS_TestUtil.createAgsCase();
		Map<String, RecordType> RecTypes_map = new Map<String, RecordType>();
		List<RecordType> RecType = new List<RecordType>([select Name, Id from RecordType where Name like 'AGS%']);
		for (RecordType rec : RecType) {
			if (!RecTypes_map.containsKey(rec.name)) {
				RecTypes_map.put(rec.name, rec);
			}
		}

		// WHEN
		AGS_Case_Action_gne__c returnedCaseAction = AGS_CaseUtility.addPleaseValidateData(agsCase, AGS_TestUtil.AGS_CASEACTION_SACTION_SYSTEM_REOPEN, RecTypes_map);

		// THEN
		System.assertEquals(agsCase.Resolver_gne__c, returnedCaseAction.ownerId, 'Should return AGS Case Action with Case\'s Resolver_gne__c assigned as owner of Case Action.');
		System.assertEquals(AGS_TestUtil.AGS_CASEACTION_SACTION_SYSTEM_REOPEN, returnedCaseAction.Action_gne__c, 'Should return AGS Case Action with value sent in param assigned to Action_gne__c field');
		System.assertEquals(agsCase.Id, returnedCaseAction.AGS_Case_gne__c, 'Should return AGS Case Action with relation to AGS Case sent in param.');
		System.assertEquals('Open', returnedCaseAction.Action_Status_internal_gne__c, 'Should return AGS Case Action with Open status.');
		System.assertEquals(RecTypes_map.get('AGS Case Action-ValidateData-Edit-Rect').id, returnedCaseAction.RecordTypeId, 'Should return AGS Case Action with AGS Case Action-ValidateData-Edit-Rect recod type.');
	}

	@isTest
	static void addNewSystem_Reopen_shouldReturnCaseAction() {
		// GIVEN
		AGS_Case_gne__c agsCase = AGS_TestUtil.createAgsCase();
		Map<String, RecordType> RecTypes_map = new Map<String, RecordType>();
		List<RecordType> RecType = new List<RecordType>([select Name, Id from RecordType where Name like 'AGS%']);
		for (RecordType rec : RecType) {
			if (!RecTypes_map.containsKey(rec.name)) {
				RecTypes_map.put(rec.name, rec);
			}
		}

		// WHEN
		AGS_Case_Action_gne__c returnedCaseAction = AGS_CaseUtility.addNewSystem_Reopen(agsCase, AGS_TestUtil.AGS_CASEACTION_SACTION_SYSTEM_REOPEN, RecTypes_map);

		// THEN
		System.assertEquals(agsCase.Resolver_gne__c, returnedCaseAction.ownerId, 'Should return AGS Case Action with Case\'s Resolver_gne__c assigned as owner of Case Action.');
		System.assertEquals(AGS_TestUtil.AGS_CASEACTION_SACTION_SYSTEM_REOPEN, returnedCaseAction.Action_gne__c, 'Should return AGS Case Action with value sent in param assigned to Action_gne__c field');
		System.assertEquals(agsCase.Id, returnedCaseAction.AGS_Case_gne__c, 'Should return AGS Case Action with relation to AGS Case sent in param.');
		System.assertEquals('Open', returnedCaseAction.Action_Status_internal_gne__c, 'Should return AGS Case Action with Open status.');
		System.assertEquals(RecTypes_map.get('AGS Case Action - Reopen Record Type').id, returnedCaseAction.RecordTypeId, 'Should return AGS Case Action with \'AGS Case AGS Case Action - Reopen Record Typ\' recod type.');
	}

	@isTest
	static void addNewAggReco_SpendingLimitReached_shouldReturnCaseAction() {
		// GIVEN
		AGS_Case_gne__c agsCase = AGS_TestUtil.createAgsCase();
		Map<String, RecordType> RecTypes_map = new Map<String, RecordType>();
		List<RecordType> RecType = new List<RecordType>([select Name, Id from RecordType where Name like 'AGS%']);
		for (RecordType rec : RecType) {
			if (!RecTypes_map.containsKey(rec.name)) {
				RecTypes_map.put(rec.name, rec);
			}
		}

		// WHEN
		AGS_Case_Action_gne__c returnedCaseAction = AGS_CaseUtility.addNewAggReco_SpendingLimitReached(agsCase, AGS_TestUtil.AGS_CASEACTION_SACTION_SYSTEM_REOPEN , RecTypes_map);

		// THEN
		System.assertEquals(agsCase.Resolver_gne__c, returnedCaseAction.ownerId, 'Should return AGS Case Action with Case\'s Resolver_gne__c assigned as owner of Case Action.');
		System.assertEquals(AGS_TestUtil.AGS_CASEACTION_SACTION_SYSTEM_REOPEN, returnedCaseAction.Action_gne__c, 'Should return AGS Case Action with value sent in param assigned to Action_gne__c field');
		System.assertEquals(agsCase.Id, returnedCaseAction.AGS_Case_gne__c, 'Should return AGS Case Action with relation to AGS Case sent in param.');
		System.assertEquals('Open', returnedCaseAction.Action_Status_internal_gne__c, 'Should return AGS Case Action with Open status.');
		System.assertEquals(RecTypes_map.get('AGS Case Action-SendAggregationLimit-Edit-Rect').id, returnedCaseAction.RecordTypeId, 'Should return AGS Case Action with \'AGS Case Action-SendAggregationLimit-Edit-Rect\' recod type.');
	}
}