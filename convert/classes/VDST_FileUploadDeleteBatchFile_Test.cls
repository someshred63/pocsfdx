/** @date 2/11/2014
* @Author Konrad Malinowski
* @description Test Batch Class for Delete Batch Files
*/
@isTest
private class VDST_FileUploadDeleteBatchFile_Test {

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for deleting batch file
	*/
	@isTest static void shouldSuccessfullyDeleteBatchFile() {
		// GIVEN
		All_User_Hierarchy_gne__c user = VDST_TestUtils.createUser();
		List<Product_vod__c> brands = VDST_TestUtils.createBrands();
		List<VDST_EventPrtcpntRole_gne__c> participantRoles = VDST_TestUtils.createParticipantRoles();
		VDST_TestUtils.createMappings();

		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('MEDWRTG', 1)[0];
		List<VDST_BatchRecord_gne__c> events = VDST_TestUtils.createBatchEvents(file, brands, user);
		List<VDST_BatchRecord_gne__c> participants = VDST_TestUtils.createBatchParticipants(events);

		file.isDeleted_gne__c = true;
		update file;

		VDST_FileUploadDeleteBatchFile delFileBatch = new VDST_FileUploadDeleteBatchFile();

		// WHEN
		Test.startTest();
		Database.executeBatch(delFileBatch, 200);
		Test.stopTest();

		// THEN
		Integer expectedNumberOfExistingFiles = 1;
		Integer numberOfExistingFiles = [ SELECT Id FROM VDST_BatchFile_gne__c ].size();
		System.assertEquals(expectedNumberOfExistingFiles, numberOfExistingFiles);
	}
}