public with sharing class AGS_SendEmail_ChangeInReporting 
{
	
	/*
	*   This class sends email to CCO distribution list whenever fields are updated for change in reporting (as per AGG Spend Mgmt Tool FS-004)
	*   The class is called from the change in reporting trigger objects when any fields are updated for change in reporting
	*
	*   Author  : Sandeep Kumar
	*   Date    : 2 Dec 2010
	*/
	
	//distribution list
	//final String CCO_DISTRIBUTION_LIST_1 = 'Complianceops-d@gene.com';
	//final String CCO_DISTRIBUTION_LIST_2 = 'aggspendcases@gene.com';
	
	final String EMAIL_SUBJECT = 'Testing AGG SPEND Business Rule Management Tool. Please ignore';
	
	//test distrinbution list
	
	final String CCO_DISTRIBUTION_LIST_1 = '';
	final String CCO_DISTRIBUTION_LIST_2 = '';
	
	public class MyException extends Exception {}
	
	//empty constructor
	public AGS_SendEmail_ChangeInReporting()
	{
		
	}
	
	//determines the fields updated for change in reporting and calls email function
	public void getAffectedRecords(sObject TriggerOld, sObject TriggerNew, List<String> FieldNames, Long vNum)
	{
		
		String body='';
		String verNum;
		body+='Hello Aggregate Spend Team,\n\n';

		body+='A change was made to the Aggregate Spend business rules via the AGG SPEND Business Rule Management Tool.  The details of the change are listed below.\n\n';
		body+='Change made by:' + ' ' + UserInfo.getName() +'\n';
		body+='Date of change:' + ' ' + System.now() +'\n';
		
		boolean isChanged=false;
		
		for(String s: FieldNames)
		{
			//check for any fields updated
			if(TriggerOld.get(s)!=TriggerNew.get(s))
			{
				String label=s;
				label=label.replace('__c','');
				label=label.replace('_gne','');
				label=label.replace('_',' ');
				body+='Business Rule effected:' + ' ' + label +'\n';
				
				isChanged=true;
			}
		}
		
		System.debug('message body : ' + body);
		
		if(vNum!=null)
		{
			verNum = String.valueOf(vNum);
			System.debug(' Version Number : ' + verNum);
		}
		body+='New Version Number:' + ' ' + verNum +'\n';
		
		if(isChanged)
		{
			String env = GlobalUtils.getEnvironment();

			List<String> lstToEmail = new List<String>();
			//lstToEmail.add(CCO_DISTRIBUTION_LIST_1);
			//lstToEmail.add(CCO_DISTRIBUTION_LIST_2);
			
			MAP<String,AGS_Env_Distribution_Lists_gne__c> inf_profiles = AGS_Env_Distribution_Lists_gne__c.getAll();
            for(AGS_Env_Distribution_Lists_gne__c env_email : inf_profiles.values())
            {
                if (env_email.Environment_gne_del__c == env)
                {
                    lstToEmail.add(env_email.Email_gne__c);
                }
            }
			
			System.debug(' Sending Email ');
			System.debug(' To address  : ' + lstToEmail);
			sendEmails(lstToEmail, new String[]{''}, '', EMAIL_SUBJECT, body);
			
		}

	}
	
	
	
	//email generic function to send emails
	public void sendEmails(List<String> toEmail, List<String> ccEmail, String replyTo, String subject, String body)
	{
		// Create a new single email message object
		// that will send out a single email to the addresses in the To, CC & BCC list.
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		// Strings to hold the email addresses to which you are sending the email.
		
		//String[] toAddresses = new String[] {TEST_EMAIL_1, TEST_EMAIL_2};
		//String[] ccAddresses = new String[] {'sandeeku@gene.com'};
		String[] toAddresses        = toEmail;
		//String[] ccAddresses      = ccEmail;
		// Assign the addresses for the To and CC lists to the mail object.
		mail.setToAddresses(toAddresses);
		//mail.setCcAddresses(ccAddresses);
		// Set to True if you want to BCC yourself on the email.
		mail.setBccSender(false);
		
		// Specify the address used when the recipients reply to the email.
		//mail.setReplyTo('support@acme.com');
		//mail.setReplyTo(replyTo);
		
		// Specify the name used as the display name.
		//mail.setSenderDisplayName('Sample Management Support');
		// Specify the subject line for your email address.
		mail.setSubject(subject);
		
		// Optionally append the salesforce.com email signature to the email.
		// The email address of the user executing the Apex Code will be used.
		//mail.setUseSignature(false);
		
		// Specify the text content of the email.
        mail.setPlainTextBody(body);
        //mail.setHtmlBody(body);
        //mail.setTemplateId('00XQ0000000I0Zw');
        //mail.setTargetObjectId('005Q0000000OEKX');
        //mail.setWhatId('a00Q0000002HQhG' );
        //mail.setSaveAsActivity(false);
        // Send the email you have created.
        
        List<Messaging.Sendemailresult> emailResult;
        try{
            emailResult =  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            if(emailResult!=null && !emailResult[0].isSuccess())
            {
                List<Messaging.SendEmailError> emailError= emailResult[0].getErrors();
                if(emailError!=null)
                {
                    System.debug('email error : ' + emailError[0].getMessage());
                    throw new MyException(emailError[0].getMessage());
                }
            }
        }
        catch(Exception ex)
        {
            throw ex;
        }
        
    }
    
    
}