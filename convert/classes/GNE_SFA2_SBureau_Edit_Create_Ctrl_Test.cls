@isTest
private class GNE_SFA2_SBureau_Edit_Create_Ctrl_Test{

	public static testMethod void plannedProgramsAvailableTest(){

		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert sb;

		ApexPages.StandardController sc = new ApexPages.StandardController(sb);
		GNE_SFA2_SBureau_Edit_Create_Ctrl ctrl = new GNE_SFA2_SBureau_Edit_Create_Ctrl(sc);

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

		System.assert(ctrl.getIsPlannedProgramsAvailableForEdit());
	}

	public static testMethod void plannedProgramsNotAvailableTest(){

		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert sb;

		ApexPages.StandardController sc = new ApexPages.StandardController(sb);
		GNE_SFA2_SBureau_Edit_Create_Ctrl ctrl = new GNE_SFA2_SBureau_Edit_Create_Ctrl(sc);

		ctrl.fieldSetHeadings = new Map<String,String>();
		ctrl.fieldSetHeadings.put('layoutId','Information');
		ctrl.fieldSetMap = new Map<String,List<SFA2_Configuration_Object_Detail_gne__c>>();
		List<SFA2_Configuration_Object_Detail_gne__c> cos = new List<SFA2_Configuration_Object_Detail_gne__c>();
		ctrl.fieldSetMap.put('layoutId',cos);

		System.assert(!ctrl.getIsPlannedProgramsAvailableForEdit());
	}

	public static testMethod void getFieldSetMapWithoutPlannedProgramsTest(){

		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert sb;

		ApexPages.StandardController sc = new ApexPages.StandardController(sb);
		GNE_SFA2_SBureau_Edit_Create_Ctrl ctrl = new GNE_SFA2_SBureau_Edit_Create_Ctrl(sc);

		ctrl.fieldSetHeadings = new Map<String,String>();
		ctrl.fieldSetHeadings.put('layoutId','Information');
		ctrl.fieldSetMap = new Map<String,List<SFA2_Configuration_Object_Detail_gne__c>>();
		List<SFA2_Configuration_Object_Detail_gne__c> cos = new List<SFA2_Configuration_Object_Detail_gne__c>();
		ctrl.fieldSetMap.put('layoutId',cos);

		Map<String, List<SFA2_Configuration_Object_Detail_gne__c>> mapCOD = ctrl.getFieldSetMapWithoutPlannedPrograms();
	}
}