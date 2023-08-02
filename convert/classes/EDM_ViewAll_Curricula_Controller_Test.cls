@isTest
private class EDM_ViewAll_Curricula_Controller_Test{

	public static testMethod void constructorTest(){
		SFA2_Configuration_Object_gne__c co = new SFA2_Configuration_Object_gne__c(
			Name = 'Speaker_Bureau_gne__c_rl',
			Application_Type__c = 'TLCRM',
			Configuration_Type_gne__c = 'Page',
			Is_Active_gne__c = true,
			Object_Name_gne__c = 'Speaker_Bureau_gne__c',
			Order_gne__c = 0.0,
			Role_gne__c = 'SpeakerBureauLead'
		);
		insert co;

		SFA2_Configuration_Object_Detail_gne__c cod = new SFA2_Configuration_Object_Detail_gne__c(
			Name = 'Curriculum_Speaker_Bureau_gne__c',
			API_Name_gne__c = 'Curriculum_Speaker_Bureau_gne__c',
			Attributes_gne__c = 'fieldsCSV=Event_Curriculum_gne__r.EDM_Title_frm_gne__c,Event_Curriculum_gne__r.Aprimo_ID_gne__c,Event_Curriculum_gne__r.Curriculum_Status_gne__c,Event_Curriculum_gne__r.Approval_Date_gne__c,Event_Curriculum_gne__r.Deactivation_Date_gne__c;orderByFieldName=NAME;hideEditLink=true;hideDeleteLink=true;pageSize=5;urlForNewRecord=/apex/GNE_SFA2_SBCurriculum_Edit_Create_Layout;parentFieldName=Speaker_Bureau_gne__c;sortDirection=DESC;hideButtons=true;filter=Event_Curriculum_gne__r.Curriculum_Status_gne__c!=\'Deleted\';customButtons=Add Curriculum#onClick>showAddCurriculumPopup();alwaysDisplayViewAll=true',
			Availability_Mode_gne__c = 'View',
			Configuration_Object_ref_gne__c = co.Id,
			Label_gne__c = 'Curricula',
			Order_gne__c = 1.0,
			Is_Active_gne__c = true,
			Type_gne__c = 'Related List'
		);
		insert cod;

		Profile p_SBL = [Select Id From Profile Where Name = 'GNE-TLS-SpeakerBureauLead'];
		User u2 = new User(
			FirstName = 'SBL',
			ProfileId = p_SBL.Id,
			Username = 'b@roche.com',
			LastName = 'Test', 
			Email = 'b@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles', 
			LocaleSidKey = 'en_US', 
			EmailEncodingKey = 'ISO-8859-1', 
			LanguageLocaleKey = 'en_US'
		);
		insert u2;

		List<Event_Curriculum_gne__c> events = new List<Event_Curriculum_gne__c>();
		events.add(new Event_Curriculum_gne__c());
		events.add(new Event_Curriculum_gne__c());
		insert events;

		System.runAs(u2){

			Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Speaker_Bureau_Type_gne__c = 'Business', Speaker_Category_gne__c = 'Physicians');
        	insert sb;

			insert new GNE_SFA2_User_App_Context_gne__c(
				App_Name_gne__c = 'TLCRM',
				Role_gne__c = 'SpeakerBureauLead'			
			);
			
			ApexPages.currentPage().getParameters().put('viewParentId',sb.Id);
			EDM_ViewAll_Curricula_Controller ctrl = new EDM_ViewAll_Curricula_Controller();

			System.assertEquals('',ctrl.getWhereCondition());

			ctrl.curriculums = events[0].Id+';'+events[1].Id;
			
			ctrl.saveCurriculum();
			System.assertEquals('Id NOT IN (\''+events[0].Id+'\',\''+events[1].Id+'\') AND Curriculum_Status_gne__c != \'Deleted\' AND Curriculum_External_Id_gne__c != null', ctrl.getWhereCondition());
			System.assertEquals('Id IN (\''+events[0].Id+'\',\''+events[1].Id+'\') AND Curriculum_Status_gne__c != \'Deleted\' AND Curriculum_External_Id_gne__c != null', ctrl.getCurrentCurricula());

			ctrl.removeCurriculum();
			System.assertEquals('', ctrl.getWhereCondition());
			System.assertEquals('', ctrl.getCurrentCurricula());

		} 
	}
}