public class GNE_MCCO_PFT_AccessMetrics_View_Section {
    
    public List<Questionnaire_gne__c> quest = new List<Questionnaire_gne__c>();

    public Survey_gne__c surv_1 = new Survey_gne__c();
    public List<Survey_gne__c> surv_list = new List<Survey_gne__c>();
    
    public List<Survey_Response_gne__c> surv_resp = new List<Survey_Response_gne__c>();
    public Boolean createNeeded = false;
    public String test_s ='';
    public List<Wrapper> m_list = new List<Wrapper>();
    map<String,Decimal> mapNewLabelForScore = new map<String,Decimal> ();       
    public Boolean error_Condition = false;
    public Boolean isEditMode = false;
    public List<String> selectedOption = new List<String>();
    public String AccountId = ApexPages.currentPage().getParameters().get('id');
    public Integer questListSize;
    
    
    public GNE_MCCO_PFT_AccessMetrics_View_Section (ApexPages.StandardController controller) {      
         system.debug('*****How many times am I here - 1st cons()');
            
             
    quest =[select Id from Questionnaire_gne__c where Ready_For_Use_gne__c = true and Category_gne__c ='Managed Care - Access Metrics' Order by CreatedDate desc limit 1];
     
     if(quest.size() > 0)
       surv_list=[select Title_gne__c, Id, LastModifiedDate, CreatedDate from Survey_gne__c where Questionnaire_gne__r.Id =:quest[0].Id and Account__c =:AccountId order by CreatedDate desc limit 1];
     else
       error_Condition = true;
     
     if (surv_List.size() > 0) 
       surv_1 = surv_list[0];
     else
       createNeeded = true;   
    
    }
    
    
    public GNE_MCCO_PFT_AccessMetrics_View_Section() {  
         system.debug('*****How many times am I here 2nd cons()');
         
     quest =[select Id from Questionnaire_gne__c where Ready_For_Use_gne__c = true and Category_gne__c ='Managed Care - Access Metrics' Order by CreatedDate desc limit 1];
     
     if(quest.size() > 0)
        surv_list=[select Title_gne__c, Id, LastModifiedDate, CreatedDate from Survey_gne__c where Questionnaire_gne__r.Id =:quest[0].Id and Account__c =:AccountId order by CreatedDate desc limit 1];
     else
       error_Condition = true;
     
     if (surv_List.size() > 0) 
     surv_1 = surv_list[0];
     else
     createNeeded = true;   
    
    }
    
    public void initiateData () {
     system.debug('*****How many times am I here initiaate');
        if (createNeeded == true){
          if(!error_condition){
              surv_1 =Assesment_WS.createSurveyFromAccount_mcco(quest[0].Id,AccountId,UserInfo.getUserId());
              
              List<QuestionnaireAccount_gne__c> qs = new List<QuestionnaireAccount_gne__c>([select id from QuestionnaireAccount_gne__c where Account__c =: AccountId]);
          
            if (qs.size() != 0) {
                QuestionnaireAccount_gne__c qs_x = new QuestionnaireAccount_gne__c();
            }
          }
        }
    
    }           
    
    public Survey_gne__c getSurveyInfo () {
        
        return  surv_1;
    }
    
    public List<Survey_Response_gne__c> getSurveyResponse () {
        
        return surv_resp;    
    }
    
