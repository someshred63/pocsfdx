/**
* @author GFRS Dev Team - MG
* @date 29/09/2015
* @description gFRS_EmailUtility - helper class for sending Email Templates
* 
* 
*/
public without sharing class gFRS_EmailUtility
{
    public static void sendEmail(List<gFRS_EmailMessageWrapper> listEmailMessageWrapper, String emailTemplateName)
    {
        List<Messaging.SendEmailResult> listEmailResult = null;
        List<Messaging.Singleemailmessage> listSingleEmailMessages = new List<Messaging.Singleemailmessage>();
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :emailTemplateName];     
        string subject=null;
        
        for (gFRS_EmailMessageWrapper emailMessageWrapper : listEmailMessageWrapper)
        {
            //*** workaround for broken HTML merge template issue.
            Messaging.SingleEmailMessage tmpMail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'dummy@roche.com'};
            tmpMail.setToAddresses(toAddresses);
            tmpMail.setUseSignature(false);
            tmpMail.setSaveAsActivity(false);
            tmpMail.setSenderDisplayName('dummy');
            tmpMail.setTargetObjectId(UserInfo.getUserId());
            tmpMail.setTemplateId(emailTemplate.Id);
            //*** 
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {tmpMail});
            Database.rollback(sp);
                    
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSenderDisplayName('fundingrequestsystem-donotreply'); 
            
            if(emailMessageWrapper.FromAddress != null && emailMessageWrapper.FromAddress.length() > 0)
            {
                mail.setReplyTo(emailMessageWrapper.FromAddress);
            }
            
            if(emailMessageWrapper.ToAddress != null && emailMessageWrapper.ToAddress.length() > 0)
            {
                mail.setToAddresses(new String[] { emailMessageWrapper.ToAddress });
            }
            else{mail.setTargetObjectId(emailMessageWrapper.ToAddressId);
            }
            
            if(emailMessageWrapper.BccAddress != null && emailMessageWrapper.BccAddress.length() > 0)
            {
                mail.setBccAddresses(new String[] {emailMessageWrapper.BccAddress });
            }
            
            if(emailMessageWrapper.Subject != null && emailMessageWrapper.Subject.length() > 0)
            {
                mail.setSubject(emailMessageWrapper.Subject);
                subject = emailMessageWrapper.Subject;
            }
            else
            {
            subject = emailTemplate.Subject;
            
            }
            
            //parse email subject 
            for(String key: emailMessageWrapper.ParameterSubjectMap.keySet())
            {
                subject = subject.replace(key, (emailMessageWrapper.ParameterSubjectMap.get(key) == null ? '' : emailMessageWrapper.ParameterSubjectMap.get(key)));
            }
                           
            mail.setSubject(subject);
            String htmlBody = tmpMail.getHTMLBody();
            String plainBody = tmpMail.getPlainTextBody();
            
            //parse email body          
            for (String key : emailMessageWrapper.ParameterBodyMap.keySet()) {
                system.debug('### Key->'+ key);
                system.debug('### emailMessageWrapper.ParameterBodyMap.get(key)->'+ emailMessageWrapper.ParameterBodyMap.get(key));
               
                htmlBody = htmlBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
                plainBody = plainBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
            }

            mail.setHtmlBody(htmlBody);
            mail.setPlainTextBody(plainBody);
            mail.setSaveAsActivity(false);
            listSingleEmailMessages.add(mail);
        }
        
        if(!Test.isRunningTest())
            listEmailResult = Messaging.sendEmail(listSingleEmailMessages);
    }
}