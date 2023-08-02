public class SCM_LogError {
    
    public static void sendEmail(Exception ex,string body) {
        if(SCM_Security.SendExceptionEmail) {
            SCM_LogError.sendEmail('There was an error in Salesforce',ex + '\n\n' + body,true);
        }
    }

    public static void sendEmail(Exception ex) {
        if(SCM_Security.SendExceptionEmail) {
            SCM_LogError.sendEmail('There was an error in Salesforce', ex + '\n\n' ,true);
        }
    }

    public static void sendEmail(ApexPages.Message[] msgs) {
        string mailBody = '';

        if(SCM_Security.SendExceptionEmail) {
            for(ApexPages.Message msg :msgs) {
                mailBody += '   Severity : ' + msg.getSeverity() + '\n  Summary : ' + msg.getSummary() + '\n';
            }
    
            SCM_LogError.sendEmail('There was an error in Salesforce',mailBody,true);
        }
    }

    public static void sendEmail(string subject, string body,boolean displayUserAndAccountInfo) {
        
        String commonEmail = SCM_Security.getEnvironmentVariable('SCM Spring Email Errors to');
        
        // Create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = new String[] {commonEmail}; 
        String[] ccAddresses = SCM_Security.getEnvironmentVariable('SCM Spring Email Errors CC').split(',');
        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);       
        // Specify the address used when the recipients reply to the email. 
        mail.setReplyTo(commonEmail);       
        // Specify the name used as the display name.
        mail.setSenderDisplayName('SpringCM Support');      
        // Specify the subject line for your email address.
        mail.setSubject(subject + ' in ' + SCM_Security.getEnvironmentByUsername());       
        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);       
        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);        
        // Specify the text content of the email.
        
        
        string mailbody = '';
        if (displayUserAndAccountInfo) { 
            try {
            mailbody += 'Users Full Name: ' + UserInfo.getName() + '\n';
            mailbody += 'Username: ' + UserInfo.getUserName() + '\n';
            mailbody += 'Organization Name: ' + UserInfo.getOrganizationName() + '\n';
            mailbody += 'Organization Id: ' + UserInfo.getOrganizationId() + '\n\n';
        
            body = mailbody + body;
            }
            catch (Exception ex) {
                
            }
        }
        //mail.setHtmlBody('Your case:<b> ' + case.Id +' </b>has been created<p>'+
        //     ' View case <a href=https://prerelna1.pre.salesforce.com/'+case.Id+'>click here</a>');
        
        // Send the email you have created.
        mail.setPlainTextBody(body);
        try {
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch (exception ex){
            
        }
        
    }

    public static testMethod void testmeth() {
        list<ApexPages.Message> msg = new list<ApexPages.Message>();
        msg.add(new ApexPages.Message(ApexPages.Severity.FATAL, 'test'));
        SCM_LogError.sendEmail(msg);
    }
}