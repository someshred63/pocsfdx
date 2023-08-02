/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, creates a Survey for the specified account.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneCreateAccountSurvey/*')
global without sharing class iPhone_Create_Account_Survey_gne {
    
    @HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String unixId, String accountId, String brandAffiliationId, 
                                                                    String surveyId, String iPhoneRequestId,
                                                                    String questionnaireId, List<CreateAccountSurveyQuestion> questions) {
        return iPhone_Commons_gne.executeAlterData(
            new CreateAccountSurveyExecutor(), 
            new AccountSurveyCreatorArg(unixId, accountId, brandAffiliationId, surveyId, iPhoneRequestId, questionnaireId, questions)
        );                                                                                                              
    }
                                                        
    public without sharing class CreateAccountSurveyExecutor implements iPhone_Commons_gne.Runnable { 
		
		private Boolean isNewMode;
		                        
        public Object run(Object args) {
       		AccountSurveyCreatorArg executorArgs = (AccountSurveyCreatorArg)args;
           	return createSurvey(executorArgs);
        }
                        
        private String createSurvey(AccountSurveyCreatorArg executorArgs){
            Survey_gne__c survey = getSurveyInfo(executorArgs.surveyId, executorArgs.iPhoneRequestId);
            this.isNewMode = survey.Id == null;
           	User user = iPhone_DAO.getUserByExternalId(executorArgs.unixId);
           	createSurveyInfo(survey, user.id, executorArgs);
           	createResponses(survey, user.id, executorArgs.questions);
            return survey.id;
        }
        
        private Survey_gne__c getSurveyInfo(String surveyId, String iPhoneRequestId) {

            String surveyQuery = 'SELECT Id, OwnerId, Account__c, Product_Metrics_vod__c, Questionnaire_gne__c, iPhone_Request_Id_gne__c, ';
                   surveyQuery += '(SELECT Id, Survey_gne__c, Question_gne__c, Title_gne__c, Help_Text_gne__c, Minimum_Score_gne__c, Maximum_Score_gne__c, ';
                   surveyQuery +=   'Weight_gne__c, Position_gne__c, Category_gne__c, Force_Ranking_Value_gne__c, Type_gne__c, Multiple_Responses_gne__c, ';
                   surveyQuery +=   'Labels_gne__c, Values_gne__c, Selected_Label_gne__c, Selected_Values_gne__c, Response_Score_gne__c, Free_Text_gne__c ';
                   surveyQuery +=   'FROM Survey_Responses_gne__r) ';
                   surveyQuery += 'FROM Survey_gne__c';

            if (String.isNotBlank(surveyId)) {
                surveyQuery += ' WHERE Id = :surveyId';
            }
            else if (String.isNotBlank(iPhoneRequestId)) {
                surveyQuery += ' WHERE iPhone_Request_Id_gne__c = :iPhoneRequestId';
            }
            surveyQuery += ' LIMIT 1';

            List<Survey_gne__c> surveyList = new List<Survey_gne__c>();
            if (String.isNotBlank(surveyId) || String.isNotBlank(iPhoneRequestId)) {
                surveyList = Database.query(surveyQuery);
            }
            
        	Survey_gne__c survey = !surveyList.isEmpty() ? surveyList[0] : new Survey_gne__c();
        	return survey;        	
        }
        
        private void createSurveyInfo(Survey_gne__c survey, String userId, AccountSurveyCreatorArg executorArgs) {
            if (this.isNewMode){
	            survey.OwnerId = userId;
    	        survey.Account__c = executorArgs.accountId;  
        	    survey.Product_Metrics_vod__c = executorArgs.brandAffiliationId;
            	survey.Questionnaire_gne__c = executorArgs.questionnaireId;
            }

            if (String.isBlank(survey.iPhone_Request_Id_gne__c) && String.isNotBlank(executorArgs.iPhoneRequestId)){
                survey.iPhone_Request_Id_gne__c = executorArgs.iPhoneRequestId;
            }

            upsert survey;
        }
        
        private void createResponses(Survey_gne__c survey, String userId, List<CreateAccountSurveyQuestion> questions) {         
            List<String> questionIds = extractQuestionIds(questions);           
            Map<Id, Question_gne__c> questionsMap = getQuestionsMapByIds(questionIds);
            
            List<Survey_Response_gne__c> surveyResponses = survey.Survey_Responses_gne__r != null ? survey.Survey_Responses_gne__r : new List<Survey_Response_gne__c>();
            Map<String, Survey_Response_gne__c> questionToResponseMap = new Map<String, Survey_Response_gne__c>();
            for (Survey_Response_gne__c sResponse : surveyResponses){
            	questionToResponseMap.put(sResponse.Question_gne__c, sResponse);
            }
            
            List<Survey_Response_gne__c> toUpsert = new List<Survey_Response_gne__c>();                                                    
            for (CreateAccountSurveyQuestion iphQuestion: questions) {                                   
                if (questionsMap.containsKey(iphQuestion.id)) {                  
                    Question_gne__c question = questionsMap.get(iphQuestion.id);
                    Survey_Response_gne__c surveyResponse = questionToResponseMap.containsKey(question.Id) ? questionToResponseMap.get(question.Id) : new Survey_Response_gne__c();
                    createSurveyResponse(surveyResponse, question, survey.Id, iphQuestion.answerValue);
                    questionToResponseMap.put(question.Id, surveyResponse);
                    toUpsert.add(surveyResponse);
                }
            }                       
            
            if (toUpsert.size() > 0) {
            	upsert toUpsert;
            }
        }
        
        private Map<Id, Question_gne__c> getQuestionsMapByIds(List<String> questionIds) {
            return new Map<Id, Question_gne__c>([
                SELECT
                    Id,
                    Name,
                    Type_gne__c,
                    Questionnaire_gne__c,
                    CreatedDate,
                    Force_Ranking_Value_gne__c,
                    Help_Text_gne__c,
                    Labels_gne__c,
                    LastModifiedDate,
                    Maximum_Score_gne__c,
                    Minimum_Score_gne__c,
                    Multiple_Responses_gne__c,
                    Position_gne__c,
                    Region_Code_gne__c,
                    Category_gne__c,
                    Title_gne__c,
                    Values_gne__c,
                    Weight_gne__c
                FROM
                    Question_gne__c
                WHERE
                    id in :questionIds
            ]);
        }
         
        private void createSurveyResponse(Survey_Response_gne__c surveyResponse, Question_gne__c question, String surveyId, String answerValue) {            
            Boolean isResponseNewMode = surveyResponse.Id == null;
            if (isResponseNewMode){
            	surveyResponse.Survey_gne__c                = surveyId;
            	surveyResponse.Question_gne__c              = question.id;
            	surveyResponse.Title_gne__c                 = question.Title_gne__c;
            	surveyResponse.Help_Text_gne__c             = question.Help_Text_gne__c ;
            	surveyResponse.Minimum_Score_gne__c         = question.Minimum_Score_gne__c;
            	surveyResponse.Maximum_Score_gne__c         = question.Maximum_Score_gne__c;  
            	surveyResponse.Weight_gne__c                = question.Weight_gne__c;
            	surveyResponse.Position_gne__c              = question.Position_gne__c;  
            	surveyResponse.Category_gne__c              = question.Category_gne__c;
            	surveyResponse.Force_Ranking_Value_gne__c   = question.Force_Ranking_Value_gne__c;
            	surveyResponse.Type_gne__c                  = question.Type_gne__c;
            	surveyResponse.Multiple_Responses_gne__c    = question.Multiple_Responses_gne__c;
            }
             
            if( question.Type_gne__c == 'Labels and Values') {
                surveyResponse.Labels_gne__c            = question.Labels_gne__c;
                surveyResponse.Values_gne__c            = question.Values_gne__c;
                surveyResponse.Selected_Label_gne__c    = computeValues( question.Labels_gne__c, answerValue );
                surveyResponse.Selected_Values_gne__c   = computeValues( question.Values_gne__c, answerValue );
                surveyResponse.Response_Score_gne__c    = totalize( surveyResponse.Selected_Values_gne__c );
            } else if (question.Type_gne__c == 'List of Values') {
                surveyResponse.Values_gne__c            = question.Values_gne__c;
                surveyResponse.Selected_Label_gne__c    = answerValue;
                surveyResponse.Selected_Values_gne__c   = answerValue;
                surveyResponse.Response_Score_gne__c    = totalize( answerValue ); 
            } else if(question.Type_gne__c == 'Numeric') {
                surveyResponse.Response_Score_gne__c    = Decimal.valueOf(answerValue);
            } else if (question.Type_gne__c == 'Free Text'){
                surveyResponse.Free_Text_gne__c         = answerValue;
            }
        }     
                                
        private List<String> extractQuestionIds(List<CreateAccountSurveyQuestion> questions) {
            List<String> questionIds = new List<String>();
            for(CreateAccountSurveyQuestion question : questions) {
                questionIds.add(question.id);
            }       
            return questionIds;
        }           
        
		private Decimal totalize( String selectedValues ) {
			List<String> valuesList = selectedValues.split( ',', 0 );
			Decimal sum = 0;

			for( String value: valuesList ) {
				if( value != null && value != '' ) {
					sum += Decimal.valueOf( value.trim() );
				}
			}

			return sum;
		}

        private String computeValues( String questionValues, String answerValues ) {
			List<String> valuesList = questionValues.split( ',', 0 );
			List<String> answersList = answerValues.split( ',', 0 );
			String resultValues = '';

			for( String answer: answersList ) {
				resultValues += valuesList[ Integer.valueOf( answer.trim() ) ].trim() + ',';
			}

			return resultValues.removeEnd(',');
        }
    }
    
    global class CreateAccountSurveyQuestion {      
        public String id;
        public String answerValue;           
    }

    class AccountSurveyCreatorArg implements iPhone_Commons_gne.BaseArgs {
        
        final String unixId; 
        final String accountId;     
        final String brandAffiliationId;
        final String iPhoneRequestId;
        final String surveyId;
        final String questionnaireId; 
        final List<CreateAccountSurveyQuestion> questions;
        
        public AccountSurveyCreatorArg (String unixId, String accountId, String brandAffiliationId, String surveyId, String iPhoneRequestId,  String questionnaireId, List<CreateAccountSurveyQuestion> questions) {
            this.unixId = unixId;
            this.accountId = accountId; 
            this.brandAffiliationId = brandAffiliationId;
            this.surveyId = surveyId;
            this.iPhoneRequestId = iPhoneRequestId;            
            this.questionnaireId = questionnaireId;
            this.questions = questions;
        }       
        
        public String getIPhoneRequestId(){
            return this.iPhoneRequestId;
        }
    }       
}