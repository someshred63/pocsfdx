public class GNE_MCCO_Mass_Survey_Updates_Ctrlr {

    private final ApexPages.standardController controller;
    private ID usrID;
    private Questionnaire_gne__c questionnaire;
    private List<SelectOption> responseOptions;
    private Set<ID> SurveyIDs = new Set<ID>();
    private Map<ID, List<Survey_Response_gne__c>> SurveyToResponses = new Map<ID, List<Survey_Response_gne__c>>();
    private Map<ID,Survey_Response_gne__c> responsesMap;
    private Map<string,double> questionToPos = new Map<string,double>();
    private Map<String,String> accIDtoName = new Map<String,String>();
    private Map<ID,ID> accIDtoSurveyIDMap = new Map<ID,ID>();
    //private Map<String, String> accNametoIDMap = new Map<String, String>();
    private Map<String,String> questionIDToTitle = new Map<String, String>();
    private String mode = '';
    private Map<ID,Survey_gne__c> surveyMap = new Map<ID, Survey_gne__c>();
    private String AudienceType = '';
    private String ssperMode = '';
    private String sCategory = '';
    private List<Survey_Response_gne__c> responseList = new List<Survey_Response_gne__c>();
    private List<Survey_Response_gne__c> toSave = new List<Survey_Response_gne__c>();
    private Map<Id,Question_gne__c> questionsMap = new Map<Id,Question_gne__c>();

    public String dataList {get; set;}
    public ID currAccount{get;set;}
    public String columns {get; set;}
    public String comboBox {get; set;}
    public String data {get; set;}
    public List<qObj> wrapperList {get; set;}
    public List<Survey_gne__c> surveys;
    public List<Question_gne__c> Questions{get;set;}
    public List<QuestionnaireAccount_gne__c> qAccounts{get;set;}
    public List<Account> accounts{get; set;}
    public List<Survey_Response_gne__c> surveyResponses{get; set;}
    public Map<Id,Integer> columnSizes=new Map<Id,Integer>();
    public String response{get;set;}
    public String currentAccount{get;set;}
    public String methods {get; set;}
    public String a_list {get; set;}
    public Integer noQs {get; set;}
    public String rows {get; set;}
    public String Title {get; set;}
    public String MainTitle {get; set;}
    private Boolean a_ListEmpty;

    public Boolean getA_ListEmpty(){
        return (a_List == null || a_List.trim().equals(''));
    }

    private Set<ID> accIDs = new Set<ID>();
    private Set<ID> newSurveyAccs = new Set<ID>();

    public void init(){}

    /*******************************************************************************************************
                                                START OF CONSTRUCTOR METHODS
    ********************************************************************************************************/
    public GNE_MCCO_Mass_Survey_Updates_Ctrlr(ApexPages.StandardController stdController){
        this.controller             = stdController;
        this.Questionnaire          = (Questionnaire_gne__c)stdController.getRecord();
        Set<ID> qAccountIDSet       = new Set<ID>();
        Set<ID> surveyAccountIDSet  = new Set<ID>();
        instantiations();

        // From user territory get group list
        Map<ID, Group> groupMap = new Map<ID, Group>([SELECT Id
                                                      FROM Group
                                                      WHERE Type = 'Territory' AND
                                                            RelatedID IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserID = :usrID)]);

        // Get all questionnaire data including questionnaire accounts
        List<QuestionnaireAccount_gne__c> questionnaireAccountList = [SELECT
                                                                        Account__c,
                                                                        Account_Name_gne__c,
                                                                        Account__r.Account_Manager_gne__c,
                                                                        Account__r.Name,
                                                                        Account__r.isPersonAccount,
                                                                        Account__r.FirstName,
                                                                        Account__r.LastName,
                                                                        Questionnaire_gne__c,
                                                                        Questionnaire_gne__r.Type_gne__c,
                                                                        Questionnaire_gne__r.Audience_Type_gne__c,
                                                                        Questionnaire_gne__r.Single_Survey_per_Mode_gne__c,
                                                                        Questionnaire_gne__r.Category_gne__c
                                                                      FROM
                                                                        QuestionnaireAccount_gne__c
                                                                      WHERE
                                                                        Questionnaire_gne__c = :this.questionnaire.Id AND
                                                                        Account__c IN (SELECT AccountID
                                                                                       FROM AccountShare
                                                                                       WHERE (RowCause = 'TerritoryRule' or RowCause = 'Territory2AssociationManual') AND
                                                                                              UserOrGroupID IN :groupMap.keySet())];

        // Get all  questionnaire's questions
        this.questions = [SELECT
                        Id,
                        Values_gne__c,
                        Weight_gne__c,
                        Labels_gne__c,
                        Type_gne__c,
                        Minimum_Score_gne__c,
                        Maximum_Score_gne__c,
                        Title_gne__c,
                        Help_Text_gne__c,
                        Position_gne__c,
                        Multiple_Responses_gne__c
                     FROM
                        Question_gne__c
                     WHERE
                        Questionnaire_gne__c = :this.questionnaire.Id
                     ORDER BY
                        Position_gne__c];

        this.questionsMap = new Map<Id,Question_gne__c>();

        for(Question_gne__c q : questions) {
            questionsMap.put(q.Id, q);
        }


        // Check if there are any questionnaire accounts retreived
        // If not get just the questionnaire data
        if (questionnaireAccountList.size() > 0) {
            this.Title              = questionnaireAccountList[0].Questionnaire_gne__r.Type_gne__c.replace('\'', '&#39;');
            this.MainTitle          = questionnaireAccountList[0].Questionnaire_gne__r.Type_gne__c;
            this.noQs               = questionsMap.size();
            this.AudienceType       = questionnaireAccountList[0].Questionnaire_gne__r.Audience_Type_gne__c;
            this.ssperMode          = questionnaireAccountList[0].Questionnaire_gne__r.Single_Survey_per_Mode_gne__c;
            this.sCategory          = questionnaireAccountList[0].Questionnaire_gne__r.Category_gne__c;
        } else {
            this.questionnaire = [SELECT Id, Type_gne__c, Audience_Type_gne__c, Single_Survey_per_Mode_gne__c, Category_gne__c
                                  FROM Questionnaire_gne__c WHERE Id = :this.questionnaire.Id];

            this.Title          = this.questionnaire.Type_gne__c.replace('\'', '&#39;');
            this.MainTitle      = questionnaireAccountList[0].Questionnaire_gne__r.Type_gne__c;
            this.noQs           = questionsMap.size();
            this.AudienceType   = this.questionnaire.Audience_Type_gne__c;
            this.ssperMode      = this.questionnaire.Single_Survey_per_Mode_gne__c;
            this.sCategory      = this.questionnaire.Category_gne__c;
        }

        // For Targeted questionnaire add to the list those accounts where the user is a manager of that account
        if (this.AudienceType == 'Targeted') {
            questionnaireAccountList.addAll([SELECT
                                                Account__c,
                                                Account__r.Name,
                                                Account__r.isPersonAccount,
                                                Account__r.FirstName,
                                                Account__r.LastName,
                                                Account_Name_gne__c,
                                                Account__r.Account_Manager_gne__c,
                                                Questionnaire_gne__c,
                                                Questionnaire_gne__r.Type_gne__c,
                                                Questionnaire_gne__r.Audience_Type_gne__c,
                                                Questionnaire_gne__r.Single_Survey_per_Mode_gne__c,
                                                Questionnaire_gne__r.Category_gne__c
                                            FROM
                                                QuestionnaireAccount_gne__c
                                            WHERE
                                                Questionnaire_gne__c = :this.questionnaire.Id AND
                                                Account__r.Account_Manager_gne__c = :usrID]);
        }

        for (QuestionnaireAccount_gne__c qa : questionnaireAccountList)
            qAccountIDSet.add(qa.Account__c);
        // Get all questionnaire's survey data including survey responses
        List<Survey_gne__c> surveyList;
        if (this.ssperMode == 'Per User Per Account') {
            surveyList = [SELECT
                            Id, Account__c, CreatedById,
                            (SELECT
                                Id, Survey_gne__c, Question_gne__c, Position_gne__c, Type_gne__c, Response_Score_gne__c, Values_gne__c, Labels_gne__c, Selected_Label_gne__c, Free_Text_gne__c
                            FROM
                                Survey_Responses_gne__r
                            ORDER BY
                                Question_gne__r.Position_gne__c)
                        FROM
                            Survey_gne__c
                        WHERE
                            Questionnaire_gne__c = :this.questionnaire.Id AND
                            Account__c IN :qAccountIDSet AND
                            CreatedById = :this.usrID];
        } else {
            surveyList = [SELECT
                            Id, Account__c, CreatedById,
                            (SELECT
                                Id, Survey_gne__c, Question_gne__c, Position_gne__c, Type_gne__c, Response_Score_gne__c, Values_gne__c, Labels_gne__c, Selected_Label_gne__c, Free_Text_gne__c
                            FROM
                                Survey_Responses_gne__r
                            ORDER BY
                                Question_gne__r.Position_gne__c)
                        FROM
                            Survey_gne__c
                        WHERE
                            Questionnaire_gne__c = :this.questionnaire.Id AND
                            Account__c IN :qAccountIDSet];
        }

        for (Survey_gne__c sa : surveyList)
            surveyAccountIDSet.add(sa.Account__c);

        this.accIDs.addAll(qAccountIDSet);
        populateSurveySet(surveyList);
        this.surveys = new List<Survey_gne__c>();
        this.surveys.addAll(surveyList);

        // Accounts that still need to have the survey created = Questionnaire Accounts visible to the user - accounts that already have the survey created
        this.newSurveyAccs.addAll(qAccountIDSet);
        this.newSurveyAccs.removeAll(surveyAccountIDSet);

        surveyResponses = new List<Survey_Response_gne__c>();
        for(Survey_gne__c s : this.surveys){
            for(Survey_Response_gne__c sr : s.Survey_responses_gne__r){
                surveyResponses.add(sr);
            }
        }
        populateSurveys(this.Surveys);

        this.responsesMap = new Map<ID, Survey_Response_gne__c>([select ID, Survey_gne__c, Labels_gne__c, Selected_Label_gne__c from
                                                                Survey_Response_gne__c where Survey_gne__c IN :SurveyIDs ORDER BY Position_gne__c]);

        sort_questions(questions);
        this.qAccounts = new List<QuestionnaireAccount_gne__c>();
        this.qAccounts.addAll(questionnaireAccountList);

        if(this.AudienceType == 'Targeted')
            populateAccMap('T');
        else
            populateAccMap('G');

       populateResponseMap(this.responsesMap.values());
    }
    /*******************************************************************************************************
                                            CONTROLLER UTIL METHODS
    ********************************************************************************************************/
    private void instantiations(){
        this.a_list = '';
        this.a_ListEmpty = true;
        this.methods = '';
        this.wrapperList = new List<qObj>();
        this.columns = '';
        this.data = '';
        this.CurrentAccount = '';
        this.usrID = Userinfo.getUserId();
        this.accounts = new List<Account>();
    }

    public void populateAccMap(String at){
        if(at == 'T'){
            for(QuestionnaireAccount_gne__c a : this.qAccounts){
                if(this.accIDs.contains(a.Account__r.ID)){
                    this.accIDtoName.put(a.Account__c, a.Account__r.Name.replace('\'', '&#39;'));
                    //this.accNametoIDMap.put(a.Account__r.Name.replace('\'', '&#39;'), a.Account__c);
                    //system.debug('AccNametoIDMap: ' + a.Account__r.Name + ' ' + a.Account__c);
                }
            }
        }else if(at == 'G'){
            for(QuestionnaireAccount_gne__c a : this.qAccounts){
                if(this.accIDs.contains(a.Account__c)){
                    if(a.Account__r.isPersonAccount){
            if(a.Account__r.FirstName == null)
            {
                       this.accIDtoName.put(a.Account__c, a.Account__r.LastName.replace('\'', '&#39;'));
                       //this.accNametoIDMap.put(a.Account__r.LastName.replace('\'', '&#39;'), a.Account__c);
            }
            else
            {
                           this.accIDtoName.put(a.Account__c, a.Account__r.FirstName.replace('\'', '&#39;') + ' ' + a.Account__r.LastName.replace('\'', '&#39;'));
                           //this.accNametoIDMap.put(a.Account__r.FirstName.replace('\'', '&#39;') + ' ' + a.Account__r.LastName.replace('\'', '&#39;'), a.Account__c);
            }
                        //system.debug('AccNametoIDMap: '+ a.Account__r.FirstName + ' ' + a.Account__r.LastName + ' ' + a.Account__c);
                    }else {
                        this.accIDtoName.put(a.Account__c, a.Account__r.Name.replace('\'', '&#39;'));
                        //this.accNametoIDMap.put(a.Account__r.Name.replace('\'', '&#39;'), a.Account__c);
                        //system.debug('AccNametoIDMap: '+ a.Account__r.Name + ' ' + a.Account__c);
                    }
                }
            }
        }
    }

    /*******************************************************************************************************
                                                    PAGE METHODS
    ********************************************************************************************************/

    public List<Question_gne__c> sort_questions(List<Question_gne__c> questions){
        for(Question_gne__c q : questions){
            string help = '';
            String showIcon = '';
            if(q.help_text_gne__c == null){
                help = '';
            //}else {help = String.EscapeSingleQuotes(q.Help_text_gne__c);}
            //}else{help = '<img style="height: 5px; csscursor: pointer;" src="../s.gif" onclick="alert(\''+String.EscapeSingleQuotes(q.Help_text_gne__c)+'\')" class="helpIcon"/>';}
            }else{help = '<img style="height: 10px;" src="http://www.veryicon.com/icon/png/System/Boomy/Help.png" onclick="alert("'+String.EscapeSingleQuotes(q.Help_text_gne__c)+'")"/>';}

            this.questionIDToTitle.put(q.ID,q.Title_gne__c);
            this.questionToPos.put(q.ID,q.Position_gne__c);
            if(!columnSizes.containsKey(Q.Id) || (columnSizes.containsKey(Q.Id) && columnSizes.get(Q.Id)<q.Title_gne__c.length())) columnSizes.put(Q.Id,q.Title_gne__c.length());
            if(q.Type_gne__c == 'Numeric'){
                this.columns += ',\n{locked: false, dataIndex: \'Question'+q.Position_gne__c+'\', header:\'<b>'+q.Title_gne__c.replace('\'', '&#39;')+' ('+q.Minimum_Score_gne__c+'-'+q.Maximum_Score_gne__c+')</b> '+help+'\', editor: new Ext.form.NumberField({allowBlank: false, minValue: '+q.Minimum_Score_gne__c+', maxValue:'+q.Maximum_Score_gne__c+'}), width: '+(columnSizes.get(Q.Id) * 6+50)+',sortable: false, tooltip:\'Click here for help\'}';
            }else if(q.Type_gne__c == 'Free Text') {
                this.columns += ',\n{locked: false, dataIndex: \'Question'+q.Position_gne__c+'\', header:\'<b>'+q.Title_gne__c.replace('\'', '&#39;')+'</b> '+help+'\', editor: new Ext.form.TextArea({grow: true, growMin: 50, growMax: 100, preventScrollbars: true}), width: '+Math.max(columnSizes.get(Q.Id) * 6+50,250)+',sortable: false, tooltip:\'Click here for help\'}';
            }else{
                this.columns += ',{locked: false, sortable: false, header:\'<b>'+q.Title_gne__c.replace('\'', '&#39;')+'</b> '+help+'\', dataIndex: \'Question'+q.Position_gne__c+'\', editor: new Ext.grid.GridEditor(combo'+q.Position_gne__c+'),isMenuDisabled: true, width: '+(columnSizes.get(Q.Id) * 6+50)+', tooltip:\'Click here for help\'}';
            }
            this.data += ',{name: \'Question'+q.Position_gne__c+'\'}';
            //count++;
        }
        return questions;
    }

    private void populateSurveys(List<Survey_gne__c> surveys){
        for(Survey_gne__c survey : surveys){
            if(!surveyMap.containsKey(survey.Account__c)){
                surveyMap.put(survey.Account__c,Survey);
            }
        }
    }

    private void populateSurveySet(List<Survey_gne__c> surveys){
        for(Survey_gne__c survey : surveys){
            SurveyIDs.add(survey.ID);
        }
    }

    private void populateResponseMap(List<Survey_Response_gne__c> responses){
        qObj wrapper = new qObj();
        dataList = '';
        //create new surveys list
        integer index = 0;
        String currentAccountData = '';
        for(ID accID : this.newSurveyAccs){
            index++;
            currentAccountData = '[';
            for(Question_gne__c q : this.Questions){
                String Label = '';
                if(!columnSizes.containsKey(q.ID)) columnSizes.put(q.ID,0);
                if(q.Type_gne__c == 'Numeric'){
                    label = ''+q.Minimum_Score_gne__c;
                    response = ''+q.weight_gne__c.intValue();
                    a_list += ' ';
                }else if (q.Type_gne__c == 'Labels and Values'){
                    if(q.Labels_gne__c.split(',')[0] == null){
                        label = ' ';
                    }else label = q.Labels_gne__c.split(',')[0];
                    response = label;
                    a_list += '<select ID="'+q.ID+'">';
                    String editorName = q.Multiple_Responses_gne__c ? 'new Ext.ux.form.LovCombo({hideOnSelect: false,beforeBlur: Ext.emptyFn,' : 'new Ext.form.ComboBox({';
                    methods += 'var combo'+q.Position_gne__c.intValue()+' = ' + editorName + 'typeAhead: false,triggerAction: \'all\',lazyRender:true,mode: \'local\', transform: \''+q.ID+'\'}); ';
                    List<String> s = new List<String>();
                    if(q.Labels_gne__c != null){
                        s = q.Labels_gne__c.split(',');
                        for(integer j=0; j<s.size();j++){
                            a_list += '<option>'+s[j]+'</option>';
                            if(s[j].length()>columnSizes.get(q.ID)) columnSizes.put(q.ID,s[j].length());
                        }
                    }
                    a_list += '</select>';
                }else if(q.Type_gne__c == 'List of Values'){
                    if(q.Values_gne__c.split(',')[0] == null){
                        label = ' ';
                    }else label = q.Values_gne__c.split(',')[0];
                    response = label;
                    a_list += '<select ID="'+q.ID+'">';
                    methods += 'var combo'+q.Position_gne__c.intValue()+' = new Ext.form.ComboBox({typeAhead: false,triggerAction: \'all\',lazyRender:true,mode: \'local\', transform: \''+q.ID+'\'}); ';
                    List<String> s = new List<String>();
                    if(q.Values_gne__c != null){
                        s = q.Values_gne__c.split(',');
                        for(integer j=0; j<s.size();j++){
                            a_list += '<option>'+s[j]+'</option>';
                            if(s[j].length()>columnSizes.get(q.ID)) columnSizes.put(q.ID,s[j].length());
                        }
                    }
                    a_list += '</select>';
                } else if(q.Type_gne__c == 'Free Text') {
                    label = '';
                    response = '';
                    a_list += ' ';
                }

                if(currentAccountData == '['){
                    currentAccountData += '\'000000000000000000'+index+'\',\''+accIDtoName.get(accID)+'\',\''+response+'\'';
                    //currentAccountData += '\''+accIDtoName.get(accID)+'\',\'000000000000000000'+index+'\',\''+response+'\'';
                }else { currentAccountData += ',\''+response+'\''; }
                    wrapper.qAccount = accID;
            }
            if(index == newSurveyAccs.size()){
                dataList += currentAccountData+']';
            }else dataList += currentAccountData+'],';
            wrapper.question = dataList;
            this.wrapperList.add(wrapper);
        }
        string endTag = ',[\'\'';
        currentAccountData = '';
        for(Integer i=0; i<this.Surveys.size(); i++){
            Survey_gne__c survey = this.Surveys[i];

            List<Survey_Response_gne__c> sortedResponse = new Survey_Response_gne__c[Survey.Survey_Responses_gne__r.size()];
            /*for(Survey_Response_gne__c sr : Survey.Survey_Responses_gne__r){
                Integer q = questionToPos.get(sr.Question_gne__c).intValue()-1;
                system.debug('***sortedResponse size:'+sortedResponse.size());
                system.debug('***sortedResponse questionToPos:'+questionToPos.get(sr.Question_gne__c).intValue());
                system.debug('***sortedResponse q:'+q);
                sortedResponse.set(q,sr);
                system.debug('Added to index q: '+sortedResponse.get(q));
            }*/
            system.debug('***SortedResponse List'+sortedResponse);


            boolean complete = false;
            double currentQ = 1;
            index = 0;
            integer maxQs = Survey.Survey_responses_gne__r.size();
                for(Survey_Response_gne__c sr : Survey.Survey_Responses_gne__r){
                    index++;
                    if(!columnSizes.containsKey(sr.Question_gne__c)) columnSizes.put(sr.Question_gne__c,0);
                    /*if(!SurveyToResponses.containsKey(survey.Account__c)){
                        SurveyToResponses.put(survey.Account__c, new List<Survey_Response_gne__c>());
                        //SurveyToResponses.put(survey.Account__c, this.responsesMap.get(survey.Survey_Responses_gne__r[0].ID));
                    }*/
                    if(!SurveyToResponses.containsKey(survey.ID)){
                        SurveyToResponses.put(survey.ID, new List<Survey_Response_gne__c>());
                    }
                    surveyToResponses.get(survey.ID).add(sr);

                    String response;
                    if(sr.Type_gne__c == 'Numeric'){
                        a_list += ' ';
                        if(sr.Response_Score_gne__c != null){
                            response = ''+sr.Response_Score_gne__c.intValue();
                        }else response = '';
                    }else if (sr.Type_gne__c == 'Labels and Values'){
                        a_list += '<select ID="'+sr.question_gne__c+'">';
                        if(sr.Selected_Label_gne__c == null){
                            response = ' ';
                        }else response = sr.Selected_Label_gne__c;
                            String editorName = questionsMap.get(sr.Question_gne__c).Multiple_Responses_gne__c ? 'new Ext.ux.form.LovCombo({hideOnSelect: false,beforeBlur: Ext.emptyFn,' : 'new Ext.form.ComboBox({';
                            methods += 'var combo'+questionsMap.get(sr.Question_gne__c).Position_gne__c.intValue()+' = ' + editorName + 'editable: false, typeAhead: false,triggerAction: \'all\',lazyRender:true,mode: \'local\', transform: \''+sr.Question_gne__c+'\'}); ';
                            List<String> s = new List<String>();
                            if(sr.Labels_gne__c != null){
                                s = sr.Labels_gne__c.split(',');
                                for(integer j=0; j<s.size();j++){
                                    a_list += '<option>'+s[j]+'</option>';
                                    if(s[j].length()>columnSizes.get(sr.Question_gne__c)) columnSizes.put(sr.Question_gne__c,s[j].length());
                                }
                            }
                            a_list += '</select>';
                    }else if(sr.Type_gne__c == 'List of Values'){
                            a_list += '<select ID="'+sr.Question_gne__c+'">';
                            if(sr.Selected_Label_gne__c == null){
                                response = ' ';
                            }else response = sr.Selected_Label_gne__c;
                            methods += 'var combo'+questionsMap.get(sr.Question_gne__c).Position_gne__c.intValue()+' = new Ext.form.ComboBox({editable: false, typeAhead: false,triggerAction: \'all\',lazyRender:true,mode: \'local\', transform: \''+sr.Question_gne__c+'\'}); ';
                            List<String> s = new List<String>();
                            if(sr.Values_gne__c != null){
                                s = sr.Values_gne__c.split(',');
                                for(integer j=0; j<s.size();j++){
                                    a_list += '<option>'+s[j]+'</option>';
                                    if(s[j].length()>columnSizes.get(sr.Question_gne__c)) columnSizes.put(sr.Question_gne__c,s[j].length());
                                }
                            }
                            a_list += '</select>';
                    } else if(sr.Type_gne__c == 'Free Text') {
                        response = sr.Free_Text_gne__c!=null ? 'decodeURIComponent(\'' + EncodingUtil.urlEncode(sr.Free_Text_gne__c, 'UTF-8') + '\'.replace(/[+]/g, \' \'))' : '\'\'';
                        a_list += ' ';
                    }

                    String tempResponse = sr.Type_gne__c == 'Free Text' ? response : '\''+response+'\'';

                    if(index == 1){
                        if(dataList != ''){
                            if(i > 0){
                                dataList +='[';
                            }else dataList += ',[';
                        }else dataList += '[';
                    }
                    if(dataList == '[' || index == 1){
                        //dataList += '\''+accIDtoName.get(survey.Account__c)+'\',\''+survey.id+'\','+tempResponse+'';
                        dataList += '\''+survey.Id+'\',\''+accIDtoName.get(survey.Account__c)+'\','+tempResponse+'';
                    //}else { dataList += ','+tempResponse+''; }
                    }else { dataList += ','+tempResponse+''; }
                    endTag += ',\'\'';
                    wrapper.qAccount = survey.Account__c;
                    wrapper.Survey = survey.ID;
                }
            if(i == this.Surveys.size()-1){
                dataList += ']';
            }else dataList +='],';
            wrapper.question = dataList;
            this.wrapperList.add(wrapper);
        }
    }

    public PageReference saveData(){

        //List<Survey_Response_gne__c> responseList = new List<Survey_Response_gne__c>();
        //List<Survey_Response_gne__c> toSave = new List<Survey_Response_gne__c>();
        if(this.newSurveyAccs.size() > 0)
            createNewSurveys();
        system.debug('OG:'+this.rows);
        List<string> split = this.rows.split(':::abcxyz:::');
        for(String s : split){
            List<String> st = s.split(':::',-1);
            String sub = st[0].substring(0,18);
            system.debug('***SUBSTRING:'+sub);
            // DECIDE IF WE ARE UPDATING OR CREATING A NEW SURVEY RESPONSE
            if(sub == '000000000000000000'){
                system.debug('\n\n -------------> st: ' + st);
                createResponse(st);
            }else {
                system.debug('\n\n -------------> st: ' + st);
                updateResponse(st);
            }
        }
        system.debug('*returned:'+this.toSave);

        try{
            upsert(toSave);
        }catch(DmlException e){System.debug(e.getMessage());}
        //Schema.Describesobjectresult result = Schema.Sobjecttype.Account_Plan_vod__c;
        //System.debug(result.getKeyPrefix());
        PageReference newpage = new PageReference('/apex/GNE_MCCO_PFT_MySurveys_Tab?sfdc.tabName=01rQ00000004NjE');
        newpage.setRedirect(true);
        return newpage;

    }

    public PageReference saveDataSFA2(){

        //List<Survey_Response_gne__c> responseList = new List<Survey_Response_gne__c>();
        //List<Survey_Response_gne__c> toSave = new List<Survey_Response_gne__c>();
        if(this.newSurveyAccs.size() > 0)
            createNewSurveys();
        system.debug('OG:'+this.rows);
        List<string> split = this.rows.split(':::abcxyz:::');
        for(String s : split){
            List<String> st = s.split(':::',-1);
            String sub = st[0].substring(0,18);
            system.debug('***SUBSTRING:'+sub);
            // DECIDE IF WE ARE UPDATING OR CREATING A NEW SURVEY RESPONSE
            if(sub == '000000000000000000'){
                system.debug('\n\n -------------> st: ' + st);
                createResponse(st);
            }else {
                system.debug('\n\n -------------> st: ' + st);
                updateResponse(st);
            }
        }
        system.debug('*returned:'+this.toSave);

        try{
            upsert(toSave);
        }catch(DmlException e){System.debug(e.getMessage());}
        //Schema.Describesobjectresult result = Schema.Sobjecttype.Account_Plan_vod__c;
        //System.debug(result.getKeyPrefix());
        PageReference newpage = new PageReference('/apex/GNE_SFA2_MySurveys_MCCO_PFT');
        newpage.setRedirect(true);
        return newpage;

    }

    public void createNewSurveys(){
        Set<ID> accountNames = new Set<ID>();

        List<string> split = this.rows.split(':::abcxyz:::');
        system.debug('this.rows: ' + this.rows);
        for(String s : split){
            List<String> st = s.split(':::');
            String sub = st[0].substring(0,18);
            //3. DECIDE IF WE ARE UPDATING OR CREATING A NEW SURVEY RESPONSE
            if(sub == '000000000000000000'){
                Integer i =0;
                Boolean isFound = false;
                List<String> accIdList = new List<String>(this.accIDtoName.keySet());
                while ((i < accIdList.size()) && (!isFound)) {
                  if (accIDtoName.get(accIdList[i]) == st[1]) {
                    //accountNames.add(this.accNametoIDMap.get(st[1]));
                    accountNames.add(accIdList[i]);
                    isFound = true;
                  }
                  i++;
                }

            }
        }

        List<Survey_gne__c> newSurveys = new List<Survey_gne__c>();

        for(ID accID : this.newSurveyAccs){
            if(accountNames.contains(accID)){
                newSurveys.add(new Survey_gne__c(
                    Account__c = accID,
                    Questionnaire_gne__c = this.questionnaire.ID
                ));
            }
        }
        if(accountNames.size() > 0){
            try{
                insert(newSurveys);
            }catch(DmlException e){System.debug(e.getMessage());}
            for(Survey_gne__c s : newSurveys){
                if(!accIDtoSurveyIDMap.containsKey(s.Account__c)){
                    accIDtoSurveyIDMap.put(s.Account__c,s.ID);
                }
            }
        }
    }

    public void createResponse(List<String> responses){
        for(integer i=2;i<responses.size();i++){

            Integer j =0;
            Boolean isFound = false;
            String accID = '';
            List<String> accIdList = new List<String>(this.accIDtoName.keySet());
            while ((j < accIdList.size()) && (!isFound)) {
                if (accIDtoName.get(accIdList[j]) == responses[1]) {
                    accID = accIdList[j];
                    isFound = true;
                }
                j++;
            }

            Survey_Response_gne__c newResponse = new Survey_Response_gne__c();
            //newResponse.Survey_gne__c = this.accIDtoSurveyIDMap.get(this.accNametoIDMap.get(responses[1]));
            newResponse.Survey_gne__c = this.accIDtoSurveyIDMap.get(accID);
            newResponse.Title_gne__c = this.Questions[i-2].Title_gne__c;
            newResponse.Help_Text_gne__c = this.Questions[i-2].Help_text_gne__c;

            newResponse.Minimum_Score_gne__c = this.Questions[i-2].minimum_score_gne__c;
            newResponse.Maximum_Score_gne__c = this.Questions[i-2].Maximum_Score_gne__c;
            newResponse.Weight_gne__c = this.Questions[i-2].Weight_gne__c;
            newResponse.Position_gne__c = this.Questions[i-2].Position_gne__c;

            newResponse.Category_gne__c = this.sCategory;
            newResponse.Values_gne__c = this.Questions[i-2].Values_gne__c;
            newResponse.Labels_gne__c = this.Questions[i-2].Labels_gne__c;
            newResponse.Type_gne__c = this.Questions[i-2].Type_gne__c;

            newResponse.Question_gne__c = this.Questions[i-2].ID;

            if(this.Questions[i-2].Type_gne__c == 'Numeric'){
                System.Debug('XXXXXXXXXXXX : ' + responses[i]);
                try {
                    newResponse.Response_Score_gne__c = decimal.valueOf(responses[i]);
                } catch(Exception e) {
                    // do nothing, response value will be null
                }
            } else if (this.Questions[i-2].Type_gne__c == 'Free Text') {
                System.Debug('[BOS]:: Free Text = ' + responses[i]);
                newResponse.Free_Text_gne__c = responses[i];
            }else {
                if(responses[i] != 'null'){
                    newResponse.selected_Label_gne__c = responses[i];
                }else newResponse.selected_Label_gne__c = ' ';

            }
            this.toSave.add(newResponse);

        }
    }

    public void updateResponse(List<String> responses){
        this.responseList = this.SurveyToResponses.get(responses[0]);
            for(integer i=0; i<responseList.size();i++){
                if(responseList[i].Type_gne__c == 'Numeric'){
                    try {
                        responseList[i].Response_Score_gne__c = decimal.valueOf(responses[i+2]);
                    } catch(Exception e) {
                        // do nothing, response value will be null
                    }
                } else if(responseList[i].Type_gne__c == 'Free Text') {
                    responseList[i].Free_Text_gne__c = responses[i+2];
                } else {
                    responseList[i].selected_Label_gne__c = responses[i+2];
                }
                this.toSave.add(responseList[i]);
            }
    }

    public List<SelectOption> getResponses(){
        responseOptions = new List<SelectOption>();

        set<String> responsesList = new set<String>();

        /*for(Survey_Response_gne__c sr : this.SurveyToResponses.get(currentAccount)){
            if(sr.Labels_gne__c != null){
                for(String response : sr.Labels_gne__c.split(',')){
                    responsesList.add(response);
                }
            }
        }

        for(String resp : responsesList){
            responseOptions.add(new SelectOption('', resp));
        }

        system.debug(responseOptions);
        */
        //return responseOptions;
        return null;

    }

    public PageReference cancel(){
        PageReference result = new PageReference('/apex/apex/GNE_MCCO_PFT_MySurveys_Tab');
        result.setRedirect(true);
        return result;
    }

    public PageReference cancelSFA2(){
        PageReference result = new PageReference('/apex/apex/GNE_SFA2_MySurveys_MCCO_PFT');
        result.setRedirect(true);
        return result;
    }

    public class qObj {
        public String QAccount {get; set;}
        public string Question {get; set;}
        public String Survey {get; set;}
    }
}