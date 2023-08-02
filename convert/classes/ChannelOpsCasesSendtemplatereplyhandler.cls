global class ChannelOpsCasesSendtemplatereplyhandler implements Messaging.InboundEmailHandler {
 
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                       Messaging.InboundEnvelope env){
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    String myPlainText= '';
    myPlainText = email.plainTextBody;
    string casenumber = '';
    Integer inte;
    if(myPlainText.contains('Case Number')){
    inte = myPlainText.indexOf('Case Number:');
    
    casenumber = myPlainText.substring(inte, inte+22);
    }
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    string sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
    OrgWideEmailAddress orgWideAddress = null;
     if(sfdcBaseURL.contains('dev') || sfdcBaseURL.contains('sqa') || sfdcBaseURL.contains('uat')){
    orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'gneforms-d@gene.com'];
   
     }
     else{
    orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'noreplyco-d@gene.com'];
    
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
   // mail.setSubject(email.subject);
   // mail.setSubject('Action Required – Please submit your Genentech Form(s) via fax at 877-329- 6737');
    //string strbody = 'Thank you for contacting Genentech.  We apologize for the inconvenience, but this mailbox is not monitored.  If you have questions or would like to submit your completed forms, please contact us at 1-800-551-2231 and provide the '+casenumber+ ' as a reference. \n\n\n Thank You! \n\nGenentech Customer Service Team';
   // string strbody;
    
    contact c = [select id from contact limit 1];
    mail.setTargetObjectId(c.Id);
    mail.setTreatTargetObjectAsRecipient(false);
    
     emailtemplate template = [Select Id, subject, body, name from emailtemplate where Name = 'ChannelOpsCallCenterReply' limit 1];
     mail.setTemplateID(template.Id);
       
    
    
    
    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
    result.success = true;
   
    return result;
  }
}