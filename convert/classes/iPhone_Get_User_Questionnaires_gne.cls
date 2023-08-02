/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns data from tables Questionnaire and Question for  
*  calling user available record types.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetUserQuestionnaires/*')
global with sharing class iPhone_Get_User_Questionnaires_gne {

	@HttpPost
	global static iPhone_Commons_gne.RestResponse processRequest(String unixId, List<String> accountsIds, List<String> productIds, List<String> questionnaireIds) {		
		return iPhone_Commons_gne.buildResponse(
			new GetUserQuestionnairesResponseBuilder(),
			new QuestionnaireRequestArgs(unixId, accountsIds, productIds, questionnaireIds)			
		);
	}
	
	private class QuestionnaireRequestArgs {
		public String unixId { get; private set;}
		public List<String> accountIds { get; private set; }
		public List<String> productIds { get; private set; }
		public List<String> questionnaireIds { get; private set; }
		
		public QuestionnaireRequestArgs(String iUnixId, List<String> iAccountIds, List<String> iProductIds, List<String> iQuestionnaireIds){
			this.unixId = iUnixId;
			this.accountIds = iAccountIds;
			this.productIds = iProductIds;
			this.questionnaireIds = iQuestionnaireIds;
		}
	}
	
	public without sharing class GetUserQuestionnairesResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
		
		public GetUserQuestionnairesResponseBuilder(){}
		
		public iPhone_Commons_gne.RestResponse build(Object args) {
			QuestionnaireRequestArgs requestArgs = (QuestionnaireRequestArgs)args;
			
			QuestionnairesUtil util = new QuestionnairesUtil();
			Set<String> categoryList = util.getCategoryList();
			Set<String> activeQuestionaires = new Set<String>();
			if(requestArgs.productIds != null){
				Map<String, Questionnaire_gne__c> questionnairesMap = getQuestionnairesByProductIds(requestArgs.productIds);
				Map<Id,List<Id>> questionnairesAccountsMap = new Map<Id,List<Id>>();
				
				activeQuestionaires.addAll(questionnairesMap.keySet());
				
				if (requestArgs.questionnaireIds != null && requestArgs.questionnaireIds.size() > 0){
					Set<String> additionalIds = new Set<String>(requestArgs.questionnaireIds);
					additionalIds.removeAll(questionnairesMap.keyset());
					questionnairesMap.putAll(getQuestionnairesByIds(additionalIds));
				}
				
				List<QuestionnaireCategory> categories = util.repackToCategories(questionnairesMap.values(), questionnairesAccountsMap, activeQuestionaires);
				return new GetUserQuestionnairesResponse(categories);
			}
			else{
				Map<String, Questionnaire_gne__c> allQuestionnairesMap = getQuestionnaires(categoryList);
				List<String> allQuestionnairesIds = iPhone_StringUtil.buildStringList(allQuestionnairesMap.values(), 'Id');
				Map<Id,List<Id>> questionnairesAccountsMap = getQuestionnairesAccounts(allQuestionnairesIds, requestArgs.accountIds);
				Map<String, Questionnaire_gne__c> questionnairesMap = prepareAvailableQuestionnaires(requestArgs.unixId, allQuestionnairesMap.values(), questionnairesAccountsMap);
				
				activeQuestionaires.addAll(questionnairesMap.keySet());

				if (requestArgs.questionnaireIds != null && requestArgs.questionnaireIds.size() > 0){
					Set<String> additionalIds = new Set<String>(requestArgs.questionnaireIds);					
					additionalIds.removeAll(questionnairesMap.keyset());
					questionnairesMap.putAll(getQuestionnairesByIds(additionalIds));
				}
				
				List<QuestionnaireCategory> categories = util.repackToCategories(questionnairesMap.values(), questionnairesAccountsMap, activeQuestionaires);
				return new GetUserQuestionnairesResponse(categories);
			}
		}
		
		private Map<String, Questionnaire_gne__c> prepareAvailableQuestionnaires(String unixId, List<Questionnaire_gne__c> allQuestionnaires, Map<Id,List<Id>> questionnairesAccountsMap) {
			
			User user = iPhone_DAO.getUserByExternalId(unixId);
			Map<String, Questionnaire_gne__c> result = new Map<String, Questionnaire_gne__c>();
			
			for(Questionnaire_gne__c quest : allQuestionnaires) {
				if(!user.Profile_Name_gne__c.containsIgnoreCase('Canada')) {
                    if(quest.Audience_Type_gne__c == 'General' || (quest.Audience_Type_gne__c == 'Targeted' && (questionnairesAccountsMap.containsKey(quest.Id) && !questionnairesAccountsMap.get(quest.Id).isEmpty()))) {
                        result.put(quest.Id, quest);
                    }
                } else {
                    if(questionnairesAccountsMap.containsKey(quest.Id) && !questionnairesAccountsMap.get(quest.Id).isEmpty()) {
                        result.put(quest.Id, quest);
                    }
                }
			}
			
			return result;
		} 
		
		private Map<String, Questionnaire_gne__c> getQuestionnairesByIds(Set<String> questionnaireIds){
			return getQuestionnaires(questionnaireIds, null, null);
		}
		
		private Map<String, Questionnaire_gne__c> getQuestionnaires(Set<String> categoryList) {
			return getQuestionnaires(null, categoryList, null);
		}
		
		private Map<String, Questionnaire_gne__c> getQuestionnairesByProductIds(List<String> productIds) {
			return getQuestionnaires(null, null, productIds);
		}
		
		private Map<String, Questionnaire_gne__c> getQuestionnaires(Set<String> questionnaireIds, Set<String> categoryList, List<String> productIds){
    		Map<String, Questionnaire_gne__c> result = new Map<String, Questionnaire_gne__c>();
    		
    		String parentFieldsToSelect = String.join(
            	new List<String>{
                	'Id',
                	'Name',                	
                	String.valueOf(Questionnaire_gne__c.Audience_Type_gne__c),
                	String.valueOf(Questionnaire_gne__c.Category_gne__c),
                	String.valueOf(Questionnaire_gne__c.Type_gne__c),
                	String.valueOf(Questionnaire_gne__c.Product_gne__c),
                	String.valueOf(Questionnaire_gne__c.Questionnaire_Status_gne__c)                	
            	},
            	', '
        	);
        	
        	String childFieldsToSelect = String.join(
            	new List<String>{
                	'Id',
                	'Name',
                	'CreatedDate',
                	'LastModifiedDate',
                	String.valueOf(Question_gne__c.Type_gne__c),
                	String.valueOf(Question_gne__c.Questionnaire_gne__c),
                	String.valueOf(Question_gne__c.Force_Ranking_Value_gne__c),
                	String.valueOf(Question_gne__c.Help_Text_gne__c),
                	String.valueOf(Question_gne__c.Labels_gne__c),
                	String.valueOf(Question_gne__c.Maximum_Score_gne__c),
                	String.valueOf(Question_gne__c.Minimum_Score_gne__c),
                	String.valueOf(Question_gne__c.Multiple_Responses_gne__c),
                	String.valueOf(Question_gne__c.Position_gne__c),
                	String.valueOf(Question_gne__c.Region_Code_gne__c),
                	String.valueOf(Question_gne__c.Category_gne__c),
                	String.valueOf(Question_gne__c.Title_gne__c),
                	String.valueOf(Question_gne__c.Values_gne__c),
                	String.valueOf(Question_gne__c.Weight_gne__c)                	
            	},
            	', '
        	);
        	
        	String whereClause = null;
        	if (questionnaireIds != null && questionnaireIds.size() > 0){
        		whereClause = 'Id IN :questionnaireIds';
        	} else if (categoryList != null && categoryList.size() > 0){
        		whereClause = String.format('{0} = true AND {1} = false AND {2} = false AND {3} = false AND {4} IN :categoryList',
        			new String[]{
        				String.valueOf(Questionnaire_gne__c.Ready_For_Use_gne__c),		// 0
        				String.valueOf(Questionnaire_gne__c.ProductSpecific_gne__c),	// 1
        				String.valueOf(Questionnaire_gne__c.Hide_Surveys_gne__c),		// 2
        				String.valueOf(Questionnaire_gne__c.Freeze_Surveys_gne__c),		// 3
        				String.valueOf(Questionnaire_gne__c.Category_gne__c)			// 4
        			}
        		);
        	} else if (productIds != null && productIds.size() > 0){
        		whereClause = String.format('{0} = true AND {1} = true AND {2} = false AND {3} = false AND {4} IN :productIds',
        			new String[]{
        				String.valueOf(Questionnaire_gne__c.Ready_For_Use_gne__c),		// 0
        				String.valueOf(Questionnaire_gne__c.ProductSpecific_gne__c),	// 1
        				String.valueOf(Questionnaire_gne__c.Hide_Surveys_gne__c),		// 2
        				String.valueOf(Questionnaire_gne__c.Freeze_Surveys_gne__c),		// 3
        				String.valueOf(Questionnaire_gne__c.Product_gne__c)				// 4
        			}
        		);
        	}
        	
        	if (String.isNotBlank(whereClause)){
        		String selQuery = String.format('SELECT {0}, (SELECT {1} FROM Questions__r) FROM Questionnaire_gne__c WHERE {2}',
            		new String[]{
                		parentFieldsToSelect,	// 0
                		childFieldsToSelect,    // 1        	                	
                		whereClause				// 2
            		}
        		);
        		
        		System.debug(selQuery);
        		for (Questionnaire_gne__c rec : (List<Questionnaire_gne__c>)Database.query(selQuery)){
        			result.put(rec.Id, rec);
        		}
        	}
        	
        	return result;
		}
		
		public Map<Id,List<Id>> getQuestionnairesAccounts(List<String> allQuestionnairesIds, List<String> accountsIds) {
			Map<Id,List<Id>> questionnairesAccountsMap = new Map<Id,List<Id>>();
			
			List<QuestionnaireAccount_gne__c> questAccountList = [ SELECT 
																        Account__c,
																        Questionnaire_gne__c
																   FROM 
																        QuestionnaireAccount_gne__c
																   WHERE
																   		Account__c IN : accountsIds
																   AND  Questionnaire_gne__c IN : allQuestionnairesIds
																 ];
			
			for(QuestionnaireAccount_gne__c quest : questAccountList) {
				if(!questionnairesAccountsMap.containsKey(quest.Questionnaire_gne__c)) {
					questionnairesAccountsMap.put(quest.Questionnaire_gne__c, new List<Id>());
				}
				
				questionnairesAccountsMap.get(quest.Questionnaire_gne__c).add(quest.Account__c);
			}
			return questionnairesAccountsMap;
		}
	}

	public class GetUserQuestionnairesResponse extends iPhone_Commons_gne.RestResponse {

		public List<QuestionnaireCategory> categories;
		
		public GetUserQuestionnairesResponse(List<QuestionnaireCategory> categories) {
			this.categories = categories;
		}
	}

	public class QuestionnaireCategory {
		public String name;
		public List<QuestionnaireInfo> questionnaires;

		public QuestionnaireCategory(String name, List<QuestionnaireInfo> questionnaires) {
			this.name = name;
			this.questionnaires = questionnaires;
		}
	}

	public class QuestionnaireInfo {
		public String id;
		public String name;
		public String title;
		public String audienceType;
		public List<QuestionInfo> questions;
		public List<Id> questionnaireAccounts;
		public String productId;
		public String status;
		public Boolean active;

		public QuestionnaireInfo(String id, String name, String title, String audienceType, List<QuestionInfo> questions, List<Id> questionnaireAccounts, String productId, String status) {
			this.id = id;
			this.name = name;
			this.title = title;
			this.audienceType = audienceType;
			this.questions = questions;
			this.questionnaireAccounts = questionnaireAccounts;
			this.productId = productId;
			this.status = status;
		}
	}

	public class QuestionInfo {
		public String id;
		public String name;
		public String title;
		public String helpText;
		public String minimumScore;
		public String maximumScore;
		public String weight;
		public String position;
		public String category;
		public String forceRankingValue;
		public String questionType;
		public String multipleResponses;
		public String labels;
		public String values;

		public QuestionInfo(Question_gne__c question) {
			this.id = iPhone_StringUtil.getString(question.id);
			this.name = iPhone_StringUtil.getString(question.Name);
			this.title = iPhone_StringUtil.getString(question.Title_gne__c);
			this.helpText = iPhone_StringUtil.getString(question.Help_Text_gne__c);
			this.minimumScore = iPhone_StringUtil.getString(question.Minimum_Score_gne__c);
			this.maximumScore = iPhone_StringUtil.getString(question.Maximum_Score_gne__c);
			this.weight = iPhone_StringUtil.getString(question.Weight_gne__c);
			this.position = iPhone_StringUtil.getString(question.Position_gne__c);
			this.category = iPhone_StringUtil.getString(question.Category_gne__c);
			this.forceRankingValue = iPhone_StringUtil.getString(question.Force_Ranking_Value_gne__c);
			this.questionType = iPhone_StringUtil.getString(question.Type_gne__c);
			this.multipleResponses = iPhone_StringUtil.getString(question.Multiple_Responses_gne__c);
			this.labels = iPhone_StringUtil.getString(question.Labels_gne__c);
			this.values = iPhone_StringUtil.getString(question.Values_gne__c);
		}
	}

	class QuestionnairesUtil {

		public List<QuestionnaireCategory> repackToCategories(List<Questionnaire_gne__c> questionnaires, Map<Id,List<Id>> questionnairesAccountsMap, Set<String> activeQuestionaires) {

			Map<String, List<Questionnaire_gne__c>> categoryMap = getCategoryMap(questionnaires);
			List<QuestionnaireCategory> categories = buildQuestionnaireCategories(categoryMap, questionnairesAccountsMap);

			//mark questionaire as active if it's not additional questionaire
			for (QuestionnaireCategory cat : categories) {
				for (QuestionnaireInfo quest : cat.questionnaires) {
					if (activeQuestionaires.contains(quest.id)) {
						quest.active = true;
					} else {
						quest.active = false;
					}
				}
			}
			return categories;
		}

		private Map<String, List<Questionnaire_gne__c>> getCategoryMap(List<Questionnaire_gne__c> questionnaires){
			List<Schema.RecordTypeInfo> recordsTypeList = Schema.SObjectType.Questionnaire_gne__c.getRecordTypeInfos();
			Map<String, List<Questionnaire_gne__c>> categoryMap = new Map<String, List<Questionnaire_gne__c>>();
        	for(Schema.RecordTypeInfo recordType : recordsTypeList) {
	            if(recordType.getName() != 'Master' && recordType.isAvailable()) {
	                List<Questionnaire_gne__c> tmpQuestionnaires = new List<Questionnaire_gne__c>();
	                for(Questionnaire_gne__c questionnaire : questionnaires) {
	                    if(questionnaire.Category_gne__c == recordType.getName() && questionnaire.Questions__r.size() > 0) {
	                        tmpQuestionnaires.add(questionnaire);
	                    }
	                }
	                if(tmpQuestionnaires.size() > 0) {
	                    categoryMap.put(recordType.getName(), tmpQuestionnaires);
	                }
	            }
	        }
			return categoryMap;
		}
		
		private Set<String> getCategoryList() {
			List<Schema.RecordTypeInfo> recordsTypeList = Schema.SObjectType.Questionnaire_gne__c.getRecordTypeInfos();
			Set<String> categoryList = new Set<String>();
        	for(Schema.RecordTypeInfo recordType : recordsTypeList) {
	            if(recordType.getName() != 'Master' && recordType.isAvailable()) {
	                categoryList.add(recordType.getName());
	            }
	        }
	        return categoryList;
		}

		private List<QuestionnaireCategory> buildQuestionnaireCategories(Map<String, List<Questionnaire_gne__c>> categoryMap, Map<Id,List<Id>> questionnairesAccountsMap) {
			List<QuestionnaireCategory> questionnaireCategories = new List<QuestionnaireCategory>();
     		for(String category: categoryMap.keySet()) {
     			List<Questionnaire_gne__c> questionnairesList = categoryMap.get(category);
     			List<QuestionnaireInfo> questionnairesInfo = convertToQuestionariesInfo(questionnairesList, questionnairesAccountsMap);

     			QuestionnaireCategory questionaireCategory = new QuestionnaireCategory(category, questionnairesInfo);
     			questionnaireCategories.add(questionaireCategory);
     		}
			return questionnaireCategories;
		}

		private List<QuestionnaireInfo> convertToQuestionariesInfo(List<Questionnaire_gne__c> questionnairesList, Map<Id,List<Id>> questionnairesAccountsMap) {
			List<QuestionnaireInfo> questionariesInfo = new List<QuestionnaireInfo>();
			for(Questionnaire_gne__c questionnaire: questionnairesList) {
				String id = questionnaire.id;
				String name = questionnaire.Name;
				String title = questionnaire.Type_gne__c;
				String audienceType = questionnaire.Audience_Type_gne__c;
				List<QuestionInfo> questions = getQuestionsFromQuestionnaire(questionnaire);
				List<String> questionnaireAccounts = new List<String>();
				String productId = questionnaire.Product_gne__c;
				String status = questionnaire.Questionnaire_Status_gne__c;
				if(questionnairesAccountsMap.containsKey(questionnaire.Id)) {
					questionnaireAccounts = questionnairesAccountsMap.get(questionnaire.Id);
				}
				QuestionnaireInfo questionaireInfo = new QuestionnaireInfo(id, name, title, audienceType, questions, questionnaireAccounts, productId, status);
				questionariesInfo.add(questionaireInfo);
			}
			return questionariesInfo;
		}

		private List<QuestionInfo> getQuestionsFromQuestionnaire(Questionnaire_gne__c questionnaire) {
			List<QuestionInfo> iphQuestions = new List<QuestionInfo>();
			for(Question_gne__c question : questionnaire.Questions__r) {
				QuestionInfo iphQuestion = new QuestionInfo(question);
				iphQuestions.add(iphQuestion);
			}
			return iphQuestions;
		}
	}
}