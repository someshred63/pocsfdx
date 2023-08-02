@isTest
private class GNE_SFA2_Speaker_Bureau_Ctrl_Test{

	public static testMethod void constructorTest(){

		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;
		ApexPages.StandardController sc = new ApexPages.StandardController(businessBureau);
		GNE_SFA2_Speaker_Bureau_Ctrl ctrl = new GNE_SFA2_Speaker_Bureau_Ctrl(sc);

		System.assertEquals(12,ctrl.monthNames.size());
	}

	public static testMethod void editLinkTest(){

		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;
		ApexPages.StandardController sc = new ApexPages.StandardController(businessBureau);
		GNE_SFA2_Speaker_Bureau_Ctrl ctrl = new GNE_SFA2_Speaker_Bureau_Ctrl(sc);
		PageReference pr = ctrl.edit();
		System.assertEquals('/apex/GNE_SFA2_SBureau_Edit_Create_Layout?id=' + businessBureau.Id,pr.getUrl());
	}

	public static testMethod void nominateLinkTest(){

		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;
		ApexPages.StandardController sc = new ApexPages.StandardController(businessBureau);
		GNE_SFA2_Speaker_Bureau_Ctrl ctrl = new GNE_SFA2_Speaker_Bureau_Ctrl(sc);
		PageReference pr = ctrl.nominateClick();
		System.assertEquals('/apex/GNE_SFA2_SBureau_Nominate_Layout?id=' + businessBureau.Id,pr.getUrl());
	}

	public static testMethod void viewAllMembershipsLinkTest(){

		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;
		ApexPages.StandardController sc = new ApexPages.StandardController(businessBureau);
		GNE_SFA2_Speaker_Bureau_Ctrl ctrl = new GNE_SFA2_Speaker_Bureau_Ctrl(sc);
		PageReference pr = ctrl.viewAllSpeakerBureauMemberships();
		System.assertEquals('/apex/GNE_SFA2_SBMembership?br_id=' + businessBureau.Id +
                                        '&parentObjectName=Speaker_Bureau_gne__c&parentRecordType=',pr.getUrl());
	}

	public static testMethod void saveCurriculumTest(){

		Event_Curriculum_gne__c event1 = new Event_Curriculum_gne__c();
		insert event1;
		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;
		ApexPages.StandardController sc = new ApexPages.StandardController(businessBureau);
		GNE_SFA2_Speaker_Bureau_Ctrl ctrl = new GNE_SFA2_Speaker_Bureau_Ctrl(sc);
		ctrl.curriculums = event1.Id;

		String whereCon = ctrl.getWhereCondition();
		System.assertEquals('',whereCon);
		ctrl.saveCurriculum();

		List<Curriculum_Speaker_Bureau_gne__c> crrls = new List<Curriculum_Speaker_Bureau_gne__c>([
			Select Id From Curriculum_Speaker_Bureau_gne__c Where Speaker_Bureau_gne__c = :businessBureau.Id
		]);
		System.assertEquals(1,crrls.size());

		Event_Curriculum_gne__c event2 = new Event_Curriculum_gne__c();
		insert event2;
		ctrl.curriculums = event2.Id;

		whereCon = ctrl.getWhereCondition();
		System.assertEquals('Id NOT IN (\''+event1.Id+'\') AND Curriculum_Status_gne__c != \'Deleted\' AND Curriculum_External_Id_gne__c != null',whereCon);
		ctrl.saveCurriculum();

		crrls = new List<Curriculum_Speaker_Bureau_gne__c>([
			Select Id From Curriculum_Speaker_Bureau_gne__c Where Speaker_Bureau_gne__c = :businessBureau.Id
		]);
		System.assertEquals(2,crrls.size());

		Event_Curriculum_gne__c event3 = new Event_Curriculum_gne__c();
		insert event3;
		ctrl.curriculums = event3.Id;

		whereCon = ctrl.getWhereCondition();
		System.assertEquals('Id NOT IN (\''+event1.Id+'\',\''+event2.Id+'\') AND Curriculum_Status_gne__c != \'Deleted\' AND Curriculum_External_Id_gne__c != null',whereCon);
		ctrl.saveCurriculum();

		crrls = new List<Curriculum_Speaker_Bureau_gne__c>([
			Select Id From Curriculum_Speaker_Bureau_gne__c Where Speaker_Bureau_gne__c = :businessBureau.Id
		]);
		System.assertEquals(3,crrls.size());
	}

