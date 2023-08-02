/** @date 15/11/2016
* @Author Gabriel Juriewicz
* @description Test Class for AGS_ProvisionalCaseCreationBatch
*/
@isTest
public class AGS_ProvisionalCaseCreationBatch_Test {

	@isTest
	static void execute_ShoudCreateProvisionalCases() {
		// GIVEN
		AGSCaseStagingTable_gne__c insStagingTable = AGS_TestUtil.createAGSCaseStagingTable('INS', 'transId', 'testINS1', 'testCCOReason', 5);
		AGSCaseStagingTable_gne__c insStagingTableDuplicate = AGS_TestUtil.createAGSCaseStagingTable('INS', 'transId', 'testINS2', 'testCCOReason', 5);
		AGSCaseStagingTable_gne__c aggStagingTable = AGS_TestUtil.createAGSCaseStagingTable('AGG', 'transId', 'testAGG1', 'testCCOReason2', 5);
		insert new AGS_Environment_Domain_gne__c(Name = userinfo.getUserId(), Mail_Domain__c = 'testMail@mail.com');

		// need to insert AGS_User_Activation_Finish_gne__c or will crash in AGS_CreateCaseAndIniActionsSchedulable.execute because of index out of bounds
		AGS_TestUtil.createAGSUserActivationFinish();
		AGS_ProvisionalCaseCreationBatch batchUnderTest = new AGS_ProvisionalCaseCreationBatch();

		// WHEN
		Test.startTest();
		Database.executeBatch(batchUnderTest);
		Test.stopTest();

		// THEN
		// assert new AGS Provisional Cases
		Integer numberOfNewProvisionalCases = [SELECT Count() FROM AGS_Provisional_Case_gne__c];
		System.assertEquals(2, numberOfNewProvisionalCases, 'After scheduling, AGS_ProvisionalCaseCreationBatch class Should create 2 Provisional Cases, '
		                    + 'based on 3 AGS Case Staging Table records. Because 3 staging table records has same value in AGS_SRC_Txn_ID_gne__c field, one INS records will be '
		                    + 'treated as a duplicate.');

		// check if AGG Provisional Case was created properly
		AGS_Provisional_Case_gne__c aggProvisionalCase = [SELECT Id, AGS_PC_Type_Flag_gne__c, AGS_PC_Src_Txn_ID_gne__c, AGS_PC_MDM_ID_gne__c, AGS_PC_Rule_ID_gne__c FROM AGS_Provisional_Case_gne__c WHERE AGS_PC_Type_Flag_gne__c = 'AGG'];

		System.assertEquals('AGG', aggProvisionalCase.AGS_PC_Type_Flag_gne__c,  'After scheduling, AGS_ProvisionalCaseCreationBatch class Should create 2 Provisional Cases, '
		                    + 'one of them being of type AGG.');
		System.assertEquals(null, aggProvisionalCase.AGS_PC_Src_Txn_ID_gne__c,  'After scheduling, AGS_ProvisionalCaseCreationBatch class should create 2 Provisional Cases, '
		                    + 'one of them being of type AGG - that one should have AGS_PC_Src_Txn_ID_gne__c field populated.');
		System.assertEquals('testAGG1', aggProvisionalCase.AGS_PC_MDM_ID_gne__c,  'After scheduling, AGS_ProvisionalCaseCreationBatch class should create 2 Provisional Cases, '
		                    + 'the one of type AGG should have AGS_PC_MDM_ID_gne__c value = \'testAGG1\', based on staging tabble record.');
		System.assertEquals('testCCOReason2', aggProvisionalCase.AGS_PC_Rule_ID_gne__c,  'After scheduling, AGS_ProvisionalCaseCreationBatch class should create 2 Provisional Cases, '
		                    + 'the one of type AGG should have value = \'testCCOReason2\', based on staging tabble record.');

		// check if INS Provisional Case was created properly
		AGS_Provisional_Case_gne__c insProvisionalCase = [SELECT Id, AGS_PC_Type_Flag_gne__c, AGS_PC_Src_Txn_ID_gne__c, AGS_PC_MDM_ID_gne__c, AGS_PC_Rule_ID_gne__c FROM AGS_Provisional_Case_gne__c WHERE AGS_PC_Type_Flag_gne__c = 'INS'];
		System.assertEquals('INS', insProvisionalCase.AGS_PC_Type_Flag_gne__c,  'After scheduling, AGS_ProvisionalCaseCreationBatch class Should create 2 Provisional Cases, '
		                    + 'one of them being of type INS.');
		System.assertEquals('transId', insProvisionalCase.AGS_PC_Src_Txn_ID_gne__c,  'After scheduling, AGS_ProvisionalCaseCreationBatch class should create 2 Provisional Cases, '
		                    + 'one of them being of type INS and set AGS_PC_Src_Txn_ID_gne__c value to \'transId\', based on staging tabble record.');
		System.assertEquals('testINS1', insProvisionalCase.AGS_PC_MDM_ID_gne__c,  'After scheduling, AGS_ProvisionalCaseCreationBatch class should create 2 Provisional Cases, '
		                    + 'the one of type INS should have AGS_PC_MDM_ID_gne__c value = \'testINS1\', based on staging tabble record.');
		System.assertEquals('testCCOReason', insProvisionalCase.AGS_PC_Rule_ID_gne__c,  'After scheduling, AGS_ProvisionalCaseCreationBatch class should create 2 Provisional Cases, '
		                    + 'the one of type INS should have value = \'testCCOReason\', based on staging tabble record.');


		// assert updated AGS Case Staging Table of non duplicate INS Type
		insStagingTable = [SELECT AGS_ProvisionalCaseCreateStatus_gne__c, AGS_Provisional_Case__c FROM AGSCaseStagingTable_gne__c WHERE Id = : insStagingTable.Id];
		System.assertEquals(insProvisionalCase.Id, insStagingTable.AGS_Provisional_Case__c, 'After creating Provisional Case, should update Staging Table with id of Provisiona Case');
		System.assertEquals('Processed', insStagingTable.AGS_ProvisionalCaseCreateStatus_gne__c, 'After creating Provisional Case, should ipdate status of staging table to Processed.');

		// assert updated AGS Case Staging Table of non duplicate AGG Type
		aggStagingTable = [SELECT AGS_ProvisionalCaseCreateStatus_gne__c, AGS_Provisional_Case__c FROM AGSCaseStagingTable_gne__c WHERE Id = : aggStagingTable.Id];
		System.assertEquals(aggProvisionalCase.Id, aggStagingTable.AGS_Provisional_Case__c, 'After creating Provisional Case, should update Staging Table with id of Provisiona Case');
		System.assertEquals('Processed', aggStagingTable.AGS_ProvisionalCaseCreateStatus_gne__c, 'After creating Provisional Case, should ipdate status of staging table to Processed.');

		//  assert updated AGS Case Staging Table of duplicate INS Type
		insStagingTableDuplicate = [SELECT AGS_ProvisionalCaseCreateStatus_gne__c, AGS_Provisional_Case__c, AGS_Case_Creation_status_gne__c FROM AGSCaseStagingTable_gne__c WHERE Id = : insStagingTableDuplicate.Id];
		System.assertEquals(null, insStagingTableDuplicate.AGS_Provisional_Case__c);
		System.assertEquals('Duplicate', insStagingTableDuplicate.AGS_ProvisionalCaseCreateStatus_gne__c);
		System.assertEquals('Duplicate', insStagingTableDuplicate.AGS_Case_Creation_status_gne__c);
	}
}