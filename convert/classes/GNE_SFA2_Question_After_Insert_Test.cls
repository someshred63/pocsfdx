/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-02-13
*  Description: This is a test class for GNE_SFA2_Question_After_Insert trigger
*    
*  Modification History
*  Date        Name        		Description
*  2014-02-18  Piotr Przesmycki Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data
*************************************************************/
@isTest
private class GNE_SFA2_Question_After_Insert_Test {
	
	public static testMethod void testQuestionAfterInsert() {
		User sfa2User = GNE_SFA2_Util.selectSFA2User();

		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Questionnaire_gne__c q = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(false);
				insert q;

				Survey_gne__c s = GNE_SFA2_Triggers_Test_Util.prepareSurvey_gne(q.Id);
				insert s;

				String values = ' test ,  test  ';
				String trimmedValues = 'test,test';
				String labels = ' sample ,  sample  ,test      ';
				String trimmedLabels = 'sample,sample,test';

				Question_gne__c testQuestion = GNE_SFA2_Triggers_Test_Util.prepareQuestion_gne(q.Id);
				testQuestion.Title_gne__c 			= 'testTitle'; 
				testQuestion.Help_Text_gne__c 		= 'testHelpText';
				testQuestion.Minimum_Score_gne__c 	= 0;
				testQuestion.Maximum_Score_gne__c 	= 5;
				testQuestion.Weight_gne__c 			= 6;
				testQuestion.Position_gne__c 		= 1;
				testQuestion.Category_gne__c 		= 'testCategory';
				testQuestion.Values_gne__c 			= values;
				testQuestion.Labels_gne__c 			= labels; 
				testQuestion.Type_gne__c 			= 'testType';
				insert testQuestion;

				List<Survey_Response_gne__c> sr = [SELECT Survey_gne__c, Title_gne__c, Help_Text_gne__c, Minimum_Score_gne__c, Maximum_Score_gne__c,
											 		Weight_gne__c, Position_gne__c, Category_gne__c, Values_gne__c, Labels_gne__c, Type_gne__c, Question_gne__c
											 		FROM Survey_Response_gne__c];
				system.assertEquals(1,sr.size());

				Survey_Response_gne__c survResp = sr[0];
				system.assertEquals(survResp.Survey_gne__c, s.Id);
				system.assertEquals(survResp.Title_gne__c, testQuestion.Title_gne__c);
	            system.assertEquals(survResp.Help_Text_gne__c, testQuestion.Help_Text_gne__c);
	            system.assertEquals(survResp.Minimum_Score_gne__c, testQuestion.Minimum_Score_gne__c);
	            system.assertEquals(survResp.Maximum_Score_gne__c, testQuestion.Maximum_Score_gne__c);
	            system.assertEquals(survResp.Weight_gne__c,  testQuestion.Weight_gne__c);
	            system.assertEquals(survResp.Position_gne__c, testQuestion.Position_gne__c);
				system.assertEquals(survResp.Category_gne__c, testQuestion.Category_gne__c);
				system.assertEquals(survResp.Values_gne__c, trimmedValues);
	            system.assertEquals(survResp.Labels_gne__c, trimmedLabels);
	            system.assertEquals(survResp.Type_gne__c, testQuestion.Type_gne__c);
	            system.assertEquals(survResp.Question_gne__c, testQuestion.Id);
	            q = [SELECT Id, No_Edit_gne__c FROM Questionnaire_gne__c WHERE Id = :q.Id LIMIT 1];
	            system.assert(q.No_Edit_gne__c);
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
}