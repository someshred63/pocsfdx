public class PRP_EmailsController {
    /**
* @author Vijay Dharoor
* @date 6/29/21
* @description to get the Submitter details of the record.
**/
    @AuraEnabled
    public static string submitterDetails(string recordId){
        system.debug('recordid'+ recordId);
        PRP_Request__c u = [select id, Email__c from PRP_Request__c where id =:recordId];
        system.debug('u.Email__c' + u.Email__c);
        return u.Email__c;
    }
    /**
* @author Vijay Dharoor
* @date 6/29/21
* @description to get the BEM details of the record.
**/
    @AuraEnabled
    public static string bemDetails(string recordId){
        system.debug('recordid@'+ recordId);
        PRP_Request__c bem = [select id, BEM__r.Email__c from PRP_Request__c where id =:recordId];
        system.debug('bem.Email__c@' + bem.BEM__r.Email__c);
        return bem.BEM__r.Email__c;
    }


    @AuraEnabled
    public static string saDetails(string recordId){
        system.debug('recordid@'+ recordId);
        PRP_Request__c sa = [select id,SA_Email__c from PRP_Request__c where id =:recordId];
        system.debug('SA.Email__c@' + sa.SA_Email__c);
        return sa.SA_Email__c;
    }

    /**
* @author : Rabindranath
* @date 6/2/2022
* @description to get the status of all Request.
**/
    @AuraEnabled
    public static Boolean checkStatusofAllReq(string recordId){
        system.debug('recordid@'+ recordId);
        Boolean val = false;
        PRP_Request__c submNum = [select id, Submission_Number__c from PRP_Request__c where id =:recordId];
        for(PRP_Request__c pr :[select id,Submission_Number__c,Request_Status__c from PRP_Request__c where Submission_Number__c=:submNum.Submission_Number__c ]){
            if(pr.Submission_Number__c!=null && pr.Request_Status__c!='New' && pr.Request_Status__c!='In Revision' && pr.Request_Status__c!='Revised'){
                val = true;
            } 
        }
        return val;
    }
    @AuraEnabled
    public static List <PRP_Request__c> retrieveRecs(string recordId){
        PRP_Request__c submNum = [select id, Submission_Number__c from PRP_Request__c where id =:recordId];
        return[select id,Name,Submission_Number__c,Request_Status__c,Product_Name__c,owner.name from PRP_Request__c where Submission_Number__c=:submNum.Submission_Number__c ];    
    }
    
    /**
* @author Vijay Dharoor
* @date 6/29/21
* @description to get the templates from "PRP Email" folder for "Send for Revision" button.
**/
    @AuraEnabled
    public static list<emailTemplates>  getEmailTempaltes(String recordId){
        list<emailTemplates> emailTemplateWrapperlist = new list<emailTemplates>();
        list<EmailTemplate> lstEmailTemp=[ SELECT Id, FolderId, HtmlValue, FolderName, isActive, body,Name,subject 
                                          FROM EmailTemplate where isActive= true and Folder.Name = 'PRP Emails'];
        system.debug('lstEmailTemp@@'+lstEmailTemp);
        if(lstEmailTemp!=null && lstEmailTemp.size()>0){
            for(EmailTemplate emailtemp: lstEmailTemp){
                emailTemplates template = new emailTemplates();
                template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
                template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
            //  template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')) :String.valueOf( emailtemp.get('body')));
                //template.emailSubject = String.valueOf(emailtemp.get('subject'));
             
                Messaging.SingleEmailMessage renderedMail = Messaging.renderStoredEmailTemplate(emailtemp.Id, null, recordId);
                template.emailbody = renderedMail.getHTMLBody();
                template.emailSubject = renderedMail.getSubject();
                
                emailTemplateWrapperlist.add( template);
            }
        }
        if(emailTemplateWrapperlist!=null && emailTemplateWrapperlist.size()>0){
            return  emailTemplateWrapperlist;
        }
        return null;
        
    }
    /**
* @author Vijay Dharoor
* @date 6/29/21
* @description to get the templates from "PRP Send Email" folder for "Send Emails" button.
**/
    @AuraEnabled
    public static list<emailTemplates>  getEmailTempaltesForSendEmail(String recordId){
        list<emailTemplates> emailTemplateWrapperlist = new list<emailTemplates>();
        list<EmailTemplate> lstEmailTemp=[ SELECT Id, FolderId, HtmlValue, FolderName, isActive, body,Name,subject 
                                          FROM EmailTemplate where isActive= true and Folder.Name = 'PRP Send Email'];
        system.debug('lstEmailTemp@@'+lstEmailTemp);
        if(lstEmailTemp!=null && lstEmailTemp.size()>0){
            for(EmailTemplate emailtemp: lstEmailTemp){
                
                
                emailTemplates template = new emailTemplates();
                template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
                template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
              //  template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')) :String.valueOf( emailtemp.get('body')));
                //template.emailSubject = String.valueOf(emailtemp.get('subject'));
                //  template.emailbody = emailtemp.HtmlValue;
               system.debug('emailtemp.HtmlValue' + emailtemp.HtmlValue);
                Messaging.SingleEmailMessage renderedMail = Messaging.renderStoredEmailTemplate(emailtemp.Id, null, recordId);
                template.emailbody = renderedMail.getHTMLBody();
                system.debug('template.emailbody DIMPY ' + template.emailbody);
                system.debug('renderedMail.getHTMLBody() DIMPY ' + renderedMail.getHTMLBody());
                template.emailSubject = renderedMail.getSubject();
                
                emailTemplateWrapperlist.add( template);
            }
        }
        if(emailTemplateWrapperlist!=null && emailTemplateWrapperlist.size()>0){
            return  emailTemplateWrapperlist;
        }
        return null;
        
    }
    /**
* @author Vijay Dharoor
* @date 6/29/21
* @description to send an email when "Send for Revision" button is clicked.
**/
    @AuraEnabled
    public static void sendMailMethod(String mMail ,String mccMail,String mSubject ,String mbody, String recordId,String templateId,String FileBody,String FileName,String FileType,Integer FileSize ){
        system.debug('FileBody@@'+FileBody+'FileName@@@'+FileName+'FileType@@'+FileType+'FileSize@@'+FileSize );
        string leadName = '';
        String leadOwnerName = '' ;
        List<String> lst = new List<String>();
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
             
                if(mccMail.containsWhitespace()){
                    mccMail=mccMail.deleteWhitespace();
                }
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
            fe = [Select Id, Address, DisplayName From OrgWideEmailAddress where DisplayName = 'Genentech Provider Rebate Request' LIMIT 1];
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
                else if(result.isSuccess()){
                    PRP_Request__c prpRequestNew = [select id,name,First_Name__c,Last_Name__c  from PRP_Request__c where id=:recordId];
                    My_Domain_gne__c mydomain = My_Domain_gne__c.getOrgDefaults();
                    system.debug('mydomain@@'+mydomain);
                    if(mbody.contains('{!PRP_Request__c.Last_Name__c}') || mbody.contains('{!PRP_Request__c.First_Name__c}') || mbody.contains('{!PRP_Request__c.Name}')){
                        mbody=mbody.replace('{!PRP_Request__c.First_Name__c}', prpRequestNew.First_Name__c);
                        mbody=mbody.replace('{!PRP_Request__c.Last_Name__c}', prpRequestNew.Last_Name__c);
                        mbody=mbody.replace('{!PRP_Request__c.Name}', prpRequestNew.Name);
                        mbody=mbody.replace('{!$Setup.My_Domain_gne__c.Instance_Url__c}/prp?update=true', mydomain.Instance_Url__c);
                    }
                    if(mSubject.contains('{!PRP_Request__c.Last_Name__c}') || mSubject.contains('{!PRP_Request__c.First_Name__c}') || mSubject.contains('{!PRP_Request__c.Name}')){
                        mSubject=mSubject.replace('{!PRP_Request__c.First_Name__c}', prpRequestNew.First_Name__c);
                        mSubject=mSubject.replace('{!PRP_Request__c.Last_Name__c}', prpRequestNew.Last_Name__c);
                        mSubject=mSubject.replace('{!PRP_Request__c.Name}', prpRequestNew.Name);
                    }
                    PRP_Request__c PRPRequest = new PRP_Request__c(id=recordId);
                    PRPRequest = [select id,Submission_Number__c from PRP_Request__c where id=:recordId ];
                    List<PRP_Request__c> recToUpdate = new List<PRP_Request__c>();
                    
                    for(PRP_Request__c pr :[select id,Submission_Number__c,Request_Status__c from PRP_Request__c where Submission_Number__c=:PRPRequest.Submission_Number__c ]){
                        if(pr.Submission_Number__c!=null && (pr.Request_Status__c=='New' ||pr.Request_Status__c=='Revised')){
                            pr.Request_Status__c='In Revision';
                            recToUpdate.add(pr);
                        }
                    }
                    update recToUpdate;
                    
                    List<Id> lstIds = new List<Id>();
                    PRPRequest = [select id,Submission_Number__c from PRP_Request__c where id=:recordId ];
                    for(PRP_Request__c pr :[select id,Submission_Number__c from PRP_Request__c where Submission_Number__c=:PRPRequest.Submission_Number__c ]){
                        if(pr.Submission_Number__c!=null){
                            lstIds.add(pr.Id);
                        }
                    }
                    system.debug('@@@Ids'+lstIds);
                    
                    List<PRP_Email_Tracker__c> rectoInsert = new List<PRP_Email_Tracker__c>();
                    for(integer i=0; i<lstIds.size(); i++){
                        PRP_Email_Tracker__c PRPEmail = new PRP_Email_Tracker__c();
                        PRPEmail.Body__c = mbody;
                        if(String.isNotBlank(mccMail)){
                            PRPEmail.CC_Address__c = mccMail;
                        }
                        PRPEmail.Provider_Rebate_Program_Request__c = lstIds[i];
                        PRPEmail.Sent__c = 'Provider Rebate Program Site Guest User';
                        PRPEmail.Sent_On__c = DateTime.now();
                        PRPEmail.Subject__c = mSubject;
                        PRPEmail.To_Address__c = mMail;
                        rectoInsert.add(PRPEmail);
                        
                    }
                    insert rectoInsert;
                    for (PRP_Email_Tracker__c trckr:rectoInsert){
                        
                        
                        if(attachments.size()>0){
                            String name = FileName;
                            String Body = FileBody;
                            String Type = FileType;
                            String reqId = trckr.Id;
                            PRP_EmailsController.saveAttachment(reqId,name,Body,Type);
                        }
                    }
                }
                
                if(!String.isBlank(ErrorMessage)){
                    AuraHandledException auraEx = new AuraHandledException(ErrorMessage);
                    auraEx.setMessage(ErrorMessage);
                    throw auraEx;
                }
            }
        }
        catch (DmlException ex) {
            throw new AurahandledException(ex.getDmlMessage(0));
        } 
        catch(Exception exp){
            AuraHandledException auraEx = new AuraHandledException(exp.getMessage());
            auraEx.setMessage(exp.getMessage());
            throw auraEx;
        }
        
    }  
    /**
* @author Vijay Dharoor
* @date 6/29/21
* @description to send email when "Send Email" button is clicked.
**/
    @AuraEnabled
    public static void sendMailMethodForSendEmail(String mMail ,String mccMail,String mSubject ,String mbody, String recordId,String templateId,String FileBody,String FileName,String FileType,Integer FileSize ){
        
        string leadName = '';
        String leadOwnerName = '' ;
        //system.debug('!!!!!!!!File'+Blob.ValueOf(FileBody));
        try{
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            if(FileName!=null && FileBody!=null &&  FileType!=null){
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(FileName);
                efa.setBody(EncodingUtil.base64Decode(FileBody));
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
                if(mccMail.containsWhitespace()){
                    mccMail=mccMail.deleteWhitespace();
                }
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
            fe = [Select Id, Address, DisplayName From OrgWideEmailAddress where DisplayName = 'Genentech Provider Rebate Request' LIMIT 1];
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
                else if(result.isSuccess()){
                    PRP_Request__c prpRequestNew= [select id,name,First_Name__c,Last_Name__c  from PRP_Request__c where id=:recordId];
                    system.debug('prpRequestNew@@'+prpRequestNew);
                    system.debug('mbody@@'+mbody);
                    system.debug('Last_Name__c@@'+mbody.contains('{!PRP_Request__c.Last_Name__c}'));
                    system.debug('Last_Name__c@@'+mbody.contains('{!PRP_Request__c.First_Name__c}'));
                    system.debug('Name@@'+mbody.contains('{!PRP_Request__c.Name}'));
                    if(mbody.contains('{!PRP_Request__c.Last_Name__c}') || mbody.contains('{!PRP_Request__c.First_Name__c}') || mbody.contains('{!PRP_Request__c.Name}')){
                        mbody=mbody.replace('{!PRP_Request__c.First_Name__c}', prpRequestNew.First_Name__c);
                        mbody=mbody.replace('{!PRP_Request__c.Last_Name__c}', prpRequestNew.Last_Name__c);
                        mbody=mbody.replace('{!PRP_Request__c.Name}', prpRequestNew.Name);
                    }
                    system.debug('mbodyNew@@'+mbody);
                    if(mSubject.contains('{!PRP_Request__c.Last_Name__c}') || mSubject.contains('{!PRP_Request__c.First_Name__c}') || mSubject.contains('{!PRP_Request__c.Name}')){
                        mSubject=mSubject.replace('{!PRP_Request__c.First_Name__c}', prpRequestNew.First_Name__c);
                        mSubject=mSubject.replace('{!PRP_Request__c.Last_Name__c}', prpRequestNew.Last_Name__c);
                        mSubject=mSubject.replace('{!PRP_Request__c.Name}', prpRequestNew.Name);
                    }
                    PRP_Email_Tracker__c PRPEmail = new PRP_Email_Tracker__c();
                    PRPEmail.Body__c = mbody;
                    if(String.isNotBlank(mccMail)){
                        PRPEmail.CC_Address__c = mccMail;
                    }
                    PRPEmail.Provider_Rebate_Program_Request__c = recordId;
                    PRPEmail.Sent__c = 'Provider Rebate Program Site Guest User';
                    PRPEmail.Sent_On__c = DateTime.now();
                    PRPEmail.Subject__c = mSubject;
                    PRPEmail.To_Address__c = mMail;
                    insert PRPEmail;
                    if(attachments.size()>0){
                        String name = FileName;
                        String Body = FileBody;
                        String Type = FileType;
                        
                        PRP_EmailsController.saveAttachment(PRPEmail.Id,name,Body,Type);
                    }
                    
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
    public static void saveAttachment(String recid,String FileName,String  FileBody,String FileType){
        List<Attachment> attachments = new List<Attachment>();
        Attachment att = new Attachment();
        att.Name = FileName;
        att.IsPrivate = false;
        att.ParentId = recid;
        
        att.Body = EncodingUtil.base64Decode(FileBody);
        attachments.add(att);
        
        
        if (attachments?.size() > 0){
            insert attachments;
        }
    }
}