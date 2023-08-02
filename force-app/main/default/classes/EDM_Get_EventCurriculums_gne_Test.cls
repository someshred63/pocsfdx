@isTest
private class EDM_Get_EventCurriculums_gne_Test{

	static testmethod void restServiceTest(){

		Event_Curriculum_gne__c ev = new Event_Curriculum_gne__c(
			Name = 'Test Event',
			Approval_Date_gne__c = Date.today(),
			Aprimo_ID_gne__c = '124325423423434234125347',
			Deactivation_Date_gne__c = Date.today()+100,
			Start_Date_gne__c = Date.today(),
			PRC_Number_gne__c = 'Sample PRC Code',
			Brands_gne__c = 'RITUXAN',
			EDM_Is_Deleted_gne__c = false
		);
		insert ev;

		RestRequest req = new RestRequest();

		RestResponse res = new RestResponse();

		req.httpMethod = 'POST';

		RestContext.request = req;

		RestContext.response = res;
		Datetime dt = Datetime.now();
		RestContext.request.addHeader('lastSyncDate',String.valueOf(dt));

		iPhone_Commons_gne.RestResponse results = EDM_Get_EventCurriculums_gne.processRequest(String.valueOf(dt));

		System.assertEquals(true,results.success);
	}

}