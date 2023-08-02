public without sharing class EDM_SB_Nomination_Ext {
    
    String accountId;
    String bureauId;
    String Userid;
    String sbm_id;
    Boolean errorCondition;
    Boolean editMode;
    String curCat;
    String retURL;
    //Survey_gne__c surv_del;
    String questId;
    String burCat;
    public String accProfType { get; private set; }

    List<Wrapper> initial_list = new List<Wrapper>();
    Questionnaire_gne__c q = new Questionnaire_gne__c();

    List<Survey_Response_gne__c> surv_rps = new List<Survey_Response_gne__c>();
    
    String errorMessage;
    
    
    public Speaker_Bureau_Membership_gne__c SBM {get; set;}
    public Survey_gne__c survey {get; set;}
    public Survey_Response_gne__c survResp {get; set;}
    public Boolean noSurveyNeeded {get; set;}
    public Boolean hasSurvey {get; set;}
    public Boolean multiple{get;set;}
    public Boolean multiPatientAmbassadorNomination { get; private set; }
    public String returnSBMIds{get;set;}
    public Set<String> sbmids{get;set;}
    private Set<String> allAccounts;
    private List<String> acc;
    private Boolean showConfirmationPopup;
    private String confirmationText = '';
    private String redirURL = '';
    private Boolean showOkPopup = false;
    private Boolean blockPage = false;

    
    public EDM_SB_Nomination_Ext(ApexPages.StandardController controller) {
        //Are we coming from Nomination button?
        noSurveyNeeded=false;

        multiPatientAmbassadorNomination = false;

        try{
            multiple = Boolean.valueOf(ApexPages.currentPage().getParameters().get('multiple'));
        }catch(Exception e){
            System.debug('Single Nomination');
            multiple=false;
        }
        bureauId = ApexPages.currentPage().getParameters().get('spb_id');
        //URL Params from Nomination button
        if(multiple){
            returnSBMIds='';
            returnSBMIds+='='+ApexPages.currentPage().getParameters().get('retBureau')+'&parentObjectName=Speaker_Bureau_gne__c&parentRecordType='+ApexPages.currentPage().getParameters().get('parentRecordType');
            Map<String,String> paramsMap = new Map<String,String>(ApexPages.currentPage().getParameters());
            sbmIds = new Set<String>();
            String wrapperId = ApexPages.currentPage().getParameters().get('wrapperId');
            if(wrapperId!=null && wrapperId!=''){
                returnSBMIds+='&wrapperId='+wrapperId;
                try{
                    sbmIds = new Set<String>([Select EDM_Multiple_Nomination_Ids__c from EDM_Multiple_Nomination_Wrapper__c where id = :wrapperId].EDM_Multiple_Nomination_Ids__c.split(';'));
                } catch(Exception e){
                    System.debug('Wrapper not found! '+e);
                    sbmIds=new Set<String>();
                }
            } else sbmIds=new Set<String>();

            

            //Getting accounts for which exclsion request must be created
            List<Speaker_Bureau_Membership_gne__c> sbmList = new List<Speaker_Bureau_Membership_gne__c>([Select Bureau_Member_gne__c From Speaker_Bureau_Membership_gne__c
                                                                                                             where id in :sbmIds]);
            allAccounts = new Set<String>();
            for(Speaker_Bureau_Membership_gne__c sbm : sbmList){
                allAccounts.add(sbm.Bureau_Member_gne__c);
            }

            List<Account> accountsToRequestExcusion = new List<Account>([Select Id,AGS_EX_Exclusion_Status_base_gne__c from Account where AGS_EX_Exclusion_Status_base_gne__c='Not checked' and id in :allAccounts]);
            acc = new List<String>();
            for(Account a : accountsToRequestExcusion){
                acc.add(a.Id);
            }

            if (countOfSpeakers == '0') {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'All of the selected members are already included in the target bureau.'));
            }

        } else {
            accountId = ApexPages.currentPage().getParameters().get('act_id');
            

            system.debug('accountId : ' + accountId);
            system.debug('bureauId : ' + bureauId);
            //Run-Time User
            userId =userInfo.getUserId();
            system.debug('userId : ' + userId);
            //Return URL
            retURL = ApexPages.currentPage().getParameters().get('retURL');

            retrieveExclusionAndClassificationStatus();
            
            /*if (ApexPages.currentPage().getParameters().get(WE_ARE_RETURNING_FROM_CLASSIFICATION_REQUEST) == '1') {
                if (EDM_Classification_Utils.checkIfPendingClassificationRequest(accountId, speakerBureauType)) {
                    popupType = 'Classification Request Pending';
                }
            }*/
        }

        
        Speaker_Bureau_gne__c bureau = [select Name,Speaker_Bureau_Type_gne__c from Speaker_Bureau_gne__c where id = :bureauId];
        speakerBureauType = bureau.Speaker_Bureau_Type_gne__c;
        speakerBureauName = bureau.Name;

        if (speakerBureauType == null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Speaker_Bureau_Type_gne__c is null'));
        }
    }
    
    private Boolean isMultiPatientAmbassadorNomination() {
        return multiple && (sbmids.size() == [SELECT Id, 
                                                Bureau_Member_gne__r.Professional_Type_gne__c
                                              FROM 
                                                Speaker_Bureau_Membership_gne__c 
                                              WHERE 
                                                Id IN :sbmids AND
                                                Bureau_Member_gne__r.Professional_Type_gne__c = 'Patient Ambassador'].size());
    }

    public void getContent () {
        initial_list.clear();
        
        String createCase = '1';

        if (createCase == '1' || createCase == '0'){
            editMode = true;
            if ((accountId != null || multiple) && bureauId != null) {
                errorCondition = false;
               
                //RecType ID for SpeakerNomination Surveys  
                Id recType = Schema.SObjectType.Questionnaire_gne__c.getRecordTypeInfosByName().get('Speaker Nomination Survey').getRecordTypeId();     
                burCat = [select Speaker_Category_gne__c from Speaker_Bureau_gne__c where id =:bureauId].Speaker_Category_gne__c;
                if(accountId != null) {
                    accProfType = [SELECT Professional_Type_gne__c FROM Account WHERE Id =:accountId].Professional_Type_gne__c;
                }

                if (isMultiPatientAmbassadorNomination()) {
                    accProfType = 'Patient Ambassador';
                    multiPatientAmbassadorNomination = true;
                }

                if(String.isBlank(burCat)){
                    burCat = 'Managed Care';
                }
                List<Questionnaire_gne__c> questId_x = new List<Questionnaire_gne__c>();
                if(accProfType != null) {
                    questId_x = [SELECT Id FROM Questionnaire_gne__c WHERE Category_gne__c =:accProfType AND ready_for_use_gne__c = true];
                }

                if (questId_x.size() == 0) {
                    questId_x = [SELECT Id FROM Questionnaire_gne__c WHERE Category_gne__c = 'Managed Care' AND ready_for_use_gne__c = true];
                }
                
                if (questId_x.size() == 1){ 
                    questId = questId_x[0].Id;
                    errorCondition = false;
                    
                    if(!multiple){                       
                        //Setup SBM
                        SBM=checkIfAccountHasRejectedSBM(accountId,bureauId);
                        if(SBM==null){
                            SBM = new Speaker_Bureau_Membership_gne__c();
                            SBM.Bureau_Member_gne__c = accountId;
                            SBM.Speaker_Bureau_ID_gne__c = bureauId;
                        }
                        
                        //SBM.Speaker_Category_gne__c; 
                        //SBM.Nominated_By_gne__c = userId;
                                  
                    }
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
        
        /*if (ApexPages.currentPage().getParameters().get(WE_ARE_RETURNING_FROM_CLASSIFICATION_REQUEST) == '1' && !multiple) {
            if (EDM_Classification_Utils.checkIfPendingClassificationRequest(accountId, speakerBureauType)) {
                setSurveyAnswersToYes();
                areAllAnswersYes();
                saveSBMs();
            }
        }*/
    }

    public Boolean getErrorCondition () {
        return this.errorCondition;
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
        if(!multiple) return this.RetUrl;
        else{
            return '/apex/GNE_SFA2_SBMembership?br_id' + returnSBMIds;
        }
    }
    
    public PageReference nextWindow() {
        return null;
    }
    
    public Boolean getShowConfirmationPopup() {
        return showConfirmationPopup != null && showConfirmationPopup;
    }
    
    public void setConfirmationText(String n) {
        confirmationText = n;
    }

    public String getConfirmationText() {
        return confirmationText;
    }

    public void setRedirURL(String n) {
        redirURL = n;
    }

    public String getRedirURL() {
        return redirURL;
    }

    public PageReference nextStep() {
        PageReference pr = new PageReference(redirURL);
        pr.setRedirect(true);
        return pr;
    }

    public void setShowOkPopup(Boolean n) {
        showOkPopup = n;
    }

    public Boolean getShowOkPopup() {
        showConfirmationPopup =  !showOkPopup;
        return showOkPopup;
    }
    
    public void blockPage() {
        
    }
    
    public void setBlockPage(Boolean n) {
        blockPage = n;
    }

    public Boolean getBlockPage() {
        System.debug('blockPage '+blockPage);
        return blockPage;
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

    public Boolean allAnswersAreYes{get;set;}
    public String popupType {get; set;}
    public Account account {get; set;}
    public String speakerBureauType {get; set;}
    public String speakerBureauName {get; set;}
    public String countOfSpeakers {
        get{
            String ret = '';
            if (sbmIds != null) {
                ret = String.valueOf(sbmIds.size());
            }
            return ret;
        } set;}
    public String sbmid{
        get{
            return SBM.Id;
        } set;}
    //private static final String WE_ARE_RETURNING_FROM_CLASSIFICATION_REQUEST  = 'returnFromEDM_Classification_Request_Page';

    public void areAllAnswersYes(){
        allAnswersAreYes=true;
        SYstem.debug('##SR##: '+initial_list);
        for(Wrapper w : initial_list){
            if(w.selectedOption_x=='No' || w.selectedOption_x=='-None-'){
                allAnswersAreYes=false;
                break;
            }
        }
        if(multiple){
            requestMultipleExclusions();
        }
        saveSBMs();
    }

    private void retrieveExclusionAndClassificationStatus() {
        if(!multiple){
            account = [SELECT Specialties_gne__c,AGS_EX_Exclusion_Status_gne__c, AGS_EX_Exclusion_Status_base_gne__c, 
            EDM_Clinical_Classification_gne__c, EDM_Business_Classification_gne__c, Professional_Type_gne__c
            FROM Account WHERE Id = :accountId];
        }
    }

    public String getEDMClassification() {
        if(!multiple){
            return EDM_Classification_Utils.getEDMClassification(account, speakerBureauType);    
        }
        return '';
    }

    public String getURLForClassificationRequest() {
        PageReference pr = GNE_SFA2_Util.isCCCrmUser() ? Page.EDM_CRM_Classification_Request : Page.EDM_Classification_Request_Edit_Create;
        pr.getParameters().put('accountId', accountId);
        pr.getParameters().put('bureauId', bureauId);
        pr.getParameters().put('nomination', 'true');
        pr.getParameters().put('typeOfClassification', speakerBureauType);
        return pr.getUrl();
    }

    public void saveSBMs() {        
        //areAllAnswersYes();
        String patient = 'Patient Ambassador';
        if(!multiple){
            retrieveExclusionAndClassificationStatus();
            String classification = getEDMClassification();
            
            system.debug('### #'+isAccountEDMClassified(classification)+'# #'+account.AGS_EX_Exclusion_Status_gne__c+'# #'+classification+'# #'+account.AGS_EX_Exclusion_Status_base_gne__c+'#');
            
            if(allAnswersAreYes && account.Professional_Type_gne__c != patient && (account.AGS_EX_Exclusion_Status_base_gne__c == null || account.AGS_EX_Exclusion_Status_base_gne__c == 'Not Checked' || account.AGS_EX_Exclusion_Status_base_gne__c == '')){
                AGS_EX_Exclusion_Utils.createRequest(account);
                system.debug('#####: '+account.AGS_EX_Exclusion_Status_base_gne__c);
            }

            SBM.Nomination_Date_gne__c = system.now();

            if(classification != null && (classification != 'Local' && classification != 'Global')) {
                if(classification == 'Classification Pending'){
                    SBM.Speaker_Scope_gne__c = 'Not Classified';
                } else {
                    SBM.Speaker_Scope_gne__c = classification;
                }
            } else if(classification == 'Local') {
                SBM.Speaker_Scope_gne__c = 'Community';
            } else if(classification == 'Global') {
                SBM.Speaker_Scope_gne__c = 'National';
            }

            if(account.Professional_Type_gne__c != patient) {
                SBM.Exclusion_Status_gne__c = ( account.AGS_EX_Exclusion_Status_gne__c == 'Request Pending' ) ? 'Check Pending' : account.AGS_EX_Exclusion_Status_gne__c;
            }

            if (!allAnswersAreYes){
                SBM.Speaker_Status_gne__c='Rejected'; 
                upsert SBM;
                System.debug('$$ Rejected ' + SBM); 
            }else if(account.Professional_Type_gne__c == patient) {
                SBM.Speaker_Status_gne__c='Nominated';
                SBM.Survey_gne__c = saveSurvey();
                upsert SBM;
                System.debug('$$ Nominated ' + SBM);
            }else if(isAccountEDMClassified(classification) && account.AGS_EX_Exclusion_Status_gne__c == 'Verified and Clear'){
                SBM.Speaker_Status_gne__c='Nominated';
                SBM.Survey_gne__c = saveSurvey();
                upsert SBM;
                System.debug('$$ Nominated ' + SBM);    
            }else if(account.AGS_EX_Exclusion_Status_base_gne__c == 'Check pending' ||  account.AGS_EX_Exclusion_Status_base_gne__c == 'In Process' || classification == 'Classification Pending'){
                SBM.Speaker_Status_gne__c='Pending';
                SBM.Survey_gne__c = saveSurvey();
                upsert SBM;
                System.debug('$$ Pending ' + SBM);
            } 
            System.debug('$$ After ' + SBM + ' ' + allAnswersAreYes + ' ' + isAccountEDMClassified(classification));  
        } else {
            if (allAnswersAreYes) {
                List<Speaker_Bureau_Membership_gne__c> sbmsToUpsert = new List<Speaker_Bureau_Membership_gne__c>();
                List<Speaker_Bureau_Membership_gne__c> rejectedSBMs = [SELECT Id, Name, Bureau_Member_gne__c,Speaker_Bureau_ID_gne__c, Speaker_Status_gne__c FROM Speaker_Bureau_Membership_gne__c 
                                                        WHERE Speaker_Status_gne__c='Rejected' AND Bureau_Member_gne__c IN :allAccounts AND Speaker_Bureau_ID_gne__c =: bureauId];
                System.debug('$$ acc: ' + acc);
                if (!acc.isEmpty() && !multiPatientAmbassadorNomination)
                    AGS_EX_Exclusion_Utils.createMultipleRequests(acc);

                //Set<String> accSet = new Set<String>(acc);
                List<Account> accountsToNominate = new List<Account>([SELECT Id, AGS_EX_Exclusion_Status_base_gne__c, AGS_EX_Exclusion_Status_gne__c, EDM_Business_Classification_gne__c, EDM_Clinical_Classification_gne__c, Classification_gne__c
                                                                      FROM Account WHERE Id IN :allAccounts]);
                List<Survey_gne__c> surveys = createSurveyForMultipleAccounts(allAccounts);
                for (Account a : accountsToNominate) {
                    Speaker_Bureau_Membership_gne__c sbm = hasRejectedSBM(rejectedSBMs,a.id);
                    if (sbm == null) {
                        sbm = new Speaker_Bureau_Membership_gne__c();
                        sbm.Bureau_Member_gne__c = a.Id;
                        sbm.Speaker_Bureau_ID_gne__c = bureauId;
                    }
                    String classification;
                    if (speakerBureauType == 'Clinical') {
                        classification = a.EDM_Clinical_Classification_gne__c;
                    } else if (speakerBureauType == 'Business') {
                        classification = a.EDM_Business_Classification_gne__c;
                    }

                    if (classification != null && (classification != 'Local' && classification != 'Global')) {
                        sbm.Speaker_Scope_gne__c = classification;
                    } else if (classification == 'Local') {
                        sbm.Speaker_Scope_gne__c = 'Community' ;
                    } else if (classification == 'Global') {
                        sbm.Speaker_Scope_gne__c = 'National' ;
                    }

                    if (!multiPatientAmbassadorNomination)
                        sbm.Exclusion_Status_gne__c = ( a.AGS_EX_Exclusion_Status_gne__c == 'Request Pending' ) ? 'Check Pending' : a.AGS_EX_Exclusion_Status_gne__c;

                    sbm.Nomination_Date_gne__c = system.now();
                    
                    Survey_gne__c surv = findSurvey(surveys,a.Id);
                    if (surv != null)
                        sbm.Survey_gne__c = surv.Id;

                    if (multiPatientAmbassadorNomination)
                        sbm.Speaker_Status_gne__c='Nominated';
                    else {
                        if (a.AGS_EX_Exclusion_Status_base_gne__c == 'Check pending' || a.AGS_EX_Exclusion_Status_base_gne__c == 'In Process') {
                            sbm.Speaker_Status_gne__c='Pending';
                        } else {
                            sbm.Speaker_Status_gne__c='Nominated';
                        }
                    }

                    sbmsToUpsert.add(sbm);
                }
                upsert sbmsToUpsert;
                String wrapperId = ApexPages.currentPage().getParameters().get('wrapperId');
                if(wrapperId!=null && wrapperId!=''){
                    delete [Select EDM_Multiple_Nomination_Ids__c from EDM_Multiple_Nomination_Wrapper__c where id = :wrapperId];
                }
            }
        }
    }
    public Speaker_Bureau_Membership_gne__c hasRejectedSBM(List<Speaker_Bureau_Membership_gne__c> sbmList,String accId){
        for(Speaker_Bureau_Membership_gne__c sbm : sbmList){
            if(sbm.Bureau_Member_gne__c==accId){
                return sbm;
            }
        }
        return null;
    }
    public Survey_gne__c findSurvey(List<Survey_gne__c> surveys,String accId){
        for(Survey_gne__c s : surveys){
            if(s.Account__c==accId){
                return s;
            }
        }
        return null;
    }
    public void requestMultipleExclusions(){
        System.debug('###:1');
        List<Account> accWithPendingExclusion = new List<Account>([
                Select Id,AGS_EX_Exclusion_Status_base_gne__c 
                from Account 
                where AGS_EX_Exclusion_Status_base_gne__c in ('Not checked', 'Check pending', 'In Process') and id in :allAccounts]);

        if (multiPatientAmbassadorNomination) {
            popupType = 'Skip Exclusion';
            System.debug('popupType="Skip Exclusion"');
        } else if (!accWithPendingExclusion.isEmpty()) {
            popupType='Multiple Exclusion Requested';
            System.debug('popupType="Multiple Exclusion Requested"');
        } else {
            popupType='Exclusion Done';
            System.debug('popupType="Exclusion Done"');
        }
    }
    public List<Survey_gne__c> createSurveyForMultipleAccounts(Set<String> acc){
        List<Survey_gne__c> surveys = new List<Survey_gne__c>();
        List<Survey_Response_gne__c> survResps=new List<Survey_Response_gne__c>();
        for(String a : acc){
            Survey_gne__c surv=new Survey_gne__c();
            surv.Speaker_Nomination_Category_gne__c =burCat;
            surv.Account__c=a;
            surv.Type_gne__c ='Speaker Nomination Survey';
            surv.Speaker_Bureau_gne__c=bureauId;
            surv.Questionnaire_gne__c=questid;
            surveys.add(surv);
        }
        insert surveys;
        for(Survey_gne__c s : surveys){
            for(Wrapper w_x : initial_list){
                Survey_Response_gne__c survResp=new Survey_Response_gne__c();
                survResp.Survey_gne__c=s.Id;
                survResp.Title_gne__c=w_x.question;
                survResp.Help_Text_gne__c = w_x.helpText ;
                survResp.Position_gne__c = w_x.position;
                survResp.Values_gne__c = w_x.old_values;
                survResp.Labels_gne__c = w_x.old_labels;
                survResp.Type_gne__c = 'Labels and Values';
                survResp.Question_gne__c= w_x.QuestionId;
                survResp.Selected_Label_gne__c = w_x.selectedOption_x;
                    
                survResps.add(survResp);
            }
        }
        insert survResps;

        return surveys;
    }
    public Id saveSurvey(){
        Survey_gne__c surv=new Survey_gne__c();
        surv.Speaker_Nomination_Category_gne__c =burCat;
        surv.Account__c=accountId;
        surv.Type_gne__c ='Speaker Nomination Survey';
        surv.Speaker_Bureau_gne__c=bureauId;
        surv.Questionnaire_gne__c=questid;
        insert surv;
        
        List<Survey_Response_gne__c> survResps=new List<Survey_Response_gne__c>();
        for(Wrapper w_x : initial_list){
            Survey_Response_gne__c survResp=new Survey_Response_gne__c();
            survResp.Survey_gne__c=surv.Id;
            survResp.Title_gne__c=w_x.question;
            survResp.Help_Text_gne__c = w_x.helpText ;
            survResp.Position_gne__c = w_x.position;
            survResp.Values_gne__c = w_x.old_values;
            survResp.Labels_gne__c = w_x.old_labels;
            survResp.Type_gne__c = 'Labels and Values';
            survResp.Question_gne__c= w_x.QuestionId;
            survResp.Selected_Label_gne__c = w_x.selectedOption_x;
                
            survResps.add(survResp);
        }
        insert survResps;

        return surv.Id;
    }

    public Boolean isAccountEDMClassified(String classification) {
        if(classification=='Community' || classification=='Regional' || classification=='National' || classification=='Global'){
            return true;
        }
        return false;
    }        

    public void setSurveyAnswersToYes(){
        for(Wrapper w_x : initial_list){
            System.debug('#W.OPTS# '+w_x.opts);
            w_x.selectedOption_x='Yes';
        }
    }

    public static Speaker_Bureau_Membership_gne__c checkIfAccountHasRejectedSBM(String account,String bureau){
            try{
                Speaker_Bureau_Membership_gne__c sbm = [select Id, Name, Bureau_Member_gne__c, Contract_Active_gne__c, Contract_End_Date_gne__c, Contract_Start_Date_gne__c, 
                                                        CreatedById, CreatedDate, Is_Contracted_Speaker_gne__c, IsDeleted, IsLocked, LastModifiedById, LastModifiedDate, 
                                                        MayEdit, Meets_Speaker_Criteria_gne__c, Nominated_By_gne__c, Nomination_Date_gne__c, RecordTypeId, Region_Code_gne__c, 
                                                        Speaker_Bureau_ID_gne__c, Speaker_Status_gne__c from Speaker_Bureau_Membership_gne__c 
                                                        where Speaker_Status_gne__c='Rejected' and Bureau_Member_gne__c=:account and Speaker_Bureau_ID_gne__c=:bureau limit 1];
                return sbm;
            } catch(Exception e){
                System.debug('No rejected SBM found!');
                return null;
            }
    }

    public static void saveNewSBM(String account,String bureau,String status){
        Speaker_Bureau_Membership_gne__c sbm = checkIfAccountHasRejectedSBM(account,bureau);
        Account acc = [SELECT AGS_EX_Exclusion_Status_gne__c FROM Account where Id = :account LIMIT 1];
        if(sbm==null){
            sbm = new Speaker_Bureau_Membership_gne__c();
            sbm.Bureau_Member_gne__c = account;
            sbm.Speaker_Bureau_ID_gne__c = bureau;
        }
        sbm.Speaker_Scope_gne__c = 'Not Classified';
        sbm.Nominated_By_gne__c = userInfo.getUserId();
        sbm.Nomination_Date_gne__c = system.now();          
        sbm.Speaker_Status_gne__c = status;
        sbm.Survey_gne__c = saveNewSurvey(account,bureau);
        sbm.Exclusion_Status_gne__c = ( acc.AGS_EX_Exclusion_Status_gne__c == 'Request Pending' ) ? 'Check Pending' : acc.AGS_EX_Exclusion_Status_gne__c;
        System.debug('## sbm survey:'+sbm.Survey_gne__c);
        upsert sbm;
    }

    public static void updateExisitngSBMStatus(String account,String bureau,String status){
        Speaker_Bureau_Membership_gne__c sbm = getExistingSBM(account, bureau);
        if(sbm!=null){
            sbm.Speaker_Status_gne__c = status;
            update sbm;
        } else {
            saveNewSBM(account, bureau, status);
        }

    }

    public PageReference cancelNominationAndRedirect(){
        return cancelNomination(accountId, bureauId);
    }

    public static PageReference cancelNomination(String account, String bureau){
        Speaker_Bureau_Membership_gne__c sbm = getExistingSBM(account, bureau);
        if(sbm!=null){
            Boolean wasRejected = false;
            for(EDM_SpeakerBureau_Membership_History_gne__c sbmH : [SELECT Id, EDM_Membership_Status_gne__c from EDM_SpeakerBureau_Membership_History_gne__c WHERE EDM_Speaker_Bureau_Membership_gne__c = :sbm.Id]){
                if(sbmH.EDM_Membership_Status_gne__c.equalsIgnoreCase('Rejected')){
                    wasRejected = true;
                    sbm.Speaker_Status_gne__c = 'Rejected';
                    sbm.Survey_gne__c = null;
                    break;
                }
            }
            if(wasRejected){
                update sbm;
            } else {
                delete sbm;
            }
        }
        List<Survey_gne__c> surveys = [SELECT Id FROM Survey_gne__c WHERE Account__c = :account AND Type_gne__c = 'Speaker Nomination Survey' AND Speaker_Bureau_gne__c = :bureau];
        if(surveys.size()>0){
            delete surveys;
        }
        return new PageReference('/'+account);
    }

    private static Speaker_Bureau_Membership_gne__c getExistingSBM(String account,String bureau){
        Speaker_Bureau_Membership_gne__c sbm = null;
        try{
            sbm = [select Id, Speaker_Status_gne__c, Survey_gne__c from Speaker_Bureau_Membership_gne__c 
                   where Bureau_Member_gne__c=:account and Speaker_Bureau_ID_gne__c=:bureau limit 1];
        } catch (Exception ex){
            system.debug('sbm not found');
        }
        return sbm;
    }

    public static Id saveNewSurvey(String account,String bureau){
        String burCat = [select Speaker_Category_gne__c from Speaker_Bureau_gne__c where id =:bureau].Speaker_Category_gne__c;
        String accProfType = [SELECT Professional_Type_gne__c FROM Account WHERE Id =:account].Professional_Type_gne__c;

        List<Questionnaire_gne__c> questId_x = new List<Questionnaire_gne__c>([select id from Questionnaire_gne__c where Category_gne__c =:accProfType and ready_for_use_gne__c = true]);
        System.debug('## Questionnaires size: '+questId_x.size());

        if (questId_x.size() == 0) {
            questId_x = [SELECT Id FROM Questionnaire_gne__c WHERE Category_gne__c = 'Managed Care' AND ready_for_use_gne__c = true];
        }

        if (questId_x.size() == 1){ 
            String questId = questId_x[0].Id;       

            Survey_gne__c surv=new Survey_gne__c();
            surv.Speaker_Nomination_Category_gne__c = burCat;
            surv.Account__c=account;
            surv.Type_gne__c ='Speaker Nomination Survey';
            surv.Speaker_Bureau_gne__c=bureau;
            surv.Questionnaire_gne__c=questId;
            insert surv;

            Questionnaire_gne__c q=[Select q.Category_gne__c, q.Id, q.Name, q.Show_Questions_Position_gne__c, q.Type_gne__c, (Select Category_gne__c, Help_Text_gne__c, Id, Maximum_Score_gne__c, 
               Minimum_Score_gne__c, Position_gne__c, Title_gne__c, Type_gne__c, Values_gne__c, Labels_gne__c, Weight_gne__c From Questions__r order by Position_gne__c) 
               from Questionnaire_gne__c q where q.ID=:questId];
            
            List<Survey_Response_gne__c> survResps=new List<Survey_Response_gne__c>();                
            for(Question_gne__c quest:q.Questions__r){
                Survey_Response_gne__c survResp=new Survey_Response_gne__c();
                survResp.Survey_gne__c=surv.Id;
                survResp.Title_gne__c= quest.Title_gne__c;
                survResp.Help_Text_gne__c = quest.Help_Text_gne__c;
                survResp.Position_gne__c = quest.Position_gne__c;
                survResp.Values_gne__c = quest.Values_gne__c;
                survResp.Labels_gne__c = quest.Labels_gne__c;
                survResp.Type_gne__c = 'Labels and Values';
                survResp.Question_gne__c= quest.Id;
                survResp.Selected_Label_gne__c = 'Yes';
                                
                survResps.add(survResp);
            }
            insert survResps;

            return surv.Id;
        } 
        return null;
    }
}