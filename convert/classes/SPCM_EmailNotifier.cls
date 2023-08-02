public without sharing class SPCM_EmailNotifier {


	public static void Notify(Id targetObjectId, string comment, List<SPCM_eWorkflowBaseUtils.CommentsWrapper> allComments, string status) {
		Notify(targetObjectId, comment, allComments, status, null);
	}
	
	public static void Notify(Id targetObjectId, string comment, List<SPCM_eWorkflowBaseUtils.CommentsWrapper> allComments, string status, Boolean isNotFinal)
	{
		//query object's data
		string objectAPIName = targetObjectId.getSObjectType().getDescribe().getName();
		sObject targetObj = Database.query('select id, name, initiated_by__c, initiated_by__r.email, Requested_Final_Approval_Date__c, Appr_Approval_Level__c,' +
										 ' Approval_Type__c, Approval_Status__c, SPCM_Department__c, Actual_Final_Approval_Date__c, GNE_SSO_Detail_Link__c, Initiator_Comments__c' +
									' from ' + objectAPIName +
                            		' where id=\''+ targetObjectId + '\' limit 1');

		Date finalApprovalDate = Date.valueOf(targetObj.get('Actual_Final_Approval_Date__c'));


		//send message - small or final
		if ((finalApprovalDate != null || status == 'Rejected') && (isNotFinal == null || isNotFinal == false))
		{
			if (objectAPIName != 'SPCM_CARS_Contract_Summary_Form__c') { 
				// don't send for Cars Contract Tracker Sign Off !
				SendFinalMessage(targetObj, objectAPIName, allComments, status, String.valueOf(targetObj.getSobject('Initiated_By__r').get('Email')));
			} 
		}
		else
		{
			//send only for MCC
			if(objectAPIName == 'SPCM_MCC_Approval_Sheet__c'
				|| objectAPIName == 'SPCM_MCC_Tracking_Sheet__c'
				|| objectAPIName == 'SPCM_MCC_Exception_Sheet__c')
				SendMessage(targetObj, comment, status);
		}
	}


	// Send small message at each but last approve level. Since the message is the same for each object,
	// the generic template is used here, and filled manually.
	private static void SendMessage(sObject targetObj, string comment, string status)
	{
		System.debug('hello from send NORMAL message. STATUS: ' + status);


		EmailTemplate template = [select id, subject, htmlValue from emailTemplate where developerName = 'eWorkflow_Generic_notifier_template' limit 1][0];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
		string subject = template.Subject;
		string body = template.HtmlValue;

		subject = subject.replace('{ApprovalType}', (string)targetObj.get('Approval_Type__c'));
		subject = subject.replace('{approvalid}', (string)targetObj.get('Name'));

		body = body.replace('{approvalid}', (string)targetObj.get('Name'));
		body = body.replace('{ApprovalType}', string.isBlank((string)targetObj.get('Approval_Type__c')) ? '' : (string)targetObj.get('Approval_Type__c'));
		body = body.replace('{Department}', string.isBlank((string)targetObj.get('SPCM_Department__c')) ? '' : (string)targetObj.get('SPCM_Department__c'));
		body = body.replace('{Comment}', string.isBlank(comment) ? '' : comment);
		body = body.replace('{link}', string.isBlank((string)targetObj.get('GNE_SSO_Detail_Link__c')) ? '' : (string)targetObj.get('GNE_SSO_Detail_Link__c'));
		body = body.replace('{status}', string.isBlank(status) ? '' : status);
		body = body.replace('{initiatorComment}', string.isBlank((string)targetObj.get('Initiator_Comments__c')) ? '' : (string)targetObj.get('Initiator_Comments__c'));
		body = body.replace('{approvalDate}', String.valueof((Date)targetObj.get('Requested_Final_Approval_Date__c')));

		mail.setSubject(subject);
		mail.setHtmlBody(body);
        mail.setUseSignature(false);        
        mail.setToAddresses(new string[] { string.valueOf(targetObj.getSobject('Initiated_By__r').get('Email')) });
        mail.saveAsActivity = false;
        if (!test.isrunningtest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }
	}

	private static void SendFinalMessage(sObject targetObj, string objectAPIName, List<SPCM_eWorkflowBaseUtils.CommentsWrapper> allComments, string status, String toAddress)
	{

		//--- WARNING -------------------------------------------------------------------------------------------
		// The convention is used here, to make the code more generic and prevent hardcoding.
		// Two first words of object's label are the name of the application (e.g. MCC Exception, CARS Contract).
		// These two words are used to assign the correct email template.
		// Similar convention is used to determine the Approved/Rejected email template.
		//
		// The temp email is used as a hack here. Since Salesforce can't send an email with setWhatId() when
		// User is used. the random Contact is used, temp message is processed and then - rollbacked.
		//-------------------------------------------------------------------------------------------------------

		String[] objectLabelSplit = Schema.describeSObjects(new List<String>{objectAPIName})[0].getLabel().split(' ');
		String emailTemplatePrefix = objectLabelSplit[0] + ' ' + objectLabelSplit[1];
		String emailTemplateSuffix = status == 'Approved' ? 'Received' : 'Rejected';
		
		System.debug('EMAIL: ' + emailTemplatePrefix + '%' + emailTemplateSuffix);

		ID emailTemplate = [select id from emailtemplate where name like :emailTemplatePrefix + '%' + emailTemplateSuffix limit 1].id;
		Messaging.SingleEmailMessage tmpMail = new Messaging.SingleEmailMessage();
		Contact c = [select id, Email from Contact where email <> null limit 1];
		tmpMail.setUseSignature(false);
		tmpMail.setToAddresses(new string[] { toAddress });
		tmpMail.setTemplateId(emailTemplate);
		tmpMail.setTargetObjectId(c.id);
		tmpMail.setWhatId(targetObj.Id);
		tmpMail.saveAsActivity = false;

		//attempt to send email and rollback sending. Template will be filled with target object, but not sent.
		Savepoint sp = Database.setSavepoint();
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {tmpMail});
		Database.rollback(sp);

		//fill the real message using tempMail, and send
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setUseSignature(false);
		mail.setToAddresses(tmpMail.getToAddresses());
		

		//check if there is any comment
		String comments = '';
		Boolean thereIsAnyComment = false;
		for (SPCM_eWorkflowBaseUtils.CommentsWrapper commentWrapper: allComments){
			if (! String.isBlank(commentWrapper.Comment))
				thereIsAnyComment = true;
		}

		if (thereIsAnyComment){
			for(SPCM_eWorkflowBaseUtils.CommentsWrapper commentWrapper: allComments) {
				commentWrapper.Comment = String.isBlank(commentWrapper.Comment) ? '' : commentWrapper.Comment;

				comments += '<tr><td style="width:160px; border:1px solid #f2f2f2; white-space:nowrap; font:12px Calibri;">'
						+ commentWrapper.LevelName + '<br />' + commentWrapper.Approver + '</td>'
						+ '<td style="width:300px; border:1px solid #f2f2f2; font:12px Calibri;">' + commentWrapper.Comment + '</td></tr>';
			}
		}
		// if there is no comment
		else
			comments = '<tr><td colspan="2" style="width:300px; border:1px solid #f2f2f2; font:12px Calibri;">There are no comments from any levels</td></tr>';
		
		mail.setPlainTextBody(tmpMail.getPlainTextBody().replace('{comments}', comments));
		mail.setHTMLBody(tmpMail.getHTMLBody().replace('{comments}', comments));
		mail.setSubject(tmpMail.getSubject());
		if (!test.isrunningtest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }

	}

}