	public static testMethod void plannedProgramsNotAvailableforViewTest(){

		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;
		ApexPages.StandardController sc = new ApexPages.StandardController(businessBureau);
		GNE_SFA2_Speaker_Bureau_Ctrl ctrl = new GNE_SFA2_Speaker_Bureau_Ctrl(sc);
		
		ctrl.fieldSetHeadings = new Map<String,String>();
		System.assert(!ctrl.getIsPlannedProgramsAvailableForView());
	}

	public static testMethod void plannedProgramsNotAvailableforViewTest2(){

		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;
		ApexPages.StandardController sc = new ApexPages.StandardController(businessBureau);
		GNE_SFA2_Speaker_Bureau_Ctrl ctrl = new GNE_SFA2_Speaker_Bureau_Ctrl(sc);
		
		ctrl.fieldSetHeadings = new Map<String,String>();
		ctrl.fieldSetHeadings.put('layoutId','Information');
		ctrl.fieldSetMap = new Map<String,List<SFA2_Configuration_Object_Detail_gne__c>>();
		ctrl.fieldSetMap.put('layoutId',new List<SFA2_Configuration_Object_Detail_gne__c>());
		System.assert(!ctrl.getIsPlannedProgramsAvailableForView());
	}

	public static testMethod void plannedProgramsAvailableforViewTest(){

		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;
		ApexPages.StandardController sc = new ApexPages.StandardController(businessBureau);
		GNE_SFA2_Speaker_Bureau_Ctrl ctrl = new GNE_SFA2_Speaker_Bureau_Ctrl(sc);
		
		ctrl.fieldSetHeadings = new Map<String,String>();
		ctrl.fieldSetHeadings.put('layoutId','Information');
		ctrl.fieldSetMap = new Map<String,List<SFA2_Configuration_Object_Detail_gne__c>>();
		List<SFA2_Configuration_Object_Detail_gne__c> cos = new List<SFA2_Configuration_Object_Detail_gne__c>();
		for(Integer i=0;i<=12;i++){
			cos.add(new SFA2_Configuration_Object_Detail_gne__c(
				API_Name_gne__c = 'Planned_Programs_'+String.valueOf(i)
			));
		}
		ctrl.fieldSetMap.put('layoutId',cos);
		System.assert(ctrl.getIsPlannedProgramsAvailableForView());
	}

	public static testMethod void fieldSetMapWithoutPlannedProgramsTest(){

		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name='BusinessBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;
		ApexPages.StandardController sc = new ApexPages.StandardController(businessBureau);
		GNE_SFA2_Speaker_Bureau_Ctrl ctrl = new GNE_SFA2_Speaker_Bureau_Ctrl(sc);
		
		ctrl.fieldSetHeadings = new Map<String,String>();
		ctrl.fieldSetHeadings.put('layoutId','Information');
		ctrl.fieldSetMap = new Map<String,List<SFA2_Configuration_Object_Detail_gne__c>>();
		List<SFA2_Configuration_Object_Detail_gne__c> cos = new List<SFA2_Configuration_Object_Detail_gne__c>();
		for(Integer i=0;i<=12;i++){
			cos.add(new SFA2_Configuration_Object_Detail_gne__c(
				API_Name_gne__c = 'Planned_Programs_'+String.valueOf(i)
			));
		}
		ctrl.fieldSetMap.put('layoutId',cos);
		System.assertEquals(0,ctrl.getFieldSetMapWithoutPlannedPrograms().get('layoutId').size());
	}
}