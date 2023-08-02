/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2013-01-22
*  Description: This is a extension controller for GNE_SFA2_Create_Servey_Layout Page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_Create_Survey_Layout_Controller {
    
    private Account account {get;set;}
    private Contact contact {get;set;}
    private Product_Metrics_vod__c barndAffiliation {get;set;}
    private List<Questionnaire_gne__c> allQuestionnairesList {get;set;}
    private Map<String, List<SelectOption>> availableQuestionnairesMap {get;set;}
    public List<SelectOption> categoriesList {get;set;}
    public List<SelectOption> questionnairesList {get;set;}
    public String category {get;set;}
    public String questionnaire {get;set;}
    private List<PreviewWrapper> previewWrappers {get; set;}
    public Boolean showPreview {get;set;}
    public Boolean guestionnairesHasExists {get;set;}
    private SFA2_Configuration_Object_gne__c pageConfiguration;  
    private List<Question_gne__c> questionsList {get;set;} 
    private List<String> questionsCategoriesList {get;set;} 
    public Map<String, List<PreviewWrapper>> questionsByCategoryMap {get;set;}
    
    public QuestionnairesWrapper questionnairesWrappers {get;set;}

    public GNE_SFA2_Create_Survey_Layout_Controller() {
        
    }
    
    public PageReference init() {
        pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Survey_gne__c');  
        // Get Account From DB
        try {
            List<Account> accountList = [SELECT Id FROM Account WHERE Id =: ApexPages.currentPage().getParameters().get('objectId')];
            List<Contact> contactList = [SELECT Id FROM Contact WHERE Id =: ApexPages.currentPage().getParameters().get('objectId')];
            if(accountList != null && accountList.size() > 0) {
                account = [SELECT Id FROM Account WHERE Id =: ApexPages.currentPage().getParameters().get('objectId') LIMIT 1];
                questionnairesWrappers = new QuestionnairesWrapper(account.Id, '');
                allQuestionnairesList = questionnairesWrappers.getAllQuestionnaires();
            } else if (contactList != null && contactList.size() > 0) {
                contact = [SELECT Id, AccountId FROM Contact WHERE Id =: ApexPages.currentPage().getParameters().get('objectId') LIMIT 1];
                questionnairesWrappers = new QuestionnairesWrapper(contact.AccountId, '');
                allQuestionnairesList = questionnairesWrappers.getAllQuestionnaires();
            } else {
                barndAffiliation = [SELECT Id, Products_vod__c FROM Product_Metrics_vod__c WHERE Id =: ApexPages.currentPage().getParameters().get('objectId') LIMIT 1];
                questionnairesWrappers = new QuestionnairesWrapper('', barndAffiliation.Products_vod__c);
                allQuestionnairesList = questionnairesWrappers.getAllQuestionnaires();
            }
        } catch (System.QueryException ex){
            PageReference pageref = new PageReference('/apex/GNE_SFA2_Exception_Layout');
            pageref.setredirect(true);
            System.debug('pageref: '+pageref);
            pageref.getParameters().put('ex', 'Record not found or Id parameter missing!');
            return pageref;
        }
        
        // Get Available Records Type 
        List<Schema.RecordTypeInfo> recordsTypeList = Schema.SObjectType.Questionnaire_gne__c.getRecordTypeInfos();
        
        // Prepare Picklists 
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
            guestionnairesHasExists = true;
            categoriesList = prepareCategoriesList(availableQuestionnairesMap);
            
            if(category == null) {
                category = categoriesList[0].getValue();
            }
            
            questionnairesList = availableQuestionnairesMap.get(category);
            
            if(questionnaire == null) {
                questionnaire = questionnairesList[0].getValue();
            }
            
            // Get Questions From DB
            questionsList = [SELECT Id, Title_gne__c, Help_Text_gne__c, Minimum_Score_gne__c, Maximum_Score_gne__c, Weight_gne__c, Position_gne__c, Labels_gne__c, Category_gne__c, Type_gne__c, Force_Ranking_Value_gne__c, Multiple_Responses_gne__c, Values_gne__c FROM Question_gne__c WHERE Questionnaire_gne__c =: questionnaire order by Position_gne__c];
            
            showPreview = false;
            
        } else {
           guestionnairesHasExists = false;         
        }
        
        return null;
    }
    
    private List<SelectOption> prepareCategoriesList(Map<String, List<SelectOption>> questionnairesMap) {
        Set<String> categoriesSet = questionnairesMap.keySet();
        List<SelectOption> result = new List<SelectOption>();
        for(String category : categoriesSet) {
                result.add(new SelectOption(category, category));
        }
        
        return result;
    }
    
    public void setCategory(String category) {
    
    }
    
    public void setQuestionnaire(String questionnaire) {
    
    }
    
    public List<String> getQuestionsCategories() {
        
        // Create Responses Cetegory List
        questionsCategoriesList = new List<String>();
        Set<String> categoriesSet = new Set<String>();
        for(Question_gne__c s : questionsList) {
            if(s.Category_gne__c == null || s.Category_gne__c == '') {
                categoriesSet.add('1');
            } else {
                categoriesSet.add(s.Category_gne__c);
            }
        }
        questionsCategoriesList.addAll(categoriesSet);
        questionsCategoriesList.sort();
        
        return questionsCategoriesList;
    }
    
    private List<SelectOption> prepareSelectOption(String values, String labels) {
        
        // Prepare Values List
        List<String> valuesList = new List<String>();
        if(values != null && values != '') {
            valuesList = values.split(',', 0);
        }    
        
        // Prepare Labels List
        List<String> labelsList = new List<String>();
        if(labels != null && labels != '') {
            labelsList = labels.split(',', 0);
        } else if(values != null && values != '') {
            labelsList = values.split(',', 0); 
        }
            
        // Prepare Select Option List
        List<SelectOption> selectOptions = new List<SelectOption>();
        for(Integer i = 0; i < valuesList.size(); i++) {
           selectOptions.add(new SelectOption(valuesList[i], labelsList[i]));
        }
        return selectOptions;
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
    
    public String getActiveMenuItem() {
       String result = '';
        if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
        result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
        }
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
    
    public Map<String, List<PreviewWrapper>> getPreviewSurvey() {
        
        Map<String, List<PreviewWrapper>> questionsByCategoryMap = new Map<String, List<PreviewWrapper>>();
        for(String category : questionsCategoriesList) {
            previewWrappers = new List<PreviewWrapper>();
            for(Question_gne__c question : questionsList) {
                if((question.Category_gne__c == null || question.Category_gne__c == '') && category == '1') {
                    // Prepare Answer To Select Options
                    Map<Id, List<SelectOption>> answersMap = new Map<Id, List<SelectOption>>();
                    answersMap.put(question.Id, prepareSelectOption(question.Values_gne__c, question.Labels_gne__c));
                    // Prepare View Responses
                    previewWrappers.add(new PreviewWrapper(question, answersMap.get(question.Id)));
                } else if(question.Category_gne__c == category) {
                    // Prepare Answer To Select Options
                    Map<Id, List<SelectOption>> answersMap = new Map<Id, List<SelectOption>>();
                    answersMap.put(question.Id, prepareSelectOption(question.Values_gne__c, question.Labels_gne__c));
                    // Prepare View Responses
                    previewWrappers.add(new PreviewWrapper(question, answersMap.get(question.Id)));
                } 
            }
            questionsByCategoryMap.put(category, previewWrappers);
        }
        return questionsByCategoryMap;
    }
    
    // Custom Buttons
    
    public PageReference createClick() {
    
        // Create Survey
        Survey_gne__c survey = new Survey_gne__c();
        if(barndAffiliation != null) {
            survey.Product_Metrics_vod__c = barndAffiliation.Id;
        } else if (contact != null) {
            survey.Account__c = contact.AccountId;
            survey.Contact_gne__c = contact.Id;
        } else {
            survey.Account__c = account.Id;
        }
        survey.Questionnaire_gne__c = questionnaire;
        
        insert survey;
        
        // Create Survey Responses
        List<Survey_Response_gne__c> surveyResponsesList =new List<Survey_Response_gne__c>();
        for(Question_gne__c question : questionsList){
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
                surveyResponse.Selected_Label_gne__c = getDefaultLabel(question.Labels_gne__c);
                surveyResponse.Selected_Values_gne__c = getDefaultValue(question.Values_gne__c);
                if(surveyResponse.Selected_Values_gne__c.isNumeric()) {
                	surveyResponse.Response_Score_gne__c = Decimal.valueOf(surveyResponse.Selected_Values_gne__c);
                }
            } else if (question.Type_gne__c == 'List of Values') {
                surveyResponse.Values_gne__c = question.Values_gne__c;
                surveyResponse.Selected_Label_gne__c = getDefaultValue(question.Values_gne__c);
                surveyResponse.Selected_Values_gne__c = getDefaultValue(question.Values_gne__c);
                if(surveyResponse.Selected_Values_gne__c.isNumeric()) {
                	surveyResponse.Response_Score_gne__c = Decimal.valueOf(surveyResponse.Selected_Values_gne__c);
                }
            } else if(question.Type_gne__c == 'Numeric'){
                surveyResponse.Response_Score_gne__c = question.Minimum_Score_gne__c;
            } else if (question.Type_gne__c=='Free Text'){
                surveyResponse.Free_Text_gne__c = '';
            }
            
            surveyResponsesList.add(surveyResponse);
        }
        
        insert surveyResponsesList;
        
        PageReference pageref = new PageReference('/apex/GNE_SFA2_Edit_Survey_Layout?Id=' + survey.Id);
        pageref.getParameters().put('retURL',ApexPages.currentPage().getParameters().get('objectId'));
        pageref.setredirect(true);
        return pageref;
    }
    
    public PageReference previewClick() {
        
        showPreview = true;
        return null;
    }
    
    public PageReference cancelClick() {
        
        PageReference pageref;
        if(barndAffiliation != null) {
            pageref = new PageReference('/apex/GNE_SFA2_Brand_Aff_Layout?Id=' + barndAffiliation.Id);
        } else if (contact != null) {
            pageref = new PageReference('/apex/GNE_SFA2_Contact_Layout?Id=' + contact.Id);
        } else {
            pageref = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        }
        pageref.setredirect(true);
        return pageref; 
    }
    
    // Action Function
    
    public PageReference refreshPicklist() {
        
        showPreview = false;
        questionnairesList = availableQuestionnairesMap.get(category);
        questionnaire = questionnairesList[0].getValue();
        
        // Update Questions From DB
        questionsList = [SELECT Id, Title_gne__c, Help_Text_gne__c, Minimum_Score_gne__c, Maximum_Score_gne__c, Weight_gne__c, Position_gne__c, Labels_gne__c, Category_gne__c, Type_gne__c, Force_Ranking_Value_gne__c, Multiple_Responses_gne__c, Values_gne__c FROM Question_gne__c WHERE Questionnaire_gne__c =: questionnaire order by Position_gne__c];
        
        return null;
    }
    
    public PageReference refreshPreviewSurvey() {
        
        showPreview = false;
        
        // Update Questions From DB
            questionsList = [SELECT Id, Title_gne__c, Help_Text_gne__c, Minimum_Score_gne__c, Maximum_Score_gne__c, Weight_gne__c, Position_gne__c, Labels_gne__c, Category_gne__c, Type_gne__c, Force_Ranking_Value_gne__c, Multiple_Responses_gne__c, Values_gne__c FROM Question_gne__c WHERE Questionnaire_gne__c =: questionnaire order by Position_gne__c];
        
        return null;
    }
    
    // Wrapper Class
    
    private class PreviewWrapper {
        
        public Question_gne__c question {get;set;}
        public List<SelectOption> answersList {get; set;}
        public String answer {get; set;}
        
        public PreviewWrapper (Question_gne__c question, List<SelectOption> answersList) {
            this.question = question;
            this.answersList = answersList;
        }
        
        public String getMinMaxNumericScore() {
            String result;
            if(question.Type_gne__c == 'Numeric') {
                result  = '(' + question.Minimum_Score_gne__c + '-' + question.Maximum_Score_gne__c + ')';
            }
            return result;
        }
    }
    
    private class QuestionnairesWrapper {
        
        public String accountId {get;set;}
        public String productId {get;set;}
        
        public QuestionnairesWrapper (String accountId, String productId) {
            this.accountId = accountId;
            this.productId = productId;
        }
        
        public List<Questionnaire_gne__c> getAllQuestionnaires() {
            
            Boolean isCanadaUser = GNE_SFA2_Util.isCanadaUser();
             
            List<Questionnaire_gne__c> result = new List<Questionnaire_gne__c>();
            for(Questionnaire_gne__c quest : [ SELECT Id, Audience_Type_gne__c, Category_gne__c, Type_gne__c, (SELECT Id FROM Questions__r), (SELECT Account__c, Id FROM QuestionnairesAccounts__r WHERE Account__c =: accountId) FROM Questionnaire_gne__c WHERE Ready_For_Use_gne__c = true AND Hide_Surveys_gne__c = false AND Freeze_Surveys_gne__c = false AND Category_gne__c != null AND Product_gne__c =: productId ORDER BY Type_gne__c]) {
                if(productId != null && productId != '') {
                	result.add(quest);
                } else {
                    if(!isCanadaUser) {
                        if(quest.Audience_Type_gne__c == 'General' || (quest.Audience_Type_gne__c == 'Targeted' && quest.QuestionnairesAccounts__r.size() != 0)) {
                            result.add(quest);
                        }
                    } else {
                        if(quest.QuestionnairesAccounts__r.size() != 0) {
                            result.add(quest);
                        }
                    }   
                } 
            }
            return result;
        }
    }
}