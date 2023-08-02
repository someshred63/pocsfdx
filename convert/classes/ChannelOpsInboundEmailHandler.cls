/**
 * ChannelOps email service to process inbound emails
 */
global class ChannelOpsInboundEmailHandler implements Messaging.InboundEmailHandler {
    private static final String noneReplyAddress_prd='noreplyco-d@gene.com';
    private static final String noneReplyAddress_test='gneforms-d@gene.com';
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        ChannelOps_App_Property__c property=[select Account_Name_for_sending_email__c, Max_Email_Body__c, Log_All_Inbound_Emails__c,None_Reply_Email_Subject__c,None_replay_email_body__c from ChannelOps_App_Property__c where active__c=true and Application_Name__c='Spoilage From' limit 1];
        Integer maxBodyLength=property.Max_Email_Body__c.intValue();
        
        String fromName, fromAddress, subject;
        DateTime receivingTime=DateTime.now();
        ChannelOps_Received_Email_Log__c inBoundMail;
        Boolean bouncedEmail=false;
        Boolean noNeedReply=false;
        try{
            fromName=email.fromName;
            fromAddress=email.fromAddress;
            
            //don't reply emails send from the none-reply dlist email address. otherwise will cause infinity loop
            if(fromAddress.trim().equalsIgnoreCase(noneReplyAddress_prd) || fromAddress.trim().equalsIgnoreCase(noneReplyAddress_test)) noNeedReply=true;
            
            subject=email.subject;
            inBoundMail = new ChannelOps_Received_Email_Log__c();
            inBoundMail.From_Name__c=fromName;
            inBoundMail.From__c=fromAddress;
            inBoundMail.Subject__c=subject;
                       
            List<String> cc=email.ccAddresses;
            if(cc!=null && cc.size()>0) {
                for(String s:cc) inBoundMail.CC__c +=s+';';
            }
            
            inBoundMail.Receiving_Time__c=DateTime.now();
            
            if(email.plainTextBody==null)   inBoundMail.Body__c='Can not get email body message';
            else if(email.plainTextBody.length()>=maxBodyLength) inBoundMail.Body__c=email.plainTextBody.substring(0, maxBodyLength );
            else inBoundMail.Body__c=email.plainTextBody;
            
            Integer index=email.plainTextBody.indexOf('GNESP-');
            if(index>-1) {
                String tempStr = email.plainTextBody.substring(index);
                Integer endIndex=tempStr.indexOf('\n');
                if(endIndex>-1){
                    String spoilageRefNum = tempStr.substring(0, endIndex);
                    if(spoilageRefNum!=null) inBoundMail.Request_ID__c=spoilageRefNum;
                }
            }
            
            if((fromAddress.containsIgnoreCase('salesforce')==true) || (subject.containsIgnoreCase('Undeliverable')==true)) bouncedEmail=true;
            
            //log bounced email. customer emails only be logged if set in app properties that log all emails
            if(bouncedEmail==true || property.Log_All_Inbound_Emails__c ==true) {
                insert inBoundMail;                       
                processAttachement(inBoundMail.id,email.textAttachments, email.binaryAttachments );  
            }
            
        }catch(Exception e){
            result.success = false;
           // result.message = ‘ChannelOpsInboundEmailHandler failure-’+e.getMessage();
        }
        
         //only send general nonereply email message back to sender is it's not a undeliverable bounced back email and the email was not sent from MCCO's nonereplay dlist email address
        if(bouncedEmail==false && noNeedReply==false){
           // String emailTemplateName='ChannelOpsCallCenterReply';
           // sendGeneralReplyToSender(email.fromAddress,email.ccAddresses,emailTemplateName, property.Account_Name_for_sending_email__c);
           sendGeneralNoneReplyEMail(email,property.None_Reply_Email_Subject__c,property.None_replay_email_body__c );
        }
        return result;
    }
    
    
    private void processAttachement(ID id,Messaging.InboundEmail.TextAttachment[] textAtts,Messaging.InboundEmail.BinaryAttachment[] binaryAtts ){
        if(textAtts!=null && textAtts.size()>0) {
            for (Messaging.Inboundemail.TextAttachment tAttachment : textAtts) {
          Attachment attachment = new Attachment();
          attachment.Name = tAttachment.fileName;
          attachment.Body = Blob.valueOf(tAttachment.body);
          attachment.ParentId = id;
          insert attachment;
            }
        }
        
        if(binaryAtts !=null && binaryAtts.size()>0) { 
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : binaryAtts ) {
          Attachment attachment = new Attachment();
          attachment.Name = bAttachment.fileName;
          attachment.Body = bAttachment.body;
          List<Messaging.InboundEmail.Header> headers=bAttachment.headers;
          for(Messaging.InboundEmail.Header h: headers){
            if(h.name=='Content-Type') attachment.ContentType=h.value;
          }
          
          attachment.ParentId = id;
          insert attachment;
            }
        }
    }
    
    private void sendGeneralReplyToSender(String fromAddress, List<String> cc, String templateName, String accountName){
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        string sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        OrgWideEmailAddress orgWideAddress;
        if(sfdcBaseURL.contains('dev') || sfdcBaseURL.contains('sqa') || sfdcBaseURL.contains('uat')){
            orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'gneforms-d@gene.com'];
        }else{
            orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'noreplyco-d@gene.com'];
        }
        if(orgWideAddress != null){
            mail.setOrgWideEmailAddressId(orgWideAddress.Id);
        }
        EmailServicesFunction emsf = [select id, FunctionName from EmailServicesFunction where functionname='ChannelOpsCasesSendtemplatereply'];
        EmailServicesAddress emsa = [SELECT EmailDomainName,LocalPart FROM EmailServicesAddress where FunctionId=: emsf.id];
        string replyemail = emsa.LocalPart+'@'+emsa.EmailDomainName;
        mail.setReplyTo(replyemail);
     
        string[] sendingto = new string[]{fromAddress};
        mail.setToAddresses(sendingto);
        if(cc!=null && cc.size()>0) mail.setCcAddresses(cc);
    
        Contact c=[select id, name, email from Contact where name=:accountName limit 1];
        mail.setTargetObjectId(c.Id);
        mail.setTreatTargetObjectAsRecipient(false);  
        emailtemplate template = [Select Id, subject, body, name from emailtemplate where Name =:templateName limit 1];
        mail.setTemplateID(template.Id);
    
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
        
    }
    
    private void sendGeneralNoneReplyEMail(Messaging.InboundEmail email, String subject, String replyStr){
        
        String forwardMsg='<br/><br/>';
        if(email !=null){
            forwardMsg+=System.now()+', '+email.fromName+' <'+email.fromAddress+'> wrote:<br/><br/>'+email.htmlBody;           
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setHtmlBody(replyStr+forwardMsg);
        mail.setSubject(subject);
        
        string sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        OrgWideEmailAddress orgWideAddress;
        if(sfdcBaseURL.contains('dev') || sfdcBaseURL.contains('sqa') || sfdcBaseURL.contains('uat')){
                orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'gneforms-d@gene.com'];
        }else{
                orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'noreplyco-d@gene.com'];
        }
        if(orgWideAddress != null){
                mail.setOrgWideEmailAddressId(orgWideAddress.Id);
        }
        EmailServicesFunction emsf = [select id, FunctionName from EmailServicesFunction where functionname='ChannelOpsCasesSendtemplatereply'];
        EmailServicesAddress emsa = [SELECT EmailDomainName,LocalPart FROM EmailServicesAddress where FunctionId=: emsf.id];
        string replyemail = emsa.LocalPart+'@'+emsa.EmailDomainName;
        mail.setReplyTo(replyemail);
         
        string[] sendingto = new string[]{email.fromAddress};
        mail.setToAddresses(sendingto);
        if(email.ccAddresses!=null && email.ccAddresses.size()>0) mail.setCcAddresses(email.ccAddresses);
    
        List<Messaging.EmailFileAttachment> attFiles=new List<Messaging.EmailFileAttachment>();

        if(email.textAttachments!=null && email.textAttachments.size()>0) {
        for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
          Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
          attachment.filename= tAttachment.fileName;
          attachment.Body = Blob.valueOf(tAttachment.body);
          attFiles.add(attachment);
        }
        }
        if(email.binaryAttachments!=null && email.binaryAttachments.size()>0) {      
        for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
          Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
          attachment.filename= bAttachment.fileName;
          attachment.Body = bAttachment.body;
          List<Messaging.InboundEmail.Header> headers=bAttachment.headers;
          for(Messaging.InboundEmail.Header h: headers){
            if(h.name=='Content-Type') attachment.ContentType=h.value;
          }
          
          attFiles.add(attachment);
          }
          }      
        mail.setFileAttachments(attFiles);
        
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
    }
        
}