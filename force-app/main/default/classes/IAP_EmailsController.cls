public  without sharing class IAP_EmailsController {
    /**
* @author Santhosh konchada
* @date 06/20/22
* @description to get the Submitter details of the record.
**/
    @AuraEnabled
    public static string submitterDetails(string recordId){
        system.debug('recordid'+ recordId);
        C_Ops_SPLOA_Request__c u = [select id, C_Ops_SPLOA_Email__c from C_Ops_SPLOA_Request__c where id =:recordId];
        system.debug('u.C_Ops_SPLOA_Email__c' + u.C_Ops_SPLOA_Email__c);
        return u.C_Ops_SPLOA_Email__c;
    }
    /**
* @author Santhosh konchada
* @date 06/20/22
* @description to get the BEM details of the record.
**/
    @AuraEnabled
    public static string bemDetails(string recordId){
        system.debug('recordid'+ recordId);
        C_Ops_SPLOA_Request__c u = [select id, C_Ops_SPLOA_Email__c from C_Ops_SPLOA_Request__c where id =:recordId];
        system.debug('u.C_Ops_SPLOA_Email__c' + u.C_Ops_SPLOA_Email__c);
        return u.C_Ops_SPLOA_Email__c;
    }
    /**
* @author Santhosh konchada
* @date 06/20/22
* @description to get the templates from "PRP Email" folder for "Send for Revision" button.
**/
    @AuraEnabled
    public static list<emailTemplates>  getEmailTempaltes(String recordId,string actionname){
        string Templatename='Customer Correction Email';
        list<emailTemplates> emailTemplateWrapperlist = new list<emailTemplates>();
        list<EmailTemplate> lstEmailTemp;
        if(actionname == 'Send Email'){
            lstEmailTemp=[ SELECT Id, FolderId, HtmlValue, FolderName, isActive, body,Name,subject 
                                          FROM EmailTemplate where isActive= true and Folder.Name = 'IAP Email Templates' and (not name =: Templatename)];
        }else{
            lstEmailTemp=[ SELECT Id, FolderId, HtmlValue, FolderName, isActive, body,Name,subject 
                                          FROM EmailTemplate where isActive= true and Folder.Name = 'IAP Email Templates' and name =: Templatename];
        }
        system.debug('lstEmailTemp@@'+lstEmailTemp);
        if(lstEmailTemp!=null && lstEmailTemp.size()>0){
            for(EmailTemplate emailtemp: lstEmailTemp){
                
                emailTemplates template = new emailTemplates();
                template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
                template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
                //template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')) :String.valueOf( emailtemp.get('body')));
                //template.emailSubject = String.valueOf(emailtemp.get('subject'));
                
                Messaging.SingleEmailMessage renderedMail = Messaging.renderStoredEmailTemplate(emailtemp.Id, null, recordId);
                template.emailbody = renderedMail.getHTMLBody();
                template.emailSubject = renderedMail.getSubject();
                
                system.debug('template.emailSubject' + template.emailSubject);
                emailTemplateWrapperlist.add( template);
            }
        }
        if(emailTemplateWrapperlist!=null && emailTemplateWrapperlist.size()>0){
            return  emailTemplateWrapperlist;
        }
        return null;
        
    }

    /**
* @author Santhosh konchada
* @date 06/20/22
* @description to send an email when "Send for Revision" button is clicked.
**/
    @AuraEnabled
    public static void sendMailMethod(String mMail ,String mccMail,String mSubject ,String mbody, String recordId,String templateId,String FileBody,String FileName,String FileType,Integer FileSize,string actionname ){
        system.debug('FileBody@@'+FileBody+'FileName@@@'+FileName+'FileType@@'+FileType+'FileSize@@'+FileSize );
        string leadName = '';
        String leadOwnerName = '' ;
        try{
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            if(FileName!=null && FileBody!=null &&  FileType!=null){
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(FileName);
                efa.setBody(Blob.ValueOf(FileBody));
                efa.setContentType(FileType);
                attachments.add(efa);
                system.debug('attachments@@'+attachments);
            }
            list<EmailTemplate> em = new list<EmailTemplate>();
            em = [SELECT Id,Subject,Body,HtmlValue From EmailTemplate where id =: templateId limit 1];
            
            
            List<EmailMessage> emailmessageList =  new List<EmailMessage>();
            emailmessageList = [select id, Subject,TextBody from emailmessage where EmailTemplateId =: templateId order By createddate desc limit 1];
            
            List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            if(mMail.contains(';'))
                sendTo.addAll(mMail.split(';'));
            if(mMail.contains(','))
                sendTo.addAll(mMail.split(','));
            if(!mMail.contains(',') && !mMail.contains(';')){
                sendTo.add(mMail);
            }
            if(String.isNotBlank(mccMail)){
                List<String> sendCC = new List<String>();
                if(mccMail.contains(';'))
                    sendCC.addAll(mccMail.split(';'));
                if(mccMail.contains(','))
                    sendCC.addAll(mccMail.split(','));
                if(!mccMail.contains(',') && !mccMail.contains(';')){
                    sendCC.add(mccMail);
                }                
                //sendCC.add(mccMail);
                mail.setCcAddresses(sendCC);
            }
            List<OrgWideEmailAddress> fe = new List<OrgWideEmailAddress>();
            fe = [Select Id, Address, DisplayName From OrgWideEmailAddress where DisplayName = 'Indirect Access Program' LIMIT 1];
            mail.setToAddresses(sendTo);
            //mail.setSenderDisplayName('Salesforce Support');
            mail.setOrgWideEmailAddressId(fe.get(0).id);
            mail.setSubject(mSubject);
            if(attachments.size()>0)
                mail.setFileAttachments(attachments);
            string htmlReplace = '' ;
            if(mbody != null && mbody != ''){
                htmlReplace = mbody;
            }
            
           mail.setHtmlBody(mbody);
            //mail.setTargetObjectId(userInfo.getUserId());
            mail.setTreatTargetObjectAsRecipient(true);
            mail.setWhatId(recordId);
            mail.setTreatBodiesAsTemplate(true);
            if(em!=null && em.size()>0)
                mail.setTemplateId(em.get(0).id);
            mail.setSaveAsActivity(false);
            mails.add(mail);
            system.debug('mails@@@'+mails);
            Messaging.SendEmailResult[] lstSendEmailResult= Messaging.sendEmail(mails);
            String ErrorMessage='';
          
            
            for(Messaging.SendEmailResult result:lstSendEmailResult){
                if(result.getErrors()!=null && result.getErrors().size()>0){
                    for(Messaging.SendEmailError error:result.getErrors()){
                        ErrorMessage=ErrorMessage+error;
                    }
                    system.debug('ErrorMessage@@'+ErrorMessage);
                }
                else if(result.isSuccess() && actionname != 'Send Email'){
                  C_Ops_SPLOA_Request__c requestiap=  [Select Id, C_Ops_SPLOA_Request_Status__c from C_Ops_SPLOA_Request__c where id =:recordId limit 1];
                    requestiap.Status_Category__c='Awaiting Updates';
                    update requestiap;
                }  
                PRP_Email_Tracker__c PRPEmail = new PRP_Email_Tracker__c();
                PRPEmail.Body__c = mbody;
                if(String.isNotBlank(mccMail)){
                    PRPEmail.CC_Address__c = mccMail;
                }
                PRPEmail.C_Ops_IAP_Submitted_Requests__c = recordId;
                PRPEmail.Sent__c = 'Indirect Access Program Site Guest User';
                PRPEmail.Sent_On__c = DateTime.now();
                PRPEmail.Subject__c = mSubject;
                PRPEmail.To_Address__c = mMail;
                insert PRPEmail;
                
                if(FileName!=null && FileBody!=null &&  FileType!=null){
                    Attachment att2 = new Attachment();     
                    att2.Body = Blob.ValueOf(FileBody);
                    att2.Name = FileName;
                    att2.IsPrivate = false;
                    att2.ParentId = PRPEmail.id;
                    att2.ContentType = FileType;
                    insert att2;
                }
                
                
                if(!String.isBlank(ErrorMessage)){
                    AuraHandledException auraEx = new AuraHandledException(ErrorMessage);
                    auraEx.setMessage(ErrorMessage);
                    throw auraEx;
                }
            }
            
            
        }
        catch(Exception exp){
            AuraHandledException auraEx = new AuraHandledException(exp.getMessage());
            auraEx.setMessage(exp.getMessage());
            throw auraEx;
        }
        
    }  
  
    
    public class emailTemplates{
        
        @AuraEnabled
        public String emailTemplateId{get;set;}
        
        @AuraEnabled
        public String emailbody{get;set;}
        
        @AuraEnabled
        public String emailSubject {get;set;}
        
        @AuraEnabled
        public String emailTemplatename{get;set;}
    }
}