    public List<Wrapper> getItems () {
        m_list.clear();
        mapNewLabelForScore.clear();
        String cur_cat;
        String prev_cat;
        questListSize = 0;
       system.debug('surv_1.Id: ' + surv_1.Id);
        //2606
      surv_resp = [select Help_text_gne__c, Response_Score_gne__c,Type_gne__c, Selected_Values_gne__c, Selected_Label_gne__c, Id, Values_gne__c, Category_gne__c, Full_Title_gne__c, Labels_gne__c, Title_gne__c, Survey_gne__c from Survey_Response_gne__c where Survey_gne__c =:surv_1.Id order by Position_gne__c];
      system.debug('Survey Resp size: '+surv_resp.size());

      for (Survey_Response_gne__c s_r : surv_resp) {
        Wrapper init = new Wrapper();
        List<String> ques_list = new List<String>();
        List<String> val_list = new List<String>();     
        
        if (prev_cat == null) {
            prev_cat = s_r.Category_gne__c;
            init.category = s_r.Category_gne__c;
        }
        else if (prev_cat != s_r.Category_gne__c) {
            prev_cat = s_r.Category_gne__c;
            init.category = s_r.Category_gne__c;
        }
        

            init.question = s_r.Title_gne__c;
            init.HelpText = s_r.Help_Text_gne__c;
            //2606
            if(s_r.Labels_gne__c != null && s_r.Labels_gne__c != '')
            ques_list = s_r.Labels_gne__c.split(',');
            system.debug('ques_list: ' + ques_list);     
            if(s_r.Values_gne__c != null && s_r.Values_gne__c != '')
            val_list = s_r.Values_gne__c.split(',');
            system.debug('val_list: ' + val_list);
            Integer rowCount = 0;
            If(s_r.Type_gne__c == 'List of Values'){
                rowCount = val_list.size();
            }else
            {
                if(val_list.size() < ques_list.size()){
                    rowCount = val_list.size();
                }
                else{
                    rowCount = ques_list.size();
                }
            }
            
            init.opts = new List<SelectOption>();
        
        

        for (Integer i=0; i<rowCount; i++) {
            //2606
            If(s_r.Type_gne__c == 'List of Values'){
                //2597
                mapNewLabelForScore.put(val_list[i].trim(),Decimal.valueOf(val_list[i].trim()));
                if (s_r.Selected_Label_gne__c != null && val_list[i].trim() != s_r.Selected_Label_gne__c.trim())
                init.opts.add(new SelectOption(val_list[i].trim(),val_list[i].trim()));
            }
            else{
                //2597
                mapNewLabelForScore.put(ques_list[i].trim(),Decimal.valueOf(val_list[i].trim()));
                if (s_r.Selected_Label_gne__c != null && ques_list[i].trim() != s_r.Selected_Label_gne__c.trim())
                init.opts.add(new SelectOption(ques_list[i].trim(),ques_list[i].trim()));         
            }
            
            if (s_r.Selected_Label_gne__c != null)
                init.defaultOp = new SelectOption(s_r.Selected_Label_gne__c,s_r.Selected_Label_gne__c);
            else
                init.defaultOp = new SelectOption('-None-','-None-');
        }                   
        
        m_list.add(init);
            
    

        }
     
        system.debug('Categroy List: '+m_list);
        questListSize = m_list.size();
        return m_list;
    
    }

    
    public class Wrapper {
        
        public String question {get; set;}
        public String category {get; set;}
        public String helpText {get; set;}
        public String selectedOption_x {get; set;}
        public SelectOption defaultOp {get; set;}
        public List<SelectOption> opts {get; set;}
    }
    
    public Integer getNumQuestions () {
        
        return questListSize;
    }
    
    public Boolean getError_Condition () {
        
        return error_condition;
    }
    
    public PageReference edit() {
        
        isEditMode = true;
        
        return null;
    
    }
    
    public PageReference cancel () {
        
        isEditMode = false;
        
        return null;
    }
    
    public Boolean getEditMode() {
        
        return isEditMode;
    }
    
    public void save() {

        for (Integer i =0; i<surv_resp.size(); i++) {
             surv_resp[i].Selected_Label_gne__c = m_list[i].selectedOption_x;
            //2597
            if(surv_resp[i].Selected_Label_gne__c != null){
                if(mapNewLabelForScore.containsKey(surv_resp[i].Selected_Label_gne__c.trim())){               
                    surv_resp[i].Response_Score_gne__c = mapNewLabelForScore.get(surv_resp[i].Selected_Label_gne__c.trim());
                    surv_resp[i].Selected_Values_gne__c = String.valueOf(mapNewLabelForScore.get(surv_resp[i].Selected_Label_gne__c.trim()));
                    
                }
            }
        }
            
        update surv_resp;
        isEditMode = false; 
    }
    
    
    
}