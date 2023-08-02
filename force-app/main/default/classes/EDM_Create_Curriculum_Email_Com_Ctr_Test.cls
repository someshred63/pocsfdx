@isTest
private class EDM_Create_Curriculum_Email_Com_Ctr_Test{

	public static testMethod void bureauTest(){
		EDM_Create_Curriculum_Email_Comp_Ctrl ctrl = new EDM_Create_Curriculum_Email_Comp_Ctrl();

		system.assertEquals(null,ctrl.bureauName);
	}
}