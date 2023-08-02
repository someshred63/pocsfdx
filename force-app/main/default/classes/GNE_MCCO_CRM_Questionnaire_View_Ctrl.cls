/* 
 * GNE_MCCO_CRM_Questionnaire_View_Ctrl
 *
 * Created By :         Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified By :   Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified Date : 01/13/2015
 */
public with sharing class GNE_MCCO_CRM_Questionnaire_View_Ctrl {
	
	private static final Integer MAX_RECORDS_PER_PAGE = 10;
	
	public Boolean isQuestionnaire { get; private set; }
    public Questionnaire_gne__c questionnaire { get; private set; }
    
    public GNE_MCCO_CRM_Questionnaire_View_Ctrl() {
    	
    	questionnaire 				= getQuestionnaire(ApexPages.currentPage().getParameters().get('id'));

    	if(questionnaire!=null) { 
    		isQuestionnaire = true; 
		} else { 
			isQuestionnaire = false; 
		}
    }

    private Questionnaire_gne__c getQuestionnaire(String questionnaireId) {
    	try {
    		return [ SELECT Id, Name, Product_gne__c, CreatedBy.Name, LastModifiedBy.Name, LastModifiedDate, Product_gne__r.Name, Questionnaire_Status_gne__c, Owner.Name, ProductSpecific_gne__c, Type_gne__c, Version_gne__c, OwnerId, Category_gne__c, Audience_Type_gne__c, Single_Survey_per_Mode_gne__c, Show_Questions_Position_gne__c, Ready_For_Use_gne__c, No_Edit_gne__c, Freeze_Surveys_gne__c, Hide_Surveys_gne__c, Show_Weight_gne__c FROM Questionnaire_gne__c WHERE Id = :questionnaireId LIMIT 1][0];
    	} catch(Exception ex) {
    		return null;
    	}
    }
    
    @RemoteAction
    public static Boolean deleteQuestionnaire(String questionnaireId) {
		try {
			Questionnaire_gne__c questionnaireToDelete = [SELECT Id FROM Questionnaire_gne__c WHERE Id = :questionnaireId LIMIT 1][0];
			delete questionnaireToDelete;
			return true;
		} catch (DMLException ex) {
			return false;
		}
    }

        
    @ReadOnly
    @RemoteAction
    public static ItemWrapper loadAccounts(Integer page, String questionnaireId, String sortDirection, String sortField, String searchValue) {
    	Integer offset = (MAX_RECORDS_PER_PAGE * page) - MAX_RECORDS_PER_PAGE;
    	
		String query = 'SELECT Id, Name, Account__r.Name, Account_Name_gne__c, PT_Access_Account_gne__c, PT_Target_gne__c FROM QuestionnaireAccount_gne__c WHERE Questionnaire_gne__c = \'' + questionnaireId + '\'';
		if(!String.isEmpty(searchValue)) {
			query += ' AND Account__r.Name LIKE \'%' + String.escapeSingleQuotes(searchValue) + '%\'';
		}
		query += ' ORDER BY ' + sortField + ' ' + sortDirection  + ' LIMIT ' + MAX_RECORDS_PER_PAGE  +' OFFSET '+ offset;
    	
		return new ItemWrapper(countAccounts(questionnaireId, searchValue), Database.query(query), null, null);
    }
            
    @ReadOnly
    @RemoteAction
    public static ItemWrapper loadQuestions(Integer page, String questionnaireId, String sortDirection, String sortField, String searchValue) {
    	Integer offset = (MAX_RECORDS_PER_PAGE * page) - MAX_RECORDS_PER_PAGE;
    	
		String query = 'SELECT Id, Name, Category_gne__c, Force_Ranking_Value_gne__c, Help_Text_gne__c, Labels_gne__c, Maximum_Score_gne__c, Minimum_Score_gne__c, Multiple_Responses_gne__c, Position_gne__c, Questionnaire_gne__c, Region_Code_gne__c, Title_gne__c, Type_gne__c, Values_gne__c, Weight_gne__c FROM Question_gne__c WHERE Questionnaire_gne__c = \'' + questionnaireId + '\'';
		if(!String.isEmpty(searchValue)) {
			query += ' AND Name LIKE \'%' + String.escapeSingleQuotes(searchValue) + '%\'';
		}
		query += ' ORDER BY ' + sortField + ' ' + sortDirection  + ' LIMIT ' + MAX_RECORDS_PER_PAGE  +' OFFSET '+ offset;
    	
		return new ItemWrapper(countQuestions(questionnaireId, searchValue), null, Database.query(query), null);
    }
            
    @ReadOnly
    @RemoteAction
    public static ItemWrapper loadSurveys(Integer page, String questionnaireId, String sortDirection, String sortField, String searchValue) {
    	Integer offset = (MAX_RECORDS_PER_PAGE * page) - MAX_RECORDS_PER_PAGE;
    	
		String query = 'SELECT Id, Name, Owner.Name, CreatedBy.Name, Title_gne__c, Product_Metrics_vod__r.Name, Total_Score_gne__c FROM Survey_gne__c WHERE Questionnaire_gne__c = \'' + questionnaireId + '\'';
		if(!String.isEmpty(searchValue)) {
			query += ' AND Name LIKE \'%' + String.escapeSingleQuotes(searchValue) + '%\'';
		}
		query += ' ORDER BY ' + sortField + ' ' + sortDirection  + ' LIMIT ' + MAX_RECORDS_PER_PAGE  +' OFFSET '+ offset;
    	
		return new ItemWrapper(countSurveys(questionnaireId, searchValue), null, null, Database.query(query));
    }
    
    @RemoteAction
    public static Boolean deleteQuestion(String questionId) {
		try {
			Question_gne__c questionToDelete = [SELECT Id FROM Question_gne__c WHERE Id = :questionId LIMIT 1][0];
			delete questionToDelete;
			return true;
		} catch (DMLException ex) {
			return false;
		}
    }    
    
    @RemoteAction
    public static Boolean deleteQuestionnairesAccounts(String accountId) {
		try {
			QuestionnaireAccount_gne__c questionnairesAccountToDelete = [SELECT Id FROM QuestionnaireAccount_gne__c WHERE Id = :accountId LIMIT 1][0];
			delete questionnairesAccountToDelete;
			return true;
		} catch (DMLException ex) {
			return false;
		}
    }

    private static Integer countAccounts(String questionnaireId, String searchValue) {
    	
		String query = 'SELECT COUNT() FROM QuestionnaireAccount_gne__c WHERE Questionnaire_gne__c = \'' + questionnaireId + '\'';
		if(!String.isEmpty(searchValue)) {
			query += ' AND Account__r.Name LIKE \'%' + String.escapeSingleQuotes(searchValue) + '%\'';
		}
		query += ' LIMIT 2000';
    	
    	return Database.countQuery(query);
    }    
    
    private static Integer countQuestions(String questionnaireId, String searchValue) {
    	
		String query = 'SELECT COUNT() FROM Question_gne__c WHERE Questionnaire_gne__c = \'' + questionnaireId + '\'';
		if(!String.isEmpty(searchValue)) {
			query += ' AND Name LIKE \'%' + String.escapeSingleQuotes(searchValue) + '%\'';
		}
		query += ' LIMIT 2000';
    	
    	return Database.countQuery(query);
    } 

    private static Integer countSurveys(String questionnaireId, String searchValue) {
    	
		String query = 'SELECT COUNT() FROM Survey_gne__c WHERE Questionnaire_gne__c = \'' + questionnaireId + '\'';
		if(!String.isEmpty(searchValue)) {
			query += ' AND Name LIKE \'%' + String.escapeSingleQuotes(searchValue) + '%\'';
		}
		query += ' LIMIT 2000';
    	
    	return Database.countQuery(query);
    }
    
    private class ItemWrapper {
    	
    	public Integer recordCount { get; private set; }
    	public List<QuestionnaireAccount_gne__c> accountList { get; private set; }
    	public List<Question_gne__c> questionList { get; private set; }
    	public List<Survey_gne__c> surveyList { get; private set; }
    	
    	public ItemWrapper(Integer recordCount, List<QuestionnaireAccount_gne__c> accountList, List<Question_gne__c> questionList, List<Survey_gne__c> surveyList) {
    		this.recordCount = recordCount;
    		this.accountList = accountList;
    		this.questionList = questionList;
    		this.surveyList = surveyList;
    	}
    		
    }

}