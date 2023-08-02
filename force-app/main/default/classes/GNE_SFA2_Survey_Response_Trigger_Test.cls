/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2013-12-17
*  Description: This is a test class for GNE_SFA2_Survey_Response_Trigger trigger.
*  
*  Modification History
*  Date        Name        			Description
*  2014-02-17  Piotr Przesmycki     Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data          
*************************************************************/
@isTest
private class GNE_SFA2_Survey_Response_Trigger_Test {
	
	public static testMethod void testSurveyResponseInsertAndUpdate() {
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Product_vod__c prod = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
                prod.Name='Lucentis - AMD';
                prod.Detail_Product_Subtype_Code_gne__c='TheraDisease';
                insert prod;
                System.assert(prod!= null, 'Product Insert Failed');
                
                Questionnaire_gne__c questionnaire = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(true);
                questionnaire.Type_gne__c='Lucentis Predictive Profiling';
                insert questionnaire;
                System.assert(questionnaire.id != null, 'Questionnaire id is missing');

                Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
                insert acc;

                Survey_gne__c survey = GNE_SFA2_Triggers_Test_Util.prepareSurvey_gne(questionnaire.id);
                survey.Account__c=acc.id;
                insert survey;

                String title = 'test';
				Survey_Response_gne__c sr = GNE_SFA2_Triggers_Test_Util.prepareSurvey_Response_gne(survey.Id); 
				sr.Title_gne__c=title;
				insert sr;

				sr = [SELECT Id, Title_gne__c, Full_title_gne__c, Category_gne__c, Report_Value_gne__c, Type_gne__c 
						FROM Survey_Response_gne__c WHERE Id = : sr.Id];
				system.assertEquals(sr.Full_title_gne__c,title);
				system.assertEquals(sr.Report_Value_gne__c,null);
				system.assertEquals(sr.Type_gne__c,null);

				sr.Category_gne__c='testCat';
				sr.Type_gne__c='Free Text';
				update sr;
				sr = [SELECT Id, Title_gne__c, Full_title_gne__c, Category_gne__c, Report_Value_gne__c, Type_gne__c 
						FROM Survey_Response_gne__c WHERE Id = : sr.Id];
				system.assertEquals(sr.Full_title_gne__c,'testCat '+title);
				system.assertEquals(sr.Report_Value_gne__c,'Free Text Answer');
				/*delete and undelete added just for code coverage, since it doesn't contain any logic*/
				delete sr;
				undelete sr;
			}
		}
	}

	public static testMethod void testSurveyResponseTypes() {
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Product_vod__c prod = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
                prod.Name='Lucentis - AMD';
                prod.Detail_Product_Subtype_Code_gne__c='TheraDisease';
                insert prod;
                System.assert(prod!= null, 'Product Insert Failed');
                
                Questionnaire_gne__c questionnaire = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(true);
                questionnaire.Type_gne__c='Lucentis Predictive Profiling';
                insert questionnaire;
                System.assert(questionnaire.id != null, 'Questionnaire id is missing');

                Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
                insert acc;

                Survey_gne__c survey = GNE_SFA2_Triggers_Test_Util.prepareSurvey_gne(questionnaire.id);
                survey.Account__c=acc.id;
                insert survey;

                String title = 'test';
				Survey_Response_gne__c sr = GNE_SFA2_Triggers_Test_Util.prepareSurvey_Response_gne(survey.Id); 
				sr.Title_gne__c 		 = title;
				sr.Type_gne__c 			 = 'Labels and Values'; 
				sr.Labels_gne__c 		 = 'test,test2';
				sr.Values_gne__c 		 = 'testV,testV2';
				sr.Selected_Label_gne__c = 'test';
				insert sr;
				sr = [SELECT Id, Report_Value_gne__c, Selected_Label_gne__c, Labels_gne__c, Values_gne__c 
						FROM Survey_Response_gne__c WHERE Id = : sr.Id];
				system.assertEquals(sr.Report_Value_gne__c, '0');
				
				sr.Selected_Label_gne__c=null;
				sr.Labels_gne__c=null;
				sr.Values_gne__c=null;
				update sr;
				sr = [SELECT Id, Report_Value_gne__c, Selected_Label_gne__c, Type_gne__c FROM Survey_Response_gne__c WHERE Id = : sr.Id];
				system.assertEquals(sr.Report_Value_gne__c, 'No Answer');

				sr.Type_gne__c 			 = 'List of Values';
				String testListOfLabels  = 'test,test1,test2';
				sr.Selected_Label_gne__c = testListOfLabels;
				update sr;
				sr = [SELECT Id, Report_Value_gne__c, Selected_Label_gne__c, Response_Score_gne__c 
						FROM Survey_Response_gne__c WHERE Id = : sr.Id];
				system.assertEquals(sr.Report_Value_gne__c, testListOfLabels);

				sr.Selected_Label_gne__c = null;
				sr.Response_Score_gne__c = 3.0;
				update sr;
				sr = [SELECT Id, Report_Value_gne__c, Selected_Label_gne__c, Type_gne__c, Response_Score_gne__c 
						FROM Survey_Response_gne__c WHERE Id = : sr.Id];
				system.assertEquals(Integer.valueOf(sr.Report_Value_gne__c), 3);

				sr.Type_gne__c='Numeric';
				update sr;
				sr = [SELECT Id, Report_Value_gne__c, Selected_Label_gne__c, Type_gne__c, Response_Score_gne__c 
						FROM Survey_Response_gne__c WHERE Id = : sr.Id];
				system.assertEquals(Integer.valueOf(sr.Report_Value_gne__c), 3);

				sr.Response_Score_gne__c=null;
				update sr;
				sr = [SELECT Id, Report_Value_gne__c, Selected_Label_gne__c, Type_gne__c, Response_Score_gne__c 
						FROM Survey_Response_gne__c WHERE Id = : sr.Id];
				system.assertEquals(sr.Report_Value_gne__c, 'No Answer');
			}
		}
	}	
}