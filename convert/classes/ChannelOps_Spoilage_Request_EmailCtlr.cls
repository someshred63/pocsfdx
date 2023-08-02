/**********************************************************************
Purpose: ChannelOps_Spoilage_Request_EmailCtlr class is bind with 
         ChannelOps_Spoilage_Request_EmailForms page. It is used to send 
         email to customer regarding customer correction, forward request to
         quality team and adverse event team
=======================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL
1.0                                 INITIAL DEVELOPMENT
1.1      Vijay      09/05/2019      Added logic to send the email to 
                                    customer for request corrections.
1.2		 Vijay      10/15/2019      Added CC email field to capture the cc emails 
									for send customer correction.
1.3		Vijay		02/20/2020		updated logic to get email template by DeveloperName
***********************************************************************/
public class ChannelOps_Spoilage_Request_EmailCtlr {
    private ID requestId;
    private List<EmailTemplate> templates;
    private String qaAddress, adverseAddress;
    public Boolean useTemplate {set; get;}
    private EmailTemplate template;       
    
    
    public String attID {set; get;}
    public String attName {set; get;}
    public String errorMsg {set; get;}
    
    public List<SelectOption> listEmailtemplateoptions{set;}
    public String selectedtemplate {get; set;}
    
    public string subject{get; set;}         
    public string Content{get; set;}
    public string recipients{get; set;}
    public string bcc {get; set;}
    
    //variable to hold the cc emails
    public string cc {get;set;}
    
    
    public list<GNE_Channel_Ops_Email_Tracker__c> lstemailtracker;
    
    //Added by vijay
    public Boolean isPendingCustomerCorrection {get;set;}
    public String pgTitle {get;set;}
    private ChannelOps_Spoilage_Request__c spoilageRequest;
    
    
    public ChannelOps_Spoilage_Request_EmailCtlr(ApexPages.StandardController controller) {
        requestId = controller.getRecord().id;
        String requestStatus = ApexPages.currentPage().getParameters().get('status');        
        
        List<ChannelOps_Spoilage_Request__c> spoilageRequstList = [Select Id, Name, Contact_Name__c, Submission_Date__c,
                                                                          Contact_Email__c, Status__c,License_Num__c,
                                                                   		  PDF_Attachment_ID__c
                                                                   From ChannelOps_Spoilage_Request__c Where Id =: requestId];
        
        if(spoilageRequstList !=null && !spoilageRequstList.isEmpty()){
            spoilageRequest = spoilageRequstList[0];
            List<Attachment> attachmentList = [SELECT Id, Name FROM Attachment WHERE Id=: spoilageRequest.PDF_Attachment_ID__c LIMIT 1];
            if(attachmentList != null && !attachmentList.isEmpty()){
                attID = attachmentList[0].id;
                attName = attachmentList[0].name;
            }
        }
        if(String.isNotBlank(requestStatus) && requestStatus == 'pcc'){  
            pgTitle = 'Customer Correction Email Spoilage Request: '+ spoilageRequest.Name; 
            isPendingCustomerCorrection = true;
            prepareEmailTemplate();
        }else{
            templates=[select id, Name, body, subject, DeveloperName from emailtemplate where DeveloperName in ('Forward_Request_to_Genentech_Adverse_Events_Team','ChannelOps_Forward_Request_to_Genentech_Quality_Team')]; //'Forward Request to Genentech Adverse Events Team','Forward Request to Genentech Quality Team'
            pgTitle = 'Email Spoilage Request '+ attName;
            isPendingCustomerCorrection = false;
        }
        
        ChannelOps_App_Property__c property=[select Adverse_Event_Email_Address__c, QA_Email_Address__c from ChannelOps_App_Property__c where active__c=true and Application_Name__c='Spoilage From' limit 1];
        qaAddress=property.QA_Email_Address__c ;
        adverseAddress=property.Adverse_Event_Email_Address__c;
        useTemplate =false;
        
    }
    
    private void prepareEmailTemplate(){
        List<EmailTemplate> templateList = [select id, Name, body, subject, HtmlValue,DeveloperName From emailtemplate where DeveloperName = 'ChannelOps_Spoilage_Customer_Correction_Email' ]; 
        if(!templateList.isEmpty()){
            this.subject=templateList[0].subject.replace('{!ChannelOps_Spoilage_Request__c.Name}', spoilageRequest.Name);  
            this.content= replaceFieldInEmailBody(templateList[0].HtmlValue, spoilageRequest);  
            recipients =(String.isNotBlank(spoilageRequest.Contact_Email__c)) ? spoilageRequest.Contact_Email__c: '';
        }
        
    }
    
