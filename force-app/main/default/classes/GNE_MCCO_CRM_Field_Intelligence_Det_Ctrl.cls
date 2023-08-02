public with sharing class GNE_MCCO_CRM_Field_Intelligence_Det_Ctrl extends GNE_MCCO_CRM_Survey_Util {
    
    private String fiId { get; set; }
    private String surveyId { get; set; }
    public String retUrl { get; set; }
    public String viewId { get; private set; }
    public String msg { get; private set; }
    
    public GNE_MCCO_CRM_Field_Intelligence__c fieldIntelligenceObject { get; public set; }
    private List<GNE_MCCO_CRM_Field_Intelligence_Answer__c> answerList { get; set; }
    public GNE_MCCO_CRM_Survey__c surveyObject { get; public set; }
    private List<GNE_MCCO_CRM_Survey_Question__c> questionsList { get; set; }
    private List<GNE_MCCO_CRM_Survey_Group__c> groupsList { get; set; }
    
    public SurveyWrapper survey { get; private set; }

    public Boolean canEdit { get; private set; }
    public Boolean valid { get; private set; }
    
    public String iconBase64 { get; private set; }
    
    public GNE_MCCO_CRM_Field_Intelligence_Det_Ctrl() {
        
        iconBase64  = GNE_MCCO_CRM_Util.getDocumentBase64('GNE_MCCO_CRM_Survey_Builder_Icon');
        
        fiId        = (ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '') ? ApexPages.currentPage().getParameters().get('id') : null;
        retUrl      = (ApexPages.currentPage().getParameters().get('retUrl') != null && ApexPages.currentPage().getParameters().get('retUrl') != '') ? ApexPages.currentPage().getParameters().get('retUrl') : null;
        viewId      = (ApexPages.currentPage().getParameters().get('view') != null && ApexPages.currentPage().getParameters().get('view') != '') ? ApexPages.currentPage().getParameters().get('view') : null;
        msg         = (ApexPages.currentPage().getParameters().get('msg') != null && ApexPages.currentPage().getParameters().get('msg') != '') ? ApexPages.currentPage().getParameters().get('msg') : null;
        canEdit     = false;
        valid       = false;

        if(String.isNotBlank(fiId)) {
            try {
            	
            	// FieldIntelligenceObject
            	fieldIntelligenceObject = [SELECT Id, Name, Account_gne__c, Available_gne__c, Comment_gne__c, CreatedById, Previous_Status__c, Survey_gne__c, Survey_Status_gne__c, Title_gne__c, User_gne__c FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE Id = :fiId];
				
				// Field Inelligence Answers
				answerList = [SELECT Answer_gne__c, Conditional_Answer_gne__c, Group_Set_gne__c, MCCO_CRM_Survey_Group_gne__c, Field_Intelligence_gne__c, Survey_Question_gne__c, Survey_Question_gne__r.Group_gne__c FROM GNE_MCCO_CRM_Field_Intelligence_Answer__c WHERE Field_Intelligence_gne__c = :fiId];
				
                // SurveyObject with Questions and Groups
                surveyObject = [SELECT Id, Name, Close_Survey_gne__c, Account_Ids_gne__c, Ready_To_Use_gne__c, Record_Type_gne__c, Territories_gne__c, Title_gne__c, Status_gne__c, Notification_gne__c, CreatedBy.Id, CreatedBy.Name, CreatedDate, Requested_By_gne__r.Id, Requested_By_gne__r.Name, LastModifiedBy.Id, LastModifiedBy.Name, LastModifiedDate, Assignment_Mode_gne__c FROM GNE_MCCO_CRM_Survey__c WHERE Id = :fieldIntelligenceObject.Survey_gne__c LIMIT 1];
            
				// QuestionsList
                questionsList = [SELECT Id, Name, Conditional_Help_Text_gne__c, Group_gne__c, Help_Text_gne__c, Order_gne__c, Required_gne__c, Question_gne__c, Type_gne__c, Values_gne__c FROM GNE_MCCO_CRM_Survey_Question__c WHERE Survey_gne__c = :fieldIntelligenceObject.Survey_gne__c];

                // GroupsList
                groupsList = [SELECT Id, Name, Order_gne__c, Title_gne__c FROM GNE_MCCO_CRM_Survey_Group__c WHERE Survey_gne__c = :fieldIntelligenceObject.Survey_gne__c];
                
                // Create Wrapper From Objects
                survey = new SurveyWrapper();
                survey = survey.createWrapperFromObjects(surveyObject, questionsList, groupsList, answerList);

                sortRankQuestions(survey);

                if(fieldIntelligenceObject.Survey_Status_gne__c != 'Closed' && fieldIntelligenceObject.User_gne__c == UserInfo.getUserId()) {
                    canEdit = true;
                }
  
                valid = true;
                    
            } catch (Exception ex) {
            	System.debug(Logginglevel.ERROR, ex.getMessage());
            }
        }

    }

    private void sortRankQuestions(SurveyWrapper survey){
        for(SurveyElementWrapper element :survey.Elements){
            if(element.getNormalType() == 'rank' && element.Answer != null && element.Answer.PicklistAnswer != null){
                parseRankAnswer(element);
            } else if(element.Type.startsWithIgnoreCase('group') && element.GroupElementsCount > 0){
                element.GroupValues = new Map<Decimal, Map<Id, List<String>>>();
                for(SurveyElementWrapper groupElement :element.Elements){
                    if(groupElement.getNormalType() == 'rank'){
                        for(Integer i = 0; i < element.GroupElementsCount; i++){
                            parseGroupRankAnswer(element, groupElement, i);
                        }
                    }
                }
            }
        }
    }

    private void parseRankAnswer(SurveyElementWrapper element){
        List<String> answersWithValues = new List<String>();
        for(Integer i = 0; i < element.Values.size(); i++){
            Boolean hasAnswer = (i < element.Answer.PicklistAnswer.size() && element.Answer.PicklistAnswer[i] != null && element.Answer.PicklistAnswer[i] != '');
            String answerValueString = (hasAnswer ? (element.Answer.PicklistAnswer[i] != '10' ? ('0' + element.Answer.PicklistAnswer[i]) : element.Answer.PicklistAnswer[i]) : 'Answer Pending') + ';;;' + element.Values[i];
            answersWithValues.add(answerValueString);
        }
        answersWithValues.sort();
        element.Values = new List<String>();
        element.Answer.PickListAnswer = new List<String>();
        for(String answerValue :answersWithValues){
            String answerToAdd = answerValue.split(';;;')[0];
            if(answerToAdd.startsWithIgnoreCase('0')){
                answerToAdd = answerToAdd.removeStart('0');
            }
            element.Values.add(answerValue.split(';;;')[1]);
            element.Answer.PickListAnswer.add(answerToAdd);
        }
    }

    private void parseGroupRankAnswer(SurveyElementWrapper element, SurveyElementWrapper groupElement, Integer counter){
        if(!element.groupValues.keySet().contains(counter)){
            element.groupValues.put(counter, new Map<Id, List<String>>());
        }

        List<String> answersWithValues = new List<String>();
        SurveyAnswerWrapper answerList = element.GroupElements.get(counter).get(groupElement.Id);
        for(Integer i = 0; i < groupElement.Values.size(); i++){
            Boolean hasAnswer = (i < answerList.PicklistAnswer.size() && answerList.PicklistAnswer[i] != null && answerList.PicklistAnswer[i] != '');
            String answerValueString = (hasAnswer ? (answerList.PicklistAnswer[i] != '10' ? ('0' + answerList.PicklistAnswer[i]) : answerList.PicklistAnswer[i]) : 'Answer Pending') + ';;;' + groupElement.Values[i];
            answersWithValues.add(answerValueString);
        }
        answersWithValues.sort();
        List<String> valuesToAdd = new List<String>();
        answerList.PickListAnswer = new List<String>();
        for(String answerValue :answersWithValues){
            String answerToAdd = answerValue.split(';;;')[0];
            if(answerToAdd.startsWithIgnoreCase('0')){
                answerToAdd = answerToAdd.removeStart('0');
            }
            valuesToAdd.add(answerValue.split(';;;')[1]);
            answerList.PickListAnswer.add(answerToAdd);
        }
        element.groupValues.get(counter).put(groupElement.Id, valuesToAdd);
        element.GroupElements.get(counter).put(groupElement.Id, answerList);
    }
}