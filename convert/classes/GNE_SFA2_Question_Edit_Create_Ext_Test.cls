/**
*  @author: Przemyslaw Giszczak
*  Date: 2015-02-09
*  This is a test class for GNE_SFA2_Question_Edit_Create_Ext
*    
*  Modification History
*  Date        Name        Description
 */
@isTest

private class GNE_SFA2_Question_Edit_Create_Ext_Test {

	static testMethod void test_GNE_SFA2_Question_Edit_Create_Ext() {
		Questionnaire_Config_gne__c qconf = new Questionnaire_Config_gne__c( Name = 'ProfileWithFreeTextQuestions' , Value_gne__c = 'like \'%GNE-MedAffairs%\';like \'%GNE-ATLS%\';IN (\'GNE-MCCO-CFT-OPS\',\'GNE-MCCO-PFT-OPS\',\'GNE-MCCO-FRM-OPS\', \'GNE-SYS-Support-UserRPT\')' );
		insert qconf;
		Questionnaire_gne__c qr = new Questionnaire_gne__c( No_Edit_gne__c = false );
		insert qr;
		Question_gne__c que = new Question_gne__c( Questionnaire_gne__c = qr.Id, Force_Ranking_Value_gne__c = true );
		insert que;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( que );
		GNE_SFA2_Question_Edit_Create_Ext testCtrl = new GNE_SFA2_Question_Edit_Create_Ext( stdCtrl );
		
		system.assertEquals( que.Id, testCtrl.questn.Id );
		system.assertEquals( qr.Id, testCtrl.questnrId );
		
		PageReference pr = testCtrl.isNewQuestionCreatable();
		system.assertEquals( null, pr );
		system.assertEquals( true, testCtrl.isCreatable );
		
		pr = testCtrl.OK();
		system.assert( pr.getUrl().contains('GNE_SFA2_Questionnaire_Layout') );
		system.assertEquals( true, pr.getredirect() );
		
		system.assertEquals( null, testCtrl.onChangeType() );
		system.assertEquals( null, testCtrl.onChangeForceRank() );
		
		pr = testCtrl.Save();
		system.assert( pr.getUrl().contains('GNE_SFA2_Question_Layout') );
		
		pr = testCtrl.cancel();
		system.assert( pr.getUrl().contains('GNE_SFA2_Questionnaires') );
		
		system.assertEquals( null, testCtrl.checkIfSectionIsRequired() );
	}
	
	static testMethod void test_method_save() {
		Questionnaire_Config_gne__c qconf = new Questionnaire_Config_gne__c( Name = 'ProfileWithFreeTextQuestions' , Value_gne__c = 'like \'%GNE-MedAffairs%\';like \'%GNE-ATLS%\';IN (\'GNE-MCCO-CFT-OPS\',\'GNE-MCCO-PFT-OPS\',\'GNE-MCCO-FRM-OPS\', \'GNE-SYS-Support-UserRPT\')' );
		insert qconf;
		Questionnaire_gne__c qr = new Questionnaire_gne__c( No_Edit_gne__c = false );
		insert qr;
		Question_gne__c que = new Question_gne__c( Questionnaire_gne__c = qr.Id, Force_Ranking_Value_gne__c = true );
		insert que;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( que );
		GNE_SFA2_Question_Edit_Create_Ext testCtrl = new GNE_SFA2_Question_Edit_Create_Ext( stdCtrl );
		
		PageReference pr = testCtrl.Save();
		system.assert( pr.getUrl().contains('GNE_SFA2_Question_Layout') );
		
		testCtrl.questnrId = null;
		system.assertEquals( null, testCtrl.Save() );
		
	}
}