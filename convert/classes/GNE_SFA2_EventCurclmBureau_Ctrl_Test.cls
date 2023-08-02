@isTest
private class GNE_SFA2_EventCurclmBureau_Ctrl_Test{

	public static testMethod void editTest(){
		Event_Curriculum_gne__c evCurr = new Event_Curriculum_gne__c(
			Description_gne__c = 'Some test description'
		);
		insert evCurr;

		ApexPages.StandardController st = new ApexPages.StandardController(evCurr);
		GNE_SFA2_EventCurclmBureau_Ctrl ctrl = new GNE_SFA2_EventCurclmBureau_Ctrl(st);
		ctrl.description = 'cover property';
		PageReference pr = ctrl.edit();
		System.assertEquals('/apex/GNE_SFA2_EventCurclmBureau_Edit_Create?id='+evCurr.Id,pr.getUrl().substringBefore('&'));
	}

	@isTest
	public static void testGettingBrandsWithIndications() {
		Id curriculumId = insertSampleCurriculum();
		Event_Curriculum_gne__c curriculum = [SELECT Id, RecordTypeId FROM Event_Curriculum_gne__c WHERE Id = :curriculumId];
		insertSampleBrandWithIndications('Test Brand', 'Test;Test1;Test2', curriculum);
		ApexPages.StandardController standardController = new ApexPages.StandardController(curriculum);
		GNE_SFA2_EventCurclmBureau_Ctrl bureauController = new GNE_SFA2_EventCurclmBureau_Ctrl(standardController);
		Test.startTest();
		List<GNE_SFA2_EventCurclmBureau_Ctrl.BrandsWithIndicationsLists> brandWithIndications = bureauController.getBrandsWithIndicationsLists();
		Test.stopTest();
		System.assertEquals(1, brandWithIndications.size());
		System.assertEquals('Test Brand', brandWithIndications[0].Brand);
	}

	private static void insertSampleBrandWithIndications(String brand, String indications, Event_Curriculum_gne__c curriculum) {
		EDM_Event_Curriculum_Brand__c curriculumBrand = new EDM_Event_Curriculum_Brand__c(EDM_Brand__c = brand, EDM_Brand_Indications__c = indications,
																						  EDM_Parent_Curriculum__r = curriculum, EDM_Parent_Curriculum__c = curriculum.Id);
		insert curriculumBrand;
	}

	private static Id insertSampleCurriculum() {
		RecordType curriculumRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'EM3_Event_Curriculum'];
		Event_Curriculum_gne__c curriculum = new Event_Curriculum_gne__c(RecordTypeId = curriculumRecordType.Id);
		insert curriculum;
		return curriculum.Id;
	}
}