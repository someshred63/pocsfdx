public class GNE_CRM_CC_Case_Details_Ctrl {
        
        public GNE_CRM_CC_Case__c myObject {get; set;}
        public List<GNE_CRM_CC_Related_Product__c> relatedProducts {get; set;}
        public List<GNE_CRM_CC_Question__c> questions {get; set;}
        public List<GNE_CRM_CC_Answer__c> answers {get; set;}
        public List<QuestionWrapper> questionWrappers {get; private set;}
        public Boolean noProductsFound {get; private set;}
        public String[] listEmailTemplate{get; set;}
        public List<SelectOption> listEmailtemplateoptions{get; set;}
        public Map<Integer, emailtemplate> mapTotemailtemplate{get; set;} 
        public Map<Integer, attachment> mapToattachment{get; set;} 
        list<emailtemplate> lsttemplate;
        public string firsttemplate{get; set;}
        public string subjectTemplate{get; set;}
        public string contentTemplate{get; set;}
        public String selectedtemplate {get; set;}
        public list<GNE_Channel_Ops_Email_Tracker__c> lstemailtracker;
        public list<emailtrackerclass> lsttrackerclass{get;set;}
        
        public GNE_CRM_CC_Case_Details_Ctrl(ApexPages.StandardController stdCtrl) {
        lstemailtracker = new list<GNE_Channel_Ops_Email_Tracker__c>();
        lsttrackerclass = new list<emailtrackerclass>();
        mapTotemailtemplate = new Map<Integer, emailtemplate>();
        SelectOption option = new SelectOption('--None--', '--None--');
      
        if(!Test.isRunningTest()){
        stdCtrl.addFields(new List<String>{'Name', 'Account_Name_ref__c', 'Contact_Name__c', 'Telephone__c', 'Call_Type__c', 'Email__c', 'Account_Name__c', 
        'SAP_Account_Id__c', 'Account_Type__c', 'SAP_Account_Id_Sold_To__c', 'Address__c', 'Zip_Code__c', 'Inquiry__c', 'Warm_Call_Transfer_To_Name__c', 'OTN__c',
        'Order_Number__c', 'Comments__c', 'OwnerId', 'Case_Status__c'});
        }
        myObject = (GNE_CRM_CC_Case__c)stdCtrl.getRecord();
        lstemailtracker = [select Attachments__c, BCC__c, Body__c, From_Address__c, Subject__c, Time_Stamp__c, To_Address__c, GNE_Sent_by_User__c from GNE_Channel_Ops_Email_Tracker__c where Parent_Case__c =: myObject.Id ORDER BY createddate DESC];
        if(lstemailtracker.size()>0)
        for(GNE_Channel_Ops_Email_Tracker__c l : lstemailtracker){
        lsttrackerclass.add(new emailtrackerclass(l));
        }
        system.debug(lsttrackerclass);
        listEmailTemplate = new list<string>();
        listEmailtemplateoptions = new List<SelectOption>();
        lsttemplate = new list<emailtemplate>();
        // listEmailtemplateoptions.add(new SelectOption('--None--','--None--'));
        //As part of these change(CHG0185671) added "AND isActive=true"
        lsttemplate = [select id, Name, body, subject from emailtemplate where folder.name = 'GNE-CUSTOPS Cases Email Forms Templates' AND IsActive=true];        
        lsttemplate.sort();
        if(lsttemplate.size()>0){
        for(emailtemplate em : lsttemplate){
       
        listEmailtemplateoptions.add(new SelectOption(em.Name,em.Name));
        }
       // listEmailtemplateoptions.sort();
        firsttemplate = lsttemplate[0].Name;
        }
        
       
        } 
        
        public void init(){
        initProducts();
        initQuestions();
        }
        
        @RemoteAction
        public static String sendEmail(String emailSubject, String emailRecipients, String emailBody){
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        Id orgWideAddressId = null;
        try{
        orgWideAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :GNE_CRM_CC_From_Address__c.getInstance('defaultFromAddress').Org_Wide_Address_Name__c LIMIT 1].Id;
        } catch (Exception ex){
        system.debug('OrgWide address or configuration not found');
        }
        if(orgWideAddressId != null){
        mail.setOrgWideEmailAddressId(orgWideAddressId);
        }
        mail.setToAddresses(emailRecipients.split(';'));
        mail.setSubject(emailSubject);
        mail.setPlainTextBody(emailBody);
        emailsToSend.add(mail);
        if(emailsToSend.size()>0){
        try{
        Messaging.sendEmail(emailsToSend);
        } catch(Exception ex){
        return ex.getMessage();
        }
        }
        return null;
        }
        
        
        
        @RemoteAction
        public static String sendEmailForms(String caseId, String templatename, string subject, string content, String emailRecipients){
       system.debug('emailRecipients'+emailRecipients);
        GNE_CRM_CC_Case__c cc = [select Id, Name from GNE_CRM_CC_Case__c where id =: caseId];
        emailtemplate template = [Select Id, subject, body, name from emailtemplate where Name =: templatename limit 1];
        list<attachment> lstatt = new list<attachment>();
        lstatt = [select name, id from attachment where parentid =: template.id  ];
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress orgWideAddress = null;
        
        try{
         string sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        
        orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'noreplyco-d@gene.com'];
        if(sfdcBaseURL.contains('dev') || sfdcBaseURL.contains('sqa') || sfdcBaseURL.contains('uat')){
        orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'gneforms-d@gene.com'];
        }
      
        } catch (Exception ex){
        system.debug('OrgWide address or configuration not found');
        }
        if(orgWideAddress != null){
        mail.setOrgWideEmailAddressId(orgWideAddress.Id);
        }
        //mail.setSenderDisplayName('doNotReply@Genentech.com');
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setWhatId(cc.Id);
        list<string> lstemail = new list<string>();
        set<string> setemail = new set<string>();
        lstemail = emailRecipients.split(';');
        system.debug('emailRecipients'+lstemail);
        setemail.addAll(lstemail);
        list<contact> lstc = new list<contact>();
        ChannelOps_App_Property__c property=[select Account_Name_for_sending_email__c from ChannelOps_App_Property__c where active__c=true and Application_Name__c='Spoilage From' limit 1];
        String accountName='';
        if(property.Account_Name_for_sending_email__c !=null) accountName=property.Account_Name_for_sending_email__c;
        lstc = [select id, email from contact where name=:accountName limit 1];
        EmailServicesFunction emsf = [select id, FunctionName from EmailServicesFunction where functionname='ChannelOpsCasesSendtemplatereply'];
        EmailServicesAddress emsa = [SELECT EmailDomainName,LocalPart FROM EmailServicesAddress where FunctionId=: emsf.id];
        string replyemail = emsa.LocalPart+'@'+emsa.EmailDomainName;
        mail.setReplyTo(replyemail);
        mail.setTemplateID(template.Id);
        if(lstc.size()>0){
        mail.setTargetObjectId(lstc[0].Id);
        boolean b = setemail.remove(lstc[0].Email);
        list<string> lststr = new list<string>();
        lststr.addall(setemail);
        mail.setToAddresses(lstemail);
        system.debug('emailRecipients'+lststr);
        mail.setBccAddresses( new String[]{UserInfo.getUserEmail()});

        }
        else{
         list<string> lststr = new list<string>();
        lststr.addall(setemail);
        contact c = [select id from contact limit 1];
        mail.setTargetObjectId(c.Id);
         mail.setToAddresses(lststr);
         system.debug('emailRecipients'+lststr);
        mail.setBccAddresses( new String[]{UserInfo.getUserEmail()});

        }
        mail.setSaveAsActivity(false);
        emailsToSend.add(mail);
        if(emailsToSend.size()>0){
        try{
          Messaging.sendEmail(emailsToSend);
          Messaging.SingleEmailMessage sem = emailsToSend[0];
          GNE_Channel_Ops_Email_Tracker__c et = new GNE_Channel_Ops_Email_Tracker__c();
          et.From_Address__c = orgWideAddress.Address;
          et.To_Address__c = emailRecipients;
          et.BCC__c = UserInfo.getUserEmail();
          et.GNE_Sent_by_User__c = userinfo.getuserid();
          et.Subject__c = template.subject;
          et.Body__c = template.body;
          et.Parent_Case__c = caseId;
          et.Time_Stamp__c = datetime.now();
          string str = '';
          for(attachment att : lstatt){
          str = str + template.name + '--'+att.name+';';
          }
          et.Attachments__c = str;
          insert et;
        } catch(Exception ex){
        return ex.getMessage();
        }
        }
        return null;
        }
        
        
        
        public PageReference goToEditPage(){
        PageReference pr = Page.GNE_CRM_CC_Log_Case;
        pr.getParameters().put('id', myObject.Id);
        pr.getParameters().put('retUrl', Page.GNE_CRM_CC_Case_Details.getUrl() + '?id=' + myObject.Id);
        pr.setRedirect(true);
        return pr;
        }
        
        public PageReference goToSendEmailPage(){
        return null;
        }
        
        private void initProducts(){
        relatedProducts = [SELECT Id, Case_ref__c, Product__c, Order__c FROM GNE_CRM_CC_Related_Product__c WHERE Case_ref__c = :myObject.Id ORDER BY Order__c];
        noProductsFound = relatedProducts.size() == 0;
        } 
        
        private void initQuestions(){
        setQuestionWrappers(myObject.Inquiry__c);
        }
        
        private List<GNE_CRM_CC_Question__c> getQuestions(String inquiry){
        return [SELECT Id, External_Id__c, Inquiry__c, Possible_Values__c, Question__c, Type__c, Order__c, Prerequisite__c, (SELECT Id, Case_ref__c, Selected_Answer__c FROM Answers__r WHERE Case_ref__c = :myObject.Id) FROM GNE_CRM_CC_Question__c WHERE Inquiry__c = :inquiry ORDER BY Order__c];
        }
        
        private void setQuestionWrappers(String inquiry){
        questionWrappers = new List<QuestionWrapper>();
        Map<String, Boolean> externalIdsToCheckboxValue = new Map<String, Boolean>();
        for(GNE_CRM_CC_Question__c question :getQuestions(inquiry)){
        QuestionWrapper qw = new QuestionWrapper(question);
        questionWrappers.add(qw);
        externalIdsToCheckboxValue.put(qw.externalId, qw.checkboxValue);
        }
        
        for(Integer i = 0; i < questionWrappers.size();){
        String prerequisite = questionWrappers[i].prerequisite;
        if(String.isNotBlank(prerequisite) && (externalIdsToCheckboxValue.get(prerequisite) == null || !externalIdsToCheckboxValue.get(prerequisite))){
        questionWrappers.remove(i);
        } else {
        i++;
        }
        }
        }
        
        public class QuestionWrapper{
        private GNE_CRM_CC_Question__c question;
        private GNE_CRM_CC_Answer__c answer;
        public String label {get; private set;}
        public String selectedValue {get; set;}
        public Boolean checkboxValue {get; set;}
        public String type {get; private set;}
        public String externalId {get; private set;}
        public String prerequisite {get; private set;}
        
        public QuestionWrapper(GNE_CRM_CC_Question__c question){
        this.question = question;
        label = question.Question__c;
        type = question.Type__c;
        externalId = question.External_Id__c;
        prerequisite = question.Prerequisite__c;
        if(question.Answers__r.size()>0){
        setAnswer(question.Answers__r[0]);
        } else {
        answer = new GNE_CRM_CC_Answer__c(Question_ref__c = question.Id);
        }
        }
        
        private void setAnswer(GNE_CRM_CC_Answer__c answer){
        this.answer = answer;
        if(type.equalsIgnoreCase('Checkbox')){
        checkboxValue = Boolean.valueOf(answer.Selected_Answer__c);
        } else if(type.equalsIgnoreCase('Multi Select') || type.equalsIgnoreCase('Dropdown') || type.equalsIgnoreCase('Text') || type.equalsIgnoreCase('Numeric') || type.equalsIgnoreCase('Alpha-Numeric')){
        selectedValue = answer.Selected_Answer__c;
        }
        }
        }
        
        public Boolean getOpenCase(){
        if(myObject.Case_Status__c == 'Closed') return false;
        else return true;
        }
        
        //Jie added in May 2017
        
        public PageReference openNewCase(){
        
        return new PageReference ('/apex/GNE_CRM_CC_Log_Case');
        }
        
        public PageReference cloneCase(){
        //Keep old case information and open a new case page
        //myObject.id=null;
        PageReference page=new PageReference('/apex/GNE_CRM_CC_Log_Case');
        page.getParameters().put('caseId', myObject.id);
        page.getParameters().put('cloneparam', 'true');
        return page;
        }
        
        //End of Jie 2017 addition
        
         
        public void templateChange(){
        string passedParam1 = Apexpages.currentPage().getParameters().get('myParam');
        string tempname = passedParam1;
        emailtemplate em = [select id, name, subject, body from emailtemplate where name =: tempname ];
        list<attachment> lstatt = [select name, id from attachment where parentid =: em.id  ];
        /*Always clear the List when begin so that previous values will be removed.*/
        
        subjectTemplate = em.subject;
        contentTemplate = em.body;
        contentTemplate = contentTemplate.replace('<div >', '');
        contentTemplate = contentTemplate.replace('</div>', '');
        contentTemplate = contentTemplate.replace('{!IF(GNE_CRM_CC_Case__c.Name=\'\', \"\" , \"Case Number: \" +GNE_CRM_CC_Case__c.Name)}', '');
        system.debug(contentTemplate);
        Integer i = 0;
        for (emailtemplate e : lsttemplate) {
        mapTotemailtemplate.put(i, e);
        i++;
        }
        i = 0;
        mapToattachment = new map<integer, attachment>();
        for (attachment e : lstatt) {
        mapToattachment.put(i, e);
        i++;
        }
        
        }
        
        public class emailtrackerclass{
        public GNE_Channel_Ops_Email_Tracker__c emtracker{get; set;}
        public map<integer, attachment> maatt{get; set;}
        public emailtrackerclass(GNE_Channel_Ops_Email_Tracker__c em){
        this.emtracker = em;
        this.maatt = new map<integer, attachment>();
        integer i = 0;
        string strtemplate = em.Attachments__c;
        if(strtemplate != null){
        list<string> liststrtemplate = strtemplate.split(';');
        for(string str: liststrtemplate){
        list<string> strr = str.split('--');
        list<attachment> at = new list<attachment>();
        system.debug(strr[0] +'==' +strr[1]);
        at= [select id, name from attachment where parent.name =: strr[0] AND name =: strr[1] ];
        if(at.size()>0)
        maatt.put(i, at[0]);
        i++;
        }
        }  
        }
        }
        
        }