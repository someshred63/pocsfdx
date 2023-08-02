public class GNE_MA_Questionnaires_List_Controller{
    
    public List<Questionnaire_gne__c> questionnaires{ get; set;}
    public boolean isQuestionariesListVisible { get; set;}
    public boolean isAnswersListVisible{ get; set;}
    public boolean isUsersListVisible { get; set;}
    
    public boolean isAccountQuestionnaire { get; set;}
    public boolean isProductQuestionnaire { get; set;}
    
    public List<Survey_gne__c> SurveysList { get; set;}
    public List<Survey_gne__c> SurveysListWithProduct{ get; set;}
    List<Survey_Response_gne__c> surveyResponse = new List<Survey_Response_gne__c> ();
    public List<Survey_Response_gne__c> Answers{ get; set;}
    public List<CorrectAnswers> correctAnswersList { get; set;}
    public String AccName { get; set;}
    public String product_name { get; set;}
    public ID delId {get;set;}
    public GNE_MA_Questionnaires_List_Controller(){
        isAnswersListVisible = false;
        isQuestionariesListVisible = false;
        isUsersListVisible = true;
        //products = [Select p.Name, p.Id from Product_vod__c p  where p.Detail_Product_Subtype_Code_gne__c='Approved Product Indications' order by name];
        //questionnaires = [Select q.Id, q.Name, q.Product_gne__r.Name from Questionnaire_gne__c q where q.createdbyid=:UserInfo.getUserId()];
        SurveysList = [Select s.Account__r.Name,s.Account__r.Id, s.Questionnaire_gne__r.Name, s.Questionnaire_gne__r.Product_gne__r.Name,s.CreatedDate, s.id, s.Title_gne__c, s.Name from Survey_gne__c s where s.createdbyid=:UserInfo.getUserId() order by s.CreatedDate desc];
    }
    
    public PageReference ShowQuestionnaires()
    {
        isQuestionariesListVisible = true;
        isAnswersListVisible = false;
        isUsersListVisible = false;
        questionnaires = [Select q.Id, q.Name, q.Product_gne__r.Name from Questionnaire_gne__c q where q.createdbyid=:UserInfo.getUserId() and q.Product_gne__r.Name =: product_name];
        return null;
    }  
    public PageReference EditQuestionnaire()
    {
        Id id = System.currentPageReference().getParameters().get('questionnaire_id');
        SurveysList = [Select s.Account__r.Name, s.Questionnaire_gne__r.Name, s.Questionnaire_gne__r.Product_gne__r.Name,s.CreatedDate, s.id, s.Title_gne__c, s.Name from Survey_gne__c s where s.createdbyid=:UserInfo.getUserId() ];
        Answers = null;
        isAnswersListVisible = false;
        isQuestionariesListVisible = false;
        isUsersListVisible = true;
        return null;
    }
     public PageReference DelSurvey(){
     Id survey_id = System.currentPageReference().getParameters().get('survey_id');
     system.debug('survey_id :'+survey_id );
     ID accId= System.currentPageReference().getParameters().get('accId');
     system.debug('accId :'+accId );
            Survey_gne__c[] e = [select id from Survey_gne__c where id = :survey_id];
            delete e; 
            SurveysList = [Select s.Account__r.Name,s.Account__r.Id, s.Questionnaire_gne__r.Name, s.Questionnaire_gne__r.Product_gne__r.Name,s.CreatedDate, s.id, s.Title_gne__c, s.Name from Survey_gne__c s where s.createdbyid=:UserInfo.getUserId()order by s.CreatedDate desc ];          
        if(accId!=null){
            return new PageReference('/'+accId);  
        }else{
            return null;
        }               
        }
    public PageReference ShowAnswers()
    {
        isAnswersListVisible = true;
        isQuestionariesListVisible = false;
        isUsersListVisible = true;
        Id survey_id = System.currentPageReference().getParameters().get('survey_id');
        AccName= System.currentPageReference().getParameters().get('acc_name');
        if(AccName != '' && AccName != null)
            Answers = [Select s.Selected_Label_gne__c,s.Type_gne__c,s.Free_Text_gne__c,s.Question_gne__c,s.Question_gne__r.Title_gne__c, s.Response_Score_gne__c  from Survey_Response_gne__c s  where s.survey_gne__c=: survey_id and s.isdeleted=false];
        else
            Answers = [Select s.Selected_Label_gne__c,s.Type_gne__c,s.Free_Text_gne__c,s.Question_gne__c,s.Question_gne__r.Title_gne__c, s.Response_Score_gne__c  from Survey_Response_gne__c s  where s.survey_gne__c=: survey_id and s.isdeleted=false];
        if(Answers.size() != 0)
        {
            correctAnswersList = new List<CorrectAnswers>();
            for(Survey_Response_gne__c survey_response:Answers)
            {
                CorrectAnswers ca = new CorrectAnswers();
                if(survey_response.Type_gne__c == 'Numeric')
                {
                    ca.Question = survey_response.Question_gne__r.Title_gne__c;
                    ca.Answer = String.valueOf(survey_response.Response_Score_gne__c);
                }
                else if(survey_response.Type_gne__c == 'Free Text')
                {
                   ca.Question = survey_response.Question_gne__r.Title_gne__c;
                 ca.Answer = String.valueOf(survey_response.Free_Text_gne__c);
                 }
                else
                {
                    ca.Question = survey_response.Question_gne__r.Title_gne__c;
                    ca.Answer = survey_response.Selected_Label_gne__c;
                }
                correctAnswersList.add(ca);
            }
        }
        return null;
    }
    
    public PageReference BackToQuestionnaires()
    {
        isAnswersListVisible = false;
        isQuestionariesListVisible = true;
        isUsersListVisible = false;
        SurveysList = null;
        Answers = null;
        return null;
    }
    
    /*public List<selectOption> product_list 
    {
    get 
    {
            List<selectOption> productsOptions = new List<selectOption>();
            productsOptions.add(new selectOption('', '--Select product--'));
        
            for (Product_vod__c lt : [Select p.Name, p.Id from Product_vod__c p  where p.Detail_Product_Subtype_Code_gne__c='Approved Product Indications' order by name]) 
            {
                productsOptions.add(new selectOption(lt.name, lt.name));
            }
            return productsOptions;   
    }
    set;
    }
    public String getproduct_name() { return product_name; }
    */
    private class CorrectAnswers
    {
        public String Question { get; set;}
        public String Answer { get; set;}
    }

}