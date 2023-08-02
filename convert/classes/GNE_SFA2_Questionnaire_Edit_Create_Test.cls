/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-09-08
*  This is a test for GNE_SFA2_Questionnaire_Edit_Create_Ext class
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
private class GNE_SFA2_Questionnaire_Edit_Create_Test {
	
	public static testMethod void testConstructor() {
		String retURL = 'test retURL';
		createConfigData();
		PageReference currentPageRef = Page.GNE_SFA2_Qstner_Edit_Create_Layout;
		currentPageRef.getParameters().put('retURL', retURL);
		currentPageRef.getParameters().put('isRdytoAddaccs', 'true');
		currentPageRef.getParameters().put('duplicateQstner', 'true');
		Test.setCurrentPage(currentPageRef);
		Questionnaire_gne__c q = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(false);
		insert q;
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test name');
		insert acc;
		QuestionnaireAccount_gne__c qa = new QuestionnaireAccount_gne__c(Account__c = acc.Id, Questionnaire_gne__c = q.Id);
		insert qa;
		GNE_SFA2_Questionnaire_Edit_Create_Ext ext = new GNE_SFA2_Questionnaire_Edit_Create_Ext(new ApexPages.StandardController(q));
		system.assertEquals(false, ext.noEdit);
		system.assertEquals(false, ext.freezeSurveys);
		system.assertEquals(false, ext.hideSurvey);
		system.assertEquals(true, ext.isShowTable);
		system.assertEquals(null, ext.checkProduct());
		system.assertEquals(true, ext.isProduct);
	}

	public static testMethod void testShowPreviewQuestions(){
		Questionnaire_gne__c q = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(false);
		insert q;
		List<Question_gne__c> questions = new List<Question_gne__c>();
		questions.add(new Question_gne__c(Questionnaire_gne__c = q.Id, Type_gne__c = 'Free Text'));
		questions.add(new Question_gne__c(Questionnaire_gne__c = q.Id, Type_gne__c = 'Numeric', Minimum_Score_gne__c = 0, Maximum_Score_gne__c = 10));
		insert questions;
		GNE_SFA2_Questionnaire_Edit_Create_Ext ext = new GNE_SFA2_Questionnaire_Edit_Create_Ext(new ApexPages.StandardController(q));
		system.assertEquals(null, ext.showPreviewQuestions());
		system.assertEquals(true, ext.showPreviewBlock);
	}

	public static testMethod void testRecordTypes(){
		Questionnaire_gne__c q = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(false);
		insert q;
		GNE_SFA2_Questionnaire_Edit_Create_Ext ext = new GNE_SFA2_Questionnaire_Edit_Create_Ext(new ApexPages.StandardController(q));
		ext.recordTypeName = 'Managed Care - PT';
		system.assertEquals(null, ext.onRecordTypeChange());
		system.assertEquals(1, ext.categories.size());
		system.assertEquals(2, ext.audiences.size());
		system.assertEquals(3, ext.surveyModes.size());
		ext.recordTypeName = 'Managed Care - Access Metrics';
		ext.loadQuestionnaireData('New');
		system.assertEquals(1, ext.categories.size());
		system.assertEquals(1, ext.audiences.size());
		system.assertEquals(1, ext.surveyModes.size());
		ext.recordTypeName = 'Medical Event Survey';
		ext.loadQuestionnaireData('New');
		system.assertEquals(2, ext.categories.size());
		system.assertEquals(2, ext.audiences.size());
		system.assertEquals(3, ext.surveyModes.size());
		ext.recordTypeName = 'Speaker Nomination Survey';
		ext.loadQuestionnaireData('New');
		system.assertEquals(4, ext.categories.size());
		system.assertEquals(2, ext.audiences.size());
		system.assertEquals(3, ext.surveyModes.size());
		ext.recordTypeName = 'MedAffairs';
		system.assertEquals('(Detail_Product_Subtype_Code_gne__c = \'Molecule\' OR Detail_Product_Subtype_Code_gne__c = \'TheraDisease\')', ext.getProductWhereExpr);
		ext.loadQuestionnaireData('New');
		system.assertEquals(1, ext.categories.size());
		system.assertEquals(2, ext.audiences.size());
		system.assertEquals(3, ext.surveyModes.size());
		ext.recordTypeName = 'Managed Care - CFT';
		ext.loadQuestionnaireData('New');
		system.assertEquals(1, ext.categories.size());
		system.assertEquals(2, ext.audiences.size());
		system.assertEquals(3, ext.surveyModes.size());
		ext.recordTypeName = 'Managed Care - FRM';
		ext.loadQuestionnaireData('New');
		system.assertEquals(1, ext.categories.size());
		system.assertEquals(2, ext.audiences.size());
		system.assertEquals(3, ext.surveyModes.size());
		ext.recordTypeName = 'Canada Sales';
		ext.loadQuestionnaireData('New');
		system.assertEquals(1, ext.categories.size());
		system.assertEquals(2, ext.audiences.size());
		system.assertEquals(3, ext.surveyModes.size());
		ext.recordTypeName = 'ATLS';
		ext.loadQuestionnaireData('New');
		system.assertEquals(4, ext.categories.size());
		system.assertEquals(2, ext.audiences.size());
		system.assertEquals(3, ext.surveyModes.size());
		ext.recordTypeName = 'MCCO Teams Shared';
		ext.loadQuestionnaireData('New');
		system.assertEquals(10, ext.categories.size());
		system.assertEquals(2, ext.audiences.size());
		system.assertEquals(3, ext.surveyModes.size());
		ext.recordTypeName = 'Master';
		ext.loadQuestionnaireData('New');
		system.assertEquals(10, ext.categories.size());
		system.assertEquals(2, ext.audiences.size());
		system.assertEquals(3, ext.surveyModes.size());
		ext.recordTypeName = 'Totaly different record type';
		ext.loadQuestionnaireData('New');
		system.assertEquals(10, ext.categories.size());
		system.assertEquals(2, ext.audiences.size());
		system.assertEquals(3, ext.surveyModes.size());
	}

