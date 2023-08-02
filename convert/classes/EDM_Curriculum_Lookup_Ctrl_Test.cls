@isTest
private class EDM_Curriculum_Lookup_Ctrl_Test{

	public static testMethod void getCurriculaTest(){

		List<Event_Curriculum_gne__c> events = new List<Event_Curriculum_gne__c>();
		events.add(new Event_Curriculum_gne__c(Curriculum_External_Id_gne__c='1929'));
		events.add(new Event_Curriculum_gne__c(Curriculum_External_Id_gne__c='1343'));
		insert events;

		EDM_Curriculum_Lookup_Ctrl ctrl = new EDM_Curriculum_Lookup_Ctrl();
		System.assertEquals(2,ctrl.getCurricula().size());

	}

	public static testMethod void searchCurriculaEmptyTest(){

		List<Event_Curriculum_gne__c> events = new List<Event_Curriculum_gne__c>();
		events.add(new Event_Curriculum_gne__c(Curriculum_External_Id_gne__c='1929'));
		events.add(new Event_Curriculum_gne__c(Curriculum_External_Id_gne__c='1343'));
		insert events;

		EDM_Curriculum_Lookup_Ctrl ctrl = new EDM_Curriculum_Lookup_Ctrl();

		ctrl.SearchPRCText = '';
		ctrl.Search();
		System.assertEquals(2,ctrl.getCurricula().size());

	}

	public static testMethod void searchCurriculaTest(){

		List<Event_Curriculum_gne__c> events = new List<Event_Curriculum_gne__c>();
		events.add(new Event_Curriculum_gne__c(Curriculum_External_Id_gne__c='1929',Aprimo_ID_gne__c='TestAprimoID1'));
		events.add(new Event_Curriculum_gne__c(Curriculum_External_Id_gne__c='1343',Aprimo_ID_gne__c='TestAprimoID2'));
		insert events;

		EDM_Curriculum_Lookup_Ctrl ctrl = new EDM_Curriculum_Lookup_Ctrl();

		ctrl.SearchPRCText = '%ID2%';
		ctrl.Search();
		System.assertEquals(1,ctrl.getCurricula().size());

	}
}