/************************************************************
*  @author: Grzegorz Skaruz
*  Date: 2016-11-07
*  This is a test for GNE_SFA2_SBCurclm_Edit_Create_Ctrl class
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest

private class GNE_SFA2_SBCurclm_Edit_Create_Ctrl_Test {

    static testMethod void testCtrlEventCurriculum() {
		String objectId = '01I70000000BHtJ';
		ApexPages.currentPage().getParameters().put( 'objectId', objectId);
    	Curriculum_Speaker_Bureau_gne__c csb = new Curriculum_Speaker_Bureau_gne__c();
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(csb);
		
		Test.startTest();
			GNE_SFA2_SBCurclm_Edit_Create_Ctrl testCtrl = new GNE_SFA2_SBCurclm_Edit_Create_Ctrl(stdCtrl);
		Test.stopTest();
		system.assertEquals(testCtrl.myObject.get('Event_Curriculum_gne__c'), objectId);
    }

    static testMethod void testCtrlSpeakerBureau() {
    	Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c();
		insert sb;
		String objectId = sb.Id;
		ApexPages.currentPage().getParameters().put( 'objectId', objectId);
    	Curriculum_Speaker_Bureau_gne__c csb = new Curriculum_Speaker_Bureau_gne__c();
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(csb);
		
		Test.startTest();
			GNE_SFA2_SBCurclm_Edit_Create_Ctrl testCtrl = new GNE_SFA2_SBCurclm_Edit_Create_Ctrl(stdCtrl);
		Test.stopTest();
		system.assertEquals(testCtrl.myObject.get('Speaker_Bureau_gne__c'), objectId);
    }

}