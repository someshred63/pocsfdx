public class GNE_MCCO_ScoreCard_Automation {
     private set<ID> users = new set<ID>();  
     private set<ID> redirectProfileIDs = new set<ID>();
     private Map<ID, List<ID>> usr_to_terr = new Map<ID, List<ID>>();
     private Map<ID,List<ID>> terr_to_groups = new Map<ID, List<ID>>();
     private Map<ID, set<ID>> groups_to_userAcc_map = new Map<ID, set<ID>>();
    private List<ID> accountIDs = new List<ID>();
    
    //Boolean to determine if in EditMode
    Boolean edit;
    public Boolean  isNull {get{if(m2_list.size() > 0){return false;}else if(m2_list == null || m2_list.size() == 0){return true;} return null;} set;}
    public Boolean  noMetrics {get; set;}
    
    //List to hold Access Accounts
    List<Account> accessAccounts = new List<Account>();
    //List to hold Contacts (External Relationships)
    public List<Contact> contacts {get; private set;}
    //public List<Internal_Relationship_gne__c> internalR {get; private set;}
    //List to Hold Surveys aka Access Metrics
    public List<Survey_gne__c> svs {get; private set;}
    //Boolean to Render Contact Section
    Boolean hasContacts;
    //Account Id to query for Access Metrics
    String ActId;
    public String AccountName {get; set;}
    //Wrapper List to Hold Survey info
    List<Wrapper> m_list = new List<Wrapper>();
    //Survey Respones
    List<Survey_Response_gne__c > surv_rps = new List<Survey_Response_gne__c>();
    //Boolean for SurveyEditMode
    Boolean surveyEdit = false;
    //Error Condition
    Boolean errorCondition = false;
    //Are there Relationship metrics?
    public Boolean hasMetrics {get; set;}
    //List of wrapper_2
    public List<Wrapper_2> m2_List {get; set;}
    //CreateList
    public List<Wrapper> createList {get; set;}
    //String Questionnaire Id
    String questId;
    //Questionnaire
    List<Questionnaire_gne__c> q = new List<Questionnaire_gne__c>();
    public Boolean initialSection {get; set;}
    
          
    public GNE_MCCO_ScoreCard_Automation() { 
        this.noMetrics = false;
        users.add(userinfo.getUserID());
        List<Environment_variables__c> env_list = [select key__c, value__c from environment_variables__C where key__c IN('sfdcID_GNE_MCCO_PFT_OPS','sfdcID_GNE_MCCO_PFT','sfdcID_GNE_MCCO_PFT_Manager') order By Id ];
        String GNE_MCCO_PFT_OPS =env_list[0].value__c;
        String GNE_MCCO_PFT =env_list[1].value__c;
        String GNE_MCCO_PFT_Manager =env_list[2].value__c;
        
        if(System.UserInfo.getProfileId().contains(GNE_MCCO_PFT_OPS)){
//         if(System.UserInfo.getProfileId().contains(GNE_MCCO_PFT_OPS)||System.UserInfo.getProfileId().contains(GNE_MCCO_PFT)||System.UserInfo.getProfileId().contains(GNE_MCCO_PFT_Manager)){
            accountIDs =  EM3_Calendar_util.accounts_PFTOps();
            System.debug('accountIDs PFT OPS: ' + accountIDs);
            //Code for 2571 starts
        }else if(System.UserInfo.getProfileId().contains(GNE_MCCO_PFT)||System.UserInfo.getProfileId().contains(GNE_MCCO_PFT_Manager)){
            //usr_to_terr =  EM3_Calendar_util.usr_to_terr(users);
            accountIDs = EM3_Calendar_util.fetchAccountOfChildTerrIDs(users);
            System.debug('accountIDs.size(): '+accountIDs.size());
            //Code for 2571 ends
        }else{
            usr_to_terr =  EM3_Calendar_util.usr_to_terr(users);
            System.debug('usr_to_terr: ' + usr_to_terr);
            
            terr_to_groups = EM3_Calendar_util.terr_to_groups();
            System.debug('terr_to_groups: ' + terr_to_groups);
            groups_to_userAcc_map = EM3_Calendar_util.groups_to_userAcc_map();
            System.debug('groups_to_userAcc_map: ' + groups_to_userAcc_map);
            for(set<ID> idSet : groups_to_userAcc_map.values()){
                for(ID accID : idSet){
                    accountIDs.add(accID);
                }
                System.debug('accountIDs: ' + accountIDs);
            }
        }
        
      //Grab all Contacts where owner=User @runtime 
        contacts = new List<Contact>([select Id, AccountId, account.name, Name, LastName, FirstName, Title, Phone, Email, MCL_Current_Depth_gne__c, MCL_Desired_Depth_gne__c, PFT_Depth_Current_gne__c, PFT_Depth_Desired_gne__c, MCL_Last_Interaction_Date_gne__c, PFT_Last_Interaction_Date_gne__c from Contact where OwnerId =:UserInfo.getUserId()ORDER by Account.Name, Name]);

      if (contacts.size() > 0)
      hasContacts=true;
      else
      hasContacts=false;
      
      //modify the below query so it returns where they are the manager or the account is in there territory
      //Grab all Accounts where AccountManager=User @runtime
      if([select count() from Questionnaire_gne__c where Category_gne__c='Managed Care - Access Metrics' AND Ready_for_use_gne__c = true] == 0){
            noMetrics = true;
      }
      if(System.UserInfo.getProfileId().contains(GNE_MCCO_PFT_OPS)||System.UserInfo.getProfileId().contains(GNE_MCCO_PFT)||System.UserInfo.getProfileId().contains(GNE_MCCO_PFT_Manager)){
        System.debug('PFT Profile:');
        accessAccounts = new List<Account>([select Id, RecordTypeId, Access_Account_x_gne__c, Name, (select lastmodifieddate from Surveys_gne__r where Questionnaire_gne__r.Ready_for_use_gne__c=true and Questionnaire_gne__r.Category_gne__c = 'Managed Care - Access Metrics' limit 1) from Account where Access_Account_x_gne__c =true AND (Account_Manager_gne__c =:UserInfo.getUserId() OR ID IN :AccountIDs) Order by Name]);
        System.debug('accessAccounts.size(): '+accessAccounts.size());
      }else{
        accessAccounts = new List<Account>([select Id, RecordTypeId, Access_Account_x_gne__c, Name, (select lastmodifieddate from Surveys_gne__r where Questionnaire_gne__r.Ready_for_use_gne__c=true and Questionnaire_gne__r.Category_gne__c = 'Managed Care - Access Metrics' limit 1) from Account where Access_Account_x_gne__c =true AND (Account_Manager_gne__c =:UserInfo.getUserId() OR ID IN :AccountIDs) Order by Name limit 20]);
      }
      //Get Related Surveys
      m2_list = new List<Wrapper_2>();
      for (Account a : accessAccounts){
        Wrapper_2 init_2 = new Wrapper_2();
        init_2.AccountId = a.Id;
        init_2.AccountN = a.Name;
        for (Survey_gne__c s : a.Surveys_gne__r){
            init_2.survLMD = s.LastModifiedDate.format();
        }
        system.debug('DATETIME: '+init_2.survLMD);
        m2_list.add(init_2);
                
      }
      
      
      
      
      
      //Internal Relationships
      //internalR = new List<Internal_Relationship_gne__c>([select id, name, Total_InteractionsMeetings_gne__c, LastmodifiedDate, createdbyId from Internal_Relationship_gne__c where ownerId=:UserInfo.getUserId()]);  
      
      //if (internalR.size() >0)
      //hasMetrics = true;
      //else
      //hasMetrics = false;   
      
    }

    public Boolean gethasContacts () {
        return hasContacts;
    }
    
    public String getuId() {
        return UserInfo.getUserId();
        
    }
    
    public void setActId (String a) {
        system.debug('I am setting: '+a);
        this.ActId = a;
        
        //Find AccountName
        for (Account a_x : accessAccounts) {
            if (a_x.Id == a)
            this.AccountName = a_x.Name;
        }
        system.debug('AccountName: '+AccountName);
    }
    
    public String getActId () {
        return ActId;
    }
    
          
    
    public List<Contact> getConts () {
        return contacts;       
    }
    
    public List<Account> getAccessAccounts () {
        return accessAccounts;
    } 
 
    public void Ed () {    
        edit = true;
    }
        
    public Boolean getEd() {   
        return edit;
     }    
   
                             
    public PageReference save () {
        edit = false;         
        update contacts;
        return null;
    }
        
        
        
    public void cancel () {
        edit = false;           
        }
        
    public class Wrapper {
        
        public Account accessA {get; set;}
        public String question {get; set;}
        public String questionId {get; set;}
        public String old_values {get; set;}
        public String old_labels {get; set;}
        public String category {get; set;}
        public String helpText {get; set;}
        public Double position {get; set;}
        public String selectedOption_x {get; set;}
        public SelectOption defaultOp {get; set;}
        public List<SelectOption> opts {get; set;}
    }
    
    public class Wrapper_2 {
        
        public Id accountId {get; set;}
        public String accountN {get; set;}
        public String survLMD {get; set;}
        
        
    }
    
    public PageReference viewMetrics () {
        surveyEdit=true;
        m_list = new List<Wrapper>();
        system.debug('AccountId: '+actId);
        system.debug('EditMode: '+surveyEdit);
        List<Survey_gne__c> surv_x = new List<Survey_gne__c>([select id, 
                                                    (select id,
                                                            Survey_gne__c,
                                                            Title_gne__c,   
                                                            Help_Text_gne__c,
                                                            Selected_Label_gne__c,
                            //2597 and 2606
                            Response_Score_gne__c,
                            Type_gne__c,
                            Selected_Values_gne__c,                                                         
                                                            Values_gne__c,
                                                            Labels_gne__c,
                                                            Position_gne__c from Survey_Responses_gne__r 
                                                            order by Position_gne__c)
                                                            from Survey_gne__c w
                                                            where Account__c =:ActId 
                                                            //and Type_gne__c ='Speaker Nomination Survey'
                                                            and Questionnaire_gne__r.Ready_for_use_gne__c=true
                                                            and Questionnaire_gne__r.Category_gne__c = 'Managed Care - Access Metrics']);
    if (surv_x.size() == 1) {
        surv_rps = surv_x[0].Survey_Responses_gne__r;
             for(Survey_Response_gne__c survR : surv_rps){
                Wrapper w = new Wrapper();
                system.debug('***Help Surveys:'+survR.Help_Text_gne__c);
                if(w.helpText != null){
                    w.helpText = String.EscapeSingleQuotes(survR.Help_Text_gne__c);
                }
                w.question = survR.Title_gne__c;
                w.position = survR.Position_gne__c;
                w.old_values = survR.Values_gne__c;
                w.old_labels = survR.Labels_gne__c;
                if (survR.Selected_Label_gne__c !=null && survR.Selected_Label_gne__c != '')
                 w.defaultOp = new SelectOption(survR.Selected_Label_gne__c,survR.Selected_Label_gne__c); 
                else
                 w.defaultOp = new SelectOption('','');
   
                List<String> answers_labels = new List<String>();
                if(survR.Labels_gne__c != null && survR.Labels_gne__c != '')
                answers_labels = survR.Labels_gne__c.split(',');
                List<String> answers_values = new List<String>();
                if(survR.Values_gne__c != null && survR.Values_gne__c != '')
                answers_values = survR.Values_gne__c.split(',');                            
                
                w.opts = new List<SelectOption>();

                Integer rowCount = 0;
                If(survR.Type_gne__c == 'List of Values'){
                    rowCount = answers_values.size();
                    answers_labels = answers_values;
                }else
                {
                    if(answers_labels.size() < answers_values.size()){
                        rowCount = answers_labels.size();
                    }
                    else{
                        rowCount = answers_values.size();
                    }
                }
                
                for (Integer i=0; i<rowCount; i++) {
                    if (answers_labels[i].trim() != w.defaultOp.getLabel().trim()){
                        w.opts.add(new SelectOption(answers_labels[i],answers_labels[i]));
                    }
                }

                m_list.add(w);
                
             } 
        }
        else {}     
        system.debug('List made: '+m_list);
        
        PageReference pageRef = ApexPages.currentPage();
        //pageRef.setRedirect(true);
        
        return null;
    }
    
    public PageReference createMetrics () {
        
        //List<Questionnaire_gne__c> questId_x = new List<Questionnaire_gne__c>([select id from Questionnaire_gne__c where Category_gne__c ='Managed Care - Access Metrics' and ready_for_use_gne__c = true]);
        
        createList = new List<Wrapper>();
        q=[Select q.Category_gne__c, q.Id, 
                   q.Name, q.Show_Questions_Position_gne__c,
                   q.Type_gne__c,
                   (Select Category_gne__c, Help_Text_gne__c, Id, Maximum_Score_gne__c, 
                           Minimum_Score_gne__c, Position_gne__c, Title_gne__c, 
                           Type_gne__c, Values_gne__c, Labels_gne__c, Weight_gne__c From Questions__r order by Position_gne__c) 
                   from Questionnaire_gne__c q where q.Category_gne__c ='Managed Care - Access Metrics' and q.ready_for_use_gne__c = true];
            
            if (q.size() == 1){
                system.debug('I am in create and we made it to first loop');
                 for(Question_gne__c quest:q[0].Questions__r){
                    Wrapper w = new Wrapper();
                    system.debug('***Help Question:'+quest.Help_Text_gne__c);
                    if(w.helptext != null){
                        w.helpText = String.EscapeSingleQuotes(quest.Help_Text_gne__c);
                    }
                    w.question = quest.Title_gne__c;
                    w.position = quest.Position_gne__c;
                    w.old_values = quest.Values_gne__c;
                    w.old_labels = quest.Labels_gne__c;
                    w.questionId = quest.Id;
                    List<String> answers_labels = new List<String>();
                    if(quest.Labels_gne__c != null && quest.Labels_gne__c != '')
                    answers_labels = quest.Labels_gne__c.split(',');
                    
                    
                    List<String> answers_values = new List<String>();
                    if(quest.Values_gne__c != null && quest.Values_gne__c != '')
                    answers_values = quest.Values_gne__c.split(',');
                
                    system.debug('answers_labels: '+answers_labels.size());
                    system.debug('answers_values: '+answers_values.size());
                    
                    w.opts = new List<SelectOption>();
                    
                    Integer rowCount = 0;
                    If(quest.Type_gne__c == 'List of Values'){
                        rowCount = answers_values.size();
                        answers_labels = answers_values;
                    }else
                    {
                        if(answers_labels.size() < answers_values.size()){
                            rowCount = answers_labels.size();
                        }
                        else{
                            rowCount = answers_values.size();
                        }
                    }
                    
                    for (Integer i=0; i<rowCount; i++) {   
                        w.opts.add(new SelectOption(answers_labels[i],answers_labels[i]));
                    }
                    
                    createList.add(w);
                    system.debug('W: '+w.opts);
                 }
            initialSection=true;
            }
            else{
                //Too many Active Surveys - this case is handeled by JS Questionnaire creation
            }
        PageReference pageRef = ApexPages.currentPage();
        //pageRef.setRedirect(true);
        
        return pageRef;
        
    }
    
    public List<Wrapper> getM_list () {
        return m_list;
    }
    
    public Boolean getSurveyEdit () {
        system.debug('I am getting SurvEdit: '+surveyEdit);
        return this.SurveyEdit;
    }
    
    public void markSurveyEdit () {
        this.SurveyEdit = true;
    } 
       
    public void cancelSurveyEdit () {
        this.SurveyEdit = false;
        this.errorCondition = false;
    }
    public void cancelInitialCreate () {
        this.SurveyEdit = false;
        this.initialSection = false;
        this.errorCondition = false;
    }
    public Boolean getErrorCondition (){
        return ErrorCondition;
    }
    
    //2597
    static  Decimal getScore(String Labels, String Scores, String selectedLabel){
        Decimal defaultScore = 0;
        
        List<String> labelLst = new List<String>();
        if(Labels != null && Labels!= '')
        labelLst = Labels.split(',');       
        
        List<String> scoreLst = new List<String>();
        if(Scores != null && Scores != '')
        scoreLst = Scores.split(',');
        
        Integer rowCount = 0;
        if(labelLst.size() < scoreLst.size()){
            rowCount = labelLst.size();
        }
        else{
            rowCount = scoreLst.size();
        }       
        map<String,Decimal> mapNewLabelForScore = new map<String,Decimal> ();       
        for(Integer i=0; i<rowCount; i++){
                mapNewLabelForScore.put(labelLst[i],Decimal.valueOf(scoreLst[i]));
        }
        if(mapNewLabelForScore.containsKey(selectedLabel)){               
            defaultScore = mapNewLabelForScore.get(selectedLabel);
        }
        return defaultScore;        
}
    
    public PageReference updateSurvey () {
    Survey_gne__c s = new Survey_gne__c();
        for (Integer i =0; i<surv_rps.size(); i++) {
            
    //Need to update LastModifiedDate correctly on Survey
            if(i==0)
            s = new Survey_gne__c(id=surv_rps[i].Survey_gne__c);
            
            surv_rps[i].Selected_Label_gne__c = m_list[i].selectedOption_x;
            //2597
            if(surv_rps[i].Type_gne__c=='Numeric' || surv_rps[i].Type_gne__c=='List of Values'){
                if(surv_rps[i].Selected_Label_gne__c != null){
                    surv_rps[i].Response_Score_gne__c = Decimal.valueOf(surv_rps[i].Selected_Label_gne__c);
                    surv_rps[i].Selected_Values_gne__c = surv_rps[i].Selected_Label_gne__c;
                }
            }
            else{
                if(surv_rps[i].Selected_Label_gne__c != null){
                    surv_rps[i].Response_Score_gne__c = getScore(surv_rps[i].Labels_gne__c,surv_rps[i].Values_gne__c,surv_rps[i].Selected_Label_gne__c);
                    surv_rps[i].Selected_Values_gne__c = String.valueOf(surv_rps[i].Response_Score_gne__c);
                }
            }
        }
        system.debug('***s_1: '+s);
        update surv_rps;
        system.debug('***s_12: '+s);
        //Ensure lastmodifieddate is updated
        if(s.id != null){
            system.debug('***s: '+s);
            update s;
            
        }
        
        
        this.SurveyEdit = false;
        
        PageReference pageRef = new PageReference('/apex/GNE_MCCO_Balanced_ScoreCard');
        pageRef.setRedirect(true);
        return pageRef;
    }   
    
     public pageReference create_srps() {
                   

        system.debug('WHAT: '+q);                   
        Survey_gne__c surv=new Survey_gne__c();
        surv.Account__c=ActId;
        //surv.Title_gne__c =q[0].Type_gne__c;
        surv.Questionnaire_gne__c=q[0].id;
        insert surv;
        List<Survey_Response_gne__c> survResps=new List<Survey_Response_gne__c>();
        for(Wrapper w_x : createList){
            Survey_Response_gne__c survResp=new Survey_Response_gne__c();
            survResp.Survey_gne__c=surv.Id;
            survResp.Title_gne__c=w_x.question;
            system.debug('***Help Wrapper:'+w_x.helpText);
            if(survResp.Help_Text_gne__c != null){
                survResp.Help_Text_gne__c = String.EscapeSingleQuotes(w_x.helpText);
            }
            survResp.Position_gne__c = w_x.position;
            survResp.Values_gne__c = w_x.old_values;
            survResp.Labels_gne__c = w_x.old_labels;
            survResp.Type_gne__c = 'Labels and Values';
            survResp.Question_gne__c= w_x.QuestionId;
            survResp.Selected_Label_gne__c = w_x.selectedOption_x;
            //2597
            if(survResp.Selected_Label_gne__c != null){
                survResp.Response_Score_gne__c = getScore(survResp.Labels_gne__c,survResp.Values_gne__c,survResp.Selected_Label_gne__c);
                survResp.Selected_Values_gne__c = String.valueOf(survResp.Response_Score_gne__c);
            }
            
            survResps.add(survResp);
        }
        insert survResps; 
        
        this.SurveyEdit = false;
        this.initialSection = false;
        this.errorCondition = false;
            
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;
        
        
    }
}