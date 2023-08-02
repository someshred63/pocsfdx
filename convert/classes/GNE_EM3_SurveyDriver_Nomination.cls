public with sharing class GNE_EM3_SurveyDriver_Nomination {
        
        String accountId;
        String bureauId;
        String Userid;
        String sbm_id;
        String createCase;
        Boolean errorCondition;
        Boolean editMode;
        String curCat;
        String retURL;
        String profileName;
        //Survey_gne__c surv_del;
        String questId;
        String burCat;
        List<Wrapper> initial_list = new List<Wrapper>();
        Questionnaire_gne__c q = new Questionnaire_gne__c();
        Boolean surveyEdit =false;
        List<Survey_Response_gne__c> surv_rps = new List<Survey_Response_gne__c>();
        
        List<Membership_Contracts_gne__c> contracts = new List<Membership_Contracts_gne__c>();
        Integer conSize;
        
        //Added by Claudia M on 9/29
        List<Member_Trainings_gne__c> trainings = new List<Member_Trainings_gne__c>();
        Integer trnSize;
        
        String errorMessage;
        
        
        public Speaker_Bureau_Membership_gne__c SBM {get; set;}
        public Survey_gne__c survey {get; set;}
        public Survey_Response_gne__c survResp {get; set;}
        public Boolean noSurveyNeeded {get; set;}
        public Boolean hasSurvey {get; set;}
        public Boolean isSFA {get; set;}
        
        //Added by Michał Szewczyk on 11/24/2010
        //START (M&E Req 00002791)
        
        public List<String> getMasterTitles()
        {
            List<String> strlist = new List<String>();
            AggregateResult[] groupedResults = [Select s.Category__c From Speaker_Bureau_Description_Config_gne__c s where s.Active__c = true Group by Category__c ];
            
            for (AggregateResult ar : groupedResults)  {
                   strlist.add((string)ar.get('Category__c'));
            }
            
            return strlist;

        }
        public List<wrapperObject > getDescriptions()
        {
            List<Speaker_Bureau_Description_Config_gne__c> des = [Select s.Subcategory__c,s.Description__c, s.Category__c, s.Active__c From Speaker_Bureau_Description_Config_gne__c s Where s.Active__c = true ORDER BY s.Category__c,s.Order_of_Appearance__c];
            List<wrapperObject> wrapObj = new List<wrapperObject>();
            for(Speaker_Bureau_Description_Config_gne__c ds : des)
            {
                ds.Description__c = ds.Description__c.replace('•','<BR/>•');
                wrapperObject tmpwrapObj = new wrapperObject();
                tmpwrapObj.Category = ds.Category__c;
                tmpwrapObj.Subcategory = ds.Subcategory__c;
                tmpwrapObj.Description = ds.Description__c;
                
                wrapObj.add(tmpwrapObj);
                
            }
            
            return wrapObj;
        }
        
        
        public class wrapperObject
        {
            public String Subcategory{get;set;}
            public String Description{get;set;}
            public String Category{get;set;}
       
        }
        //END (M&E Req 00002791)
        
        public GNE_EM3_SurveyDriver_Nomination (ApexPages.StandardController controller) {
            isSFA = false;
            
            //Are we coming from Nomination button?
            createCase = ApexPages.currentPage().getParameters().get('create_flag');
            system.debug('createCase : ' + createCase);
            if(createCase=='0')
            noSurveyNeeded=true;
            else
            noSurveyNeeded=false;
            
            //URL Params from Nomination button
            accountId = ApexPages.currentPage().getParameters().get('act_id');
            bureauId = ApexPages.currentPage().getParameters().get('spb_id');
            system.debug('accountId : ' + accountId);
            system.debug('bureauId : ' + bureauId);
            //Run-Time User
            userId =userInfo.getUserId();
            system.debug('userId : ' + userId);
            //Return URL
            retURL = ApexPages.currentPage().getParameters().get('retURL');
        }
        
        public void getContent () {
            String profileName = [select ID, Name from Profile where ID = :userinfo.getProfileId()].Name;
            if(profileName.startswith('GNE-SFA') && !profileName.startsWithIgnoreCase('GNE-SFA-OPS') )
            {
                if(profileName.startsWith('GNE-SFA-CC') || profileName.startswith('GNE-SFA-OCC')){ isSFA = false;} 
                else isSFA = true;
            }
            else isSFA = false;         
            system.debug('isSFA : ' + isSFA);
            initial_list.clear();
            if (createCase == '1' || createCase == '0'){
                editMode = true;
                if (accountId != null && bureauId != null) {
                    errorCondition = false;
                   
                    //RecType ID for SpeakerNomination Surveys  
                    Id recType = Schema.SObjectType.Questionnaire_gne__c.getRecordTypeInfosByName().get('Speaker Nomination Survey').getRecordTypeId();     
                    burCat = [select Speaker_Category_gne__c from Speaker_Bureau_gne__c where id =:bureauId].Speaker_Category_gne__c;
                    system.debug('$$$BurCat: '+burCat);
                    List<Questionnaire_gne__c> questId_x = new List<Questionnaire_gne__c>([select id from Questionnaire_gne__c where Category_gne__c =:burCat and ready_for_use_gne__c = true]);
                    system.debug('&&&quetId: '+questId);
                    if (questId_x.size() == 1){ 
                        questId = questId_x[0].Id;
                        surveyEdit = true;
                        errorCondition = false;
                                               
                        //Setup SBM
                        SBM = new Speaker_Bureau_Membership_gne__c();
                        SBM.Speaker_Status_gne__c = 'Nominated';
                        SBM.Bureau_Member_gne__c = accountId;
                        SBM.Speaker_Bureau_ID_gne__c = bureauId;
                        if(accountId != null || accountId !='') {
                             String classification = [Select Classification_gne__c  from Account where Id =:accountId].Classification_gne__c ;
                             if(classification != null && (classification != 'Local' && classification != 'Global')) {
                                SBM.Speaker_Scope_gne__c = classification;
                             }
                             else if(classification == 'Local') {
                                SBM.Speaker_Scope_gne__c = 'Community' ;
                             }
                             else if(classification == 'Global') {
                                SBM.Speaker_Scope_gne__c = 'National' ;
                             }
                        }
                        //SBM.Speaker_Category_gne__c; 
                        //SBM.Nominated_By_gne__c = userId;
                        SBM.Nomination_Date_gne__c = system.now();          
         
                        //Setup Variable for display (since Formula fields are evaluated at Query Time)
                        curCat = burCat;
                    
                        if (createCase == '1') {
                            q=[Select q.Category_gne__c, q.Id, 
                                   q.Name, q.Show_Questions_Position_gne__c,
                                   q.Type_gne__c,
                                   (Select Category_gne__c, Help_Text_gne__c, Id, Maximum_Score_gne__c, 
                                           Minimum_Score_gne__c, Position_gne__c, Title_gne__c, 
                                           Type_gne__c, Values_gne__c, Labels_gne__c, Weight_gne__c From Questions__r order by Position_gne__c) 
                                   from Questionnaire_gne__c q where q.ID=:questid];
                            
                             for(Question_gne__c quest:q.Questions__r){
                                Wrapper w = new Wrapper();
                                w.helpText = quest.Help_Text_gne__c;
                                w.question = quest.Title_gne__c;
                                w.position = quest.Position_gne__c;
                                w.old_values = quest.Values_gne__c;
                                w.old_labels = quest.Labels_gne__c;
                                w.questionId = quest.Id;
                                
                                List<String> answers_labels = new List<String>();                               
                                if (quest.Labels_gne__c !=null) {
                                    answers_labels = quest.Labels_gne__c.split(',');
                                }
                                                                                                
                                List<String> answers_values = new List<String>();
                                if (quest.Values_gne__c != null) {
                                    answers_values = quest.Values_gne__c.split(',');
                                }                            
                                
                                w.opts = new List<SelectOption>();
                                w.opts.add(new SelectOption('-None-','-None-'));
                                
                                for (Integer i=0; i<answers_labels.size(); i++) {   
                                    w.opts.add(new SelectOption(answers_labels[i],answers_labels[i]));
                                }
                                
                                initial_list.add(w);
                                
                             }  
                        }                              
                    
                    }
                    else {                      
                        //Questionnaire Type DNE
                        if (questId_x.size() > 1) {
                            errorMessage ='There are multiple active Questionnaires for this Bureau Category. Please contact your manager for support.';
                            errorCondition = true;
                        }
                        if (questId_x.size() < 1){
                            errorMessage ='There are no active Questionnaires.';
                            errorCondition = true;
                        }   
                    }
                }
                else {
                    //Bad URL Passed
                    errorMessage='An internal error has occured. Please contact the administrator for support.';
                    errorCondition = true;
                }
            }
            //View Case
            else {
                system.debug('I made it into SPECIAL ELSE');          
                //This means we are in View Mode (not coming from Nomination Button)               
                editmode=false;               
                sbm_id = ApexPages.currentPage().getParameters().get('id');
                
                Speaker_Bureau_Membership_gne__c s_x = [select Bureau_Member_gne__c, Speaker_Bureau_ID_gne__c, Speaker_Category_gne__c from Speaker_Bureau_Membership_gne__c where id=:sbm_id];
                
                List<Survey_gne__c> surv_x = new List<Survey_gne__c>([select id, 
                                                            (select id,
                                                                    Title_gne__c,   
                                                                    Help_Text_gne__c,
                                                                    Selected_Label_gne__c,
                                                                    Values_gne__c,
                                                                    Labels_gne__c,
                                                                    Position_gne__c from Survey_Responses_gne__r 
                                                                    order by Position_gne__c)
                                                                    from Survey_gne__c w
                                                                    where Account__c =:s_x.Bureau_Member_gne__c 
                                                                    //and Type_gne__c ='Speaker Nomination Survey'
                                                                    and Speaker_Nomination_Category_gne__c =:s_x.Speaker_Category_gne__c
                                                                    and Questionnaire_gne__r.Ready_for_use_gne__c=true
                                                                    and Speaker_Bureau_gne__c =:s_x.Speaker_Bureau_ID_gne__c ]);
                                                                    
                if (surv_x.size() == 1) {
                    hasSurvey=true;
                    surv_rps = surv_x[0].Survey_Responses_gne__r;
                     for(Survey_Response_gne__c survR : surv_rps){
                        Wrapper w = new Wrapper();
                        w.helpText = survR.Help_Text_gne__c;
                        w.question = survR.Title_gne__c;
                        w.position = survR.Position_gne__c;
                        w.old_values = survR.Values_gne__c;
                        w.old_labels = survR.Labels_gne__c;
                        if(survR.Selected_Label_gne__c != null && survR.Selected_Label_gne__c != null)
                            w.defaultOp = new SelectOption(survR.Selected_Label_gne__c,survR.Selected_Label_gne__c); 
            
                        List<String> answers_labels = new List<String>();
                        List<String> answers_values = new List<String>();
                        
                        //need to catch exception here if there is a question of type = Number, or only one possible answer
                        //added null checking Łukasz Kwiatkowski 11/10/2011
                        if(survR.Labels_gne__c != null) {
                            answers_labels = survR.Labels_gne__c.split(',');
                        }
                        if(survR.Values_gne__c != null) {
                            answers_values = survR.Values_gne__c.split(',');
                        }    
                            
                        w.opts = new List<SelectOption>();
                     
                        for (Integer i=0; i<answers_labels.size(); i++) {   
                            system.debug('checking....'+answers_labels[i]);
                            
                            if (w.defaultOp != null && answers_labels[i].trim() != w.defaultOp.getLabel().trim()){
                                system.debug('versus...'+w.defaultOp.getLabel());
                                system.debug('They are not EQUAL');
                                w.opts.add(new SelectOption(answers_labels[i],answers_labels[i]));
                            }
                        }
                        system.debug('What: '+w.defaultOp);
                        system.debug('Whatx2: '+w.opts);
                        initial_list.add(w);
                        
                        

                        
                        
                        
                     } 
                }
                else {
                    //More than one Survey for this type exists!
                    if (surv_x.size() > 1) {
                    errorMessage ='Multiple Surveys exist for this Speaker at this Bureau. Please contact your manager for support.';
                    errorCondition=true;
                    }
                    if (surv_x.size() < 1)
                    hasSurvey=false;    
                    
                }                                                               
                                                         
                contracts = [select Speaker_Contract_gne__c, Contract_Start_Date_gne__c, End_Date_gne__c from Membership_Contracts_gne__c where Speaker_Bureau_Membership_gne__c =:s_x.Id order by Contract_Start_Date_gne__c desc];                                          
                conSize = contracts.size();
                
                //Added by Claudia M on 9/29
                trainings = [select Curriculum_gne__c, Date_Trained_gne__c, Expiration_Date_gne__c,Speaker_Training_gne__r.Status_gne__c,Speaker_Training_gne__r.Curriculum_Status1__c ,Speaker_Training_gne__c,Speaker_Training_gne__r.Delivery_Method_gne__c from Member_Trainings_gne__c where Speaker_Bureau_Membership_gne__c =:s_x.Id order by Date_Trained_gne__c desc];                                       
                trnSize = trainings.size();
            }
    
        }
    
        public Boolean getErrorCondition () {
            return this.errorCondition;
        }
        
        public List<Membership_Contracts_gne__c> getContracts () {
            return contracts;
        }
        //Added by Claudia M on 9/29
        public List<Member_Trainings_gne__c> getTrainings () {
            return trainings;
        }
        
        public Integer getConSize() {
            return conSize;
        }
                
        public Integer gettrnSize() {
            return trnSize;
        }
        
        public String getErrorMessage () {
            return this.ErrorMessage;
        }        
        public Boolean geteditMode () {
            return this.editMode;
        }
        
        public String getAccountId () {
            return this.AccountId;
        }

        public String getBureauId () {
            return this.BureauId;
        }
        
        public String getCurCat () {
            return this.CurCat;
        }
        public String getRetUrl () {
            return this.RetUrl;
        }
        public Boolean getSurveyEdit () {
            return this.SurveyEdit;
        }
        public void markSurveyEdit () {
            this.SurveyEdit = true;
        }
        public void cancelSurveyEdit () {
            this.SurveyEdit = false;
        }
        public void updateSurvey () {
            try {        
                for (Integer i =0; i<surv_rps.size(); i++) {
                     surv_rps[i].Selected_Label_gne__c = initial_list[i].selectedOption_x;      
                }
                
                update surv_rps;
                this.SurveyEdit = false;
            }
            catch(exception e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                //return null;
            }
        }       
        public class Wrapper {
            
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
        
        public List<Wrapper> getinitial_list () {
            return this.initial_list;
        }           

        public pageReference save() {          
          if(noSurveyNeeded == false){
            system.debug('WHAT: '+q);                   
            Survey_gne__c surv=new Survey_gne__c();
            surv.Speaker_Nomination_Category_gne__c =burCat;
            surv.Account__c=accountId;
            surv.Type_gne__c ='Speaker Nomination Survey';
            //surv.Medical_Event_gne__c=medicalEventId;
            surv.Speaker_Bureau_gne__c=bureauId;
            //surv.Speaker_Bureau_Membership_gne__c=[select id from Speaker_Bureau_Membership_gne__c where Speaker_Bureau_ID_gne__c =:burId and Bureau_Member_gne__c =:actId limit 1 ].Id;
            //surv.Speaker_Bureau_Member_Name_gne__c=actId;
            surv.Questionnaire_gne__c=questid;
            //surv.Title_gne__c = q.Type_gne__c;
            insert surv;
            List<Survey_Response_gne__c> survResps=new List<Survey_Response_gne__c>();
            for(Wrapper w_x : initial_list){
                Survey_Response_gne__c survResp=new Survey_Response_gne__c();
                survResp.Survey_gne__c=surv.Id;
                survResp.Title_gne__c=w_x.question;
                survResp.Help_Text_gne__c = w_x.helpText ;
                //survResp.Minimum_Score_gne__c = quest.Minimum_Score_gne__c;
                //survResp.Maximum_Score_gne__c = quest.Maximum_Score_gne__c;
                //survResp.Weight_gne__c =  quest.Weight_gne__c ;
                survResp.Position_gne__c = w_x.position;
                //survResp.Category_gne__c = quest.Category_gne__c;
                survResp.Values_gne__c = w_x.old_values;
                survResp.Labels_gne__c = w_x.old_labels;
                survResp.Type_gne__c = 'Labels and Values';
                //survResp.Type_gne__c = quest.Type_gne__c;
                survResp.Question_gne__c= w_x.QuestionId;
                survResp.Selected_Label_gne__c = w_x.selectedOption_x;
                system.debug('***********SURV-RESP: '+w_x.selectedOption_x);
                
                survResps.add(survResp);
            }
            insert survResps; 
          }
            insert SBM;
            
            // check that Account for new SBM has interaction using Curriculum from SB to create Curriculum Trainings records
            List<Member_Trainings_gne__c> MemberTrainings = new List<Member_Trainings_gne__c>();    
            //Get all TR for account
            List<Speaker_Training_gne__c> SpeakerTRs = [Select Id,Event_Curriculum_gne__c, Event_Curriculum_gne__r.Id, Speaker_gne__c from Speaker_Training_gne__c where Speaker_gne__c =:accountId]; 
            // Get all curriculum that exist below Bureau
            List<Speaker_Bureau_gne__c> bureau =[Select Id, (Select Event_Curriculum_gne__c From Curriculum_Speaker_Bureau_s__r) from Speaker_Bureau_gne__c s where Id=: bureauId];
            
            for(Speaker_Training_gne__c tmspTr : SpeakerTRs)
            {
                if(bureau != null && bureau.size() == 1)
                {
                    for(Curriculum_Speaker_Bureau_gne__c  eventCurrTmp : bureau[0].Curriculum_Speaker_Bureau_s__r)
                    {
                        if(tmspTr.Event_Curriculum_gne__c == eventCurrTmp.Event_Curriculum_gne__c)
                        {
                            // create Curriculum trainings 
                            Member_Trainings_gne__c MemberTraining = new Member_Trainings_gne__c();
                            MemberTraining.Speaker_Bureau_Membership_gne__c = SBM.Id;
                            MemberTraining.Speaker_Training_gne__c = tmspTr.Id;
                            MemberTrainings.add(MemberTraining);
                        }
                    }
                }
            }
            
            insert MemberTrainings;
            
            
            editMode=false;
            PageReference pageRef = new PageReference('/'+sbm.id);
            system.debug('I am here: '+pageRef);
            return pageRef;
            
            
        }
        
}