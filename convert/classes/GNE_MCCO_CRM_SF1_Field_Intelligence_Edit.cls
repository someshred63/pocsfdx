public with sharing class GNE_MCCO_CRM_SF1_Field_Intelligence_Edit extends GNE_MCCO_CRM_Survey_Util {
    
    private final String FIELD_INTELLIGENCE_ID { get; set; }
    public final String VIEW_ID { get; set; }
        
    private List<GNE_MCCO_CRM_Field_Intelligence_Answer__c> answerList { get; set; }
    private List<GNE_MCCO_CRM_Survey_Question__c> questionsList { get; set; }
    private List<GNE_MCCO_CRM_Survey_Group__c> groupsList { get; set; }
    
    public Id fieldIntelligenceLogoId { get; private set; }
    
    public GNE_MCCO_CRM_Field_Intelligence__c fieldIntelligenceObject { get; set; }
    public GNE_MCCO_CRM_Survey__c surveyObject { get; set; }
    
    public SurveyWrapper survey { get; private set; }
    public List<SurveyElementWrapper> sortedRanks {get; private set; }
    public List<SurveyElementWrapper> sortedGroupRanks {get; private set; }
    public String surveyJson { get; private set; }

    public Boolean isEditable { get; private set; }
    public Boolean isSubmitted { get; private set; }
    public Boolean editMode { get; private set; }
    
    public String userTimeZone { get; private set; }
    
    public GNE_MCCO_CRM_SF1_Field_Intelligence_Edit() {
        
        isEditable  = false;
        isSubmitted = false;
        editMode    = false;
        
        userTimeZone = String.valueOf(UserInfo.getTimeZone());
        
        FIELD_INTELLIGENCE_ID   = (ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '') ? ApexPages.currentPage().getParameters().get('id') : null;
        VIEW_ID                 = (ApexPages.currentPage().getParameters().get('view') != null && ApexPages.currentPage().getParameters().get('view') != '') ? ApexPages.currentPage().getParameters().get('view') : null;
        
        editMode                = (ApexPages.currentPage().getParameters().get('edit') != null && ApexPages.currentPage().getParameters().get('edit') != '') ? true : false;
        
        fieldIntelligenceLogoId = [SELECT Id FROM Document WHERE DeveloperName = 'GNE_MCCO_CRM_SF1_Field_Intelligence_Tab' LIMIT 1].Id;

        try {
                
            // FieldIntelligenceObject
            fieldIntelligenceObject = [SELECT Id, Name, Account_gne__c, Available_gne__c, Comment_gne__c, CreatedById, Previous_Status__c, Survey_gne__c, Survey_Status_gne__c, Title_gne__c, User_gne__c FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE Id = :FIELD_INTELLIGENCE_ID];
                
            // Field Inelligence Answers
            answerList = [SELECT Answer_gne__c, Conditional_Answer_gne__c, Group_Set_gne__c, MCCO_CRM_Survey_Group_gne__c, Field_Intelligence_gne__c, Survey_Question_gne__c, Survey_Question_gne__r.Group_gne__c FROM GNE_MCCO_CRM_Field_Intelligence_Answer__c WHERE Field_Intelligence_gne__c = :FIELD_INTELLIGENCE_ID];
                
            // SurveyObject with Questions and Groups
            surveyObject = [SELECT Id, Name, Close_Survey_gne__c, Account_Ids_gne__c, Ready_To_Use_gne__c, Record_Type_gne__c, Territories_gne__c, Title_gne__c, Status_gne__c, Notification_gne__c, CreatedBy.Id, CreatedBy.Name, CreatedDate, Requested_By_gne__r.Id, Requested_By_gne__r.Name, LastModifiedBy.Id, LastModifiedBy.Name, LastModifiedDate, Assignment_Mode_gne__c FROM GNE_MCCO_CRM_Survey__c WHERE Id = :fieldIntelligenceObject.Survey_gne__c LIMIT 1];
            
            // QuestionsList
            questionsList = [SELECT Id, Name, Conditional_Help_Text_gne__c, Group_gne__c, Help_Text_gne__c, Order_gne__c, Required_gne__c, Question_gne__c, Type_gne__c, Values_gne__c FROM GNE_MCCO_CRM_Survey_Question__c WHERE Survey_gne__c = :fieldIntelligenceObject.Survey_gne__c];

            // GroupsList
            groupsList = [SELECT Id, Name, Order_gne__c, Title_gne__c FROM GNE_MCCO_CRM_Survey_Group__c WHERE Survey_gne__c = :fieldIntelligenceObject.Survey_gne__c];
                
            // Create Wrapper From Objects
            survey = new SurveyWrapper();
            survey = survey.createWrapperFromObjects(surveyObject, questionsList, groupsList, answerList);
            surveyJson = JSON.serializePretty(survey);
            sortedRanks = sortRankQuestions(survey);
            sortedGroupRanks = prepareListOfGroupRankAnswers(survey);
                
            if(!surveyObject.Close_Survey_gne__c && surveyObject.Ready_To_Use_gne__c && questionsList.size() > 0 && fieldIntelligenceObject.User_gne__c == UserInfo.getUserId()) {
                isEditable = true;
            }
            
            if(fieldIntelligenceObject.Survey_Status_gne__c == 'Submitted') {
                isSubmitted = true;
            }
            
        } catch(Exception ex) {
            System.debug(Logginglevel.ERROR, ex.getMessage());
            checkIfFieldIntelligenceCanBeEdit();
        }
        
    }
    
    public PageReference checkIfFieldIntelligenceCanBeEdit() {
        
        PageReference pageRef = null;
        
        // No Field Intelligence Id or Field Intelligence
        if(FIELD_INTELLIGENCE_ID == null || fieldIntelligenceObject == null) {
            pageRef = new PageReference('/apex/GNE_MCCO_CRM_SF1_Field_Intelligence');

            pageref.getParameters().put('msg', 'This survey is not available.');
            if(VIEW_ID != null) {
                pageref.getParameters().put('view', VIEW_ID);
            }
            
            pageRef.setRedirect(true);
            
        }
        
        // Is not editable
        if(!isEditable && isEditable) {
            pageRef = new PageReference('/apex/GNE_MCCO_CRM_SF1_Field_Intelligence_Edit');
                        
            pageref.getParameters().put('id', FIELD_INTELLIGENCE_ID);
            pageref.getParameters().put('msg', 'This survey is not editable.');
            if(VIEW_ID != null) {
                pageref.getParameters().put('view', VIEW_ID);
            }
            
            pageRef.setRedirect(true);
            return pageRef;
        }

        return pageRef;
    }
    
    @RemoteAction
    public static Map<String, String> save(String fiId, String answersJson, String fisToDeleteJson, Boolean inProgress) {
        Map<String, String> result = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            List<FieldIntelligenceWrapper> fieldIntelligenceWrapperList = (List<FieldIntelligenceWrapper>)JSON.deserialize(answersJson, List<FieldIntelligenceWrapper>.class);
            List<String> fieldIntelligencesToDeleteList = (List<String>)JSON.deserialize(fisToDeleteJson, List<String>.class);
            GNE_MCCO_CRM_Field_Intelligence__c fieldIntelligence = [SELECT Survey_Status_gne__c, Previous_Status__c FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE Id = :fiId];
            List<GNE_MCCO_CRM_Field_Intelligence_Answer__c> listToUpsert = new List<GNE_MCCO_CRM_Field_Intelligence_Answer__c>();
            
            for(FieldIntelligenceWrapper fieldIntelligenceWrapper : fieldIntelligenceWrapperList) {

                if(fieldIntelligenceWrapper.Type == 'group') {
                    for(FieldIntelligenceWrapper fieldIntelligenceChild : fieldIntelligenceWrapper.Elements) {
                        listToUpsert.add(convertToObject(fieldIntelligenceChild, fiId));
                    }
                } else {
                    listToUpsert.add(convertToObject(fieldIntelligenceWrapper, fiId));
                }
        
            }
            
            for(GNE_MCCO_CRM_Field_Intelligence_Answer__c fi : listToUpsert) {
                System.debug(fi);
            }
            
            if(inProgress) {
                fieldIntelligence.Survey_Status_gne__c = 'In Progress';
            } else {
                fieldIntelligence.Survey_Status_gne__c = 'Submitted';
            }
            
            if(fieldIntelligencesToDeleteList.size() > 0) {
                List<GNE_MCCO_CRM_Field_Intelligence_Answer__c> fisToDelete = [SELECT Id FROM GNE_MCCO_CRM_Field_Intelligence_Answer__c WHERE Id = :fieldIntelligencesToDeleteList];
                delete fisToDelete;
            }
            
            update fieldIntelligence;
            upsert listToUpsert;
            
            result.put('status', 'OK');
        } catch(Exception ex) {
            result.put('status', 'ERROR');
            result.put('message', ex.getMessage());
        }
        
        return result;
    }
    
    public static GNE_MCCO_CRM_Field_Intelligence_Answer__c convertToObject(FieldIntelligenceWrapper wrapper, String fiId) {
        GNE_MCCO_CRM_Field_Intelligence_Answer__c result = new GNE_MCCO_CRM_Field_Intelligence_Answer__c();
    
        if(wrapper.Type == 'multipicklist') {
            if(wrapper.Picklist != null) {
                String tmpAnwser = '';
                for(String s : wrapper.Picklist) {
                    if(!String.isEmpty(s)) {
                        tmpAnwser += s + ';;;';
                    }
                }
                tmpAnwser = tmpAnwser.removeEnd(';;;');
                result.Answer_gne__c        = tmpAnwser;
            } else {
                result.Answer_gne__c        = null;
            }
        } else {
            result.Answer_gne__c            = wrapper.Answer;
        }
        
        if(!String.isEmpty(wrapper.Id)) {
            result.Id                       = wrapper.Id;
        } else {
            result.Field_Intelligence_gne__c = fiId;
            result.MCCO_CRM_Survey_Group_gne__c = wrapper.GroupId;
            result.Survey_Question_gne__c       = wrapper.QuestionId;
        }
                
        result.Conditional_Answer_gne__c    = wrapper.Conditional;
        result.Group_Set_gne__c             = wrapper.GroupSet;
    
        return result;
    }

    private List<SurveyElementWrapper> sortRankQuestions(SurveyWrapper survey){
        List<SurveyElementWrapper> rankElementsToDisplay = new List<SurveyElementWrapper>();
        for(SurveyElementWrapper element :survey.Elements){
            if(element.getNormalType() == 'rank'){
                if(element.Answer != null && element.Answer.PicklistAnswer != null){
                    SurveyElementWrapper sortedElement = new SurveyElementWrapper();
                    sortedElement.Id = element.Id;
                    sortedElement.Type = element.Type;
                    sortedElement.Title = element.Title;
                    sortedElement.Help = element.Help;
                    sortedElement.CondHelp = element.CondHelp;
                    sortedElement.Required = element.Required;
                    sortedElement.Order = element.Order;
                    sortedElement.Values = new List<String>();
                    sortedElement.CondValues = element.CondValues;
                    sortedElement.Elements = element.Elements;
                    sortedElement.Answer = new SurveyAnswerWrapper();
                    sortedElement.GroupElements = element.GroupElements;
                    sortedElement.GroupElementsCount = element.GroupElementsCount;

                    List<String> answersWithValues = new List<String>();
                    for(Integer i = 0; i < element.Values.size(); i++){
                        Boolean hasAnswer = (i < element.Answer.PicklistAnswer.size() && element.Answer.PicklistAnswer[i] != null && element.Answer.PicklistAnswer[i] != '');
                        String answerValueString = (hasAnswer ? (element.Answer.PicklistAnswer[i] != '10' ? ('0' + element.Answer.PicklistAnswer[i]) : element.Answer.PicklistAnswer[i]) : 'Answer Pending') + ';;;' + element.Values[i];
                        answersWithValues.add(answerValueString);
                    }
                    answersWithValues.sort();

                    sortedElement.Answer.PickListAnswer = new List<String>();
                    for(String answerValue :answersWithValues){
                        String answerToAdd = answerValue.split(';;;')[0];
                        if(answerToAdd.startsWithIgnoreCase('0')){
                            answerToAdd = answerToAdd.removeStart('0');
                        }
                        sortedElement.Values.add(answerValue.split(';;;')[1]);
                        sortedElement.Answer.PickListAnswer.add(answerToAdd);
                    }
                    rankElementsToDisplay.add(sortedElement);
                } else {
                    rankElementsToDisplay.add(element);
                }
            }
        }
        return rankElementsToDisplay;
    }

    private List<SurveyElementWrapper> prepareListOfGroupRankAnswers(SurveyWrapper survey){
        List<SurveyElementWrapper> groupRankElementsToDisplay = new List<SurveyElementWrapper>();
        for(SurveyElementWrapper element :survey.Elements){
            if(element.Type.startsWithIgnoreCase('group') && element.GroupElementsCount > 0){
                SurveyElementWrapper sortedElement = new SurveyElementWrapper();
                sortedElement.Id = element.Id;
                sortedElement.Type = element.Type;
                sortedElement.Title = element.Title;
                sortedElement.Help = element.Help;
                sortedElement.CondHelp = element.CondHelp;
                sortedElement.Required = element.Required;
                sortedElement.Order = element.Order;
                sortedElement.Values = new List<String>();
                sortedElement.CondValues = element.CondValues;
                sortedElement.Elements = new List<SurveyElementWrapper>();
                sortedElement.Answer = new SurveyAnswerWrapper();
                sortedElement.GroupElements = element.GroupElements;
                sortedElement.GroupElementsCount = element.GroupElementsCount;
                sortedElement.GroupValues = new Map<Decimal, Map<Id, List<String>>>();
                for(SurveyElementWrapper groupElement :element.Elements){
                    if(groupElement.getNormalType() == 'rank'){
                        for(Integer i = 0; i < element.GroupElementsCount; i++){
                            parseGroupRankAnswer(sortedElement, groupElement, i);
                        }
                    }
                }
                groupRankElementsToDisplay.add(sortedElement);
            }
        }
        return groupRankElementsToDisplay;
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
        SurveyAnswerWrapper newAnswer = new SurveyAnswerWrapper();
        newAnswer.PicklistAnswer = new List<String>();
        for(String answerValue :answersWithValues){
            String answerToAdd = answerValue.split(';;;')[0];
            if(answerToAdd.startsWithIgnoreCase('0')){
                answerToAdd = answerToAdd.removeStart('0');
            }
            valuesToAdd.add(answerValue.split(';;;')[1]);
            newAnswer.PicklistAnswer.add(answerToAdd);
        }
        element.groupValues.get(counter).put(groupElement.Id, valuesToAdd);
        element.GroupElements.get(counter).put(groupElement.Id, newAnswer);
    }
}