public class GNE_AP_Email_Util {

	public String fromEmail{get;set;}
	public String toEmail{get;set;}
	public String ccEmail{get;set;}
	public String bccEmail{get;set;}
	public String subjectEmail{get;set;}
	public String bodyEmail{get;set;}
	public Boolean renderMessages{get;set;}
	
	public String attachmentName{get;set;}
	public Boolean hasNoErrors{get;set;}
	
	private String defaultFromEmail;
	private String defaultToEmail;
	private String defaultCcEmail;
	private String defaultBccEmail;
	private String defaultSubjectEmail;
	private String defaultBodyEmail;
	
	private AP_Account_Planning_gne__c currentAP;
	
	public GNE_AP_Email_Util(){    
		renderMessages = false;
		hasNoErrors = false;
		Id accountPlanId = ApexPages.currentPage().getParameters().get('planId');
		Id csUserId = ApexPages.currentPage().getParameters().get('csUserId');
		if(accountPlanId != null){ 
			currentAP = GNE_AP_DAO.getAccountPlan(accountPlanId);
		}
		fromEmail = [SELECT Email from User WHERE id = :Userinfo.getUserId()].Email;
		toEmail = '';
		ccEmail = '';
		subjectEmail = '';
		
		attachmentName = 'Current_Account_Plannings';
		attachmentName = attachmentName.trim();
		attachmentName = attachmentName +'.pdf';
		if(currentAP != null){
			List <User> toEmails = [SELECT Email FROM User WHERE id = :currentAP.CS_User_gne__c LIMIT 1];
			List <User> ccEmails = [SELECT Email FROM User WHERE id = :currentAP.DM_User_gne__c LIMIT 1];
			if(toEmails.size()>0){
				toEmail = toEmails.get(0).Email + ';';
			}
			if(ccEmails.size()>0){
				ccEmail = ccEmails.get(0).Email + ';';
			}
			subjectEmail = currentAP.Name;
			attachmentName = currentAP.Name;
			attachmentName = attachmentName.trim();
			attachmentName = attachmentName +'.pdf';
		}
		defaultFromEmail = fromEmail;
		defaultToEmail = toEmail;
		defaultCcEmail = ccEmail;
		defaultBccEmail = bccEmail;
		defaultSubjectEmail = subjectEmail;
		defaultBodyEmail = bodyEmail;
	}
	
	public void resetEmailFormToDefaultValues(){
		renderMessages = false;
		hasNoErrors = false;
		fromEmail = defaultFromEmail;
		toEmail = defaultToEmail;
		ccEmail = defaultCcEmail;
		bccEmail = defaultBccEmail;
		subjectEmail = defaultSubjectEmail;
		bodyEmail = defaultBodyEmail;
	}
	
	public PageReference sendEmailFromForm(){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		Id accountPlanId = ApexPages.currentPage().getParameters().get('planId');
		Id csUserId = ApexPages.currentPage().getParameters().get('csUserId');    
		String[] toAddresses;
		if(this.toEmail != ''){
			this.toEmail = this.toEmail.replaceAll('(\\s+)','');
			toAddresses = this.toEmail.split(';', 0);  
		}
		String[] ccAddresses;
		if(this.ccEmail != ''){
			this.ccEmail = this.ccEmail.replaceAll('(\\s+)','');
			ccAddresses = this.ccEmail.split(';', 0);  
		}
		String[] bccAddresses;
		if(this.bccEmail != ''){
			this.bccEmail = this.bccEmail.replaceAll('(\\s+)','');
			bccAddresses = this.bccEmail.split(';', 0);
		}else{
			mail.setBccSender(false);
		}
		
		mail.setToAddresses(toAddresses);
		mail.setCcAddresses(ccAddresses);
		mail.setSubject(this.subjectEmail);
		mail.setbccAddresses(bccAddresses);
		
		
		mail.setUseSignature(false);
		mail.setPlainTextBody(this.bodyEmail);
		PageReference pdf = Page.GNE_AP_Pdf_Report ;        
		Blob pdfPreview = null;
		//pdf = new PageReference('/apex/GNE_AP_Pdf_Report?planId=aEVV00000000035OAA&csUserId=csUserId');
		pdf.setRedirect(true);        
		pdf.getParameters().put('planId', accountPlanId);
		pdf.getParameters().put('csUserId',csUserId);
		

		pdfPreview = pdf.getContentAsPdf();
		
		Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
		efa.setFileName(attachmentName);
		efa.setInline(false);
		efa.setContentType('application/pdf');
		efa.Body = pdfPreview;
		
		mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
		
		try{
			Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			renderMessages = true;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Email pdf has been sent successfully'));
			hasNoErrors = true;
			return null;
		}catch(EmailException e){
			renderMessages = true;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'One or more email addresses are invalid, please recheck your form'));
			hasNoErrors = false;
			return null;
		}
		resetEmailFormToDefaultValues();
		return null;
	}
	
	public PageReference cancelSendingEmail(){
		resetEmailFormToDefaultValues();
		return null;
	}
}