    private String replaceFieldInEmailBody(String body, ChannelOps_Spoilage_Request__c spoilageRequest){
        if(String.isNotBlank(body) && spoilageRequest != null){
            
            body = (String.isNotBlank(spoilageRequest.Contact_Name__c)) ? body.replace('{!ChannelOps_Spoilage_Request__c.Contact_Name__c}', spoilageRequest.Contact_Name__c) : body.replace('{!ChannelOps_Spoilage_Request__c.Contact_Name__c}', 'Customer');
            body = (String.isNotBlank(spoilageRequest.Contact_Email__c)) ? body.replace('{!ChannelOps_Spoilage_Request__c.Contact_Email__c}', spoilageRequest.Contact_Email__c) : body.replace('{!ChannelOps_Spoilage_Request__c.Contact_Email__c}', '');
            body = (String.isNotBlank(spoilageRequest.License_Num__c)) ? body.replace('{!ChannelOps_Spoilage_Request__c.License_Num__c}', spoilageRequest.License_Num__c) : body.replace('{!ChannelOps_Spoilage_Request__c.License_Num__c}', '');
            body = body.replace('{!ChannelOps_Spoilage_Request__c.Submission_Date__c}', ChannelOps_SpoilageRequest_Util.formatDateInMMDDYYYY(spoilageRequest.Submission_Date__c));
            body = body.replace('{!ChannelOps_Spoilage_Request_Site_URL}', Label.ChannelOps_Spoilage_Request_Site_Domain_URL +'/ChannelOps_SpoilageRequest_Selection');
            body = body.replace('{!ChannelOps_Spoilage_Request__c.Name}', spoilageRequest.Name);
        }
        System.debug('----------'+body);
        return body;
    }
    
    public List<SelectOption> getListEmailtemplateoptions(){
        List<SelectOption> options = new List<SelectOption>();
        SelectOption none=new SelectOption('None', 'None');
        options.add(none);
        if(templates!=null && templates.size()>0){
            Integer index=0;
            for(Emailtemplate et: templates) {
                SelectOption op=new SelectOption (et.name+'-'+index, et.name);
                options.add(op);
                index +=1;
            }
        }
        return options;
    }
    
    private void getEmailTemplate(String str){
        Integer index;
        Integer i= str.lastIndexOf('-');
        if(i!=-1) {
            i+=1;
            String temp=str.substring(i);
            index = Integer.valueOf(temp);
            template= templates.get(index);
        }
        
        
    }
    
    public PageReference templateChange(){
        
        if(selectedtemplate!=null && selectedtemplate!='None') {
            getEmailTemplate(selectedtemplate);   
            this.subject=template.subject;  
            this.content=template.body;
            useTemplate =true;
            if( selectedtemplate.indexOf('Quality')!=-1) recipients =qaAddress+';';   
            else recipients =adverseAddress+';';
        }else {
            recipients ='';
            useTemplate =false;
            subject='';
            content='';
            template=null;
        }
        errorMsg ='';
        return null;
    }
    
    private Boolean validateEmailForm(){
        
        errorMsg='';
        if(recipients==null || recipients.trim().length()<=0) errorMsg='Please enter recipients<br/>';
        if(subject==null || subject.trim().length()<=0)  errorMsg+='Please enter subject<br/>';
        if(Content==null || Content.trim().length()<=0) errorMsg+='Please enter content';
        if (errorMsg.length()>0) return false;
        else return true;
    }
    
    public PageReference sendEmailForms(){
        //if form is not completed, display error message
        if(!validateEmailForm()) return null;
        
        List<String> toAddress=createAddressList(recipients);
        List<String> bccAddress=createAddressList(bcc);
        List<String> ccAddress=createAddressList(cc);
        
        if(useTemplate){
            sendConfirmationEmail(attID, template.DeveloperName, toAddress, requestId, bccAddress);
        }else{
            Boolean isHtmlBody = false;
            if(isPendingCustomerCorrection){
                isHtmlBody = true;
                spoilageRequest.Status__c = (spoilageRequest.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_DRAFT) ?  ChannelOps_Constants.SPOILAGE_STATUS_PENDING_CUST_CORRECTION : spoilageRequest.Status__c;
                update spoilageRequest;
            }
            sendConfirmationEmail(attID, subject, Content, toAddress, requestId, ccAddress, bccAddress, isHtmlBody);                
        } 
        return new PageReference('/'+requestId);
    }
    
    public PageReference Cancel(){
        return new PageReference('/'+requestId);
    }
    
    private List<String> createAddressList(String str){
        List<String> result=new List<String> ();
        if(str!=null && str.trim().length()>0) {
            result=str.split(';');
        }
        return result;
    }
    
