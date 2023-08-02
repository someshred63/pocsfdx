/** @date 2/11/2014
* @Author Konrad Malinowski
* @description Test Class for Process Batch Records
*/
@isTest
private class VDST_FileUploadProcessBatchRecords_Test {
	
	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for processing batch records 
	*/
	@isTest static void shouldSuccessfullyProcessBatchRecords() {
		// GIVEN
		All_User_Hierarchy_gne__c user = VDST_TestUtils.createUser();
		List<Product_vod__c> brands = VDST_TestUtils.createBrands();
		List<VDST_EventPrtcpntRole_gne__c> participantRoles = VDST_TestUtils.createParticipantRoles();

		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('MEDWRTG', 1)[0];
		List<VDST_BatchRecord_gne__c> events = VDST_TestUtils.createBatchEvents(file, brands, user);
		List<VDST_BatchRecord_gne__c> participants = VDST_TestUtils.createBatchParticipants(events);

		file.ProcessStartDate_gne__c = null;
		file.ProcessEndDate_gne__c = null;
		update file;

		VDST_FileUploadProcessBatchRecords procBatchRecs = new VDST_FileUploadProcessBatchRecords();

		// WHEN
		Test.startTest();
		Database.executeBatch(procBatchRecs, 200);
		Test.stopTest();

		// THEN
		VDST_BatchFile_gne__c processedFile = [ SELECT Status_frm_gne__c FROM VDST_BatchFile_gne__c WHERE Id = :file.Id ];
		System.assertEquals( 'Passed', processedFile.Status_frm_gne__c );
	}
	
}