/**
*  @author: Przemek Giszczak
*  Date: 2014-08-07
*  This is a test class for GNE_SFA2_Question_Ext
*    
*  Modification History
*  Date        Name        Description
 */
@isTest
private class GNE_SFA2_Question_Ext_Test {

	static testMethod void test_GNE_SFA2_Question_Ext() {
		Questionnaire_gne__c questionnaire = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne( false );
		questionnaire.No_Edit_gne__c = true;
		insert questionnaire;
		Question_gne__c question = GNE_SFA2_Triggers_Test_Util.prepareQuestion_gne( questionnaire.Id );
		insert question;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( question );

		GNE_SFA2_Question_Ext testCtrl = new GNE_SFA2_Question_Ext( stdCtrl );

		// constructor test
		system.assertEquals( question.Id, testCtrl.qstn.Id );

		// edit() method test
		PageReference pr = testCtrl.edit();
		system.assert( pr.getUrl().contains('GNE_SFA2_Question_Edit_Create_Layout') );
		system.assertEquals( true, pr.getredirect() );
		system.assertEquals( question.Id, pr.getParameters().get('id') );

		// deleteQuestion() method test
		pr = testCtrl.deleteQuestion();
		system.assertEquals( null, pr );

		questionnaire.No_Edit_gne__c = false;
		update questionnaire;
		pr = testCtrl.deleteQuestion();
		system.assertNotEquals( null, pr );
		system.assertEquals( true, pr.getredirect() );
		system.assert( pr.getUrl().contains('GNE_SFA2_Questionnaires') );

		pr = testCtrl.deleteQuestion();
		system.assertEquals( null, pr );	// try catch test

		question = GNE_SFA2_Triggers_Test_Util.prepareQuestion_gne( questionnaire.Id );
		insert question;
		testCtrl.qstn = question;
		pr = Page.GNE_SFA2_Question_Layout;
		pr.getParameters().put( 'retURL', 'sampleRetURL' );
		Test.setCurrentPage( pr );
		pr = testCtrl.deleteQuestion();
		system.assertNotEquals( null, pr );
		system.assertEquals( true, pr.getredirect() );
		system.assert( pr.getUrl().contains('sampleRetURL') );

        // cloneQuestion() method test
		pr = testCtrl.cloneQuestion();
		system.assert( pr.getUrl().contains('GNE_SFA2_Question_Edit_Create_Layout') );
		system.assertEquals( true, pr.getredirect() );
		system.assertEquals( 'true', pr.getParameters().get('isClone') );
		system.assertEquals( question.Id, pr.getParameters().get('id') );
	}
}