    @future
    static void sendConfirmationEmail(ID attachId, String emailTemplate , List<string> toAddress, ID requestId, List<string> bcc) {
        Attachment att = null;
        if(attachId != null){
        	att = [select id, body, name from Attachment where id=:attachId Order by LastModifiedDate DESC limit 1];
        } 
        // Create the email attachment
        Messaging.EmailFileAttachment efa = null;
        if(att != null){
            efa = new Messaging.EmailFileAttachment();     
            efa.setFileName(att.name );
            efa.setBody(att.body);
        }
        
        // Define the email 
        EmailTemplate et = [SELECT Id, name,Subject,HtmlValue, body FROM EmailTemplate WHERE DeveloperName =:emailTemplate ];
        
        //only to make email template works well
        Contact c=[select id, name, email from Contact where name='Lwo Monitor' limit 1];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(et.Id);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setWhatId(requestId);       
        mail.setTargetObjectId(c.id);
        mail.setToAddresses(toAddress);
        if(bcc!=null && bcc.size()>0) mail.setBccAddresses(bcc);
        
        //set from email address to org wide email address
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
        
        
        
        //set reply to to ChannelOpsCasesSendtemplatereply email service
        EmailServicesFunction emsf = [select id, FunctionName from EmailServicesFunction where functionname='ChannelOpsCasesSendtemplatereply'];
        EmailServicesAddress emsa = [SELECT EmailDomainName,LocalPart FROM EmailServicesAddress where FunctionId=: emsf.id];
        string replyemail = emsa.LocalPart+'@'+emsa.EmailDomainName;
        mail.setReplyTo(replyemail);
        
        if(efa != null){
        	mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        }
        
        // Sends the email 
        try{
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});  
        }catch(Exception e){
            System.debug('failed to send spoilage request confirmation email due to: '+e.getMessage());
        }
        
        
        //log outbound emails
        GNE_Channel_Ops_Email_Tracker__c newEmail=new GNE_Channel_Ops_Email_Tracker__c();
        newEmail.Send_By__c=UserInfo.getUserId();
        newEmail.From_Address__c =orgWideAddress.Address ;
        newEmail.ChannelOps_Spoilage_Request__c=requestId;
        newEmail.Use_email_Tempate__c=true;
        newEmail.Email_Template_Name__c=et.name;
        newEmail.Time_Stamp__c=System.now();
        newEmail.To_Address__c='';
        for(String temp: toAddress) {
            newEmail.To_Address__c+=temp+',';
        }
        newEmail.BCC__c='';
        for(String temp: bcc) {
            newEmail.BCC__c+=temp+',';
        }
        if(att != null){
        	newEmail.Attachments__c=att.name;
        }
        try{
            
            insert newEmail;
            
        }catch(Exception e){
            System.debug('Log email failed due to: '+e.getMessage());
        }
    } 
    
    @future
    static void sendConfirmationEmail(ID attachId, String subject, String body, List<string> toAddress, ID requestId, List<string> ccAddress, List<string> bcc, Boolean isHtmlBody) {
        Attachment att = null;
        if(attachId != null){
            List<Attachment> attachmentList =[select id, body, name from Attachment where id=:attachId Order by LastModifiedDate DESC limit 1];
            att = attachmentList[0];
        }    
        // Create the email attachment
        Messaging.EmailFileAttachment efa = null;
        if(att != null){
            efa = new Messaging.EmailFileAttachment();     
            efa.setFileName(att.name );
            efa.setBody(att.body);
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(isHtmlBody){
            mail.setHtmlBody(body);
        }else{
            mail.setPlainTextBody(body);
        }
        
        mail.setSubject(subject);
        mail.setToAddresses(toAddress);
        if(bcc!=null && bcc.size()>0) mail.setBccAddresses(bcc);
        
        if(ccAddress != null && !ccAddress.isEmpty()){
            mail.setCcAddresses(ccAddress);
        }
        
        //set from email address to org wide email address
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
        
        
        
        //set reply to to ChannelOpsCasesSendtemplatereply email service
        EmailServicesFunction emsf = [select id, FunctionName from EmailServicesFunction where functionname='ChannelOpsCasesSendtemplatereply'];
        EmailServicesAddress emsa = [SELECT EmailDomainName,LocalPart FROM EmailServicesAddress where FunctionId=: emsf.id];
        string replyemail = emsa.LocalPart+'@'+emsa.EmailDomainName;
        mail.setReplyTo(replyemail);
        
        if(efa != null){
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        }
        // Sends the email 
        try{
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});  
        }catch(Exception e){
            System.debug('failed to send spoilage request confirmation email due to: '+e.getMessage());
        }
        
        
        //log outbound emails
        GNE_Channel_Ops_Email_Tracker__c newEmail=new GNE_Channel_Ops_Email_Tracker__c();
        newEmail.Send_By__c=UserInfo.getUserId();
        newEmail.From_Address__c =orgWideAddress.Address ;
        newEmail.ChannelOps_Spoilage_Request__c=requestId;
        newEmail.Use_email_Tempate__c=false;
        newEmail.Subject__c=subject;
        newEmail.Body__c=body;
        newEmail.Time_Stamp__c=System.now();
        newEmail.To_Address__c='';
        for(String temp: toAddress) {
            newEmail.To_Address__c+=temp+',';
        }
        newEmail.BCC__c='';
        for(String temp: bcc) {
            newEmail.BCC__c+=temp+',';
        }
        newEmail.CC__c='';
        for(String ccEmail: ccAddress) {
            newEmail.CC__c+=ccEmail+',';
        }
        if(att != null){
        	newEmail.Attachments__c=att.name;
        }
        try{
            
            insert newEmail;
            
        }catch(Exception e){
            System.debug('Log email failed due to: '+e.getMessage());
        }
    }      
    
}