	public static testMethod void testGettersSettersAndPageRef(){
		User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		system.runAs(currentUser){
			createConfigData();
		}
		system.assertNotEquals(null, GNE_SFA2_Util.getListPageConfiguration('Questionnaire_gne__c'));
		Questionnaire_gne__c q = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(false);
		insert q;
		List<Account> accounts = new List<Account>();
		accounts.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test name1'));
		accounts.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test name2'));
		insert accounts;
		QuestionnaireAccount_gne__c qa = new QuestionnaireAccount_gne__c(Account__c = accounts[0].Id, Questionnaire_gne__c = q.Id);
		insert qa;
		GNE_SFA2_Questionnaire_Edit_Create_Ext ext = new GNE_SFA2_Questionnaire_Edit_Create_Ext(new ApexPages.StandardController(q));
		ext.accountcsvList = accounts[1].Id;
		system.assertEquals(null, ext.updateAccountList());
		system.debug(ApexPages.getMessages());
		system.assertEquals(true, ext.isShowTable);
		system.assertEquals('test', ext.getActiveMenuItem());
		system.assertEquals(null, ext.reorderQuestions());
		system.assertEquals(0, ext.getProductSize('Not inserted Actemra'));
		PageReference pr = ext.cancel();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(q.Id, pr.getParameters().get('id'));
		system.assertEquals('null', pr.getParameters().get('retURL'));
		system.assert(pr.getUrl().contains('GNE_SFA2_Questionnaire_Layout'), 'Wrong URL: ' + pr.getURL());
	}

	public static testMethod void testSave(){
		Questionnaire_gne__c q = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(false);
		q.ProductSpecific_gne__c = false;
		insert q;
		GNE_SFA2_Questionnaire_Edit_Create_Ext ext = new GNE_SFA2_Questionnaire_Edit_Create_Ext(new ApexPages.StandardController(q));
		PageReference pr = ext.save();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(q.Id, pr.getParameters().get('id'));
		system.assertEquals('null', pr.getParameters().get('retURL'));
		system.assert(pr.getUrl().contains('GNE_SFA2_Questionnaire_Layout'), 'Wrong URL: ' + pr.getURL());
	}

	private static void createConfigData(){
		insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = false, SetupOwnerId = UserInfo.getUserId());
        String objectName = 'Questionnaire_gne__c';
        String componentType = 'testButtons';
        String configType = 'List Page';
        String attributes = 'action=test;styleClass=test;dir=test;onclick=test;rerender=test1,test2;immediate=true;';
        String attributes2 = 'immediate=false;';
        SFA2_Configuration_Object_gne__c master = GNE_SFA2_Triggers_Test_Util.prepareSFA2_Configuration_Object_gne();
        master.Object_Name_gne__c = objectName;
        master.Configuration_Type_gne__c = configType;
        master.Is_Active_gne__c = true;
        master.Attributes_gne__c = 'activeMenuItem=test;';
        insert master;

        List<SFA2_Configuration_Object_Detail_gne__c> details = new List<SFA2_Configuration_Object_Detail_gne__c>();
        details.add(new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'true', Is_Read_Only_gne__c = true, 
                                                                Type_gne__c = componentType, Configuration_Object_ref_gne__c = master.Id,
                                                                Is_Active_gne__c = true
                                                                )
                    );
        details.add(new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'false', Is_Read_Only_gne__c = false, 
                                                                Type_gne__c = componentType, Configuration_Object_ref_gne__c = master.Id,
                                                                Is_Active_gne__c = true, Attributes_gne__c = attributes2
                                                                )
                    );
        details.add(new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'false', Is_Read_Only_gne__c = false, 
                                                                Type_gne__c = componentType, Configuration_Object_ref_gne__c = master.Id,
                                                                Is_Active_gne__c = true, Label_gne__c ='label', Attributes_gne__c = attributes
                                                                )
                    );
        insert details;
	}
}