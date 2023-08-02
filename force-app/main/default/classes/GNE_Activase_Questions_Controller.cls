public without sharing class GNE_Activase_Questions_Controller {
    public List<ActivaseQuestionWrapper> activaseQuestionsWrappers {get; set;}
    public List<Activase_Question_gne__c> activaseQuestions {get; set;}
    public List<Activase_Answer_gne__c> activaseAnswers {get; set;}
    private Map<String, Activase_Answer_gne__c> activaseAnswersMap;
    private List<Activase_Answer_gne__c> answersToUpdate;
    private List<Activase_Answer_gne__c> answersToInsert;
    private List<Activase_Answer_gne__c> answersToDelete;
    private final Account acc;
    private String accountId;
    private String userProfile;
    
    public GNE_Activase_Questions_Controller(ApexPages.StandardController controller){
        this.acc = (Account)controller.getRecord();
        accountId = acc.Id;
        userProfile = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        // get qusetions and answers
        activaseQuestions = getQuestions();
        activaseAnswers = getAnswers(activaseQuestions);
        
        prepareData();
    }

    public PageReference save(){
        answersToUpdate = new List<Activase_Answer_gne__c>();
        answersToDelete = new List<Activase_Answer_gne__c>();
        answersToInsert = new List<Activase_Answer_gne__c>();
        for(ActivaseQuestionWrapper wrapper : activaseQuestionsWrappers){
            if(activaseAnswersMap.containsKey(wrapper.activaseQuestion.Id) && activaseAnswersMap.get(wrapper.activaseQuestion.Id).Id != null){
                if(wrapper.activaseQuestion.Type_gne__c == 'List of Values'){
                    if(activaseAnswersMap.get(wrapper.activaseQuestion.Id).Value_gne__c != wrapper.pickListAnswer){
                        activaseAnswersMap.get(wrapper.activaseQuestion.Id).Value_gne__c = wrapper.pickListAnswer;
                        if(activaseAnswersMap.get(wrapper.activaseQuestion.Id).Value_gne__c != null){
                            answersToUpdate.add(activaseAnswersMap.get(wrapper.activaseQuestion.Id));
                        } else {
                            answersToDelete.add(activaseAnswersMap.get(wrapper.activaseQuestion.Id));
                        }
                    }
                } else if (wrapper.activaseQuestion.Type_gne__c == 'Numeric'){
                    //System.debug('found existing numeric answer');
                    boolean isNumber = pattern.matches('[0-9]+(\\.[0-9]+)?',wrapper.numericAnswer);
                    if (isNumber || wrapper.numericAnswer == ''){
                        if(activaseAnswersMap.get(wrapper.activaseQuestion.Id).Value_gne__c != wrapper.numericAnswer){
                            activaseAnswersMap.get(wrapper.activaseQuestion.Id).Value_gne__c = wrapper.numericAnswer;
                            if(activaseAnswersMap.get(wrapper.activaseQuestion.Id).Value_gne__c != null && activaseAnswersMap.get(wrapper.activaseQuestion.Id).Value_gne__c != ''){
                                answersToUpdate.add(activaseAnswersMap.get(wrapper.activaseQuestion.Id));
                            } else {
                                answersToDelete.add(activaseAnswersMap.get(wrapper.activaseQuestion.Id));
                            }
                        }
                    } else {
                        //System.debug('NOT A NUMBER!!!, isNumber: "'+ isNumber+'", wrapper.numericAnswer: "'+wrapper.numericAnswer+'"');
                        String message = 'You can only enter numeric value for "'+wrapper.activaseQuestion.Title_gne__c+'" field.';
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,message));
                    }
                }
            } else {
                if(wrapper.activaseQuestion.Type_gne__c == 'List of Values'){
                    if(activaseAnswersMap.get(wrapper.activaseQuestion.Id).Value_gne__c != wrapper.pickListAnswer){
                        activaseAnswersMap.get(wrapper.activaseQuestion.Id).Value_gne__c = wrapper.pickListAnswer;
                        answersToInsert.add(activaseAnswersMap.get(wrapper.activaseQuestion.Id));
                    }
                } else if (wrapper.activaseQuestion.Type_gne__c == 'Numeric'){
                    //System.debug('found new numeric answer');
                    boolean isNumber = pattern.matches('[0-9]+(\\.[0-9]+)?',wrapper.numericAnswer);
                    if (isNumber|| wrapper.numericAnswer == ''){
                        if(activaseAnswersMap.get(wrapper.activaseQuestion.Id).Value_gne__c != wrapper.numericAnswer){
                            if(wrapper.numericAnswer != ''){
                                activaseAnswersMap.get(wrapper.activaseQuestion.Id).Value_gne__c = wrapper.numericAnswer;
                                answersToInsert.add(activaseAnswersMap.get(wrapper.activaseQuestion.Id));
                            }
                        }
                    } else {
                        //System.debug('NOT A NUMBER!!!, isNumber: "'+ isNumber+'", wrapper.numericAnswer: "'+wrapper.numericAnswer+'"');
                        String message = 'You can only enter numeric value for "'+wrapper.activaseQuestion.Title_gne__c+'" field.';
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,message));
                    }
                }
            }
        }
        if (answersToUpdate != null && answersToUpdate.size() > 0){
            update answersToUpdate;
        }
        if (answersToDelete != null && answersToDelete.size() > 0){
            delete answersToDelete;
        }
        if (answersToInsert != null && answersToInsert.size() > 0){
            try{
                insert answersToInsert;
            } catch (Exception e){
                System.debug('Exception during inserting Profiling Answer: ' + e);
            }
        }
        refreshData();
        return null;
    }
    
    private List<Activase_Question_gne__c> getQuestions(){
        List<List<SObject>> questions = [FIND :userProfile IN ALL FIELDS RETURNING Activase_Question_gne__c (Id, Answers_gne__c, Profile_gne__c, Title_gne__c, Type_gne__c ORDER BY Id)];
        return questions[0];
    }
    
    private List<Activase_Answer_gne__c> getAnswers(List<Activase_Question_gne__c> activaseQuestions){
        return [SELECT Id, 
                          Account_gne__c, 
                          Activase_Question_gne__c, 
                          Question_Value_gne__c,
                          Value_gne__c
                    FROM Activase_Answer_gne__c
                    WHERE Activase_Question_gne__c in :activaseQuestions
                    AND Account_gne__c = :accountId];
    }
    
    private void refreshData(){
        activaseQuestions = getQuestions();
        activaseAnswers = getAnswers(activaseQuestions);
        prepareData();
    }
    
    private void prepareData(){
        activaseQuestionsWrappers = new List<ActivaseQuestionWrapper>();
        activaseAnswersMap = new Map<String, Activase_Answer_gne__c>();     
        
        for(Activase_Answer_gne__c answer : activaseAnswers){
            if(!activaseAnswersMap.containsKey(answer.Activase_Question_gne__c)){
                activaseAnswersMap.put(answer.Activase_Question_gne__c, answer);
            }
        }
        
        for(Activase_Question_gne__c question : activaseQuestions){
            ActivaseQuestionWrapper questionWrapper = new ActivaseQuestionWrapper();
            questionWrapper.activaseQuestion = question;
            if(questionWrapper.activaseQuestion.Type_gne__c == 'List of Values'){
                questionWrapper.activaseQuestionAnswers = new List<String>();
                List<String> tmpAnswers = question.Answers_gne__c.split(',');
                for(String tmpAnswer : tmpAnswers){
                    questionWrapper.activaseQuestionAnswers.add(tmpAnswer.trim());
                }
                if(activaseAnswersMap.containsKey(question.Id)){
                    questionWrapper.pickListAnswer = activaseAnswersMap.get(question.Id).Value_gne__c;
                }
            }else if(questionWrapper.activaseQuestion.Type_gne__c == 'Numeric') {
                if(activaseAnswersMap.containsKey(question.Id)){
                    questionWrapper.numericAnswer = activaseAnswersMap.get(question.Id).Value_gne__c;
                }
            }
            activaseQuestionsWrappers.add(questionWrapper);
        }
        
        for(ActivaseQuestionWrapper wrapper : activaseQuestionsWrappers){
            if(!activaseAnswersMap.containsKey(wrapper.activaseQuestion.Id)){
                Activase_Answer_gne__c tmpAnswer = new Activase_Answer_gne__c();
                tmpAnswer.Activase_Question_gne__c = wrapper.activaseQuestion.Id;
                tmpAnswer.Question_Value_gne__c = wrapper.activaseQuestion.Title_gne__c;
                tmpAnswer.Value_gne__c = null;
                tmpAnswer.Account_gne__c = accountId;
                activaseAnswersMap.put(wrapper.activaseQuestion.Id, tmpAnswer);
            }
        }
    }
    
    // HELPER CLASS
    public class ActivaseQuestionWrapper{
        public Activase_Question_gne__c activaseQuestion {get; set;}
        public List<String> activaseQuestionAnswers {get; set;}
        public String pickListanswer {get; set;}
        public String numericAnswer {get; set;}
        private List<SelectOption> answerSelectOptions;
        
        public ActivaseQuestionWrapper(){
        }
        
        public List<SelectOption> getAnswerSelectOptions() {
            List<SelectOption> answerSelectOptions = new List<SelectOption>();
            answerSelectOptions.add(new SelectOption('','-'));
            for(String activaseQuestionAnswer : activaseQuestionAnswers){
                answerSelectOptions.add(new SelectOption(activaseQuestionAnswer, activaseQuestionAnswer));
            }
            return answerSelectOptions;
        }
    }
}