/**
*  @author: Przemek Giszczak
*  Date: 2015-02-09
*  This is a test class for GNE_SFA2_Questionnaire_Accounts_Ext, GNE_SFA2_Questionnaire_Ext, GNE_SFA2_Questionnaire_Layout_Controller, GNE_SFA2_Questionnaires_Controller
*    
*  Modification History
*  Date        Name        Description
 */
@isTest
private class GNE_SFA2_Questionnaire_Test {

	static testMethod void test_GNE_SFA2_Questionnaire_Accounts_Ext() {
    	QuestionnaireAccount_gne__c qa = new QuestionnaireAccount_gne__c();
    	insert qa;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( qa );
		GNE_SFA2_Questionnaire_Accounts_Ext testCtrl = new GNE_SFA2_Questionnaire_Accounts_Ext( stdCtrl );

		PageReference pr = testCtrl.edit();
		system.assert( pr.getUrl().contains('GNE_SFA2_Qstner_Acc_Edit_Create_Layout') );
		system.assertEquals( true, pr.getredirect() );
		system.assertEquals( qa.Id, pr.getParameters().get('id') );
	}

	static testMethod void test_GNE_SFA2_Questionnaire_Ext() {
		Questionnaire_gne__c que = new Questionnaire_gne__c();
		insert que;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( que );
		GNE_SFA2_Questionnaire_Ext testCtrl = new GNE_SFA2_Questionnaire_Ext( stdCtrl );

		PageReference pr = testCtrl.edit();
		system.assert( pr.getUrl().contains('GNE_SFA2_Qstner_Edit_Create_Layout') );
		system.assertEquals( true, pr.getredirect() );
		system.assertEquals( que.Id, pr.getParameters().get('id') );

		pr = testCtrl.AnalyzeClick();
		system.assert( pr.getUrl().contains('GNE_SFA2_SurveyGraph') );
		system.assertEquals( true, pr.getredirect() );
		system.assertEquals( que.Id, pr.getParameters().get('id') );

		pr = testCtrl.addQuestionnaireAccounts();
		system.assert( pr.getUrl().contains('GNE_SFA2_AssignTerritories') );
		system.assertEquals( true, pr.getredirect() );
		system.assertEquals( que.Id, pr.getParameters().get('objectId') );

		pr = testCtrl.callMethod( 'addQuestionnaireAccounts' );
		system.assert( pr.getUrl().contains('GNE_SFA2_AssignTerritories') );
	}

	static testMethod void test_GNE_SFA2_Questionnaire_Layout_Controller() {
		Questionnaire_gne__c que = new Questionnaire_gne__c();
		que.Freeze_Surveys_gne__c = true; que.Hide_Surveys_gne__c = true; que.No_Edit_gne__c = true; que.Ready_For_Use_gne__c = true; que.Show_Questions_Position_gne__c = true;
		que.Show_Questions_Position_gne__c = true; que.ProductSpecific_gne__c = true;
		insert que;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( que );
		GNE_SFA2_Questionnaire_Layout_Controller testCtrl = new GNE_SFA2_Questionnaire_Layout_Controller( stdCtrl );
		system.assert( !testCtrl.isNew && testCtrl.isFreeze && testCtrl.isHide && testCtrl.noEdit && testCtrl.readyUse && testCtrl.showWeight && testCtrl.productSpecific );

		PageReference pr = testCtrl.save();
		system.assert( pr.getUrl().contains( que.Id ) );
		pr = testCtrl.cancel();
		system.assert( pr.getUrl().contains( que.Id ) );
		pr = testCtrl.edit();
		system.assert( pr.getUrl().contains( 'GNE_SFA2_Edit_Questionnaire_Layout' ) );
		system.assertEquals( que.Id, pr.getParameters().get('id') );
	}
	
	static testMethod void test_GNE_SFA2_Questionnaires_Controller() {
		GNE_SFA2_Questionnaires_Controller testCtrl = new GNE_SFA2_Questionnaires_Controller();
		
		PageReference pr = testCtrl.newClick();
		system.assert( pr.getParameters().get('retURL').contains( 'GNE_SFA2_Questionnaires' ) );
	}
}