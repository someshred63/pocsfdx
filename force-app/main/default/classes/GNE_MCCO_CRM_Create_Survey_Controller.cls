/* 
 * GNE_MCCO_CRM_Create_Survey_Controller
 *
 * Created By :         Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified By :   Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified Date : 01/13/2015
 * 
 */
public without sharing class GNE_MCCO_CRM_Create_Survey_Controller {
    
    public String accountId { get; private set; }
    public String contactId { get; private set; }
    public String productId { get; private set; }
    private String retURL { get; set; }
    
    private Account account { get; set; }
    private Contact contact { get; set; }
    private Product_Metrics_vod__c brandAffiliation { get; set; }
    
    public Boolean hasQuestionnaires { get; private set; }
    public Boolean isCreatable { get; private set; }
    
    public List<Questionnaire_gne__c> allQuestionnairesList { get; private set; }
    private Map<String, List<SelectOption>> availableQuestionnairesMap { get; private set; }
    private List<Question_gne__c> questionsList { get; set; } 
    
    public List<SelectOption> categoriesList { get; private set; }
    public List<SelectOption> questionnairesList { get; set; }
    
    public String category { get; set; }
    public String questionnaire { get; set; }
    
    public GNE_MCCO_CRM_Create_Survey_Controller() {
    	
    	accountId = (ApexPages.currentPage().getParameters().get('accountId') != null && ApexPages.currentPage().getParameters().get('accountId') != '') ? ApexPages.currentPage().getParameters().get('accountId') : null;
    	contactId = (ApexPages.currentPage().getParameters().get('contactId') != null && ApexPages.currentPage().getParameters().get('contactId') != '') ? ApexPages.currentPage().getParameters().get('contactId') : null;
    	productId = (ApexPages.currentPage().getParameters().get('productId') != null && ApexPages.currentPage().getParameters().get('productId') != '') ? ApexPages.currentPage().getParameters().get('productId') : null;
		retURL = (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL') != '') ? ApexPages.currentPage().getParameters().get('retURL') : null;
		
    	try {
    		
    		isCreatable = false;
    		
	    	if(accountId != null) {
	    		account = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1][0];
	    		if(account != null) {
	    			isCreatable = true;
	    		}
	    	}
	    	
	    	if(contactId != null) {
	    		contact = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1][0];
	    	}    	
	    	
	    	if(productId != null) {
	    		brandAffiliation = [SELECT Id, Products_vod__c FROM Product_Metrics_vod__c WHERE Products_vod__c = :productId LIMIT 1][0];
	    	}

    	} catch(Exception ex) {
    		
    	}
    		    	
    	allQuestionnairesList = getAllAvailableQuestionnaires();
    	
    	List<Schema.RecordTypeInfo> recordsTypeList = Schema.SObjectType.Questionnaire_gne__c.getRecordTypeInfos();
    	
    	availableQuestionnairesMap = new Map<String, List<SelectOption>>();
    	
        for(Schema.RecordTypeInfo recordType : recordsTypeList) {
            if(recordType.getName() != 'Master' && recordType.isAvailable()) {
                List<SelectOption> questionnairesList = new List<SelectOption>(); 
                for(Questionnaire_gne__c questionnaire : allQuestionnairesList) {
                    if(questionnaire.Category_gne__c == recordType.getName() && questionnaire.Questions__r.size() > 0) {
                        questionnairesList.add(new SelectOption(questionnaire.Id, questionnaire.Type_gne__c));                     
                    }
                }
                if(questionnairesList != null && questionnairesList.size() > 0) {
                    availableQuestionnairesMap.put(recordType.getName(), questionnairesList);
                }
            }
        }
        
        if(availableQuestionnairesMap.size() > 0) {
        	hasQuestionnaires = true; 
        	
        	categoriesList = prepareCategoriesList(availableQuestionnairesMap);
            
            if(category == null) {
                category = categoriesList[0].getValue();
            }
            
        	questionnairesList = availableQuestionnairesMap.get(category);

            if(questionnaire == null) {
                questionnaire = questionnairesList[0].getValue();
            }

        } else {
        	hasQuestionnaires = false; 
        }
        
    }
    
    private List<SelectOption> prepareCategoriesList(Map<String, List<SelectOption>> questionnairesMap) {
        Set<String> categoriesSet = questionnairesMap.keySet();
        List<SelectOption> result = new List<SelectOption>();
        for(String category : categoriesSet) {
            result.add(new SelectOption(category, category));
        }
        return result;
    }
    
    private List<Questionnaire_gne__c> getAllAvailableQuestionnaires() {
        Boolean isCanadaUser = GNE_SFA2_Util.isCanadaUser();
         
        List<Questionnaire_gne__c> result = new List<Questionnaire_gne__c>();
        for(Questionnaire_gne__c questionnaire : [ SELECT Id, Audience_Type_gne__c, Category_gne__c, Type_gne__c, (SELECT Id FROM Questions__r), (SELECT Account__c, Id FROM QuestionnairesAccounts__r WHERE Account__c =: accountId) FROM Questionnaire_gne__c WHERE Ready_For_Use_gne__c = true AND Hide_Surveys_gne__c = false AND Freeze_Surveys_gne__c = false AND Category_gne__c != null AND Product_gne__c = :productId ]) {
            if(productId != null && productId != '') {
            	result.add(questionnaire);
            } else {
                if(!isCanadaUser) {
                    if(questionnaire.Audience_Type_gne__c == 'General' || (questionnaire.Audience_Type_gne__c == 'Targeted' && questionnaire.QuestionnairesAccounts__r.size() != 0)) {
                        result.add(questionnaire);
                    }
                } else {
                    if(questionnaire.QuestionnairesAccounts__r.size() != 0) {
                        result.add(questionnaire);
                    }
                }   
            } 
        }
        return result;
    }
    
    public PageReference create() {

        System.debug('##### Questionnaire === ' +  questionnaire);
    
        Survey_gne__c survey = new Survey_gne__c();
        if(brandAffiliation != null) {
            survey.Product_Metrics_vod__c = brandAffiliation.Id;
        } else if (contact != null) {
            survey.Account__c = contact.AccountId;
            survey.Contact_gne__c = contact.Id;
        } else {
            survey.Account__c = account.Id;
        }
        survey.Questionnaire_gne__c = questionnaire;
        
        insert survey;

        List<Survey_Response_gne__c> surveyResponsesList =new List<Survey_Response_gne__c>();
        for(Question_gne__c question : [SELECT Id, Title_gne__c, Help_Text_gne__c, Minimum_Score_gne__c, Maximum_Score_gne__c, Weight_gne__c, Position_gne__c, Labels_gne__c, Category_gne__c, Type_gne__c, Force_Ranking_Value_gne__c, Multiple_Responses_gne__c, Values_gne__c FROM Question_gne__c WHERE Questionnaire_gne__c =: questionnaire order by Position_gne__c]){
            Survey_Response_gne__c surveyResponse = new Survey_Response_gne__c();
            surveyResponse.Survey_gne__c = survey.Id;
            surveyResponse.Title_gne__c = question.Title_gne__c;
            surveyResponse.Help_Text_gne__c = question.Help_Text_gne__c ;
            surveyResponse.Minimum_Score_gne__c = question.Minimum_Score_gne__c;
            surveyResponse.Maximum_Score_gne__c = question.Maximum_Score_gne__c;
            surveyResponse.Weight_gne__c =  question.Weight_gne__c ;
            surveyResponse.Position_gne__c = question.Position_gne__c;
            surveyResponse.Category_gne__c = question.Category_gne__c;
            surveyResponse.Force_Ranking_Value_gne__c = question.Force_Ranking_Value_gne__c;
            surveyResponse.Type_gne__c = question.Type_gne__c;
            surveyResponse.Question_gne__c = question.Id;
            surveyResponse.Multiple_Responses_gne__c = question.Multiple_Responses_gne__c;
            if( question.Type_gne__c == 'Labels and Values') {
                surveyResponse.Labels_gne__c = question.Labels_gne__c;
                surveyResponse.Values_gne__c = question.Values_gne__c;
                //surveyResponse.Selected_Label_gne__c = getDefaultLabel(question.Labels_gne__c);
                //surveyResponse.Selected_Values_gne__c = null;
                //if(surveyResponse.Selected_Values_gne__c.isNumeric()) {
                	//surveyResponse.Response_Score_gne__c = Decimal.valueOf(surveyResponse.Selected_Values_gne__c);
               // }
            } else if (question.Type_gne__c == 'List of Values') {
                surveyResponse.Values_gne__c = question.Values_gne__c;
                //surveyResponse.Selected_Label_gne__c = getDefaultValue(question.Values_gne__c);
                //surveyResponse.Selected_Values_gne__c = null;
                //if(surveyResponse.Selected_Values_gne__c.isNumeric()) {
                	//surveyResponse.Response_Score_gne__c = Decimal.valueOf(surveyResponse.Selected_Values_gne__c);
                //}
            } else if(question.Type_gne__c == 'Numeric'){
                surveyResponse.Response_Score_gne__c = question.Minimum_Score_gne__c;
            } else if (question.Type_gne__c=='Free Text'){
                surveyResponse.Free_Text_gne__c = '';
            }
            
            surveyResponsesList.add(surveyResponse);
        }
        
        insert surveyResponsesList;
        
        String link = '/apex/GNE_MCCO_CRM_Edit_Survey';

        PageReference pageref = new PageReference(link);
        pageref.getParameters().put('id', survey.Id);
        if(!String.isEmpty(retURL)) {
        	pageref.getParameters().put('retURL', retURL);
        }
        pageref.setredirect(true);
        return pageref;
    }
        
    private String getDefaultLabel(String labels) {
        
        String result;
        List<String> labelsList = new List<String>();
        if(labels != null && labels != '') {
            labelsList = labels.split(',', 0);
        }
        
        result = labelsList[0];
        return result;
    }
        
    private String getDefaultValue(String values) {
        String result;
        List<String> valuesList = new List<String>();
        if(values != null && values != '') {
            valuesList = values.split(',', 0);
        }
        
        result = valuesList[0];
        return result;
    }
    
}